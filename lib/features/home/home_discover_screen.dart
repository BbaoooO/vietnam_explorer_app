import 'package:android_project/core/app_nav.dart';
import 'package:flutter/material.dart';
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

  final TextEditingController _searchController = TextEditingController();
  //quản lý nội dung ô nhập _searchController.clear() xóa chữ đang hiển thị
  final PageController _heroController = PageController(viewportFraction: 0.9);
  //điều khiển pageview mỗi trang chiếm 90% chiều rộng vùng xem, giúp lộ một phần ảnh kế tiếp
  //và gợi ý thao tác vuốt

  String _query = ''; //ban đầu chưa nhập từ khóa
  String _selectedRegion = 'All'; //chưa giới hạn khu vực
  int _heroIndex = 0; //ảnh đầu tiên có chỉ số bằng 0
  final Set<String> _favorites = <String>{};
  //tạo tập hợp mã địa điểm yêu thích rỗng
  //final vẫn thêm xóa sửa được , final ngăn gán _favorites sang tập hợp khác, nhưng không ngăn thay đổi của tập hợp hiện tại
  final List<String> _regions = const <String>['All', 'North', 'Central', 'South'];
  //danh sách nhãn dùng để tạo các nút lọc. Danh sách const khong the thêm,sua,xóa phần tử

  final List<_Destination> _destinations = const <_Destination>
  //khai báo dữ liệu địa điểm và trải nghiệm
  [
    // ======================= NORTH =======================
    _Destination(
      id: 'hanoi',
      title: 'Hanoi',
      subtitle: 'Culture & old streets', //đặc điểm nổi bật trình bày ngắn
      region: 'North', //khu vực dùng để lọc
      image: 'assets/images/hanoi.jpg',
      rating: 4.9,
      description:
      'Walk around Hoan Kiem Lake, eat bun cha in the Old Quarter and watch the city wake up over a cup of egg coffee.',
      bestTime: 'Sep - Nov',
      duration: '3 days', //thời lượng chuyến đi gợi ý
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

    // ======================= CENTRAL =======================
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
      id: 'nhatrang',
      title: 'Nha Trang',
      subtitle: 'Sea & island escape',
      region: 'Central', // trước đây: South
      image: 'assets/images/nhatrang.jpg',
      rating: 4.7,
      description:
      'Island hopping, snorkeling and mud baths along a long curved bay.',
      bestTime: 'Jan - Aug',
      duration: '3 days',
      budget: '1M/day',
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
      id: 'muine',
      title: 'Mui Ne',
      subtitle: 'Red dunes & kitesurfing',
      region: 'Central', // trước đây: South
      image: 'assets/images/muine.jpg',
      rating: 4.6,
      description:
      'Watch sunrise on the white and red sand dunes, walk the Fairy Stream and try kitesurfing when the wind picks up.',
      bestTime: 'Dec - Apr',
      duration: '2 days',
      budget: '800k/day',
    ),

    // ======================= SOUTH =======================
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
      region: 'South', // trước đây: Mekong
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
      region: 'South', // trước đây: Mekong
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
      region: 'South', // trước đây: Mekong
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
      region: 'South', // trước đây: Mekong
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
      region: 'South', // trước đây: Mekong
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
      region: 'South', // trước đây: Mekong
      image: 'assets/images/dongthap.jpg',
      rating: 4.7,
      description:
      'Famous for its pink lotus ponds, the Sa Dec flower village and Tram Chim National Park, where cranes visit in the dry season.',
      bestTime: 'Jun - Aug',
      duration: '2 days',
      budget: '550k/day',
      //budget hiện chỉ là chuỗi, nên không trực tiếp cộng với ngân sách khác
    ),
  ];


  final List<_Experience> _experiences = const <_Experience>[
    _Experience(
      title: 'Ha Long Cruise',
      subtitle: 'Wake up among limestone islands',
      duration: '2 days',
      image: 'assets/images/halong.jpg',
    ),
    //mỗi trải nghiệm có tên, mô tả, thời lượng và ảnh
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
  //get__featured getter trả về danh sách địa điểm nổi bật
      _featuredIds.map((id) => _destinations.firstWhere((d) => d.id == id)).toList();
//_featuredIds.map duyệt tùng mã và biến mã thành một đối tượng địa điểm
  //firstWhere (....) tìm địa đầu tiên có d.id ==id
  //toList: chuyền kết quả thành list
  //nếu mã không tồn tại, fistWhere() sẽ báo lỗi vì chưa có orElse. Cần đảm bảo các mã nổi bật
  //hợp lệ hoặc bổ sung xử lý trường hợp thiếu
  List<_Destination> get _filteredDestinations
  //getter tao danh sách phù hợp với lựa chọn hiện tại
  {
    final q = _query.trim().toLowerCase();
    return _destinations.where((item)
    //duyệt địa điểm và chỉ giữ phần tử thỏa điều kiện
    {
      final regionMatch = _selectedRegion == 'All' || item.region == _selectedRegion;
      //địa điểm đạt điều kiện khu vực nếu: Chọn All hoặc khu vực địa điểm trùng khu vực đã chọn
      final queryMatch = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          item.region.toLowerCase().contains(q);
      //đạt điều kiện tìm kiếm nếu từ khóa rỗng hoặc xuất hiện trong ít nhất 1 trường: tên, mô tả ngắn, khu vực
      return regionMatch && queryMatch;//điều kiện phải thỏa cả 2 điều kiện
    }).toList();//chuyển kết quả lọc thành danh sách
  }
  //danh sách yêu thích
  List<_Destination> get _savedDestinations =>
      _destinations.where((d) => _favorites.contains(d.id)).toList();
  // duyệt dữ liệu điểm đến, kiểm tra mã có trong _favorites không=> trả về địa điểm đã chọn
  //thứ tự kết quả theo _destinations, không theo tgian người dùng nhấn lưu
  @override
  void dispose() //dispose() được gọi khi đôí tượng State bị hủy
  {
    _searchController.dispose();
    _heroController.dispose();
    //hai controller được giải phóng tài nguyên
    super.dispose(); //gọi xử lý của lớp cha
  }

  void _toggleFavorite(String id)
  //_toggleFavorite(..) hàm nhận mã địa điểm, không trả về giá trị
  {
    setState(() // thay đổi trạng thái và yêu cầu flutter cập nhật giao diên
    {
      if (!_favorites.remove(id)) _favorites.add(id);
      //favorite_remove(id) thử xóa mã trả về true nếu mã đã tồn tại và được xóa
      //favorite_add(id) nếu chưa có mã để xóa thì thêm mã vào
    });
  }

//xóa bộ lộc và giải phóng controler
  void _resetFilters() {
    setState(() {
      _query = ''; //xóa từ khóa dùng trong logic
      _selectedRegion = 'All'; //trả khu vực về All
      _searchController.clear(); //xóa chữ đang hiện trong ô nhập
    });
  }
  // Bảng chi tiết địa điểm
  void _openDestination(_Destination item) //nhận đối tượng địa điểm người dùng chọn
  {
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
                          AppNav.mapFocusId.value = item.id;//gửi mã địa điểm
                          AppNav.tab.value = AppNav.map; //gửi yêu cầu chuyển tab map
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
                          AppNav.plannerAddId.value = item.id; //nút plan trip
                          AppNav.tab.value = AppNav.planner;
                          //gửi mã sang Planner & yêu cầu chuyển tab
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
//chi tiết trải nghiệm
  void _openExperience(_Experience item) //_openExperience() tạo bottom Sheet
  {
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
                    Navigator.pop(context); //đóng bảng hiện tại
                    AppNav.tab.value = AppNav.planner;//dòng sau chuyển tab
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
//bảng view all và saved places
  void _showDestinationsSheet(String title, List<_Destination> list) //1 hàm dùng cho 2 mục đích khác nhau bằng cách truyền tiêu đề và ds khác nhau
  {
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
          expand: false, //không tự chiếm toàn bộ vùng bố cục cha
          initialChildSize: 0.88, //mở đầu 88% chiều cao vùng cha
          minChildSize: 0.55,
          maxChildSize: 0.96,
          builder: (context, scrollController) //cung cấp controller để phối hợp thao tác cuộn bẳng và cuộn ds
          {
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
                    controller: scrollController,//gắn controller của bảng
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: list.length, // xác định số phần tử
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, //2 cột
                      mainAxisSpacing: 14, //khoảng cách giữa hàng và cột là 14
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72, //tỉ lệ chiều rộng/chiều cao thẻ là 0,72 nên thẻ cao rộng hơn
                    ),
                    itemBuilder: (context, index) => _destinationCard(list[index]),
                    //lấy phần tử ở vị trí index và tạo thẻ tương ứng
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

  // Header và thanh tìm kiếm
  Widget _buildHeader() {
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
                    Flexible(
                      child: Text(
                        'Hanoi, Vietnam',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
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
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _showDestinationsSheet('Saved places', _savedDestinations),
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
                    _favorites.isEmpty
                        ? Icons.favorite_border_rounded
                        : Icons.favorite_rounded,
                    size: 18,
                    color: _favorites.isEmpty ? _primary : _stamp,
                  ),
                  if (_favorites.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${_favorites.length}',
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
          suffixIcon: _query.isEmpty
              ? const Icon(Icons.mic_none_rounded, color: _primary)
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
  Widget _heroCard(_Destination item) {
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
  Widget _destinationList(List<_Destination> list) {
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

  // Banner passport

  Widget _passportBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => AppNav.tab.value = AppNav.passport,
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