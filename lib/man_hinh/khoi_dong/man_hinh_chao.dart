import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:cloudstorage/man_hinh/chinh/trang_chu.dart';
import '../chinh/menu.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade100, Colors.white, Colors.blue.shade50],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: IntroductionScreen(
          globalBackgroundColor: Colors.transparent,
          pages: [
            _buildPageViewModel(
              title: "Lưu trữ thông minh",
              body: "Tối ưu hóa không gian lưu trữ với công nghệ nén dữ liệu thông minh và phân loại tự động.",
              lottieAsset: 'assets/intro_1.json',
              color: Colors.blue,
              context: context,
              features: ["Tự động sao lưu", "Phân loại thông minh", "Tiết kiệm dung lượng"],
            ),
            _buildPageViewModel(
              title: "Bảo mật tuyệt đối",
              body: "Bảo vệ dữ liệu của bạn với mã hóa AES-256, xác thực hai lớp và theo dõi hoạt động thời gian thực.",
              lottieAsset: 'assets/intro_2.json',
              color: Colors.indigo,
              context: context,
              features: ["Mã hóa đầu cuối", "Xác thực 2 lớp", "Kiểm soát truy cập"],
            ),
            _buildPageViewModel(
              title: "Đồng bộ liền mạch",
              body: "Truy cập và đồng bộ dữ liệu tức thì trên mọi thiết bị với tốc độ truyền tải siêu nhanh.",
              lottieAsset: 'assets/intro_3.json',
              color: Colors.lightBlue,
              context: context,
              features: ["Đồng bộ tự động", "Chia sẻ nhanh chóng", "Làm việc offline"],
            ),
          ],
          onDone: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const MenuScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 1000),
              ),
            );
          },
          onSkip: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const MenuScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 1000),
              ),
            );
          },
          showSkipButton: true,
          skip: _buildButton("Bỏ qua").animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
          next: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ).animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: 0.2, end: 0),
          done: _buildButton("Bắt đầu").animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8)),
          dotsDecorator: DotsDecorator(
            size: const Size(10.0, 10.0),
            color: Colors.grey.shade300,
            activeSize: const Size(24.0, 10.0),
            activeColor: Colors.blue,
            activeShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
            spacing: const EdgeInsets.symmetric(horizontal: 5),
          ),
          curve: Curves.easeInOutCubic,
          animationDuration: 600,
        ),
      ),
    );
  }

  PageViewModel _buildPageViewModel({
    required String title,
    required String body,
    required String lottieAsset,
    required Color color,
    required BuildContext context,
    required List<String> features,
  }) {
    return PageViewModel(
      title: title,
      body: body,
      image: FadeInDown(
        duration: const Duration(milliseconds: 800),
        child: ZoomIn(
          duration: const Duration(milliseconds: 1000),
          child: Lottie.asset(
            lottieAsset,
            height: MediaQuery.of(context).size.height * 0.35,
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
          ),
        ),
      ),
      decoration: PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: color.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        bodyTextStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey.shade800,
          height: 1.5,
        ),
        titlePadding: const EdgeInsets.only(top: 50.0, bottom: 24.0),
        bodyPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        pageColor: Colors.transparent,
        imagePadding: const EdgeInsets.all(24),
        bodyAlignment: Alignment.center,
        imageAlignment: Alignment.center,
      ),
      footer: Column(
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_outline, color: color),
                      const SizedBox(width: 12),
                      Text(
                        "Tính năng nổi bật",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: color, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            feature,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFooterText(String title) {
    switch (title) {
      case "Lưu trữ thông minh":
        return "Tối ưu hóa không gian với công nghệ nén thông minh";
      case "Bảo mật tuyệt đối":
        return "Bảo vệ dữ liệu với công nghệ mã hóa tiên tiến";
      case "Đồng bộ liền mạch":
        return "Truy cập dữ liệu mọi lúc, mọi nơi một cách an toàn";
      default:
        return "";
    }
  }

  Widget _buildButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
