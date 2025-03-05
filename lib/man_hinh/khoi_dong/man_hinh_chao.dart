import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:cloudstorage/man_hinh/chinh/trang_chu.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "Quản lý dễ dàng", // String instead of Text widget
          body: "Lưu trữ và quản lý dữ liệu của bạn một cách hiệu quả.",
          image: Center(
            child: Lottie.asset(
              'assets/intro_1.json',
              height: 175,
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlueAccent,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        PageViewModel(
          title: "Bảo mật cao", // String instead of Text widget
          body: "Dữ liệu của bạn được bảo mật tuyệt đối với công nghệ tiên tiến.",
          image: Center(
            child: Lottie.asset(
              'assets/intro_2.json',
              height: 175,
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlueAccent,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        PageViewModel(
          title: "Truy cập mọi nơi", // String instead of Text widget
          body: "Truy cập dữ liệu của bạn mọi lúc, mọi nơi, trên mọi thiết bị.",
          image: Center(
            child: Lottie.asset(
              'assets/intro_3.json',
              height: 175,
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlueAccent,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
      onDone: () {
        // Chuyển sang màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      onSkip: () {
        // Bỏ qua và vào màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      showSkipButton: true,
      skip: const Text("Bỏ qua", style: TextStyle(color: Colors.lightBlueAccent)),
      next: const Icon(Icons.arrow_forward, color: Colors.lightBlueAccent),
      done: const Text("Bắt đầu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlueAccent)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.black26,
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.lightBlueAccent,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
