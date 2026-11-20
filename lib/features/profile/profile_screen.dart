import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../core/app_nav.dart';
import '../../core/explorer_app_bar.dart';
import '../../core/models/travel_records.dart';
import '../../core/providers/travel_data.dart';
import '../booking/my_tickets_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryColor = Color(0xFF0F4C3A);
  static const Color secondaryColor = Color(0xFFF2B705);
  static const Color bgColor = Color(0xFFF7F8FA);

  // Dynamic user data states
  String _displayName = 'Master Explorer';
  String _avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500';

  // Settings states
  bool _enableNotifications = true;
  bool _enableDarkMode = false;
  String _selectedCurrency = 'VND (₫)';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      _displayName = user.displayName!;
    }
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      _avatarUrl = user.photoURL!;
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- 1. AVATAR PICKER SHEET ---
  void _showAvatarPickerSheet() {
    final List<String> presetAvatars = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Profile Picture',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Be Vietnam Pro',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: presetAvatars.map((url) {
                  return GestureDetector(
                    onTap: () async {
                      setState(() => _avatarUrl = url);
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await user.updatePhotoURL(url);
                      }
                      if (context.mounted) Navigator.pop(context);
                      _showMessage('Profile photo updated!');
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(url),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- 2. PERSONAL DETAILS SHEET ---
  void _showPersonalDetailsSheet() {
    final user = FirebaseAuth.instance.currentUser;
    final nameController = TextEditingController(text: _displayName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Personal Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: 'Be Vietnam Pro',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: const Icon(Icons.person_outline, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  user?.email ?? 'N/A',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Account User ID',
                  prefixIcon: const Icon(Icons.fingerprint, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  user?.uid ?? 'Unknown',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      setState(() => _displayName = newName);
                      if (user != null) {
                        await user.updateDisplayName(newName);
                      }
                      if (context.mounted) Navigator.pop(context);
                      _showMessage('Personal details saved successfully!');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 3. SAVED DESTINATIONS SHEET ---
  void _showSavedDestinationsSheet() {
    final data = context.read<TravelData>();
    final navigation = context.read<AppNav>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => ListenableBuilder(
        listenable: data,
        builder: (_, _) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.65,
            child: Column(
              children: [
                Text('Saved (${data.favorites.length})', style: Theme.of(sheetContext).textTheme.titleLarge),
                if (data.canImportLegacyFavorites)
                  TextButton.icon(
                    onPressed: () => _importLegacyFavorites(sheetContext, data),
                    icon: const Icon(Icons.restore),
                    label: const Text('Import previously saved places'),
                  ),
                Expanded(
                  child: data.favorites.isEmpty
                      ? const Center(child: Text('You have no saved places yet.'))
                      : ListView(
                          children: [
                            for (final target in data.favorites)
                              ListTile(
                                leading: Icon(target.kind == CatalogKind.place
                                    ? Icons.place_outlined : Icons.map_outlined),
                                title: Text(data.title(target) ?? target.id),
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  navigation.openMap(target);
                                },
                                trailing: IconButton(
                                  tooltip: 'Remove from saved places',
                                  onPressed: () async {
                                    try {
                                      await data.setFavorite(target, false);
                                    } catch (_) {
                                      if (mounted) _showMessage('Could not remove the saved place.', isError: true);
                                    }
                                  },
                                  icon: const Icon(Icons.bookmark_remove_outlined),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _importLegacyFavorites(BuildContext context, TravelData data) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import saved places?'),
        content: const Text('The previous version stored places on this device. Import this list only if it belongs to you. Places will be added to your current account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Import')),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await data.importLegacyFavorites();
      if (mounted) _showMessage('Saved places imported.');
    } catch (_) {
      if (mounted) _showMessage('Could not import your saved places.', isError: true);
    }
  }

  // --- 4. SETTINGS SHEET ---
  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: 'Be Vietnam Pro',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive travel tips and trip updates'),
                    activeColor: secondaryColor,
                    value: _enableNotifications,
                    onChanged: (val) {
                      setModalState(() => _enableNotifications = val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch app theme color mode'),
                    activeColor: secondaryColor,
                    value: _enableDarkMode,
                    onChanged: (val) {
                      setModalState(() => _enableDarkMode = val);
                      setState(() {});
                    },
                  ),
                  ListTile(
                    title: const Text('Currency'),
                    trailing: DropdownButton<String>(
                      value: _selectedCurrency,
                      underline: const SizedBox(),
                      items: ['VND (₫)', 'USD (\$)'].map((curr) {
                        return DropdownMenuItem(value: curr, child: Text(curr));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _selectedCurrency = val);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- 5. HELP & SUPPORT SHEET ---
  void _showHelpSupportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: 'Be Vietnam Pro',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ExpansionTile(
                        title: Text('How do I add a new travel plan?'),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Create a trip in Trip Planner, then select Add activity.',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: Text('How to collect passport stamps?'),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Open a place on the map and select Mark as visited to add a passport stamp.',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: Text('Can I use Vietnam Explorer offline?'),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Your itinerary and saved places are available on this device. Maps and online photos may need an internet connection.',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showMessage('Support email sent to support@vietnamexplorer.com');
                  },
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Contact Support Team'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 6. LOGOUT DIALOG ---
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const ExplorerAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildActionMenu(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final displayEmail = user?.email ?? 'Explorer';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: secondaryColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 54,
                  backgroundImage: NetworkImage(_avatarUrl),
                ),
              ),
              GestureDetector(
                onTap: _showAvatarPickerSheet,
                child: Container(
                  margin: const EdgeInsets.only(right: 4, bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 16, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayEmail,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontFamily: 'Be Vietnam Pro',
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _displayName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final data = context.watch<TravelData>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.map,
              value: '${data.visitedAreas.length}',
              label: 'Areas',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.verified,
              value: '${data.visits.length}',
              label: 'Passport stamps',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      {required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: secondaryColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _openMyTickets() {
    final data = context.read<TravelData>();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider.value(
        value: data,
        child: const MyTicketsScreen(),
      ),
    ));
  }

  Widget _buildActionMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMenuItem(context, Icons.person_outline, 'Personal Details',
                true, onTap: _showPersonalDetailsSheet),
            _buildMenuItem(context, Icons.favorite_border,
                'Saved Destinations', true, onTap: _showSavedDestinationsSheet),
            _buildMenuItem(context, Icons.confirmation_number_outlined, 'My Tickets',
                true, onTap: _openMyTickets),
            _buildMenuItem(context, Icons.settings_outlined, 'Settings', true,
                onTap: _showSettingsSheet),
            _buildMenuItem(context, Icons.help_outline, 'Help & Support', true,
                onTap: _showHelpSupportSheet),
            _buildMenuItem(context, Icons.logout, 'Log Out', false,
                isDestructive: true, onTap: _handleLogout),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, bool hasDivider,
      {bool isDestructive = false, required VoidCallback onTap}) {
    final color = isDestructive ? Colors.red.shade400 : primaryColor;

    return Column(
      children: [
        ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.1)
                  : primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDestructive ? Colors.red.shade400 : Colors.black87,
            ),
          ),
          trailing: isDestructive
              ? null
              : const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        if (hasDivider)
          Divider(
              height: 1,
              indent: 64,
              endIndent: 20,
              color: Colors.grey.shade100),
      ],
    );
  }
}
