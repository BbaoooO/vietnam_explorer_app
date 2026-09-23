import '../models/province_stamp.dart';

/// Tổng số tỉnh/thành trong hệ thống game hoá "Collection Book".
const int totalVietnamProvinces = 63;

/// Danh sách tỉnh/thành người dùng ĐÃ mở khoá (đã ghé thăm).
/// Các ô còn lại (chưa mở khoá) được render dạng "Locked" chung,
/// không cần dữ liệu cụ thể cho từng tỉnh.
final List<ProvinceStamp> sampleCollectionBook = [
  const ProvinceStamp(name: 'Hanoi', tagline: 'Capital City'),
  const ProvinceStamp(name: 'Thua Thien Hue', tagline: 'Imperial City'),
  const ProvinceStamp(name: 'Ho Chi Minh City', tagline: 'Southern Hub'),
];
