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
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});
  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }
  Future<void> _checkAuthState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    setState(() {
      _isAuthenticated = token != null;
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return _isAuthenticated ? const MenuScreen() : const CheckFirstScreen();
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
    return _isFirstTime ? const IntroScreen() : const MenuScreen();
  }
}
