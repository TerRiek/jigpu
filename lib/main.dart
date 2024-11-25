import 'package:flutter/material.dart';
import 'package:jigpu_1/pages/home/home_bottom_menu.dart';
import 'package:jigpu_1/pages/home/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.dark,  // 다크 모드 활성화
      darkTheme: ThemeData.dark(), // 다크 모드 테마 설정
      home: const HomeBottomMenu(),
    );
  }
}