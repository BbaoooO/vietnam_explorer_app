import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme
//tạo lớp chứa giao diện dùng chung
{
  static const Color primaryColor = Color(0xFF0F4C3A);
  static const Color secondaryColor = Color(0xFFF2B705);
  static const Color backgroundColor = Color(0xFFF7F8FA);

  static ThemeData get lightTheme
  //get lightTheme là getter,truy cập bằng AppTheme.lightTheme, trả về một cấu hình ThemeData
  //Getter này tạo cấu hình khi được gọi, không phải tự động lưu sẵn một đôí tượng duy nhất
  {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor, //đặt nền mặc định cho scaffold

      colorScheme: ColorScheme.fromSeed
        //formSeed tạo màu từ bản gốc
        (
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
      ),

      textTheme: GoogleFonts.beVietnamProTextTheme().copyWith
        //tạo chữ bằng phông Be VietNam Pro, sau đó tùy chỉnh 1 số kiểu chữ = copyWith
        (
        headlineLarge: GoogleFonts.beVietnamPro(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        headlineMedium: GoogleFonts.beVietnamPro(
          fontSize: 22,
          fontWeight: FontWeight.w700, //độ đậm
          color: primaryColor,
        ),
        titleLarge: GoogleFonts.beVietnamPro(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.beVietnamPro(
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.beVietnamPro(
          fontSize: 14,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom
          //thiết lập kiểu mặc định cho ElevatedButton
          (
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          //yêu cầu nút rộng theo không gian bố cục cho phép, cao tối thiểu 52 đơn vị logic
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            //bo gốc với bán kính 12
          ),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom( //nút viền
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}