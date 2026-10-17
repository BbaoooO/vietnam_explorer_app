import '../models/passport_stamp.dart';
import '../models/traveler_profile.dart';

final sampleProfile = TravelerProfile(
  fullName: 'Đỗ Gia Bảo',
  avatarUrl: 'https://i.pravatar.cc/150?img=12',
  passportId: 'VN-TRAVELER-000123',
  issueDate: DateTime(2026, 1, 15),
  totalDestinations: 6,
  levelNumber: 3,
  levelTitle: 'Wandering Scholar',
  currentXP: 1450,
  xpToNextLevel: 2000,
  nextBadgeName: 'Mekong Navigator',
  nextBadgeLevel: 4,
  stamps: [
    PassportStamp(
      placeName: 'Ha Long bay',
      province: 'Quang Ninh',
      imageUrl: 'https://picsum.photos/seed/halong/400/500',
      visitedDate: DateTime(2026, 3, 10),
    ),
    PassportStamp(
      placeName: 'Hoi An Ancient Town',
      province: 'Quang Nam',
      imageUrl: 'https://picsum.photos/seed/hoian/400/500',
      visitedDate: DateTime(2026, 5, 2),
    ),
    PassportStamp(
      placeName: 'Sapa Terraced Rice Field',
      province: 'Lao Cai',
      imageUrl: 'https://picsum.photos/seed/sapa/400/500',
      visitedDate: DateTime(2026, 6, 20),
    ),
    PassportStamp(
      placeName: 'Cu Chi Tunnels',
      province: 'Ho chi Minh City',
      imageUrl: 'https://picsum.photos/seed/cuchi/400/500',
      visitedDate: DateTime(2000),
      isUnlocked: false,
    ),
    PassportStamp(
      placeName: 'Dreamy Da Lat',
      province: 'Lam Dong',
      imageUrl: 'https://picsum.photos/seed/dalat/400/500',
      visitedDate: DateTime(2000),
      isUnlocked: false,
    ),
    PassportStamp(
      placeName: 'Phong Nha - Ke Bang',
      province: 'Quảng Bình',
      imageUrl: 'https://picsum.photos/seed/phongnha/400/500',
      visitedDate: DateTime(2000),
      isUnlocked: false,
    ),
  ],
);
