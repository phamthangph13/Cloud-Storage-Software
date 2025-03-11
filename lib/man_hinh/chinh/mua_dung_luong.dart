import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'payment_sheet.dart';

class StoragePurchasePage extends StatefulWidget {
  final String token;
  
  const StoragePurchasePage({super.key, required this.token});

  @override
  State<StoragePurchasePage> createState() => _StoragePurchasePageState();
}

class _StoragePurchasePageState extends State<StoragePurchasePage>
    with SingleTickerProviderStateMixin {
  double _storageAmount = 1.0; // GB
  final double _pricePerGB = 25000;
  int _selectedPaymentMethodIndex = 0;

  // Payment methods - only QR BANKING and Bank Transfer
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'QR BANKING',
      'instructions': [
        'Bước 1: Mở ứng dụng ngân hàng của bạn',
        'Bước 2: Quét mã QR lúc thanh toán',
        'Bước 3: Xác nhận và hoàn tất giao dịch',
      ],
    },
    {
      'name': 'Chuyển Khoản',
      'instructions': [
        'Bước 1: Mở ứng dụng ngân hàng của bạn',
        'Bước 2: Chọn chuyển khoản và nhập thông tin:',
        'Bước 3: Nhập đúng số tiền cần thanh toán',
        'Bước 4: Ghi nội dung chuyển khoản: "Mã giao dịch"',
      ],
      'bankInfo': {
        'accountName': 'PHAM NHU THANG',
        'accountNumber': '0915878677',
        'bank': 'MB Bank',
      }
    },
  ];

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

  // Convert slider value to storage value
  double _sliderToStorageValue(double sliderValue) {
    // Convert from 0-1 to range 1GB to 2TB (2000GB)
    // Using exponential function for reasonable distribution
    return math.pow(10, 3.301 * sliderValue).toDouble().clamp(1.0, 2000.0);
  }

  double _storageToSliderValue(double storageValue) {
    // Convert from 1GB-2000GB to 0-1
    // Using log base 10, and limit the result to 0-1
    return (math.log(storageValue.clamp(1.0, 2000.0)) / math.ln10 / 3.301).clamp(0.0, 1.0);
  }

  String _formatStorageSize(double value) {
    if (value < 1000) {
      // Below 1TB display in GB
      if (value == value.round()) {
        // If integer, don't show decimal
        return '${value.toInt()} GB';
      } else {
        // If has decimal, show 1 digit
        return '${value.toStringAsFixed(1)} GB';
      }
    } else {
      // From 1TB and above
      double tbValue = value / 1000;
      if (tbValue == tbValue.round()) {
        return '${tbValue.toInt()} TB';
      } else {
        return '${tbValue.toStringAsFixed(1)} TB';
      }
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )} VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mua Dung Lượng', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600
          )
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade50,
              Colors.white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              
              // Storage selector
              _buildSectionTitle('Chọn dung lượng'),
              const SizedBox(height: 16),
              _buildStorageSelector(),
              const SizedBox(height: 32),
              
              // Payment method
              _buildSectionTitle('Phương thức thanh toán'),
              const SizedBox(height: 12),
              _buildPaymentMethods(),
              const SizedBox(height: 32),
              
              // Storage benefits
              _buildBenefitsCard(),
              const SizedBox(height: 20),
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
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Nâng cấp dung lượng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Chọn dung lượng phù hợp với nhu cầu của bạn',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade800,
      ),
    );
  }
  
  Widget _buildStorageSelector() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Storage visualization
                  Container(
                    height: 180,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Cloud icon with size animation
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                double size = 50.0 + (15.0 * _storageToSliderValue(_storageAmount));
                                return Icon(
                                  Icons.cloud,
                                  size: size,
                                  color: Colors.blue.shade400,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            // Storage amount display
                            Text(
                              _formatStorageSize(_storageAmount),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(_pricePerGB * _storageAmount),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.blue.shade500,
                      inactiveTrackColor: Colors.blue.shade100,
                      thumbColor: Colors.white,
                      overlayColor: Colors.blue.withOpacity(0.2),
                      trackHeight: 10,
                      thumbShape: _CustomSliderThumbShape(
                        thumbRadius: 14, 
                        borderColor: Colors.blue.shade600,
                      ),
                    ),
                    child: Slider(
                      value: _storageToSliderValue(_storageAmount),
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() {
                          final newValue = _sliderToStorageValue(value);
                          // Round to nearest appropriate value
                          if (newValue < 10) {
                            // Below 10GB, round to 0.1GB
                            _storageAmount = (newValue * 10).round() / 10;
                          } else if (newValue < 100) {
                            // From 10GB to 100GB, round to 1GB
                            _storageAmount = newValue.round().toDouble();
                          } else if (newValue < 1000) {
                            // From 100GB to 1TB, round to 10GB
                            _storageAmount = (newValue / 10).round() * 10;
                          } else {
                            // Above 1TB, round to 50GB
                            _storageAmount = (newValue / 50).round() * 50;
                          }
                        });
                      },
                    ),
                  ),
                  
                  // Min and max values
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 GB',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '2 TB',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price indicator
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Giá: ${_formatCurrency(_pricePerGB)} / 1GB',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick selection buttons
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.flash_on,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Chọn nhanh:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickSelectButton('1 GB', 1.0),
                      _buildQuickSelectButton('10 GB', 10.0),
                      _buildQuickSelectButton('100 GB', 100.0),
                      _buildQuickSelectButton('1 TB', 1000.0),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Payment Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => PaymentSheet(
                            storageAmount: _storageAmount,
                            pricePerGB: _pricePerGB,
                            selectedPaymentMethod: _paymentMethods[_selectedPaymentMethodIndex]['name'],
                            bankInfo: _paymentMethods[1]['bankInfo'],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.blue.shade300,
                      ),
                      child: const Text(
                        'Thanh Toán',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildQuickSelectButton(String label, double value) {
    final isSelected = _storageAmount == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _storageAmount = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.blue.shade200,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.shade200.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: List.generate(
                      _paymentMethods.length,
                      (index) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethodIndex = index;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              left: index == 0 ? 0 : 8,
                              right: index == _paymentMethods.length - 1 ? 0 : 8,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _selectedPaymentMethodIndex == index
                                  ? Colors.blue.shade600
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedPaymentMethodIndex == index
                                    ? Colors.transparent
                                    : Colors.blue.shade200,
                                width: 1.5,
                              ),
                              boxShadow: [
                                if (_selectedPaymentMethodIndex == index)
                                  BoxShadow(
                                    color: Colors.blue.shade200.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _paymentMethods[index]['name'],
                                  style: TextStyle(
                                    color: _selectedPaymentMethodIndex == index
                                        ? Colors.white
                                        : Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Payment Instructions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade100,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hướng dẫn thanh toán',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Bank Information
                        if (_selectedPaymentMethodIndex == 1 && 
                            _paymentMethods[_selectedPaymentMethodIndex]['bankInfo'] != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildBankInfoRow(
                                  'Ngân hàng:',
                                  _paymentMethods[_selectedPaymentMethodIndex]['bankInfo']['bank'],
                                ),
                                const SizedBox(height: 8),
                                _buildBankInfoRow(
                                  'Tên TK:',
                                  _paymentMethods[_selectedPaymentMethodIndex]['bankInfo']['accountName'],
                                ),
                                const SizedBox(height: 8),
                                _buildBankInfoRow(
                                  'Số TK:',
                                  _paymentMethods[_selectedPaymentMethodIndex]['bankInfo']['accountNumber'],
                                  isAccountNumber: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Instructions Steps
                        ..._paymentMethods[_selectedPaymentMethodIndex]['instructions']
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: Colors.blue.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: TextStyle(
                                            color: Colors.blue.shade900,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankInfoRow(String label, String value, {bool isAccountNumber = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isAccountNumber)
                GestureDetector(
                  onTap: () {
                    // Copy to clipboard functionality can be added here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép số tài khoản'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildBenefitsCard() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.blue.shade100,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Lợi ích khi nâng cấp',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildBenefit('Lưu trữ dữ liệu an toàn'),
                  _buildBenefit('Bảo mật dữ liệu theo chuẩn ISO 27001'),
                  _buildBenefit('Hỗ trợ kỹ thuật 24/7'),
                  _buildBenefit('Tốc độ truy cập cao từ mọi thiết bị'),
                  _buildBenefit('Đồng bộ hóa dữ liệu tự động'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final Color borderColor;

  const _CustomSliderThumbShape({
    required this.thumbRadius,
    required this.borderColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawCircle(center, thumbRadius, shadowPaint);
    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}