import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API_Services/Auth_services.dart';
import '../chinh/menu.dart';

class AuthenticatorScreen extends StatefulWidget {
  const AuthenticatorScreen({super.key});

  @override
  State<AuthenticatorScreen> createState() => _AuthenticatorScreenState();
}
 
class _AuthenticatorScreenState extends State<AuthenticatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _isForgetPassword = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _authService = AuthService();
  bool _isLoading = false;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  void _showErrorDialog(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 5,
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            const Text('Error', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [ 
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }
  void _showSuccessDialog(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 5,
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            const Text('Success', style: TextStyle(color: Colors.green)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final email = _emailController.text;
        final password = _passwordController.text;

        Map<String, dynamic> response;
        if (_isForgetPassword) {
          response = await _authService.forgotPassword(email);
          if (response['message'] != null) {
            _showSuccessDialog('Password reset email has been sent if the account exists.');
          }
        } else if (_isLogin) {
          response = await _authService.login(email, password);
          if (response['access_token'] != null) {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MenuScreen(isAuthenticated: true)),
              (route) => false,
            );
          } else {
            _showErrorDialog(response['message'] ?? 'Login failed');
          }
        } else {
          // Ensure passwords match before registration
          if (_passwordController.text != _confirmPasswordController.text) {
            _showErrorDialog('Mật khẩu không trùng khớp');
            setState(() => _isLoading = false);
            return;
          }
          
          response = await _authService.register(email, password);
          if (response['message']?.contains('successfully') ?? false) {
            _showSuccessDialog('Registration successful. Please check your email to verify your account.');
            setState(() => _isLogin = true);
          } else {
            _showErrorDialog(response['message'] ?? 'Registration failed');
          }
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // Create a gradient theme color
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF4776E6),
        Color(0xFF8E54E9),
      ],
    );
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6F0FF),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // Logo Container with shadows and glow
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF8E54E9).withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cloud_done,
                        size: 70,
                        color: Colors.white,
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms)
                      .scale(duration: 250.ms, delay: 100.ms)
                      .shimmer(delay: 600.ms, duration: 900.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Title with shadow
                    Text(
                      _isForgetPassword 
                        ? 'Quên mật khẩu'
                        : (_isLogin ? 'Đăng nhập' : 'Đăng ký'),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        foreground: Paint()..shader = primaryGradient.createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)
                        ),
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.3, end: 0)
                      .shimmer(delay: 600.ms, duration: 900.ms),
                      
                    const SizedBox(height: 12),
                    
                    // Subtitle with soft animation
                    Text(
                      _isForgetPassword 
                        ? 'Nhập email của bạn để khôi phục mật khẩu'
                        : (_isLogin 
                            ? 'Chào mừng quay trở lại! Đăng nhập để tiếp tục' 
                            : 'Tạo tài khoản mới để bắt đầu'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.2, end: 0),
                      
                    const SizedBox(height: 50),
                    
                    // Email Field with animation
                    _buildInputField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'your_email_here@email.com',
                      icon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ).animate()
                      .fadeIn(duration: 300.ms, delay: 150.ms)
                      .slideX(begin: -0.2, end: 0),
                      
                    const SizedBox(height: 16),
                    
                    // Password Field
                    if (!_isForgetPassword)
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Mật khẩu',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscureText: _obscurePassword,
                        toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ).animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                        .slideX(begin: 0.2, end: 0),
                    
                    // Confirm Password Field (only for registration)
                    if (!_isLogin && !_isForgetPassword)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _confirmPasswordController,
                            label: 'Xác nhận mật khẩu',
                            hint: '••••••••',
                            icon: Icons.lock_outlined,
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng xác nhận mật khẩu';
                              }
                              if (value != _passwordController.text) {
                                return 'Mật khẩu không trùng khớp';
                              }
                              return null;
                            },
                          ).animate()
                            .fadeIn(duration: 300.ms, delay: 250.ms)
                            .slideX(begin: 0.2, end: 0),
                        ],
                      ),
                    
                    const SizedBox(height: 40),
                    
                    // Submit Button with gradient
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF8E54E9).withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isForgetPassword
                                    ? 'Gửi email khôi phục'
                                    : (_isLogin ? 'Đăng nhập' : 'Đăng ký'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ).animate()
                      .fadeIn(duration: 300.ms, delay: 300.ms)
                      .slideY(begin: 0.2, end: 0)
                      .shimmer(delay: 500.ms, duration: 600.ms),
                    
                    const SizedBox(height: 24),
                    
                    // Toggle Registration/Login
                    if (!_isForgetPassword)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                ? 'Chưa có tài khoản? '
                                : 'Đã có tài khoản? ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              _isLogin ? 'Đăng ký ngay' : 'Đăng nhập',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()..shader = primaryGradient.createShader(
                                  const Rect.fromLTWH(0.0, 0.0, 100.0, 20.0)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate()
                        .fadeIn(duration: 300.ms, delay: 350.ms),
                    
                    // Forgot Password Toggle
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isForgetPassword = !_isForgetPassword;
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _isForgetPassword
                          ? 'Quay lại đăng nhập'
                          : 'Quên mật khẩu?',
                        style: TextStyle(
                          fontSize: 16,
                          color: _isForgetPassword 
                            ? Colors.grey.shade600
                            : Color(0xFF8E54E9),
                          fontWeight: _isForgetPassword 
                            ? FontWeight.normal
                            : FontWeight.w500,
                        ),
                      ),
                    ).animate()
                      .fadeIn(duration: 300.ms, delay: 400.ms),
                      
                    const SizedBox(height: 20),
                    
                    // Additional design element - divider with text
                    if (_isLogin && !_isForgetPassword)
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Hoặc tiếp tục với',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ).animate()
                        .fadeIn(duration: 300.ms, delay: 450.ms),
                        
                    // Social login buttons
                    if (_isLogin && !_isForgetPassword)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(
                              icon: Icons.g_mobiledata_rounded,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(width: 24),
                            _socialButton(
                              icon: Icons.facebook,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 24),
                            _socialButton(
                              icon: Icons.apple,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ).animate()
                        .fadeIn(duration: 300.ms, delay: 500.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Custom Input Field Widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF8E54E9), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF8E54E9),
          ),
          suffixIcon: isPassword && toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 16,
        ),
        validator: validator,
      ),
    );
  }
  
  // Social login button
  Widget _socialButton({
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    ).animate()
      .scale(duration: 150.ms, curve: Curves.easeOut)
      .fadeIn(duration: 150.ms);
  }
}
 