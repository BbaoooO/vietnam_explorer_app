import 'package:flutter/material.dart';

class HomeDiscoverScreen extends StatefulWidget {
  const HomeDiscoverScreen({super.key});

  @override
  State<HomeDiscoverScreen> createState() => _HomeDiscoverScreenState();
}

class _HomeDiscoverScreenState extends State<HomeDiscoverScreen> {
  static const Color _background = Color(0xFFF7F8F6);
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFF0F4C3A);
  static const Color _primaryDark = Color(0xFF073B2F);
  static const Color _text = Color(0xFF18201D);
  static const Color _muted = Color(0xFF6B746F);
  static const Color _line = Color(0xFFE6EAE8);
  static const Color _gold = Color(0xFFE6A524);

  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _selectedRegion = 'All';
  final Set<String> _favorites = <String>{};

  final List<String> _regions = const <String>[
    'All',
    'North',
    'Central',
    'South',
    'Mekong',
  ];

  final List<_Destination> _destinations = const <_Destination>[
    _Destination(
      id: 'hanoi',
      title: 'Hanoi',
      subtitle: 'Culture & old streets',
      region: 'North',
      image: 'assets/images/hanoi.jpg',
      rating: 4.9,
    ),
    _Destination(
      id: 'sapa',
      title: 'Sapa',
      subtitle: 'Mountains & terraces',
      region: 'North',
      image: 'assets/images/sapa.jpg',
      rating: 4.8,
    ),
    _Destination(
      id: 'halong',
      title: 'Ha Long Bay',
      subtitle: 'Cruise & limestone islands',
      region: 'North',
      image: 'assets/images/halong.jpg',
      rating: 4.9,
    ),
    _Destination(
      id: 'danang',
      title: 'Da Nang',
      subtitle: 'Beach & city',
      region: 'Central',
      image: 'assets/images/danang.jpg',
      rating: 4.8,
    ),
    _Destination(
      id: 'hoian',
      title: 'Hoi An',
      subtitle: 'Lanterns & heritage',
      region: 'Central',
      image: 'assets/images/hoian.jpg',
      rating: 4.9,
    ),
    _Destination(
      id: 'nhatrang',
      title: 'Nha Trang',
      subtitle: 'Sea & island escape',
      region: 'South',
      image: 'assets/images/nhatrang.jpg',
      rating: 4.7,
    ),
    _Destination(
      id: 'phuquoc',
      title: 'Phu Quoc',
      subtitle: 'Tropical island',
      region: 'South',
      image: 'assets/images/phuquoc.jpg',
      rating: 4.8,
    ),
    _Destination(
      id: 'cantho',
      title: 'Can Tho',
      subtitle: 'River & floating market',
      region: 'Mekong',
      image: 'assets/images/cantho.jpg',
      rating: 4.7,
    ),
  ];

  final List<_Experience> _experiences = const <_Experience>[
    _Experience(
      title: 'Ha Long Cruise',
      subtitle: 'Wake up among limestone islands',
      duration: '2 days',
      image: 'assets/images/halong.jpg',
    ),
    _Experience(
      title: 'Lantern Night Walk',
      subtitle: 'A calm evening in Hoi An',
      duration: '3 hours',
      image: 'assets/images/hoian.jpg',
    ),
    _Experience(
      title: 'Hanoi City Walk',
      subtitle: 'Food, history and hidden corners',
      duration: '4 hours',
      image: 'assets/images/hanoi.jpg',
    ),
  ];

  List<_Destination> get _filteredDestinations {
    final q = _query.trim().toLowerCase();

    return _destinations.where((item) {
      final regionMatch =
          _selectedRegion == 'All' || item.region == _selectedRegion;

      final queryMatch = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          item.region.toLowerCase().contains(q);

      return regionMatch && queryMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _selectedRegion = 'All';
      _searchController.clear();
    });
  }

  void _openDestination(_Destination item) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: _assetImage(
                  item.image,
                  height: 220,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 24,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ratingChip(item.rating),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.map_outlined, size: 19),
                      label: const Text('Open map'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.event_note_rounded, size: 19),
                      label: const Text('Plan trip'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: _line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openExperience(_Experience item) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: _assetImage(
                    item.image,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: _primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.duration,
                      style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAllDestinations() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.55,
          maxChildSize: 0.96,
          builder: (context, scrollController) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 2, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'All Destinations',
                          style: TextStyle(
                            color: _text,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: _destinations.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.90,
                    ),
                    itemBuilder: (context, index) {
                      return _destinationCard(_destinations[index]);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredDestinations;
    final visibleDestinations = filtered.take(4).toList();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildRegionFilter()),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'Popular Destinations',
                action: 'View all',
                onAction: _showAllDestinations,
              ),
            ),
            if (visibleDestinations.isEmpty)
              SliverToBoxAdapter(child: _emptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                        _destinationCard(visibleDestinations[index]),
                    childCount: visibleDestinations.length,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.93,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'Must-Try Experiences',
              ),
            ),
            SliverToBoxAdapter(child: _experienceCarousel()),
            SliverToBoxAdapter(child: _travelNote()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: _primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current location',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hanoi, Vietnam',
                  style: TextStyle(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _line),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.wb_sunny_rounded,
                  color: _gold,
                  size: 17,
                ),
                SizedBox(width: 5),
                Text(
                  '28°C',
                  style: TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Where do you want to go?',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _primary,
          ),
          suffixIcon: _query.isEmpty
              ? const Icon(
            Icons.mic_none_rounded,
            color: _primary,
          )
              : IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _query = '');
            },
            icon: const Icon(Icons.close_rounded),
          ),
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: _primary,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionFilter() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        scrollDirection: Axis.horizontal,
        itemCount: _regions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final region = _regions[index];
          final selected = region == _selectedRegion;

          return ChoiceChip(
            label: Text(region),
            selected: selected,
            showCheckmark: false,
            selectedColor: _primary,
            backgroundColor: _surface,
            side: BorderSide(
              color: selected ? _primary : _line,
            ),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              color: selected ? Colors.white : _text,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            onSelected: (_) {
              setState(() => _selectedRegion = region);
            },
          );
        },
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => _openDestination(
          _destinations.firstWhere((item) => item.id == 'halong'),
        ),
        child: SizedBox(
          height: 230,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _assetImage(
                  'assets/images/halong.jpg',
                  height: 230,
                  width: double.infinity,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xDA07130F),
                        Color(0x6307130F),
                        Color(0x0007130F),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 17,
                  left: 17,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: _primaryDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 18,
                  right: 100,
                  bottom: 58,
                  child: Text(
                    'Ha Long Bay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Positioned(
                  left: 18,
                  right: 80,
                  bottom: 26,
                  child: Text(
                    'A natural wonder of Vietnam',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    String? action,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _text,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (action != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                action,
                style: const TextStyle(
                  color: _primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _destinationCard(_Destination item) {
    final favorite = _favorites.contains(item.id);

    return InkWell(
      onTap: () => _openDestination(item),
      borderRadius: BorderRadius.circular(19),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _assetImage(
                      item.image,
                      height: 130,
                      width: double.infinity,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleFavorite(item.id),
                        child: Container(
                          width: 31,
                          height: 31,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            favorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: favorite
                                ? const Color(0xFFB94D5A)
                                : _primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: _gold,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: _text,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _experienceCarousel() {
    return SizedBox(
      height: 194,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _experiences.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _experiences[index];

          return InkWell(
            onTap: () => _openExperience(item),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 190,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _line),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _assetImage(
                      item.image,
                      height: 108,
                      width: 190,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _text,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: _primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.duration,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _travelNote() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1ED),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel deeper',
                    style: TextStyle(
                      color: _primaryDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Discover Vietnam at your own pace.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: _primary,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Column(
        children: [
          const Icon(
            Icons.travel_explore_rounded,
            size: 42,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          const Text(
            'No destinations found',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset filters'),
          ),
        ],
      ),
    );
  }

  Widget _ratingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: _gold,
            size: 16,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: _text,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetImage(
      String path, {
        required double height,
        required double width,
      }) {
    return Image.asset(
      path,
      height: height,
      width: width,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) {
        return Container(
          height: height,
          width: width,
          color: const Color(0xFFE9EFEC),
          alignment: Alignment.center,
          child: const Icon(
            Icons.landscape_rounded,
            color: _primary,
            size: 38,
          ),
        );
      },
    );
  }
}

class _Destination {
  final String id;
  final String title;
  final String subtitle;
  final String region;
  final String image;
  final double rating;

  const _Destination({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.region,
    required this.image,
    required this.rating,
  });
}

class _Experience {
  final String title;
  final String subtitle;
  final String duration;
  final String image;

  const _Experience({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.image,
  });
}
