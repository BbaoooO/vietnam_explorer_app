import 'package:android_project/core/app_nav.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../../core/models/destination.dart';
import '../../core/models/experience_booking.dart';
import '../../core/models/tourism_place.dart';
import '../../core/models/travel_records.dart';
import '../../core/providers/travel_data.dart';
import '../booking/experience_booking_screen.dart';
import '../../core/services/location_weather_service.dart';
//nạp lớp điều bộ appNav & thư viện giao diện Material

class HomeDiscoverScreen extends StatefulWidget
//Home kế thừa StatefulWidget vì màn hình có trạng thái thay đổi: từ khóa
//bộ lọc, ảnh hiện tại, yêu thích
    {
  const HomeDiscoverScreen({super.key});
  //constructor tạo màn hinhf, super.key truyền lên key lớp cha,
  //key hỗ trọ Flutter nhận diện Widget khi cập nhật cây giao diện, constructor const khong có nghĩa trạng thái màn hình không thay đổi
  @override
  State<HomeDiscoverScreen> createState() => _HomeDiscoverScreenState();//createState() tạo đối tượng giữ trạng thái cho Home
}
class _HomeDiscoverScreenState extends State<HomeDiscoverScreen> //lớp này chứa dữ liệu trạng thái, các hàm xử lý và hàm build()
    {
  String _currentCity = 'Đang xác định...';
  String _currentTemperature = '--°C';

  @override
  void initState() {
    super.initState();
    _loadRealWeather();
  }
  Future<void> _loadRealWeather() async {
    try {
      final data = await LocationWeatherService.load();

      if (!mounted) return;
      setState(() {
        _currentCity = (data['city'] ?? 'Vị trí hiện tại').toString();
        final temp = data['temperature'];
        _currentTemperature = temp == null ? '--°C' : '${temp}°C';
      });
      debugPrint('THANH PHO: ${data['city']}');
      debugPrint('NHIET DO: ${data['temperature']}°C');
      debugPrint('VI DO: ${data['latitude']}');
      debugPrint('KINH DO: ${data['longitude']}');
    } catch (e) {
      debugPrint('LOI GPS/THOI TIET: $e');
      if (mounted) {
        setState(() {
          _currentCity = 'Không lấy được vị trí';
          _currentTemperature = '--°C';
        });
      }
    }
  }
  // màu sắc, controller và biến trang thái
  static const Color _background = Color(0xFFF4F6F4);
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFF0F4C3A);
  static const Color _primaryDark = Color(0xFF073B2F);
  static const Color _text = Color(0xFF18201D);// _text chữ chính
  static const Color _muted = Color(0xFF69736E); //_muted chữ phụ
  static const Color _line = Color(0xFFE2E7E4);
  static const Color _gold = Color(0xFFE6A524); //_gold màu sao đánh giá
  static const Color _stamp = Color(0xFFB3362E); //_stamp màu đỏ của dấu và trái tim đã chọn

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> _toggleVoiceSearch() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() => _isListening = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Voice search: ${error.errorMsg}')),
            );
          }
        },
      );
      if (!mounted) return;
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể sử dụng micro. Hãy kiểm tra quyền micro.')),
        );
        return;
      }
      setState(() => _isListening = true);
      await _speech.listen(
        localeId: 'vi_VN',
        onResult: (result) {
          if (!mounted) return;
          final words = result.recognizedWords;
          _searchController.value = TextEditingValue(
            text: words,
            selection: TextSelection.collapsed(offset: words.length),
          );
          setState(() => _query = words);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không khởi động được tìm kiếm giọng nói: $e')),
      );
    }
  }

  final TextEditingController _searchController = TextEditingController();
  //quản lý nội dung ô nhập _searchController.clear() xóa chữ đang hiển thị
  final PageController _heroController = PageController(viewportFraction: 0.9);
  //điều khiển pageview mỗi trang chiếm 90% chiều rộng vùng xem, giúp lộ một phần ảnh kế tiếp
  //và gợi ý thao tác vuốt

  String _query = ''; //ban đầu chưa nhập từ khóa
  String _selectedRegion = 'All'; //chưa giới hạn khu vực
  int _heroIndex = 0; //ảnh đầu tiên có chỉ số bằng 0
  Set<String> get _favorites => context.read<TravelData>().favorites
      .where((target) => target.kind == CatalogKind.destination)
      .map((target) => target.id)
      .toSet();

  final List<String> _regions = const <String>['All', 'North', 'Central', 'South'];
  //danh sách nhãn dùng để tạo các nút lọc. Danh sách const khong the thêm,sua,xóa phần tử

  List<Destination> get _destinations => context.read<TravelData>().destinations;

  // Translate place names for display only. Keep original data and IDs unchanged.
  String _placeName(String name) {
    const names = <String, String>{
      'Ha Long Bay': 'Vịnh Hạ Long',
      'Halong Bay': 'Vịnh Hạ Long',
      'Ha Long': 'Hạ Long',
      'Halong': 'Hạ Long',
      'Hoi An': 'Hội An',
      'Hanoi': 'Hà Nội',
      'Ha Noi': 'Hà Nội',
      'Sapa': 'Sa Pa',
      'Sa Pa': 'Sa Pa',
      'Da Nang': 'Đà Nẵng',
      'Danang': 'Đà Nẵng',
      'Da Lat': 'Đà Lạt',
      'Dalat': 'Đà Lạt',
      'Hue': 'Huế',
      'Ninh Binh': 'Ninh Bình',
      'Trang An': 'Tràng An',
      'Nha Trang': 'Nha Trang',
      'Phu Quoc': 'Phú Quốc',
      'Ho Chi Minh City': 'Thành phố Hồ Chí Minh',
      'Ho Chi Minh': 'Hồ Chí Minh',
      'Mekong Delta': 'Đồng bằng sông Cửu Long',
      'Phong Nha': 'Phong Nha',
      'Quy Nhon': 'Quy Nhơn',
      'Mui Ne': 'Mũi Né',
      'Can Tho': 'Cần Thơ',
    };
    var result = name;
    for (final entry in names.entries) {
      result = result.replaceAllMapped(
        RegExp(RegExp.escape(entry.key), caseSensitive: false),
            (_) => entry.value,
      );
    }
    return result;
  }

  String _searchKey(String value) {
    const accents = <String, String>{
      'àáạảãâầấậẩẫăằắặẳẵ': 'a',
      'èéẹẻẽêềếệểễ': 'e',
      'ìíịỉĩ': 'i',
      'òóọỏõôồốộổỗơờớợởỡ': 'o',
      'ùúụủũưừứựửữ': 'u',
      'ỳýỵỷỹ': 'y',
      'đ': 'd',
    };
    var result = value.toLowerCase();
    for (final entry in accents.entries) {
      for (final char in entry.key.split('')) {
        result = result.replaceAll(char, entry.value);
      }
    }
    return result;
  }


  final List<_Experience> _experiences = const <_Experience>[
    _Experience(
      title: 'Hạ Long Cruise',
      subtitle: 'Wake up among limestone islands',
      duration: '2 days',
      image: 'assets/images/halong.jpg',
    ),
    //mỗi trải nghiệm có tên, mô tả, thời lượng và ảnh
    _Experience(
      title: BookableExperience.lanternNightWalkTitle,
      offer: BookableExperience.lanternNightWalk,
      subtitle: 'A calm evening in Hội An',
      duration: '3 hours',
      image: 'assets/images/hoian.jpg',
    ),
    _Experience(
      title: 'Hà Nội City Walk',
      subtitle: 'Food, history and hidden corners',
      duration: '4 hours',
      image: 'assets/images/hanoi.jpg',
    ),

  ];

  static const List<String> _featuredIds = <String>['halong', 'hoian', 'sapa'];

  List<Destination> get _featured =>
      //get__featured getter trả về danh sách địa điểm nổi bật
  _featuredIds.map((id) => _destinations.firstWhere((d) => d.id == id)).toList();
//_featuredIds.map duyệt tùng mã và biến mã thành một đối tượng địa điểm
  //firstWhere (....) tìm địa đầu tiên có d.id ==id
  //toList: chuyền kết quả thành list
  //nếu mã không tồn tại, fistWhere() sẽ báo lỗi vì chưa có orElse. Cần đảm bảo các mã nổi bật
  //hợp lệ hoặc bổ sung xử lý trường hợp thiếu
  List<Destination> get _filteredDestinations
  //getter tao danh sách phù hợp với lựa chọn hiện tại
  {
    final q = _searchKey(_query.trim());
    return _destinations.where((item)
    //duyệt địa điểm và chỉ giữ phần tử thỏa điều kiện
    {
      final regionMatch = _selectedRegion == 'All' || item.region == _selectedRegion;
      //địa điểm đạt điều kiện khu vực nếu: Chọn All hoặc khu vực địa điểm trùng khu vực đã chọn
      final queryMatch = q.isEmpty ||
          _searchKey(_placeName(item.title)).contains(q) ||
          _searchKey(item.title).contains(q) ||
          _searchKey(item.subtitle).contains(q) ||
          _searchKey(item.region).contains(q);
      //đạt điều kiện tìm kiếm nếu từ khóa rỗng hoặc xuất hiện trong ít nhất 1 trường: tên, mô tả ngắn, khu vực
      return regionMatch && queryMatch;//điều kiện phải thỏa cả 2 điều kiện
    }).toList();//chuyển kết quả lọc thành danh sách
  }
  //danh sách yêu thích
  List<Destination> get _savedDestinations =>
      _destinations.where((d) => _favorites.contains(d.id)).toList();
  // duyệt dữ liệu điểm đến, kiểm tra mã có trong _favorites không=> trả về địa điểm đã chọn
  //thứ tự kết quả theo _destinations, không theo tgian người dùng nhấn lưu
  @override
  void dispose() //dispose() được gọi khi đôí tượng State bị hủy
  {
    _speech.stop();
    _searchController.dispose();
    _heroController.dispose();
    //hai controller được giải phóng tài nguyên
    super.dispose(); //gọi xử lý của lớp cha
  }

  Future<void> _toggleFavorite(String id) => _toggleSaved(destinationRef(id));

  Future<void> _toggleSaved(CatalogRef target, {bool? saved}) async {
    try {
      final data = context.read<TravelData>();
      if (saved == null) {
        await data.toggleFavorite(target);
      } else {
        await data.setFavorite(target, saved);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update your saved places.')),
      );
    }
  }

  void _resetFilters() {
    setState(() {
      _query = ''; //xóa từ khóa dùng trong logic
      _selectedRegion = 'All'; //trả khu vực về All
      _searchController.clear(); //xóa chữ đang hiện trong ô nhập
    });
  }
  // Bảng chi tiết địa điểm
  void _openDestination(Destination item) //nhận đối tượng địa điểm người dùng chọn
  {
    final data = context.read<TravelData>();
    final navigation = context.read<AppNav>();
    final places = data.places.where((place) => place.destinationId == item.id).toList();
    showModalBottomSheet(
      context: context, //cho flutter biết vị trí cây widget để mở bảng
      useSafeArea: true, //tránh vùng hệ thống ở phía trên và hai bên bảng
      isScrollControlled: true, //cho phép bảng có chiều cao linh hoạt hơn, phù hợp với ndung cuộn
      showDragHandle: true, //hiển thị thanh kéo nhỏ phía trên
      backgroundColor: _surface,//nền bàng
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ), //bo 2 góc trên
      builder: (context) //hàm tạo nội dung trong bảng
      {
        return SafeArea //tiếp tục xử lý vùng an toàn, bỏ phần trên
          (
          top: false,
          child: SingleChildScrollView //cho phép cuộn nêú nội dung dài
            (
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), //khoảng đệm: trái 20, trên 4,phải 20, dưới 20
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              //xếp nội dung theo chiều dọc, chiếm chiều cao theo giới hạn bố cục
              //căn các phần tử về đầu trục ngang, thường là bên trái
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 210,
                    width: double.infinity,
                    child: _assetImage(item.image),
                  ), //tạo ảnh cao 210, rộng theo vùng có sẵn và cắt ảnh theo bo góc
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
                            _placeName(item.title),
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
                                  '${item.subtitle}, ${item.region}',//ghép mô tả ngắn với khu vực
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis, //giới hạn 1 dòng, nếu thiếu chỗ thì hiển tị dấu..
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
                  ], //tạo 3 ô thông tin bằng cùng một hàm, khác biểu tượng, nhãn và giá trị
                ),
                const SizedBox(height: 16),
                Text(
                  item.description, //hiển thị mô tả dài
                  style: const TextStyle(color: _text, fontSize: 14.5, height: 1.55),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () //nút open map
                        {
                          Navigator.popUntil(context, (route) => route.isFirst);//đóng các route phia trên đến route đầu tiên của Navigator đang được sd
                          navigation.openMap(destinationRef(item.id));
                          //popUntil có thể đóng cả danh sách và bảng chi tiết nếu 2 bảng đang mở chồng nhau.
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
                          navigation.openPlanner((title: item.title, target: destinationRef(item.id)));
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
                if (places.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Places in ${_placeName(item.title)}', style: Theme.of(context).textTheme.titleMedium),
                  for (final place in places)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(_placeName(place.name)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        navigation.openMap(placeRef(place.id));
                      },
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
//chi tiết trải nghiệm
  void _openExperience(_Experience item) //_openExperience() tạo bottom Sheet
  {
    final data = context.read<TravelData>();
    final navigator = Navigator.of(context);
    final navigation = context.read<AppNav>();
    final offer = item.offer;
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
                  _placeName(item.title),
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
                if (offer != null) ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      navigator.push(MaterialPageRoute<void>(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: data,
                          child: ExperienceBookingScreen(offer: offer),
                        ),
                      ));
                    },
                    icon: const Icon(Icons.confirmation_number_outlined),
                    label: const Text('Book tickets'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); //đóng bảng hiện tại
                    navigation.openPlanner((title: item.title, target: offer == null ? null : placeRef(offer.placeId)));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Add to Planner'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
//bảng view all và saved places
  void _showDestinationsSheet(String title, {bool savedOnly = false}) {
    final data = context.read<TravelData>();
    final navigation = context.read<AppNav>();
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _background,
      builder: (sheetContext) => ListenableBuilder(
        listenable: data,
        builder: (_, _) {
          final destinations = savedOnly ? _savedDestinations : data.destinations;
          final places = savedOnly
              ? data.places.where((place) => data.favorites.contains(placeRef(place.id))).toList()
              : const <TourismPlace>[];
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: .88,
            minChildSize: .55,
            maxChildSize: .96,
            builder: (_, scrollController) => CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                    child: Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
                  ),
                ),
                if (destinations.isEmpty && places.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('You have no saved places yet.')),
                  ),
                if (destinations.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: .72,
                      ),
                      itemCount: destinations.length,
                      itemBuilder: (_, index) => _destinationCard(destinations[index]),
                    ),
                  ),
                if (places.isNotEmpty)
                  SliverList.list(
                    children: [
                      for (final place in places)
                        ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(_placeName(place.name)),
                          subtitle: Text(place.province),
                          trailing: IconButton(
                            tooltip: 'Remove from saved places',
                            icon: const Icon(Icons.bookmark_remove_outlined),
                            onPressed: () => _toggleSaved(placeRef(place.id), saved: false),
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            navigation.openMap(placeRef(place.id));
                          },
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TravelData>();
    final destinations = _filteredDestinations;
    //mỗi lần build, lấy danh sách phù hợp với từ khóa và khu vực hiện tại

    return Scaffold(
      backgroundColor: _background, //tạo khung màn hình và đặt nền
      body: SafeArea( //bảo vệ khỏi vùng hệ thống, nhưng không chừa vùng an toàn phía dưới tại đây
        bottom: false,
        child: CustomScrollView //tạo màn hình cuộn dọc
          (
          physics: const BouncingScrollPhysics(), //hiệu ứng nhảy khi kéo vượt biên
          slivers: //các phần tử trong vùng cuộn
          [
            SliverToBoxAdapter(child: _buildHeader()),//đưa 1 widget thông thường vào CustomScrollView
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'Popular destinations',
                action: 'View all', //nhận danh sách gốc không phải danh sách đã lọc
                onAction: () => _showDestinationsSheet('All destinations'),
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

  // Header và thanh tìm kiếm
  Widget _buildHeader() {
    final saved = context.read<TravelData>().favorites;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row //header dùng row để xếp ngang
        (
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back', style: TextStyle(color: _muted, fontSize: 12)),
                SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: _primary, size: 17),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        _currentCity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
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
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_rounded, color: _gold, size: 17),
                SizedBox(width: 5),
                Text(
                  _currentTemperature,
                  style: const TextStyle(color: _text, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _showDestinationsSheet('Saved places', savedOnly: true),
            //nút yêu thích : Mở bảng với danh sách đã đánh dấu
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    saved.isEmpty
                        ? Icons.favorite_border_rounded
                        : Icons.favorite_rounded,
                    size: 18,
                    color: saved.isEmpty ? _primary : _stamp,
                  ),
                  if (saved.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${saved.length}',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSearch() { //thanh tìm kiếm
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: TextField //ô nhập dữ liệu
        (
        controller: _searchController, //controller liên kết nội dung nhập với controller
        textInputAction: TextInputAction.search,
        //gợi ý nút search trên bàn phím,không tự triển khai thuật toán tìm kiếm
        onChanged: (value) => setState(() => _query = value), // onChanged khi người dùng thay đổi nội dung
        //_query=value lưu từ khóa mới, setState() yêu câù xây dưng lại gdien
        decoration: InputDecoration(
          hintText: 'Where do you want to go?',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.5),
          prefixIcon: const Icon(Icons.search_rounded, color: _primary),
          suffixIcon: _query.isEmpty || _isListening
              ? IconButton(
            tooltip: _isListening ? 'Dừng nghe' : 'Tìm bằng giọng nói',
            onPressed: _toggleVoiceSearch,
            icon: Icon(
              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: _isListening ? Colors.red : _primary,
            ),
          )
              : IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _query = ''); //xóa nội dung hiển thị lẫn từ khóa logic
              //ô rỗng biểu tượng micro, có chữ: nút xóa
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
          enabledBorder: OutlineInputBorder( //enabledBorder là viền khi ô hoạt động nhưng chưa được focus
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder( //focusedBorder là viền khi đang chọn ô nhập
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _primary, width: 1.3),
          ),
        ),
      ),
    );
  }

  // Băng chuyền ảnh và dấu chỉ báo

  Widget _buildHero() {
    final items = _featured;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            height: 270,
            child: PageView.builder(
              controller: _heroController, //điểu khiển trang
              itemCount: items.length, //itemCount số trang
              onPageChanged: (i) => setState(() => _heroIndex = i),//cập nhật chỉ số khi chuyển trang
              itemBuilder: (context, index) => _heroCard(items[index]),
              //itemBuilder : dựng thẻ tương ứng
            ),
          ), //không có timer hay lệnh tự chuyển, nên băng chuyền hiện được chuyển bằng thao tác người dùng
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (i) //dấu chỉ báo
            {
              final active = i == _heroIndex; //tạo dấu cho mỗi trang; xác định dấu nào đang được chọn
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut, //easeOut giúp chuyển động chậm dần ở cuối
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

  //Thẻ banner và thẻ địa điểm
  Widget _heroCard(Destination item) {
    final saved = _favorites.contains(item.id);//kiểm tra để vẽ trái tim rỗng hoặc đầy
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector( //bắt đầu thao tác chạm lên thẻ
        onTap: () => _openDestination(item),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _assetImage(item.image),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient( //tạo lớp phú từ trong suốt sang tối ở phần dưới ảnh để chữ trắng dễ đọc
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
                            _placeName(item.title),
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

  // nút lọc khu vực
  Widget _buildRegionFilter() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
        scrollDirection: Axis.horizontal, //tạo danh sách các nút cuộn ngang
        itemCount: _regions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8), //tạo kcach giữa các nút.
        //tham số không sử dụng nên được đặt tên dạng gạch dưới
        itemBuilder: (context, index) {
          final region = _regions[index];
          final selected = region == _selectedRegion;
          //kiểm tra tên khu vực và kiểm tra khu vực đó có được chọn hay không
          return ChoiceChip(
            label: Text(region),//nhãn của nút
            selected: selected, //trạng thái chọn
            showCheckmark: false, //không hiện dấu tích
            selectedColor: _primary,
            backgroundColor: _surface,
            side: BorderSide(color: selected ? _primary : _line),
            shape: const StadiumBorder(), //tạo hình viên thuốc
            labelStyle: TextStyle(
              color: selected ? Colors.white : _text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) => setState(() => _selectedRegion = region),
            //lưu khu vực và cập nhật giao diện
          );
        },
      ),
    );
  }
//tiêu đề và danh sách cuộn ngang
  Widget _sectionHeader({required String title, String? action, VoidCallback? onAction})
  //title: bắt buộc,action: nhãn tùy chọn, vd View All, onAction hàm xử lý khi nhấn, VoidCallback: hàm kh nhận tham số kh trả về gia trị
  {
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
          if (action != null && onAction != null)//chỉ tạo nút khi có cả nhãn và hành động
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

  //Danh sách địa điểm
  Widget _destinationList(List<Destination> list) {
    return SizedBox(
      height: 262,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        scrollDirection: Axis.horizontal,
        //giới hạn chiều cao và vùng cuộn ngang
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

  Widget _destinationCard(Destination item) {
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
                    _placeName(item.title),
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
                            _placeName(item.title),
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

  // Banner passport

  Widget _passportBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => context.read<AppNav>().tab.value = AppNav.passport,
        //toàn bộ banner có thể nhấn để gửi yêu cầu chuyển sang passport
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

  Widget _emptyState()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Column(
        children: [
          const Icon(Icons.travel_explore_rounded, size: 42, color: Colors.grey),
          const SizedBox(height: 8),
          const Text(
            'No destinations match your search',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            //thông báo không có kết quả và cung cấp cách khôi phục danh sách
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: _resetFilters, child: const Text('Clear filters')),
        ],
      ),
    );
  }

  Widget _heartButton(bool saved, VoidCallback onTap, {double size = 38})
  //nhận trạng thái, hàm xử lý và kích thước tùy chọn
  {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, //cho phép vùng trong suốt trong phạm vi của bộ phận thao tác vẫn tham gia nhận chạm
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

class _Experience {
  final String title;
  final String subtitle;
  final String duration;
  final String image;
  final BookableExperience? offer;

  const _Experience({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.image,
    this.offer,
  });
}