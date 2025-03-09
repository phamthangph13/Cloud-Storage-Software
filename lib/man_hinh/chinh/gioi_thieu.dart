import 'package:flutter/material.dart';
import 'dart:math' as math;

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  final List<Founder> _founders = [
    Founder(
      name: 'Phạm Như Thắng',
      role: 'Founder & CEO',
      bio: 'Cloud technology enthusiast with over 10 years of experience in the technology sector. Passionate about building secure and user-friendly cloud solutions.',
      image: 'assets/images/founder1.jpg', // Replace with actual image path
    ),
    Founder(
      name: 'Nguyễn Văn A',
      role: 'Co-Founder & CTO',
      bio: 'Expert in cloud architecture and security systems with a background in cybersecurity. Leading our technical innovation and system design.',
      image: 'assets/images/founder2.jpg', // Replace with actual image path
    ),
    Founder(
      name: 'Trần Thị B',
      role: 'Co-Founder & COO',
      bio: 'Business strategist with experience in scaling technology companies. Manages operations and ensures our services meet the highest standards.',
      image: 'assets/images/founder3.jpg', // Replace with actual image path
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _isScrolled = _scrollController.offset > 50;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: AnimatedOpacity(
          opacity: _isScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: const Text(
            'About Us',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: _isScrolled
            ? Colors.indigo.shade800.withOpacity(0.95)
            : Colors.transparent,
        elevation: _isScrolled ? 4 : 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Animated Header
          SliverToBoxAdapter(
            child: _buildAnimatedHeader(),
          ),

          // Main Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Mission Statement with Animation
              _buildMissionStatement(),
              
              // Company History Section
              _buildHistorySection(),

              // Founders Section
              _buildFoundersSection(),

              // Animated Values Section
              _buildValuesCarousel(),
              
              // Technology Section
              _buildTechnologySection(),

              // Animated Contact Section
              _buildContactSection(),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Gradient
        Container(
          height: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.blue.shade500],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),

        // Animated Logo and Text
        Column(
          children: [
            const SizedBox(height: 100),
            // Animated Logo
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Hero(
                tag: 'companyLogo',
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.cloud,
                    size: 70,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Company Name with Fade Animation
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
              ),
              child: const Text(
                'Yune Cloud Storage',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Tagline with Slide Animation
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
                ),
              ),
              child: const Text(
                'Your Secure Cloud Storage Solution',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),

        // Animated Particles (optional)
        Positioned.fill(
          child: AnimatedParticles(),
        ),
      ],
    );
  }

  Widget _buildMissionStatement() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade500, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade700.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_objects_outlined, color: Colors.yellow.shade200, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'To provide secure, reliable, and accessible cloud storage solutions that empower individuals and businesses to store, manage, and share their digital assets with confidence.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Innovating since 2020',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    final milestones = [
      {
        'year': '2020',
        'title': 'Foundation',
        'description': 'Yune Cloud Storage was founded with a vision to create secure, accessible cloud storage for everyone.'
      },
      {
        'year': '2021',
        'title': 'First Product Launch',
        'description': 'Released our first cloud storage solution with advanced security features and 15GB free storage.'
      },
      {
        'year': '2022',
        'title': 'Business Expansion',
        'description': 'Launched enterprise-level storage solutions and expanded our team to 50+ cloud experts.'
      },
      {
        'year': '2023',
        'title': 'Global Reach',
        'description': 'Expanded to 15 countries with data centers in Asia, Europe, and North America.'
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Our Journey',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.blue.shade500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: milestones.length,
                itemBuilder: (context, index) {
                  final milestone = milestones[index];
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.shade300,
                          Colors.indigo.shade500,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              milestone['year'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 22),
                              Text(
                                milestone['title'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  milestone['description'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoundersSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'Our Founders',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Meet the team behind Yune Cloud',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 420,
            child: PageView.builder(
              itemCount: _founders.length,
              controller: PageController(viewportFraction: 0.85),
              itemBuilder: (context, index) {
                final founder = _founders[index];
                return _buildFounderCard(founder, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFounderCard(Founder founder, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (index * 200)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Profile Image with Gradient Overlay
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                color: Colors.indigo.shade200,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: Image.asset(
                        'assets/images/profile_placeholder.jpg', // Placeholder if image doesn't exist
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.indigo.shade200,
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.indigo.shade50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.indigo.shade900.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          founder.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          founder.role,
                          style: TextStyle(
                            color: Colors.blue.shade100,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bio
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    height: 80,
                    child: SingleChildScrollView(
                      child: Text(
                        founder.bio,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.business_center, Colors.blue.shade700),
                      const SizedBox(width: 12),
                      _buildSocialButton(Icons.email, Colors.red.shade400),
                      const SizedBox(width: 12),
                      _buildSocialButton(Icons.language, Colors.green.shade600),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // Handle social link tap
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildValuesCarousel() {
    final values = [
      ValueItem(
        icon: Icons.security,
        title: 'Security',
        description: 'Your data security is our top priority with end-to-end encryption and advanced access controls.',
        color: Colors.blue,
      ),
      ValueItem(
        icon: Icons.speed,
        title: 'Performance',
        description: 'Fast and reliable access to your files from anywhere with optimized data transfer speeds.',
        color: Colors.green,
      ),
      ValueItem(
        icon: Icons.people,
        title: 'User-Focused',
        description: 'Built with our users in mind, ensuring intuitive interfaces and seamless experiences.',
        color: Colors.orange,
      ),
      ValueItem(
        icon: Icons.sync,
        title: 'Innovation',
        description: 'Constantly evolving and improving our technology to stay ahead of industry standards.',
        color: Colors.purple,
      ),
      ValueItem(
        icon: Icons.public,
        title: 'Accessibility',
        description: 'Making cloud storage accessible to everyone with adaptable solutions for all needs.',
        color: Colors.teal,
      ),
      ValueItem(
        icon: Icons.support_agent,
        title: 'Support',
        description: '24/7 customer support with dedicated specialists to solve your technical issues.',
        color: Colors.red,
      ),
    ];

    return Column(
      children: [
        const SizedBox(height: 40),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Column(
            children: [
              Text(
                'Our Values',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.blue.shade500,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Container(
          height: 350,
          child: ModernValuesCarousel(values: values),
        ),
      ],
    );
  }

  Widget _buildValueCard(ValueItem value) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: value.color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: value.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              value.icon,
              color: value.color,
              size: 35,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologySection() {
    final technologies = [
      {'name': 'Cloud Infrastructure', 'icon': Icons.cloud_outlined},
      {'name': 'Data Encryption', 'icon': Icons.enhanced_encryption},
      {'name': 'AI-Powered Search', 'icon': Icons.search},
      {'name': 'Automated Backups', 'icon': Icons.backup},
      {'name': 'Multiple Device Sync', 'icon': Icons.devices},
      {'name': 'Real-time Collaboration', 'icon': Icons.group_work},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Our Technology',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.blue.shade500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Powered by cutting-edge technologies to provide you with the best cloud storage experience',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: technologies.map((tech) => _buildTechItem(
                (tech['name'] as String?) ?? '',
                (tech['icon'] as IconData?) ?? Icons.code,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechItem(String name, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.indigo.shade600,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.headset_mic, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                Text(
                  'Get In Touch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAnimatedContactItem(Icons.email, 'Email', 'support@yunecloud.com'),
            _buildAnimatedContactItem(Icons.phone, 'Phone', '+1 (555) 123-4567'),
            _buildAnimatedContactItem(Icons.location_on, 'Address', '123 Cloud Street, Tech City'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Handle contact form action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact form coming soon!')),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Us a Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedContactItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.indigo.shade700, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Founder {
  final String name;
  final String role;
  final String bio;
  final String image;

  Founder({
    required this.name,
    required this.role,
    required this.bio,
    required this.image,
  });
}

class ValueItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  ValueItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class AnimatedParticles extends StatefulWidget {
  const AnimatedParticles({Key? key}) : super(key: key);

  @override
  State<AnimatedParticles> createState() => _AnimatedParticlesState();
}

class _AnimatedParticlesState extends State<AnimatedParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Create particles
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 400,
        ),
        size: (3 + _random.nextDouble() * 5).toDouble(),
        opacity: 0.1 + _random.nextDouble() * 0.2,
        speed: 0.2 + _random.nextDouble() * 0.4,
        angle: _random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var particle in _particles) {
          particle.update(_controller.value);
        }
        return CustomPaint(
          painter: ParticlePainter(particles: _particles),
          size: const Size(400, 400),
        );
      },
    );
  }
}

class Particle {
  Offset position;
  final double size;
  final double opacity;
  final double speed;
  final double angle;
  late double initialX;
  late double initialY;

  Particle({
    required this.position,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.angle,
  }) {
    initialX = position.dx;
    initialY = position.dy;
  }

  void update(double progress) {
    double movement = speed * 50 * progress;
    double offsetX = math.cos(angle) * movement;
    double offsetY = math.sin(angle) * movement;
    
    // Create a cycle effect
    double cycleX = initialX + offsetX;
    double cycleY = initialY + offsetY;
    
    // Reset position if particle moves off-screen
    if (cycleX < 0 || cycleX > 400) {
      cycleX = initialX;
    }
    if (cycleY < 0 || cycleY > 400) {
      cycleY = initialY;
    }
    
    position = Offset(cycleX, cycleY);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CircularCarousel extends StatefulWidget {
  final List<Widget> items;

  const CircularCarousel({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  State<CircularCarousel> createState() => _CircularCarouselState();
}

class _CircularCarouselState extends State<CircularCarousel> {
  // Current selected item index
  int _currentIndex = 0;
  
  // Scroll controller for handling drag gestures
  late final ScrollController _scrollController;
  
  // Arc parameters
  final double _arcRadius = 300.0;
  final double _arcAngle = math.pi / 1.5; // 120 degrees in radians
  
  // Arc view height - defines the height of the carousel
  final double _arcViewHeight = 280.0;
  
  // Track last drag position for swipe logic
  double _lastDragPos = 0.0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_handleScroll);
  }
  
  void _handleScroll() {
    // Circular scrolling effect happens in actual widget building
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // Handle taps to select items
  void _handleItemTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  // Handle horizontal drag gestures to rotate the carousel
  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    // Calculate the amount of drag
    double dragDistance = details.primaryDelta ?? 0;
    
    // Ensure we have some drag amount
    if (dragDistance.abs() < 0.5) return;
    
    // Adjust current index based on drag direction
    setState(() {
      _lastDragPos += dragDistance;
      
      // When drag amount reaches a threshold, move to next/previous item
      if (_lastDragPos.abs() > 20) {
        int direction = _lastDragPos > 0 ? -1 : 1;
        int newIndex = _currentIndex + direction;
        
        // Enable circular scrolling
        if (newIndex < 0) {
          newIndex = widget.items.length - 1; // Wrap to last item
        } else if (newIndex >= widget.items.length) {
          newIndex = 0; // Wrap to first item
        }
        
        _currentIndex = newIndex;
        
        // Reset drag position
        _lastDragPos = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get available width for layout calculations
    final double width = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        // The arc carousel view
        SizedBox(
          height: _arcViewHeight,
          width: width,
          child: GestureDetector(
            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
            onHorizontalDragEnd: (details) {
              // Reset drag position at end of gesture
              _lastDragPos = 0;
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Create each carousel item in its position on the arc
                ...List.generate(widget.items.length, (index) {
                  // Calculate angle based on position relative to current index
                  double itemAngle = _calculateAngle(index);
                  
                  // Calculate distance from center for scaling effect
                  double normalizedDistance = (index - _currentIndex).abs() / (widget.items.length / 2);
                  normalizedDistance = normalizedDistance.clamp(0.0, 1.0);
                  
                  // Calculate scale based on distance from center
                  double scale = 1.0 - (normalizedDistance * 0.3);
                  
                  // Calculate opacity based on distance from center
                  double opacity = 1.0 - (normalizedDistance * 0.7);
                  
                  // Calculate position on arc
                  double x = _arcRadius * math.sin(itemAngle);
                  double y = -_arcRadius * (1 - math.cos(itemAngle)) + 80;
                  
                  // Calculate rotation angle (items face toward center)
                  double rotationAngle = -itemAngle;
                  
                  // Skip rendering cards that are too far from center to improve performance
                  if (normalizedDistance > 0.8) {
                    return const SizedBox.shrink();
                  }
                  
                  // Make sure edge cards stay on screen
                  double adjustedX = width / 2 + x;
                  
                  // Ensure card is at least partially visible at edges
                  adjustedX = adjustedX.clamp(
                    -(110 * scale) + 30, // Allow at least 30px on screen from left
                    width - (110 * scale) - 30 // Allow at least 30px on screen from right
                  );
                  
                  return Positioned(
                    left: adjustedX - (110 * scale), // Position with adjustment
                    top: y,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      builder: (context, value, child) {
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // Perspective
                            ..translate(0.0, 0.0, 100.0 * (1 - opacity)) // Push back items farther from center
                            ..rotateY(rotationAngle * 0.7) // Rotate toward center
                            ..scale(scale * value),
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: opacity,
                            child: GestureDetector(
                              onTap: () => _handleItemTap(index),
                              child: SizedBox(
                                width: 220,
                                child: widget.items[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                
                // Optional: Add a central indicator line
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.indigo.shade600.withOpacity(0.0),
                          Colors.indigo.shade600,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Indicators
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentIndex == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? Colors.indigo.shade600
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Calculate the angle for an item based on its position
  double _calculateAngle(int index) {
    // Center the angle calculation around the current index
    int relativeIndex = index - _currentIndex;
    
    // Use a smaller divisor to ensure edge items are still visible within the arc
    // Instead of dividing by (length-1), we divide by a larger number to compress the arc
    double divisor = math.max(widget.items.length * 1.5, 3.0);
    
    // Calculate angle within the arc range but with better distribution
    double angleFraction = relativeIndex / divisor;
    
    // Scale the arc angle to ensure first and last items are still visible
    double scaledArcAngle = _arcAngle * 0.8;
    
    // Convert to radians within arc range
    return -scaledArcAngle / 2 + angleFraction * _arcAngle;
  }
}

// Modern Values Carousel - New Implementation
class ModernValuesCarousel extends StatefulWidget {
  final List<ValueItem> values;

  const ModernValuesCarousel({
    Key? key,
    required this.values,
  }) : super(key: key);

  @override
  State<ModernValuesCarousel> createState() => _ModernValuesCarouselState();
}

class _ModernValuesCarouselState extends State<ModernValuesCarousel> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  int _currentPage = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _currentPage,
    );
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _pageController.addListener(_pageListener);
  }

  void _pageListener() {
    int page = _pageController.page?.round() ?? 0;
    if (_currentPage != page && !_isAnimating) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Modern Card Slider
        SizedBox(
          height: 300, // Increase height slightly to accommodate content
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            itemCount: widget.values.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildModernCard(
                widget.values[index],
                index,
                (_pageController.page ?? _currentPage.toDouble()) - index,
              );
            },
          ),
        ),
        
        // Page Indicators with Animation
        const SizedBox(height: 20),
        AnimatedIndicators(
          itemCount: widget.values.length,
          currentIndex: _currentPage,
          onTap: (index) {
            _isAnimating = true;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            ).then((_) {
              _isAnimating = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildModernCard(ValueItem value, int index, double position) {
    // Calculate values for transition effects
    final double distanceFromCenter = position.abs();
    final bool isCenter = distanceFromCenter < 0.5;
    
    // Scale and opacity effects
    final double scale = 1.0 - (distanceFromCenter * 0.12);
    final double opacity = math.max(0.4, 1.0 - (distanceFromCenter * 0.6));
    
    // Calculate the offset for the parallax effect
    final double parallaxOffset = position * 20;
    
    // Calculate shadow intensity based on elevation
    final double shadowOpacity = isCenter ? 0.3 : 0.1;
    final double blurRadius = isCenter ? 20.0 : 10.0;
    
    // Calculate rotation for 3D effect (subtle)
    final double rotationY = position * 0.1; // Subtle rotation
    
    // Gradient change based on position
    final List<Color> gradientColors = [
      value.color.withOpacity(isCenter ? 0.8 : 0.5),
      value.color.withOpacity(isCenter ? 0.6 : 0.3),
    ];
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
      builder: (context, animValue, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..scale(scale * animValue)
            ..rotateY(rotationY),
          child: Opacity(
            opacity: opacity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: isCenter ? 5 : 15,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: value.color.withOpacity(shadowOpacity),
                    blurRadius: blurRadius,
                    offset: const Offset(0, 10),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background with gradient
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: double.infinity,
                      height: 220, // Set a fixed height to ensure consistency
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isCenter 
                              ? [Colors.white, Colors.white]
                              : gradientColors,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative elements
                          Positioned(
                            right: -20,
                            top: -20,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: value.color.withOpacity(isCenter ? 0.06 : 0.0),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -30,
                            bottom: -30,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: value.color.withOpacity(isCenter ? 0.04 : 0.0),
                              ),
                            ),
                          ),
                          
                          // Content with Parallax Effect - Now in a SingleChildScrollView to handle overflow
                          SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(), // Disable actual scrolling
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(20), // Further reduce padding
                              child: Transform.translate(
                                offset: Offset(position < 0 ? -parallaxOffset : parallaxOffset, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Use min size to avoid overflow
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Icon with background
                                    Container(
                                      padding: const EdgeInsets.all(12), // Smaller padding
                                      decoration: BoxDecoration(
                                        color: isCenter 
                                            ? value.color.withOpacity(0.1)
                                            : value.color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Icon(
                                        value.icon,
                                        size: 30, // Slightly smaller icon
                                        color: isCenter ? value.color : Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 12), // Reduced spacing
                                    
                                    // Title
                                    Text(
                                      value.title,
                                      style: TextStyle(
                                        fontSize: 20, // Slightly smaller font
                                        fontWeight: FontWeight.bold,
                                        color: isCenter ? Colors.black87 : Colors.white,
                                      ),
                                    ),
                                    
                                    // Animated underline
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(vertical: 6), // Reduced margin
                                      height: 3,
                                      width: isCenter ? 40 : 0,
                                      decoration: BoxDecoration(
                                        color: value.color,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    
                                    // Description with constrained height
                                    SizedBox(
                                      height: 80, // Fixed height for description
                                      child: Text(
                                        value.description,
                                        style: TextStyle(
                                          fontSize: 13, // Smaller font size
                                          height: 1.3, // Tighter line height
                                          color: isCenter ? Colors.black54 : Colors.white.withOpacity(0.8),
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Interactive overlay
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          if (index != _currentPage) {
                            _isAnimating = true;
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                            ).then((_) {
                              _isAnimating = false;
                            });
                          }
                        },
                        splashColor: value.color.withOpacity(0.1),
                        highlightColor: value.color.withOpacity(0.05),
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
}

// Animated Indicators for Modern Carousel
class AnimatedIndicators extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedIndicators({
    Key? key,
    required this.itemCount,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool isActive = currentIndex == index;
        
        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isActive ? 24 : 8,
            decoration: BoxDecoration(
              color: isActive 
                  ? Colors.indigo.shade600
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}