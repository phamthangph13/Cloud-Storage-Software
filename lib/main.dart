import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudstorage/man_hinh/chinh/trang_chu.dart';
import 'package:cloudstorage/man_hinh/khoi_dong/man_hinh_chao.dart';
import 'man_hinh/chinh/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Storage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MenuScreen(),
    );
  }
}

class CheckFirstScreen extends StatefulWidget {
  const CheckFirstScreen({super.key});

  @override
  _CheckFirstScreenState createState() => _CheckFirstScreenState();
}

class _CheckFirstScreenState extends State<CheckFirstScreen> {
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isFirstTime = prefs.getBool('isFirstTime');
    if (isFirstTime == null || isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      setState(() {
        _isFirstTime = true;
      });
    } else {
      setState(() {
        _isFirstTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime == null) {
      // Hiển thị màn hình chờ khi đang tải trạng thái
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _isFirstTime ? const IntroScreen() : const HomeScreen();
  }
}
