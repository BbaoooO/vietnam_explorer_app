import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/destination_model.dart';
import '../models/planner_model.dart';

class DummyDataRepository {
  // Kho dữ liệu cho Interactive Map
  static final List<Destination> destinations = [
    Destination(
      id: '1',
      name: 'Tran Quoc Pagoda',
      subtitle: 'Hanoi, Northern Vietnam',
      category: 'Heritage Site',
      imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=600',
      entryFee: 'Free',
      bestTime: 'Late Afternoon',
      rating: 4.8,
      reviewCount: 2100,
      position: const LatLng(21.0469, 105.8189),
      icon: Icons.temple_buddhist,
      region: 'North',
    ),
    Destination(
      id: '2',
      name: 'My Khe Beach',
      subtitle: 'Da Nang, Central Vietnam',
      category: 'Beach',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
      entryFee: 'Free',
      bestTime: 'Sunrise',
      rating: 4.6,
      reviewCount: 1500,
      position: const LatLng(16.0544, 108.2469),
      icon: Icons.beach_access,
      region: 'Central',
    ),
    Destination(
      id: '3',
      name: 'Sapa Terraces',
      subtitle: 'Lao Cai, Northern Vietnam',
      category: 'Mountain',
      imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=600',
      entryFee: '50,000 VND',
      bestTime: 'Morning',
      rating: 4.9,
      reviewCount: 980,
      position: const LatLng(22.3364, 103.8438),
      icon: Icons.landscape,
      region: 'North',
    ),
    Destination(
      id: '4',
      name: 'Mekong Delta',
      subtitle: 'Can Tho, Southern Vietnam',
      category: 'Nature',
      imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=600',
      entryFee: '30,000 VND',
      bestTime: 'Early Morning',
      rating: 4.7,
      reviewCount: 760,
      position: const LatLng(10.0452, 105.7469),
      icon: Icons.water,
      region: 'South',
    ),
  ];

  // Kho dữ liệu cho Trip Planner
  static final List<DailyItinerary> itineraries = [
    DailyItinerary(
      day: 1,
      date: 'Oct 12',
      items: [
        PlannerItem(
          id: '1',
          time: '08:00\nAM',
          title: 'Đến Sân bay Nội Bài',
          description: 'Di chuyển về khách sạn trung tâm phố cổ bằng taxi.',
          icon: Icons.flight_land,
          estimatedCost: '350,000đ',
          isCompleted: true,
        ),
        PlannerItem(
          id: '2',
          time: '10:30\nAM',
          title: 'Phở Gia Truyền Bát Đàn',
          description: 'Thưởng thức phở bò đặc trưng Hà Nội.',
          icon: Icons.restaurant,
          estimatedCost: '60,000đ',
        ),
        PlannerItem(
          id: '3',
          time: '02:00\nPM',
          title: 'Văn Miếu Quốc Tử Giám',
          description: 'Tham quan trường đại học đầu tiên của Việt Nam.',
          icon: Icons.account_balance,
          estimatedCost: '30,000đ',
        ),
      ],
    ),
    DailyItinerary(
      day: 2,
      date: 'Oct 13',
      items: [
        PlannerItem(
          id: '4',
          time: '07:00\nAM',
          title: 'Khởi hành đi Ninh Bình',
          description: 'Lên xe Limousine tại điểm hẹn Nhà Hát Lớn.',
          icon: Icons.directions_bus,
          estimatedCost: '250,000đ',
        ),
        PlannerItem(
          id: '5',
          time: '09:30\nAM',
          title: 'Quần thể danh thắng Tràng An',
          description: 'Đi đò ngắm cảnh núi non hùng vĩ (Tuyến 3).',
          icon: Icons.sailing,
          estimatedCost: '250,000đ',
        ),
      ],
    ),
    DailyItinerary(
      day: 3,
      date: 'Oct 14',
      items: [
        PlannerItem(
          id: '6',
          time: '09:00\nAM',
          title: 'Mua sắm chợ Đồng Xuân',
          description: 'Mua quà lưu niệm và đặc sản địa phương.',
          icon: Icons.shopping_bag,
          estimatedCost: 'Tùy chọn',
        ),
      ],
    ),
  ];
}