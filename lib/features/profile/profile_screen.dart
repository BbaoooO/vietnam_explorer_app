import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/explorer_app_bar.dart';

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
  String _selectedLanguage = 'English';

// Sample saved destinations
  final List _savedDestinations = [
  {
  'title': 'Ha Long Bay',
  'location': 'Quang Ninh, Vietnam',
  'image':
  'https://images.unsplash.com/photo-1528127269322-539801943592?w=500',
  },
  {
  'title': 'Hoi An Ancient Town',
  'location': 'Quang Nam, Vietnam',
  'image':
  'https://images.unsplash.com/photo-1555921015-5532091f6026?w=500',
  },
  {
  'title': 'Trang An Landscape',
  'location': 'Ninh Binh, Vietnam',
  'image':
  'https://images.unsplash.com/photo-1509099836639-18ba1795216d?w=500',
  },
  ];

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saved Destinations (${_savedDestinations.length})',
                        style: const TextStyle(
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
                  _savedDestinations.isEmpty
                      ? const Expanded(
                    child: Center(
                      child: Text(
                        'No saved destinations yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                      : Expanded(
                    child: ListView.builder(
                      itemCount: _savedDestinations.length,
                      itemBuilder: (context, index) {
                        final item = _savedDestinations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item['image']!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              item['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            subtitle: Text(item['location']!),
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite,
                                  color: Colors.redAccent),
                              onPressed: () {
                                setModalState(() {
                                  _savedDestinations.removeAt(index);
                                });
                                setState(() {});
                                _showMessage('Removed from saved list.');
                              },
                            ),
                          ),
                        );
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
                  ListTile(
                    title: const Text('Language'),
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      underline: const SizedBox(),
                      items: ['English', 'Tiếng Việt'].map((lang) {
                        return DropdownMenuItem(value: lang, child: Text(lang));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _selectedLanguage = val);
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
                              'Go to the Trip Planner tab and click the "+ Add Plan" button at the bottom right.',
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
                              'Stamps are automatically unlocked when you visit destinations on the Interactive Map.',
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
                              'Yes! Your planned itineraries are saved locally so you can view them anytime without internet.',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.map,
              value: '12',
              label: 'Provinces',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.verified,
              value: '45',
              label: 'Stamps',
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