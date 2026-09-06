import 'package:flutter/material.dart';
import '../../core/explorer_app_bar.dart'; // Đổi đường dẫn cho khớp với cấu trúc của bạn

class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const ExplorerAppBar(), // Tái sử dụng banner tại đây
      body: Center(
        child: Text('Nội dung màn hình Planner'),
      ),
    );
  }
}