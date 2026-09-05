import '../models/passport_stamp.dart';
import '../models/traveler_profile.dart';

final sampleProfile = TravelerProfile(
  fullName: 'Nguyễn Văn A',
  avatarUrl: 'https://i.pravatar.cc/150?img=12',
  passportId: 'VN-TRAVELER-000123',
  issueDate: DateTime(2026, 1, 15),
  totalDestinations: 6,
  stamps: [
    PassportStamp(
      placeName: 'Vịnh Hạ Long',
      province: 'Quảng Ninh',
      imageUrl: 'https://picsum.photos/seed/halong/400/500',
      visitedDate: DateTime(2026, 3, 10),
    ),
    PassportStamp(
      placeName: 'Phố cổ Hội An',
      province: 'Quảng Nam',
      imageUrl: 'https://picsum.photos/seed/hoian/400/500',
      visitedDate: DateTime(2026, 5, 2),
    ),
    PassportStamp(
      placeName: 'Ruộng bậc thang Sa Pa',
      province: 'Lào Cai',
      imageUrl: 'https://picsum.photos/seed/sapa/400/500',
      visitedDate: DateTime(2026, 6, 20),
    ),
    PassportStamp(
      placeName: 'Địa đạo Củ Chi',
      province: 'TP.HCM',
      imageUrl: 'https://picsum.photos/seed/cuchi/400/500',
      visitedDate: DateTime(2000),
      isUnlocked: false,
    ),
    PassportStamp(
      placeName: 'Đà Lạt mộng mơ',
      province: 'Lâm Đồng',
      imageUrl: 'https://picsum.photos/seed/dalat/400/500',
      visitedDate: DateTime(2000),
      isUnlocked: false,
    ),
    PassportStamp(
      placeName: 'Phong Nha - Kẻ Bàng',
      province: 'Quảng Bình',
      imageUrl: 'https://picsum.photos/seed/phongnha/400/500',
      visitedDate: DateTime(2000),
      isUnlocked: false,
    ),
  ],
);
