import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  final List<String> categories = ['All', 'AI', 'Software', 'Cloud'];
  int _currentCarouselIndex = 0;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'News & Updates',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
              
                  ],
                ),
                centerTitle: false,
              ),
            ),

            // Promotion Carousel
            SliverToBoxAdapter(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      CarouselSlider(
                        items: [
                          _buildPromotionCard(
                            'Special Offer!',
                            'Get 1GB storage for only 2,500 VND',
                            'assets/images/storage_promo1.jpg',
                            Colors.blue.shade700,
                          ),
                          _buildPromotionCard(
                            'Limited Time Deal!',
                            'Buy 10GB, get 2GB free',
                            'assets/images/storage_promo2.jpg',
                            Colors.purple.shade700,
                          ),
                          _buildPromotionCard(
                            'Premium Storage',
                            'Cloud backup with 99.9% uptime',
                            'assets/images/storage_promo3.jpg',
                            Colors.green.shade700,
                          ),
                        ],
                        options: CarouselOptions(
                          height: 180,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: true,
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          viewportFraction: 0.9,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentCarouselIndex = index;
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [0, 1, 2].map((index) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentCarouselIndex == index
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Category Tabs - Special design
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.purple.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: categories.map((category) {
                    bool isSelected = _selectedCategory == category;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? _getCategoryColor(category) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Icon(
                                _getCategoryIcon(category),
                                color: Colors.white,
                                size: 16,
                              ),
                            if (isSelected) const SizedBox(width: 4),
                            Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // News Content - Grid Layout
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final newsItems = _getNewsItems(_selectedCategory);
                    if (index >= newsItems.length) return null;
                    
                    final newsItem = newsItems[index];
                    return _buildNewsGridCard(
                      title: newsItem['title'],
                      description: newsItem['description'],
                      category: newsItem['category'],
                      date: newsItem['date'],
                      imageUrl: newsItem['imageUrl'],
                    );
                  },
                  childCount: _getNewsItems(_selectedCategory).length,
                ),
              ),
            ),
            
            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
      
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'AI':
        return Colors.blue;
      case 'Software':
        return Colors.green;
      case 'Cloud':
        return Colors.purple;
      default:
        return Colors.blue.shade700;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'AI':
        return Icons.psychology;
      case 'Software':
        return Icons.code;
      case 'Cloud':
        return Icons.cloud;
      default:
        return Icons.apps;
    }
  }

  Widget _buildPromotionCard(String title, String subtitle, String imagePath, Color color) {
    // Fallback image URL in case asset doesn't exist
    const fallbackImageUrl = 'https://picsum.photos/seed/promo/600/300';
    
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              fallbackImageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: color.withOpacity(0.2),
                  child: Icon(Icons.storage, size: 50, color: color),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            height: 180,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getNewsItems(String category) {
    final List<Map<String, dynamic>> allNews = [
      {
        'title': 'ChatGPT 5.0 Release Preview',
        'description': 'The newest model from OpenAI brings unprecedented reasoning capabilities and multilingual improvements.',
        'category': 'AI',
        'date': '12/08/2023',
        'imageUrl': 'https://picsum.photos/seed/ai1/600/300',
      },
      {
        'title': 'Microsoft Introduces Azure AI Computing Platform',
        'description': 'New infrastructure designed specifically for AI workloads with 200% performance increase.',
        'category': 'AI',
        'date': '10/08/2023',
        'imageUrl': 'https://picsum.photos/seed/ai2/600/300',
      },
      {
        'title': 'Flutter 4.0 Released with Improved Performance',
        'description': 'The latest update focuses on performance optimizations and new material design components.',
        'category': 'Software',
        'date': '08/08/2023',
        'imageUrl': 'https://picsum.photos/seed/software1/600/300',
      },
      {
        'title': 'GitHub Copilot Enterprise Now Available',
        'description': 'Bring the power of AI-assisted development to your entire organization with enterprise controls.',
        'category': 'Software',
        'date': '05/08/2023',
        'imageUrl': 'https://picsum.photos/seed/software2/600/300',
      },
      {
        'title': 'AWS Announces 50% Price Cut on Storage Solutions',
        'description': 'Amazon Web Services reduces prices on S3 and EBS storage services to compete with Google Cloud.',
        'category': 'Cloud',
        'date': '04/08/2023',
        'imageUrl': 'https://picsum.photos/seed/cloud1/600/300',
      },
      {
        'title': 'Google Cloud Launches New Asian Data Centers',
        'description': 'Two new regions in Vietnam and Thailand aim to reduce latency for Southeast Asian customers.',
        'category': 'Cloud',
        'date': '01/08/2023',
        'imageUrl': 'https://picsum.photos/seed/cloud2/600/300',
      },
      {
        'title': 'New Quantum Computing Breakthrough',
        'description': 'Scientists achieve quantum supremacy with 1000-qubit processor.',
        'category': 'AI',
        'date': '02/08/2023',
        'imageUrl': 'https://picsum.photos/seed/ai3/600/300',
      },
      {
        'title': 'React 19 Beta Released',
        'description': 'The popular JavaScript library gets major performance improvements and new features.',
        'category': 'Software',
        'date': '03/08/2023',
        'imageUrl': 'https://picsum.photos/seed/software3/600/300',
      },
    ];

    if (category == 'All') {
      return allNews;
    } else {
      return allNews.where((news) => news['category'] == category).toList();
    }
  }

  Widget _buildNewsGridCard({
    required String title,
    required String description,
    required String category,
    required String date,
    required String imageUrl,
  }) {
    Color categoryColor = _getCategoryColor(category);
    IconData categoryIcon = _getCategoryIcon(category);

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: imageUrl,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error_outline, size: 40),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    // Footer row with date and icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 14),
                          color: categoryColor,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}