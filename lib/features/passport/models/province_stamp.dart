/// Huy hiệu (con dấu) tỉnh/thành trong "Collection Book" của Digital Passport.
/// Khác với [PassportStamp] (địa danh cụ thể, VD: Vịnh Hạ Long),
/// [ProvinceStamp] đại diện cho cả một tỉnh/thành đã được "mở khoá".
class ProvinceStamp {
  final String name; // VD: "Hanoi"
  final String tagline; // VD: "Capital City"
  final bool isUnlocked;

  const ProvinceStamp({
    required this.name,
    required this.tagline,
    this.isUnlocked = true,
  });
}
