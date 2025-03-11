import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentSheet extends StatefulWidget {
  final double storageAmount;
  final double pricePerGB;
  final String selectedPaymentMethod;
  final Map<String, dynamic> bankInfo;

  const PaymentSheet({
    super.key,
    required this.storageAmount,
    required this.pricePerGB,
    required this.selectedPaymentMethod,
    required this.bankInfo,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  String _selectedPaymentMethod = '';
  final String _transactionId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.selectedPaymentMethod;
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )} VND';
  }

  String _formatStorageSize(double value) {
    if (value < 1000) {
      if (value == value.round()) {
        return '${value.toInt()} GB';
      } else {
        return '${value.toStringAsFixed(1)} GB';
      }
    } else {
      double tbValue = value / 1000;
      if (tbValue == tbValue.round()) {
        return '${tbValue.toInt()} TB';
      } else {
        return '${tbValue.toStringAsFixed(1)} TB';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.storageAmount * widget.pricePerGB;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Chi tiết thanh toán',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order details
                  _buildOrderDetails(totalAmount),
                  const SizedBox(height: 24),

                  // Payment methods
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),

                  // Selected payment method details
                  if (_selectedPaymentMethod == 'QR BANKING')
                    _buildQRBankingDetails()
                  else if (_selectedPaymentMethod == 'Chuyển Khoản')
                    _buildBankTransferDetails(),

                  const SizedBox(height: 32),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle payment confirmation
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng hoàn tất thanh toán theo hướng dẫn'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận thanh toán',
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
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Dung lượng:',
            _formatStorageSize(widget.storageAmount),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Đơn giá:',
            '${_formatCurrency(widget.pricePerGB)}/GB',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            'Tổng tiền:',
            _formatCurrency(totalAmount),
            isTotal: true,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Mã giao dịch:',
            _transactionId,
            showCopy: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false, bool showCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
            if (showCopy) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép mã giao dịch'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(
                  Icons.copy,
                  size: 18,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phương thức thanh toán',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodButton('QR BANKING'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentMethodButton('Chuyển Khoản'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodButton(String method) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.blue.shade200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          method,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQRBankingDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hướng dẫn thanh toán QR',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 16),
          // QR Code placeholder
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.qr_code_2,
                size: 150,
                color: Colors.blue.shade200,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep('Mở ứng dụng ngân hàng của bạn'),
          _buildInstructionStep('Quét mã QR'),
          _buildInstructionStep('Kiểm tra thông tin và xác nhận thanh toán'),
        ],
      ),
    );
  }

  Widget _buildBankTransferDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin chuyển khoản',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                _buildBankInfoRow('Ngân hàng:', widget.bankInfo['bank']),
                const SizedBox(height: 8),
                _buildBankInfoRow('Tên TK:', widget.bankInfo['accountName']),
                const SizedBox(height: 8),
                _buildBankInfoRow(
                  'Số TK:',
                  widget.bankInfo['accountNumber'],
                  showCopy: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep('Mở ứng dụng ngân hàng của bạn'),
          _buildInstructionStep('Chọn chuyển khoản và nhập thông tin'),
          _buildInstructionStep('Nhập đúng số tiền cần thanh toán'),
          _buildInstructionStep('Ghi nội dung CK: $_transactionId'),
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(String label, String value, {bool showCopy = false}) {
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
              if (showCopy)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
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

  Widget _buildInstructionStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 