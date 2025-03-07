import 'package:flutter/material.dart';
import 'dart:math' as math;

class StoragePurchasePage extends StatefulWidget {
  const StoragePurchasePage({super.key});

  @override
  State<StoragePurchasePage> createState() => _StoragePurchasePageState();
}

class _StoragePurchasePageState extends State<StoragePurchasePage>
    with SingleTickerProviderStateMixin {
  double _storageAmount = 1.0; // GB
  final double _pricePerGB = 2500.0;
  final double _taxRate = 0.1; // 10%

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _subtotal => _storageAmount * _pricePerGB;
  double get _taxAmount => _subtotal * _taxRate;
  double get _total => _subtotal + _taxAmount;

  String _formatStorageSize(double value) {
    return value < 1000 ? '${value.toInt()} GB' : '${(value / 1000).toStringAsFixed(1)} TB';
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )} VND';
  }

  double _getSliderValue() => _storageAmount <= 1000
      ? _storageAmount / 1000 * 0.5
      : 0.5 + ((_storageAmount - 1000) / 9000) * 0.5;

  double _getStorageFromSlider(double sliderValue) => sliderValue <= 0.5
      ? sliderValue / 0.5 * 1000
      : 1000 + ((sliderValue - 0.5) / 0.5 * 9000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mua Dung Lượng', 
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600
          )
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50.withOpacity(0.8),
              Colors.purple.shade50.withOpacity(0.3),
              Colors.white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStorageCard(),
              const SizedBox(height: 32),
              _buildBenefitsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Nâng cấp dung lượng', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Chọn dung lượng phù hợp với nhu cầu', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStorageCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.purple.shade100.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.purple.shade50.withOpacity(0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: _storageAmount),
                    builder: (context, double value, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 90 * _animation.value,
                            backgroundColor: Colors.purple.withOpacity(0.1),
                          ),
                          CircleAvatar(
                            radius: 70 * _animation.value,
                            backgroundColor: Colors.purple.withOpacity(0.15),
                          ),
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.purple.shade600,
                            child: Text(
                              _formatStorageSize(_storageAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.purple.shade400,
                  inactiveTrackColor: Colors.purple.shade100,
                  thumbColor: Colors.purple.shade600,
                  overlayColor: Colors.purple.withOpacity(0.2),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _getSliderValue(),
                  onChanged: (value) => setState(() => _storageAmount = _getStorageFromSlider(value)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1 GB', style: TextStyle(color: Colors.grey[600])),
                    Text('10 TB', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildPriceRow('Dung lượng', _formatStorageSize(_storageAmount)),
                    _buildPriceRow('Tạm tính', _formatCurrency(_subtotal)),
                    _buildPriceRow('Thuế (10%)', _formatCurrency(_taxAmount)),
                    const Divider(height: 24),
                    _buildPriceRow('Tổng tiền', _formatCurrency(_total), isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                  shadowColor: Colors.purple.shade200,
                ),
                child: const Text(
                  'Xác nhận mua',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.blue.shade100.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lợi ích khi nâng cấp',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              _buildBenefit('Lưu trữ dữ liệu không giới hạn'),
              _buildBenefit('Bảo mật dữ liệu theo chuẩn ISO 27001'),
              _buildBenefit('Hỗ trợ kỹ thuật 24/7'),
              _buildBenefit('Tốc độ truy cập cao từ mọi thiết bị'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, color: isTotal ? Colors.purple : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [const Icon(Icons.check, color: Colors.green, size: 18), const SizedBox(width: 8), Text(text)],
      ),
    );
  }
}
