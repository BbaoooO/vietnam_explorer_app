import 'package:android_project/core/app_nav.dart';
import 'package:flutter/material.dart';

class HomeDiscoverScreen extends StatefulWidget {
  const HomeDiscoverScreen({super.key});

  @override
  State<HomeDiscoverScreen> createState() => _HomeDiscoverScreenState();
}

class _HomeDiscoverScreenState extends State<HomeDiscoverScreen> {
  // Palette: ngọc bích + đỏ con dấu hộ chiếu + nền giấy xám nhạt
  static const Color _background = Color(0xFFF4F6F4);
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFF0F4C3A);
  static const Color _primaryDark = Color(0xFF073B2F);
  static const Color _soft = Color(0xFFE3EEE9);
  static const Color _text = Color(0xFF18201D);
  static const Color _muted = Color(0xFF69736E);
  static const Color _line = Color(0xFFE2E7E4);
  static const Color _gold = Color(0xFFE6A524);
  static const Color _stamp = Color(0xFFB3362E);

  final TextEditingController _searchController = TextEditingController();
  final PageController _heroController = PageController(viewportFraction: 0.9);

  String _query = '';
  String _selectedRegion = 'All';
  int _heroIndex = 0;
  final Set<String> _favorites = <String>{};

  final List<String> _regions = const <String>['All', 'North', 'Central', 'South', 'Mekong'];

  final List<_Destination> _destinations = const <_Destination>[
    _Destination(
      id: 'hanoi',
      title: 'Hanoi',
      subtitle: 'Culture & old streets',
      region: 'North',
      image: 'assets/images/hanoi.jpg',
      rating: 4.9,
      description:
      'Walk around Hoan Kiem Lake, eat bun cha in the Old Quarter and watch the city wake up over a cup of egg coffee.',
      bestTime: 'Sep - Nov',
      duration: '3 days',
      budget: '800k/day',
    ),
    _Destination(
      id: 'sapa',
      title: 'Sapa',
      subtitle: 'Mountains & terraces',
      region: 'North',
      image: 'assets/images/sapa.jpg',
      rating: 4.8,
      description:
      'Trek between rice terraces, sleep in a village homestay and wake up above the clouds.',
      bestTime: 'Mar - May',
      duration: '3 days',
      budget: '700k/day',
    ),
    _Destination(
      id: 'halong',
      title: 'Ha Long Bay',
      subtitle: 'Cruise & limestone islands',
      region: 'North',
      image: 'assets/images/halong.jpg',
      rating: 4.9,
      description:
      'Thousands of limestone islands rise out of emerald water. Kayak through caves and spend a night on a cruise.',
      bestTime: 'Oct - Apr',
      duration: '2 days',
      budget: '1.5M/day',
    ),
    _Destination(
      id: 'danang',
      title: 'Da Nang',
      subtitle: 'Beach & city',
      region: 'Central',
      image: 'assets/images/danang.jpg',
      rating: 4.8,
      description:
      'A clean beach city with the Dragon Bridge, Marble Mountains and the Ba Na Hills a short ride away.',
      bestTime: 'Feb - May',
      duration: '3 days',
      budget: '900k/day',
    ),
    _Destination(
      id: 'hoian',
      title: 'Hoi An',
      subtitle: 'Lanterns & heritage',
      region: 'Central',
      image: 'assets/images/hoian.jpg',
      rating: 4.9,
      description:
      'A lantern-lit ancient town. Get a tailored outfit, cycle through paddy fields and float a candle on the river.',
      bestTime: 'Feb - Apr',
      duration: '2 days',
      budget: '850k/day',
    ),
    _Destination(
      id: 'nhatrang',
      title: 'Nha Trang',
      subtitle: 'Sea & island escape',
      region: 'South',
      image: 'assets/images/nhatrang.jpg',
      rating: 4.7,
      description:
      'Island hopping, snorkeling and mud baths along a long curved bay.',
      bestTime: 'Jan - Aug',
      duration: '3 days',
      budget: '1M/day',
    ),
    _Destination(
      id: 'phuquoc',
      title: 'Phu Quoc',
      subtitle: 'Tropical island',
      region: 'South',
      image: 'assets/images/phuquoc.jpg',
      rating: 4.8,
      description:
      'White sand, clear water and night markets. The easiest place in Vietnam to do nothing well.',
      bestTime: 'Nov - Apr',
      duration: '4 days',
      budget: '1.4M/day',
    ),
    _Destination(
      id: 'cantho',
      title: 'Can Tho',
      subtitle: 'River & floating market',
      region: 'Mekong',
      image: 'assets/images/cantho.jpg',
      rating: 4.7,
      description:
      'Board a boat at dawn for the Cai Rang floating market, then eat fruit straight from the orchard.',
      bestTime: 'Aug - Dec',
      duration: '2 days',
      budget: '600k/day',
    ),
    _Destination(
      id: 'bentre',
      title: 'Ben Tre',
      subtitle: 'Coconut groves & canals',
      region: 'Mekong',
      image: 'assets/images/bentre.jpg',
      rating: 4.7,
      description:
      'The coconut capital of Vietnam. Paddle a small boat through narrow canals, watch candy being made from coconut and stay in a riverside homestay.',
      bestTime: 'Dec - Apr',
      duration: '2 days',
      budget: '600k/day',
    ),
    _Destination(
      id: 'chaudoc',
      title: 'Chau Doc',
      subtitle: 'Floating villages & Sam Mountain',
      region: 'Mekong',
      image: 'assets/images/chaudoc.jpg',
      rating: 4.7,
      description:
      'A border town on the Bassac River. Visit the floating fish farms, the Cham village and climb Sam Mountain for a view over the paddy fields.',
      bestTime: 'Sep - Nov',
      duration: '2 days',
      budget: '600k/day',
    ),
    _Destination(
      id: 'camau',
      title: 'Ca Mau',
      subtitle: 'Mangroves & the southern tip',
      region: 'Mekong',
      image: 'assets/images/camau.jpg',
      rating: 4.6,
      description:
      'Take a boat through the U Minh mangrove forest and travel to Mui Ca Mau, the southernmost point of mainland Vietnam.',
      bestTime: 'Dec - Apr',
      duration: '2 days',
      budget: '550k/day',
    ),
    _Destination(
      id: 'vinhlong',
      title: 'Vinh Long',
      subtitle: 'Orchards & village life',
      region: 'Mekong',
      image: 'assets/images/vinhlong.jpg',
      rating: 4.6,
      description:
      'Cycle between fruit orchards, visit old riverside houses and see how pottery and bricks are made in the traditional kilns.',
      bestTime: 'May - Aug',
      duration: '2 days',
      budget: '550k/day',
    ),
    _Destination(
      id: 'dongthap',
      title: 'Dong Thap',
      subtitle: 'Lotus fields & Sa Dec flowers',
      region: 'Mekong',
      image: 'assets/images/dongthap.jpg',
      rating: 4.7,
      description:
      'Famous for its pink lotus ponds, the Sa Dec flower village and Tram Chim National Park, where cranes visit in the dry season.',
      bestTime: 'Jun - Aug',
      duration: '2 days',
      budget: '550k/day',
    ),
    _Destination(
      id: 'dalat',
      title: 'Da Lat',
      subtitle: 'Pine hills & cool cafes',
      region: 'Central',
      image: 'assets/images/dalat.jpg',
      rating: 4.8,
      description:
      'A cool highland town of pine forests, flower farms and hillside cafes. Ride to the waterfalls or just wander the lake at dusk.',
      bestTime: 'Dec - Mar',
      duration: '3 days',
      budget: '750k/day',
    ),
    _Destination(
      id: 'hochiminh',
      title: 'Ho Chi Minh City',
      subtitle: 'Street food & city life',
      region: 'South',
      image: 'assets/images/hochiminh.jpg',
      rating: 4.7,
      description:
      'Vietnam\'s busiest city. Eat your way through Ben Thanh and District 1, visit the War Remnants Museum and finish on a rooftop bar.',
      bestTime: 'Dec - Apr',
      duration: '3 days',
      budget: '1M/day',
    ),
    _Destination(
      id: 'hue',
      title: 'Hue',
      subtitle: 'Imperial city & royal tombs',
      region: 'Central',
      image: 'assets/images/hue.jpg',
      rating: 4.8,
      description:
      'The old capital of the Nguyen emperors. Explore the Citadel, the royal tombs along the Perfume River and the local royal cuisine.',
      bestTime: 'Jan - Apr',
      duration: '2 days',
      budget: '700k/day',
    ),
    _Destination(
      id: 'ninhbinh',
      title: 'Ninh Binh',
      subtitle: 'Karst rivers & ancient capital',
      region: 'North',
      image: 'assets/images/ninhbinh.jpg',
      rating: 4.9,
      description:
      'Row a boat through Trang An caves, climb Hang Mua for the view and visit Hoa Lu, the capital of Vietnam a thousand years ago.',
      bestTime: 'Jan - May',
      duration: '2 days',
      budget: '650k/day',
    ),
    _Destination(
      id: 'hagiang',
      title: 'Ha Giang',
      subtitle: 'Mountain loop & Ma Pi Leng',
      region: 'North',
      image: 'assets/images/hagiang.jpg',
      rating: 4.9,
      description:
      'The far north loop: winding passes, stone villages and the Ma Pi Leng pass above the Nho Que river. Best done on a motorbike with a local guide.',
      bestTime: 'Sep - Nov',
      duration: '4 days',
      budget: '700k/day',
    ),
    _Destination(
      id: 'quynhon',
      title: 'Quy Nhon',
      subtitle: 'Quiet beaches & seafood',
      region: 'Central',
      image: 'assets/images/quynhon.jpg',
      rating: 4.7,
      description:
      'A calmer coastal city with clear beaches, Cham towers and very fresh seafood. Ky Co and Eo Gio are the places to go.',
      bestTime: 'Feb - Aug',
      duration: '3 days',
      budget: '750k/day',
    ),
    _Destination(
      id: 'muine',
      title: 'Mui Ne',
      subtitle: 'Red dunes & kitesurfing',
      region: 'South',
      image: 'assets/images/muine.jpg',
      rating: 4.6,
      description:
      'Watch sunrise on the white and red sand dunes, walk the Fairy Stream and try kitesurfing when the wind picks up.',
      bestTime: 'Dec - Apr',
      duration: '2 days',
      budget: '800k/day',
    ),
    _Destination(
      id: 'condao',
      title: 'Con Dao',
      subtitle: 'Island history & turtle beaches',
      region: 'South',
      image: 'assets/images/condao.jpg',
      rating: 4.8,
      description:
      'A quiet island group with historic prisons, empty beaches and good diving. Turtles nest here in the warmer months.',
      bestTime: 'Mar - Sep',
      duration: '3 days',
      budget: '1.3M/day',
    ),
    _Destination(
      id: 'laocai',
      title: 'Lao Cai',
      subtitle: 'Fansipan & Bac Ha market',
      region: 'North',
      image: 'assets/images/laocai.jpg',
      rating: 4.8,
      description:
      'Take the cable car up Fansipan, the highest peak in Indochina, then visit the colorful Bac Ha Sunday market and the terraced valleys of Y Ty.',
      bestTime: 'Sep - Nov',
      duration: '3 days',
      budget: '700k/day',
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

  static const List<String> _featuredIds = <String>['halong', 'hoian', 'sapa'];

  List<_Destination> get _featured =>
      _featuredIds.map((id) => _destinations.firstWhere((d) => d.id == id)).toList();

  List<_Destination> get _filteredDestinations {
    final q = _query.trim().toLowerCase();
    return _destinations.where((item) {
      final regionMatch = _selectedRegion == 'All' || item.region == _selectedRegion;
      final queryMatch = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          item.region.toLowerCase().contains(q);
      return regionMatch && queryMatch;
    }).toList();
  }

  List<_Destination> get _savedDestinations =>
      _destinations.where((d) => _favorites.contains(d.id)).toList();

  @override
  void dispose() {
    _searchController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (!_favorites.remove(id)) _favorites.add(id);
    });
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _selectedRegion = 'All';
      _searchController.clear();
    });
  }

  // ---------------------------------------------------------------- sheets

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
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 210,
                    width: double.infinity,
                    child: _assetImage(item.image),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: _text,
                              fontSize: 26,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 15, color: _muted),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  '${item.subtitle}, ${item.region}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: _muted, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ratingChip(item.rating),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _infoTile(Icons.wb_sunny_outlined, 'Best time', item.bestTime),
                    const SizedBox(width: 8),
                    _infoTile(Icons.schedule_rounded, 'Suggested', item.duration),
                    const SizedBox(width: 8),
                    _infoTile(Icons.payments_outlined, 'Budget', item.budget),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.description,
                  style: const TextStyle(color: _text, fontSize: 14.5, height: 1.55),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          AppNav.mapFocusId.value = item.id;
                          AppNav.tab.value = AppNav.map;
                        },
                        icon: const Icon(Icons.map_outlined, size: 19),
                        label: const Text('Open map'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          AppNav.plannerAddId.value = item.id;
                          AppNav.tab.value = AppNav.planner;
                        },
                        icon: const Icon(Icons.event_note_rounded, size: 19),
                        label: const Text('Plan trip'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primary,
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(color: _line),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
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

  void _openExperience(_Experience item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: _assetImage(item.image),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: const TextStyle(color: _muted, fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: _primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      item.duration,
                      style: const TextStyle(color: _text, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AppNav.tab.value = AppNav.planner;
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Add to planner'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDestinationsSheet(String title, List<_Destination> list) {
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? const Center(
                    child: Text(
                      'Nothing here yet.\nTap the heart on a destination to save it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, height: 1.5),
                    ),
                  )
                      : GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: list.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) => _destinationCard(list[index]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final destinations = _filteredDestinations;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'Popular destinations',
                action: 'View all',
                onAction: () => _showDestinationsSheet('All destinations', _destinations),
              ),
            ),
            SliverToBoxAdapter(child: _buildRegionFilter()),
            SliverToBoxAdapter(
              child: destinations.isEmpty ? _emptyState() : _destinationList(destinations),
            ),
            SliverToBoxAdapter(child: _sectionHeader(title: 'Things to do')),
            SliverToBoxAdapter(child: _experienceCarousel()),
            SliverToBoxAdapter(child: _passportBanner()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- header

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back', style: TextStyle(color: _muted, fontSize: 12)),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: _primary, size: 17),
                    SizedBox(width: 3),
                    Text(
                      'Hanoi, Vietnam',
                      style: TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _line),
            ),
            child: const Row(
              children: [
                Icon(Icons.wb_sunny_rounded, color: _gold, size: 17),
                SizedBox(width: 5),
                Text(
                  '28°C',
                  style: TextStyle(color: _text, fontSize: 12.5, fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Where do you want to go?',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.5),
          prefixIcon: const Icon(Icons.search_rounded, color: _primary),
          suffixIcon: _query.isEmpty
              ? const Icon(Icons.mic_none_rounded, color: _primary)
              : IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _query = '');
            },
            icon: const Icon(Icons.close_rounded),
          ),
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
            borderSide: const BorderSide(color: _primary, width: 1.3),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------- quick actions

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _quickAction(Icons.map_rounded, 'Map', () => AppNav.tab.value = AppNav.map),
          _quickAction(Icons.calendar_month_rounded, 'Planner', () => AppNav.tab.value = AppNav.planner),
          _quickAction(Icons.badge_rounded, 'Passport', () => AppNav.tab.value = AppNav.passport),
          _quickAction(
            _favorites.isEmpty ? Icons.favorite_border_rounded : Icons.favorite_rounded,
            _favorites.isEmpty ? 'Saved' : 'Saved (${_favorites.length})',
                () => _showDestinationsSheet('Saved places', _savedDestinations),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _soft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: _primary, size: 25),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ hero

  Widget _buildHero() {
    final items = _featured;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            height: 270,
            child: PageView.builder(
              controller: _heroController,
              itemCount: items.length,
              onPageChanged: (i) => setState(() => _heroIndex = i),
              itemBuilder: (context, index) => _heroCard(items[index]),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (i) {
              final active = i == _heroIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? _primary : const Color(0xFFCBD4CF),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(_Destination item) {
    final saved = _favorites.contains(item.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => _openDestination(item),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _assetImage(item.image),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x1A07130F), Color(0x0007130F), Color(0xE607130F)],
                    stops: [0, 0.4, 1],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: _gold, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: _text,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _heartButton(saved, () => _toggleFavorite(item.id)),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_outward_rounded, color: _primary, size: 22),
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

  // --------------------------------------------------------------- regions

  Widget _buildRegionFilter() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
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
            side: BorderSide(color: selected ? _primary : _line),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              color: selected ? Colors.white : _text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) => setState(() => _selectedRegion = region),
          );
        },
      ),
    );
  }

  Widget _sectionHeader({required String title, String? action, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _text,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          if (action != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                action,
                style: const TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------ destination list

  Widget _destinationList(List<_Destination> list) {
    return SizedBox(
      height: 262,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => SizedBox(
          width: 176,
          child: _destinationCard(list[index]),
        ),
      ),
    );
  }

  Widget _destinationCard(_Destination item) {
    final saved = _favorites.contains(item.id);

    return GestureDetector(
      onTap: () => _openDestination(item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _assetImage(item.image),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x0007130F), Color(0xEB07130F)],
                  stops: [0.42, 1],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _heartButton(saved, () => _toggleFavorite(item.id), size: 32),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11.5),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: _gold, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.budget,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------- experiences

  Widget _experienceCarousel() {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _experiences.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _experiences[index];

          return GestureDetector(
            onTap: () => _openExperience(item),
            child: SizedBox(
              width: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _assetImage(item.image),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x0007130F), Color(0xE007130F)],
                          stops: [0.3, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded, size: 13, color: _primary),
                            const SizedBox(width: 4),
                            Text(
                              item.duration,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 13,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 12,
                            ),
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

  // ------------------------------------------------------ passport banner

  Widget _passportBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => AppNav.tab.value = AppNav.passport,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          decoration: BoxDecoration(
            color: _primaryDark,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Collect a stamp\nfor every place you visit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your passport fills up as you explore.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.5),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Open passport',
                        style: TextStyle(
                          color: _primaryDark,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Transform.rotate(angle: -0.22, child: _stampMark()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stampMark() {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _stamp, width: 3),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _stamp.withValues(alpha: 0.7), width: 1.4),
        ),
        child: const Icon(Icons.temple_buddhist_rounded, color: _stamp, size: 34),
      ),
    );
  }

  // -------------------------------------------------------------- helpers

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Column(
        children: [
          const Icon(Icons.travel_explore_rounded, size: 42, color: Colors.grey),
          const SizedBox(height: 8),
          const Text(
            'No destinations match your search',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: _resetFilters, child: const Text('Clear filters')),
        ],
      ),
    );
  }

  Widget _heartButton(bool saved, VoidCallback onTap, {double size = 38}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
          ),
          child: Icon(
            saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: size * 0.52,
            color: saved ? _stamp : _primary,
          ),
        ),
      ),
    );
  }

  Widget _ratingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: _gold, size: 16),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: _primary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
            const SizedBox(height: 1),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFFE3EBE7),
          alignment: Alignment.center,
          child: const Icon(Icons.landscape_rounded, color: _primary, size: 38),
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
  final String description;
  final String bestTime;
  final String duration;
  final String budget;

  const _Destination({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.region,
    required this.image,
    required this.rating,
    required this.description,
    required this.bestTime,
    required this.duration,
    required this.budget,
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