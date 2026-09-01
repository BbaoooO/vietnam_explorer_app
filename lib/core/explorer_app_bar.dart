import 'package:flutter/material.dart';

class ExplorerAppBar extends StatelessWidget implements PreferredSizeWidget{
  const ExplorerAppBar({super.key});


@override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FA),
      elevation: 0, // xóa bóng đổ
      title:Row(
        children: const[
          Icon(Icons.location_on,
          color: Color(0xFF0F4C3A),
          size: 28,
          ),
          SizedBox(width: 8), // khoảng cách giữa icon và text
          Text(
            'Vietnam Explorer',
            style: TextStyle(
              color: Color(0xFF0F4C3A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}