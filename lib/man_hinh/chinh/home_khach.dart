import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class HomeKhachScreen extends StatefulWidget {
  const HomeKhachScreen({super.key});

  @override
  State<HomeKhachScreen> createState() => _HomeKhachScreenState();
}

class _HomeKhachScreenState extends State<HomeKhachScreen> {
  final List<String> _testimonials = [
    "The best cloud storage solution I've ever used! - John D.",
    "Secure, fast, and incredibly user-friendly. - Sarah M.",
    "I can access all my files anywhere, anytime. - Michael T.",
    "Customer support is amazing and responsive. - Lisa K.",
  ];

  int _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Yune Cloud Storage',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade500,
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.5],
              ),
            ),
          ),
          
          SingleChildScrollView(
            child: Column(
              children: [
                // Top space for app bar
                const SizedBox(height: 100),
                
                // Hero section with Lottie animation
                _buildHeroSection().animate().fade(duration: 800.ms).slide(begin: const Offset(0, 0.2), curve: Curves.easeOutQuad),
                
                // Advertisement slider
                _buildAdvertSlider().animate().fade(duration: 800.ms, delay: 200.ms),
                
                // Features section with improved design
                _buildFeaturesSection().animate().fade(duration: 800.ms, delay: 400.ms),
                
                // Testimonials
                _buildTestimonialsSection().animate().fade(duration: 800.ms, delay: 600.ms),
                
                // Plans section
                _buildPlansSection().animate().fade(duration: 800.ms, delay: 800.ms),
                
                // Enhanced Call to Action
                _buildCallToAction().animate().fade(duration: 800.ms, delay: 1000.ms),
                
                // Footer
                _buildFooterSection().animate().fade(duration: 800.ms, delay: 1200.ms),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Secure Cloud Storage For Everyone',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 600.ms).move(begin: const Offset(-30, 0)),
                    const SizedBox(height: 15),
                    const Text(
                      'Store, share, and access your files from anywhere',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).move(begin: const Offset(-20, 0)),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to get started page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).move(begin: const Offset(0, 20)),
                  ],
                ),
              ),
              SizedBox(
                height: 150,
                width: 120,
                child: Lottie.asset(
                  'assets/lottie/cloud_storage.json',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/img/cloud_storage.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.cloud,
                        size: 100,
                        color: Colors.white,
                      );
                    },
                  );
                },
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 400.ms).scale(delay: 400.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertSlider() {
    final List<Map<String, dynamic>> adSlides = [
      {
        'title': 'Special Offer',
        'subtitle': 'Get 50% off on annual plans!',
        'color': Colors.orange.shade800,
        'icon': Icons.local_offer,
      },
      {
        'title': 'New Feature',
        'subtitle': 'AI-powered organization',
        'color': Colors.purple.shade700,
        'icon': Icons.auto_awesome,
      },
      {
        'title': 'Enterprise',
        'subtitle': 'Secure storage for business',
        'color': Colors.teal.shade700,
        'icon': Icons.business,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 130, // Fixed container height
      child: CarouselSlider(
        options: CarouselOptions(
          height: 120, // Reduced carousel height
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.85,
          autoPlayInterval: const Duration(seconds: 5),
          onPageChanged: (index, reason) {
            setState(() {
              _currentCarouselIndex = index;
            });
          },
        ),
        items: adSlides.map((slide) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      slide['color'],
                      slide['color'].withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                // Simplify to use direct constraints instead of nesting
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 120,
                    child: Stack(
                      children: [
                        // Background icon
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            slide['icon'],
                            size: 70, // Further reduced
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column with title and subtitle
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Title row
                                    Row(
                                      children: [
                                        Icon(
                                          slide['icon'],
                                          color: Colors.white,
                                          size: 16, // Further reduced
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            slide['title'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16, // Further reduced
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 4), // Minimal spacing
                                    
                                    // Subtitle
                                    Text(
                                      slide['subtitle'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11, // Further reduced
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Small spacer
                              const SizedBox(width: 8),
                              
                              // Right aligned button
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle action for this advertisement
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: slide['color'],
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    minimumSize: const Size(50, 20),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text('Learn', style: TextStyle(fontSize: 9)),
                                ),
                              ),
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
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.star, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 15),
              const Text(
                'Our Premium Features',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildFeatureCard(
                'Security',
                Icons.security,
                'End-to-end encryption',
                Colors.blue.shade700,
              ),
              _buildFeatureCard(
                'Fast Access',
                Icons.speed,
                'Quick access anywhere',
                Colors.green.shade600,
              ),
              _buildFeatureCard(
                'Sharing',
                Icons.share,
                'Custom permissions',
                Colors.orange.shade600,
              ),
              _buildFeatureCard(
                'Multi-platform',
                Icons.devices,
                'All your devices',
                Colors.purple.shade600,
              ),
              _buildFeatureCard(
                'Recovery',
                Icons.restore,
                '30-day file recovery',
                Colors.teal.shade600,
              ),
              _buildFeatureCard(
                'AI Features',
                Icons.folder_special,
                'Smart organization',
                Colors.indigo.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.format_quote, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 15),
              const Text(
                'What Our Users Say',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 120,
                autoPlay: true,
                viewportFraction: 1.0,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, reason) {
                  // You can use this to show current testimonial indicator
                },
              ),
              items: _testimonials.map((testimonial) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.format_quote, color: Colors.blue.shade200, size: 24),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              testimonial,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.monetization_on, color: Colors.green.shade600),
              ),
              const SizedBox(width: 15),
              const Text(
                'Choose Your Plan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPlanCard(
                  'Basic',
                  'Free',
                  ['5 GB Storage', 'Basic Security', 'Limited Sharing'],
                  Colors.blue.shade50,
                  Colors.blue.shade700,
                  false,
                ),
                const SizedBox(width: 15),
                _buildPlanCard(
                  'Pro',
                  '\$9.99/mo',
                  ['100 GB Storage', 'Advanced Security', 'Unlimited Sharing'],
                  Colors.purple.shade50,
                  Colors.purple.shade700,
                  true,
                ),
                const SizedBox(width: 15),
                _buildPlanCard(
                  'Enterprise',
                  '\$19.99/mo',
                  ['1 TB Storage', 'Max Security', 'Team Features'],
                  Colors.green.shade50,
                  Colors.green.shade700,
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade300.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Start Your Cloud Journey Today',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Join thousands of satisfied users',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to sign up page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Sign Up Free',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 15),
              OutlinedButton(
                onPressed: () {
                  // Navigate to learn more page
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Learn More',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(Icons.support_agent, color: Colors.blue, size: 22),
                  SizedBox(height: 6),
                  Text('24/7 Support', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.security, color: Colors.blue, size: 22),
                  SizedBox(height: 6),
                  Text('100% Secure', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.speed, color: Colors.blue, size: 22),
                  SizedBox(height: 6),
                  Text('Fast Access', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Text(
            '© ${DateTime.now().year} Yune Cloud Storage. All Rights Reserved.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, String description, Color color) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildPlanCard(String title, String price, List<String> features, 
                         Color bgColor, Color textColor, bool isPopular) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isPopular ? Border.all(color: textColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontSize: 16,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 15),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: textColor, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              // Handle plan selection
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Select Plan', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutQuad);
  }
}