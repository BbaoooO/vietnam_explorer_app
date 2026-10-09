class TicketRate {
  const TicketRate({
    required this.id,
    required this.label,
    required this.priceVnd,
    required this.condition,
    this.validFrom,
    this.validUntil,
  });

  final String id;
  final String label;
  final int priceVnd;
  final String condition;
  final String? validFrom;
  final String? validUntil;

  bool appliesOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (validFrom != null && day.isBefore(DateTime.parse(validFrom!))) {
      return false;
    }
    if (validUntil != null && day.isAfter(DateTime.parse(validUntil!))) {
      return false;
    }
    return true;
  }
}

class TicketPackage {
  const TicketPackage({
    required this.id,
    required this.label,
    required this.rates,
    this.note = '',
    this.weekdays = const [],
  });
  final String id;
  final String label;
  final List<TicketRate> rates;
  final String note;
  final List<int> weekdays;
  bool appliesOn(DateTime day) => weekdays.isEmpty || weekdays.contains(day.weekday);
}

class VisitPeriod {
  const VisitPeriod(this.label, this.detail);
  final String label;
  final String detail;
}

class VisitSource {
  const VisitSource(this.label, this.url);
  final String label;
  final String url;
}

class PlaceVisitInfo {
  const PlaceVisitInfo({
    required this.openingHours,
    required this.periods,
    required this.packages,
    this.extras = const [],
    this.notes = const [],
    this.sources = const [],
    this.checkedOn,
  });

  final String openingHours;
  final List<VisitPeriod> periods;
  final List<TicketPackage> packages;
  final List<TicketRate> extras;
  final List<String> notes;
  final List<VisitSource> sources;
  final String? checkedOn;
}

const _dayPeriods = <VisitPeriod>[
  VisitPeriod('Sáng', 'Tham quan trong giờ mở cửa.'),
  VisitPeriod('Trưa', 'Tham quan trong giờ mở cửa.'),
  VisitPeriod('Chiều', 'Tham quan trong giờ mở cửa.'),
  VisitPeriod('Tối', 'Chưa xác minh chương trình tham quan buổi tối.'),
];

// Không suy ra giá miễn phí hoặc ưu đãi từ loại địa điểm.
const unknownVisitInfo = PlaceVisitInfo(
  openingHours: 'Chưa cập nhật giờ mở cửa.',
  periods: [
    VisitPeriod('Sáng', 'Chưa xác minh lịch và giá.'),
    VisitPeriod('Trưa', 'Chưa xác minh lịch và giá.'),
    VisitPeriod('Chiều', 'Chưa xác minh lịch và giá.'),
    VisitPeriod('Tối', 'Chưa xác minh lịch và giá.'),
  ],
  packages: [],
  notes: [
    'Chưa có bảng giá đã xác minh cho địa điểm này.',
    'Ưu đãi trẻ em, học sinh/sinh viên và người cao tuổi: chưa cập nhật.',
  ],
);

const placeVisitInfos = <String, PlaceVisitInfo>{
  ...hueVisitInfos,
  'dinh_doc_lap': PlaceVisitInfo(
    checkedOn: '09/10/2026',
    openingHours: '07:00–18:00 hằng ngày. Cổng 135 Nam Kỳ Khởi Nghĩa bán vé 07:00–18:00; cổng 106 Nguyễn Du bán vé 08:00–16:00.',
    periods: [
      VisitPeriod('Sáng', 'Từ 07:00, trong giờ tham quan.'),
      VisitPeriod('Trưa', 'Trong giờ tham quan 07:00–18:00.'),
      VisitPeriod('Chiều', 'Tham quan đến 18:00; lưu ý giờ bán vé theo cổng.'),
      VisitPeriod('Tối', 'Sau 18:00 nằm ngoài giờ tham quan công bố.'),
    ],
    packages: [
      TicketPackage(
        id: 'full', label: 'Toàn bộ: Dinh + Nhà Trưng bày',
        rates: [
          TicketRate(id: 'full_adult', label: 'Người lớn', priceVnd: 80000, condition: 'Từ 18 đến 59 tuổi.'),
          TicketRate(id: 'full_student', label: 'Sinh viên Việt Nam', priceVnd: 40000, condition: 'Mang thẻ sinh viên để đối chiếu ưu đãi tại quầy.'),
          TicketRate(id: 'full_senior', label: 'Người cao tuổi', priceVnd: 40000, condition: 'Từ 60 tuổi trở lên; mang giấy tờ chứng minh tuổi.'),
          TicketRate(id: 'full_child', label: 'Trẻ em / thiếu niên', priceVnd: 20000, condition: 'Từ 6 đến 17 tuổi.'),
        ],
      ),
      TicketPackage(
        id: 'limited', label: 'Giới hạn: chỉ Dinh hoặc Nhà Trưng bày',
        note: 'Chọn một khu tham quan; không thay thế vé toàn bộ.',
        rates: [
          TicketRate(id: 'limited_adult', label: 'Người lớn', priceVnd: 40000, condition: 'Từ 18 đến 59 tuổi.'),
          TicketRate(id: 'limited_student', label: 'Sinh viên Việt Nam', priceVnd: 20000, condition: 'Mang thẻ sinh viên để đối chiếu ưu đãi tại quầy.'),
          TicketRate(id: 'limited_senior', label: 'Người cao tuổi', priceVnd: 20000, condition: 'Từ 60 tuổi trở lên.'),
          TicketRate(id: 'limited_child', label: 'Trẻ em / thiếu niên', priceVnd: 10000, condition: 'Từ 6 đến 17 tuổi.'),
        ],
      ),
    ],
    extras: [
      TicketRate(id: 'electric_car', label: 'Xe điện', priceVnd: 25000, condition: 'Mỗi người, mỗi lượt; dịch vụ bổ sung, không phải vé vào cổng.'),
    ],
    notes: [
      'Bảng giá này áp dụng từ 01/01/2026. Chọn một gói vé cho nhóm đang tính.',
      'Trang bảng giá chưa nêu ưu đãi riêng theo sáng, trưa, chiều; không tự áp dụng giảm giá theo giờ.',
      'Miễn/giảm khác được xử lý theo quy định tại quầy; trẻ dưới 6 tuổi cần đối chiếu điều kiện miễn vé.',
    ],
    sources: [VisitSource('Giờ & bảng giá 2026', 'https://dinhdoclap.gov.vn/gio-tham-quan-va-gia-ve-moi-nhat-ap-dung-tu-01-8-2025-2/')],
  ),
  'van_mieu': PlaceVisitInfo(
    checkedOn: '09/10/2026',
    openingHours: 'Ban ngày 08:00–17:00 hằng ngày. Tour đêm 18:30–22:00, thứ Tư, thứ Bảy và Chủ nhật theo lịch công bố.',
    periods: [
      VisitPeriod('Sáng', 'Vé ban ngày từ 08:00.'),
      VisitPeriod('Trưa', 'Trong giờ ban ngày 08:00–17:00.'),
      VisitPeriod('Chiều', 'Vé ban ngày đến 17:00.'),
      VisitPeriod('Tối', 'Tour đêm 18:30–22:00: thứ Tư, thứ Bảy, Chủ nhật. Vé riêng.'),
    ],
    packages: [
      TicketPackage(id: 'day', label: 'Tham quan ban ngày', rates: [
        TicketRate(id: 'day_adult', label: 'Người lớn', priceVnd: 70000, condition: 'Khách tham quan phổ thông.'),
        TicketRate(id: 'day_student', label: 'Học sinh / sinh viên', priceVnd: 35000, condition: 'Các trường tại Việt Nam; có thẻ. Người dưới 16 tuổi thuộc diện miễn phí.'),
        TicketRate(id: 'day_senior', label: 'Người cao tuổi', priceVnd: 35000, condition: 'Từ 60 tuổi, mang CCCD.'),
        TicketRate(id: 'day_child', label: 'Trẻ em dưới 16 tuổi', priceVnd: 0, condition: 'Miễn phí theo bảng giá ban ngày.'),
      ]),
      TicketPackage(id: 'night_one', label: 'Tour đêm: gói 1 show', weekdays: [3, 6, 7], note: 'Theo lịch tour; không dùng vé ban ngày để thay vé đêm.', rates: [
        TicketRate(id: 'night_one_adult', label: 'Người lớn', priceVnd: 299000, condition: 'Cao trên 1,30 m.'),
        TicketRate(id: 'night_one_child', label: 'Trẻ em', priceVnd: 149000, condition: 'Cao từ 1,00 đến 1,30 m.'),
        TicketRate(id: 'night_one_free', label: 'Trẻ dưới 1,00 m', priceVnd: 0, condition: 'Miễn phí.'),
      ]),
      TicketPackage(id: 'night_two', label: 'Tour đêm: gói 2 show', weekdays: [3, 6, 7], note: 'Chưa xác minh ưu đãi riêng cho sinh viên/người cao tuổi với tour đêm.', rates: [
        TicketRate(id: 'night_two_adult', label: 'Người lớn', priceVnd: 399000, condition: 'Cao trên 1,30 m.'),
        TicketRate(id: 'night_two_child', label: 'Trẻ em', priceVnd: 199000, condition: 'Cao từ 1,00 đến 1,30 m.'),
        TicketRate(id: 'night_two_free', label: 'Trẻ dưới 1,00 m', priceVnd: 0, condition: 'Miễn phí.'),
      ]),
    ],
    notes: [
      'Ưu đãi ban ngày không tự áp dụng cho tour đêm.',
      'Ban ngày còn có miễn/giảm cho một số đối tượng chính sách, người khuyết tật; xem điều kiện tại nguồn.',
      'Chưa thấy giá riêng cho buổi sáng, trưa và chiều trong bảng giá ban ngày.',
    ],
    sources: [
      VisitSource('Vé & giờ ban ngày', 'https://www.vanmieu.gov.vn/vi/introduction/visitor-information'),
      VisitSource('Bảng giá tour đêm', 'https://vanmieu.gov.vn/vi/experience/night-tour'),
    ],
  ),
  'hoa_lo': PlaceVisitInfo(
    checkedOn: '09/10/2026', openingHours: '08:00–17:00 hằng ngày, kể cả Lễ, Tết.',
    periods: _dayPeriods,
    packages: [TicketPackage(id: 'day', label: 'Tham quan ban ngày', rates: [
      TicketRate(id: 'adult', label: 'Vé thông thường', priceVnd: 50000, condition: 'Mỗi người.'),
      TicketRate(id: 'student', label: 'Học sinh / sinh viên', priceVnd: 25000, condition: 'Có thẻ học sinh/sinh viên; dưới 16 tuổi thuộc diện miễn phí.'),
      TicketRate(id: 'senior', label: 'Người cao tuổi', priceVnd: 25000, condition: 'Từ 60 tuổi trở lên.'),
      TicketRate(id: 'child', label: 'Trẻ em dưới 16 tuổi', priceVnd: 0, condition: 'Miễn phí.'),
    ])],
    notes: ['Giảm 50% còn áp dụng cho người khuyết tật nặng và một số đối tượng chính sách; người khuyết tật đặc biệt nặng được miễn phí.', 'Giá tour đêm chưa được xác minh trong gói dữ liệu này.', 'Chưa có thông tin ưu đãi riêng sáng/trưa/chiều.'],
    sources: [VisitSource('Vé & giờ tham quan', 'https://hoalo.vn/Home/Ve')],
  ),
  'hoang_thanh': PlaceVisitInfo(
    checkedOn: '09/10/2026', openingHours: '08:00–17:00 hằng ngày.', periods: _dayPeriods,
    packages: [TicketPackage(id: 'day', label: 'Tham quan ban ngày', rates: [
      TicketRate(id: 'adult', label: 'Vé thông thường', priceVnd: 100000, condition: 'Du khách Việt Nam và quốc tế.'),
      TicketRate(id: 'student', label: 'Học sinh / sinh viên', priceVnd: 50000, condition: 'Từ 16 tuổi, có thẻ do trường trong hệ thống giáo dục Việt Nam cấp.'),
      TicketRate(id: 'senior', label: 'Người cao tuổi', priceVnd: 50000, condition: 'Công dân Việt Nam từ 60 tuổi, có giấy tờ chứng minh.'),
      TicketRate(id: 'child', label: 'Trẻ dưới 16 tuổi', priceVnd: 0, condition: 'Có giấy tờ chứng minh; nếu không có, áp dụng chiều cao dưới 1,30 m.'),
    ])],
    notes: ['Bảng giá áp dụng từ 01/01/2025; còn có miễn/giảm cho một số đối tượng chính sách.', 'Tour đêm là sản phẩm riêng; giá và lịch chưa cập nhật ở đây.', 'Chưa xác minh ưu đãi riêng theo sáng/trưa/chiều.'],
    sources: [VisitSource('Bảng giá chính thức', 'https://hoangthanhthanglong.vn/tang-gia-ve-tham-quan-tai-khu-trung-tam-hoang-thanh-thang-long-ha-noi/')],
  ),
  'chung_tich': PlaceVisitInfo(
    checkedOn: '09/10/2026', openingHours: '07:30–17:30 hằng ngày; quầy vé ngừng nhận khách lúc 17:00.', periods: _dayPeriods,
    packages: [TicketPackage(id: 'entry', label: 'Tham quan bảo tàng', note: 'Trang đặt vé đang hiển thị giá khác trang điều khoản cũ; xác nhận lại tại quầy trước khi mua.', rates: [
      TicketRate(id: 'adult', label: 'Vé thông thường', priceVnd: 60000, condition: 'Giá hiển thị trên trang đặt vé tại thời điểm kiểm tra.'),
      TicketRate(id: 'reduced', label: 'Vé giảm 50%', priceVnd: 30000, condition: 'Cần xác nhận đối tượng đủ điều kiện trên hệ thống hoặc tại quầy.'),
      TicketRate(id: 'child', label: 'Trẻ dưới 6 tuổi', priceVnd: 0, condition: 'Có người lớn đi kèm; nhận vé tại quầy.'),
      TicketRate(id: 'student_oct', label: 'Học sinh / sinh viên — ưu đãi tháng 10', priceVnd: 0, condition: 'Đăng ký tại cổng vé miễn phí và đối chiếu thẻ hợp lệ tại quầy. Chỉ từ 01–31/10/2026.', validFrom: '2026-10-01', validUntil: '2026-10-31'),
    ])],
    notes: ['Ngoài thời gian 01–31/10/2026, không tự áp dụng vé miễn phí sinh viên trong bản demo.', 'Điều kiện trẻ 6–dưới 16 tuổi và người cao tuổi cần kiểm tra lại do các trang chính thức chưa đồng nhất bảng giá.', 'Chưa xác minh ưu đãi theo sáng/trưa/chiều.'],
    sources: [
      VisitSource('Trang đặt vé hiện tại', 'https://ticket.baotangchungtichchientranh.vn/'),
      VisitSource('Đăng ký miễn phí tháng 10/2026', 'https://mienphi.baotangchungtichchientranh.vn/'),
      VisitSource('Giờ & điều khoản', 'https://ticket.baotangchungtichchientranh.vn/terms-and-conditions.html'),
    ],
  ),
};

PlaceVisitInfo visitInfoFor(String placeId) =>
    placeVisitInfos[placeId] ?? unknownVisitInfo;

// Nguồn bảng giá Huế: Nghị quyết 55/2025/NQ-HĐND, mục giá điểm lẻ.
// Không áp dụng mức sinh viên/người cao tuổi khi chưa xác minh điều kiện.
const _hueSources = <VisitSource>[
  VisitSource('Bảng phí tham quan Huế', 'https://vbpl.moj.gov.vn/thuathienhue/Pages/vbpq-toanvan.aspx?ItemID=185769'),
  VisitSource('Cổng vé di tích Huế', 'https://vdt.hueworldheritage.org.vn/'),
];
const _huePeriods = <VisitPeriod>[
  VisitPeriod('Sáng', 'Kiểm tra giờ mở cửa tại nguồn hoặc quầy vé.'),
  VisitPeriod('Trưa', 'Chưa xác minh lịch nghỉ trưa.'),
  VisitPeriod('Chiều', 'Kiểm tra giờ đóng cửa tại nguồn hoặc quầy vé.'),
  VisitPeriod('Tối', 'Chưa xác minh lịch và giá chương trình buổi tối.'),
];
const _hueNotes = <String>[
  'Giá dưới đây là vé điểm lẻ, không phải vé tuyến gộp.',
  'Điều kiện tuổi/chiều cao trẻ em và ưu đãi sinh viên, người cao tuổi cần đối chiếu tại quầy trước khi chọn vé.',
  'Chưa xác minh ưu đãi theo sáng/trưa/chiều/tối; dịch vụ bổ sung chưa nằm trong giá tính.',
];
const hueVisitInfos = <String, PlaceVisitInfo>{
  'dai_noi': PlaceVisitInfo(
    checkedOn: '09/10/2026', openingHours: 'Chưa xác minh giờ mở cửa hiện hành.',
    periods: _huePeriods, notes: _hueNotes, sources: _hueSources,
    packages: [TicketPackage(id: 'entry', label: 'Điểm lẻ Đại Nội Huế', rates: [
      TicketRate(id: 'adult', label: 'Người lớn', priceVnd: 200000, condition: 'Vé điểm lẻ theo bảng phí công bố.'),
      TicketRate(id: 'child', label: 'Trẻ em', priceVnd: 40000, condition: 'Cần xác nhận điều kiện trẻ em tại quầy trước khi áp dụng.'),
    ])],
  ),
  'khai_dinh': PlaceVisitInfo(
    checkedOn: '09/10/2026', openingHours: 'Chưa xác minh giờ mở cửa hiện hành.',
    periods: _huePeriods, notes: _hueNotes, sources: _hueSources,
    packages: [TicketPackage(id: 'entry', label: 'Điểm lẻ Lăng Khải Định', rates: [
      TicketRate(id: 'adult', label: 'Người lớn', priceVnd: 150000, condition: 'Vé điểm lẻ theo bảng phí công bố.'),
      TicketRate(id: 'child', label: 'Trẻ em', priceVnd: 30000, condition: 'Cần xác nhận điều kiện trẻ em tại quầy trước khi áp dụng.'),
    ])],
  ),
  'tu_duc': PlaceVisitInfo(
    checkedOn: '09/10/2026', openingHours: 'Chưa xác minh giờ mở cửa hiện hành.',
    periods: _huePeriods, notes: _hueNotes, sources: _hueSources,
    packages: [TicketPackage(id: 'entry', label: 'Điểm lẻ Lăng Tự Đức', rates: [
      TicketRate(id: 'adult', label: 'Người lớn', priceVnd: 150000, condition: 'Vé điểm lẻ theo bảng phí công bố.'),
      TicketRate(id: 'child', label: 'Trẻ em', priceVnd: 30000, condition: 'Cần xác nhận điều kiện trẻ em tại quầy trước khi áp dụng.'),
    ])],
  ),
};