
class PassportStamp {
  final String placeName; // Tên địa danh, VD: "Vịnh Hạ Long"
  final String province; // Tỉnh/thành, VD: "Quảng Ninh"
  final String imageUrl; // Ảnh đại diện địa danh
  final DateTime visitedDate; // Ngày check-in
  final bool isUnlocked; // Đã mở khóa (đã check-in) hay chưa

  const PassportStamp({
    required this.placeName,
    required this.province,
    required this.imageUrl,
    required this.visitedDate,
    this.isUnlocked = true,
  });
}
