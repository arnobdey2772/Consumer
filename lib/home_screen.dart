import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'region_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  final PageController _categoryPageController = PageController();
  final GlobalKey _complaintCardKey = GlobalKey();
  Timer? _timer;
  Timer? _bannerTimer;
  Timer? _categoryTimer;
  String _currentTime = "";
  int _currentPage = 0;
  int _currentCategoryPage = 0;

  final List<String> _bannerImages = [
    'image/background (2).png',
    'image/banner2.png',
  ];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateTime();
        });
      }
    });
    _startBannerTimer();
    _startCategoryTimer();
  }

  void _startCategoryTimer() {
    _categoryTimer?.cancel();
    _categoryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_categoryPageController.hasClients) {
        _currentCategoryPage = (_currentCategoryPage + 1) % 2;
        _categoryPageController.animateToPage(
          _currentCategoryPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _bannerImages.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? "PM" : "AM";
    // Using seconds to show it's updating in real-time as requested
    _currentTime = "আজ, ${hour.toString().padLeft(2, '0')}:$minute:$second $ampm";
  }

  void _showRegionSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "আপনার অঞ্চল নির্বাচন করুন",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: ListView(
                shrinkWrap: true,
                children: [
                  "ঢাকা", "চট্টগ্রাম", "রাজশাহী", "খুলনা", "বরিশাল", "সিলেট", "রংপুর", "ময়মনসিংহ"
                ].map((region) => ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: Color(0xFF1B5E20)),
                  title: Text(region, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    context.read<RegionProvider>().updateRegion(region);
                    Navigator.pop(context);
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToComplaint() {
    final context = _complaintCardKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showComplaintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("অভিযোগ জমা দিন", style: TextStyle(color: Color(0xFFD32F2F))),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "আপনার নাম",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "অভিযোগের বিবরণ",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("বাতিল"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("আপনার অভিযোগটি সফলভাবে জমা দেওয়া হয়েছে।")),
              );
            },
            child: const Text("জমা দিন", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "নোটিফিকেশন সেটআপ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("প্রতিদিনের বাজার দর"),
              value: true,
              onChanged: (val) {},
              activeThumbColor: const Color(0xFF1B5E20),
              activeTrackColor: const Color(0xFF1B5E20).withValues(alpha: 0.5),
            ),
            SwitchListTile(
              title: const Text("জরুরি বিজ্ঞপ্তি"),
              value: true,
              onChanged: (val) {},
              activeThumbColor: const Color(0xFF1B5E20),
              activeTrackColor: const Color(0xFF1B5E20).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("সংরক্ষণ করুন", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerTimer?.cancel();
    _categoryTimer?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    _categoryPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Responsive logic for categories
    final int categoryCrossAxisCount = screenWidth > 800 ? 8 : (screenWidth > 600 ? 6 : 4);
    final double categoryHeight = screenWidth > 800 ? 150 : (screenWidth > 600 ? 180 : 300);
    final double categoryAspectRatio = screenWidth > 800 ? 1.0 : (screenWidth > 600 ? 0.85 : 0.7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.asset(
              'image/logo.jpeg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Consumer Guardian BD",
              style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "সচেতন ভোক্তা, নিরাপদ বাজার",
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Colors.black, size: 28),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // 1. Header Section: Info Card + Complaint Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Info Card (Location & Time)
                    Expanded(
                      flex: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            // Location Section
                            Expanded(
                              flex: 4,
                              child: InkWell(
                                onTap: _showRegionSelection,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "আপনার অঞ্চল",
                                      style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on, color: Color(0xFF1B5E20), size: 14),
                                        const SizedBox(width: 2),
                                        Flexible(
                                          child: Consumer<RegionProvider>(
                                            builder: (context, provider, child) {
                                              return Text(
                                                provider.selectedRegion,
                                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87),
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      "অঞ্চল পরিবর্তন করুন >",
                                      style: TextStyle(fontSize: 8, color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 25,
                              color: Colors.grey.shade200,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            // Price Update Section
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "দাম আপডেট",
                                    style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _currentTime,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green.shade800, size: 8),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            "আপডেট হয়েছে",
                                            style: TextStyle(color: Colors.green.shade800, fontSize: 8, fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Complaint Button (Outside the main info card)
                    Expanded(
                      flex: 3,
                      child: AnimatedComplaintButton(onTap: _scrollToComplaint),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Banner Area (Slideshow)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      _startBannerTimer();
                    },
                    itemCount: _bannerImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Image.asset(
                            _bannerImages[index],
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 160,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                                    SizedBox(height: 8),
                                    Text("ইমেজ লোড করা সম্ভব হয়নি",
                                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Overlay content for the first banner (optional, can be different for each)
                          if (index == 0)
                            Container(
                              height: 160,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "নিয়মিত বাজার দর জানুন",
                                    style: TextStyle(
                                      color: Color(0xFF1B5E20),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    "সঠিক তথ্য, সঠিক সিদ্ধান্ত",
                                    style: TextStyle(
                                      color: Color(0xFF1B5E20),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "দেশের প্রতিটি জেলার নিত্যপ্রয়োজনীয় পণ্যের\nবাজার দর এখন হাতের মুঠোয়।",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Add specific text or overlay for the second banner if needed
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Complaint Summary Section (Design as requested)
            _buildComplaintSummary(),

            const SizedBox(height: 8),

            // Scrolling Notification Bar
            const ScrollingNotice(
              text: "বিশেষ বিজ্ঞপ্তি: নিত্যপ্রয়োজনীয় পণ্যের সঠিক বাজার দর জানতে আমাদের সাথেই থাকুন। অসাধু ব্যবসায়ীদের থেকে সাবধান থাকুন এবং অভিযোগ জানাতে লাল বাটনে ক্লিক করুন।",
            ),

            const SizedBox(height: 8),

            // 4. Categories Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    "নিত্যপ্রয়োজনীয় পণ্য",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.whatshot, color: Colors.orange.shade900, size: 20),
                ],
              ),
            ),

            // 5. Categories Slideshow
            SizedBox(
              height: categoryHeight,
              child: PageView(
                controller: _categoryPageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentCategoryPage = index;
                  });
                  _startCategoryTimer();
                },
                children: [
                  // Page 1
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      padding: const EdgeInsets.only(top: 5),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: categoryCrossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 10,
                      childAspectRatio: categoryAspectRatio,
                      children: [
                        _buildCategory("চাল", Icons.rice_bowl_outlined),
                        _buildCategory("ডাল", Icons.eco_outlined),
                        _buildCategory("সবজি", Icons.grass),
                        _buildCategory("তেল", Icons.opacity),
                        _buildCategory("মাছ ও মাংস", Icons.set_meal),
                        _buildCategory("ডিম", Icons.egg_outlined),
                        _buildCategory("মসলা", Icons.grain_outlined),
                        _buildCategory("ফল", Icons.apple_outlined),
                      ],
                    ),
                  ),
                  // Page 2
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      padding: const EdgeInsets.only(top: 5),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: categoryCrossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 10,
                      childAspectRatio: categoryAspectRatio,
                      children: [
                        _buildCategory("নুন", Icons.opacity),
                        _buildCategory("দুধ", Icons.water_drop_outlined),
                        _buildCategory("শুকনো খাবার", Icons.fastfood_outlined),
                        _buildCategory("পরিষ্কারক", Icons.cleaning_services_outlined),
                        _buildCategory("বেকারি", Icons.bakery_dining_outlined),
                        _buildCategory("ঔষধ", Icons.medication_outlined),
                        _buildCategory("প্রসাধনী", Icons.face_retouching_natural_outlined),
                        _buildCategory("আরও", Icons.grid_view, onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("সকল ক্যাটাগরি দেখার ফিচারটি শীঘ্রই যুক্ত করা হবে।")),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 5. Info/Service Cards Section
            _buildInfoCards(),

            const SizedBox(height: 12),

            // 7. Bottom Action Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    key: _complaintCardKey,
                    child: _buildActionCard(
                      "অভিযোগ করুন",
                      "সমস্যা জানাতে ক্লিক করুন",
                      Icons.assignment_late_rounded,
                      Colors.red.shade50,
                      const Color(0xFFD32F2F),
                      () => _showComplaintDialog(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      "বাজার দর আপডেট",
                      "নোটিফিকেশন পেতে চান?",
                      Icons.notifications_active_rounded,
                      const Color(0xFFE8F5E9),
                      const Color(0xFF1B5E20),
                      () => _showNotificationSettings(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green.shade800,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "হোম"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "প্রোফাইল"),
        ],
      ),
    );
  }

  Widget _buildComplaintSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "আমার অভিযোগের সংক্ষিপ্ত চিত্র",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryCard(
                "মোট অভিযোগ",
                "৫",
                Icons.description_outlined,
                const Color(0xFFF1F7FF),
                const Color(0xFF2196F3),
              ),
              const SizedBox(width: 10),
              _buildSummaryCard(
                "তদন্তাধীন",
                "১",
                Icons.search_rounded,
                const Color(0xFFF8F7FF),
                const Color(0xFF673AB7),
              ),
              const SizedBox(width: 10),
              _buildSummaryCard(
                "নিষ্পত্তি হয়েছে",
                "২",
                Icons.check_circle_outline_rounded,
                const Color(0xFFF2FAF5),
                const Color(0xFF4CAF50),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color bgColor, Color iconColor) {
    return Expanded(
      child: InkWell(
        onTap: () {}, // Add navigation to relevant complaint list
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(icon, size: 24, color: iconColor.withValues(alpha: 0.6)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildServiceCard(
            "অন্যান্য অভিযোগ",
            "নকল, মেয়াদোত্তীর্ণ,\nওজন কম ইত্যাদি",
            Icons.verified_user,
            const Color(0xFFF5F3FF),
            const Color(0xFF6366F1),
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _buildServiceCard(
            "ভোক্তা শিক্ষা",
            "আপনার অধিকার\nসম্পর্কে জানুন",
            Icons.menu_book,
            const Color(0xFFF0FDF4),
            const Color(0xFF22C55E),
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _buildServiceCard(
            "নোটিশ ও ঘোষণা",
            "সরকারি নোটিশ ও\nসর্বশেষ আপডেট",
            Icons.campaign,
            const Color(0xFFFFFBEB),
            const Color(0xFFF59E0B),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String sub, IconData icon, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String label, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
            ),
            child: Icon(icon, color: Colors.orange.shade700, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String desc, IconData icon, Color bgColor, Color accentColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "আরও দেখুন",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accentColor),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: accentColor, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollingNotice extends StatefulWidget {
  final String text;
  const ScrollingNotice({super.key, required this.text});

  @override
  State<ScrollingNotice> createState() => _ScrollingNoticeState();
}

class _ScrollingNoticeState extends State<ScrollingNotice> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          top: BorderSide(color: Colors.green.shade100, width: 0.5),
          bottom: BorderSide(color: Colors.green.shade100, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: double.infinity,
            color: const Color(0xFF1B5E20),
            alignment: Alignment.center,
            child: const Text(
              "বিজ্ঞপ্তি",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Positioned(
                            left: constraints.maxWidth - (_controller.value * (constraints.maxWidth + 1000)),
                            top: 8,
                            child: child!,
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  softWrap: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedComplaintButton extends StatefulWidget {
  final VoidCallback onTap;
  const AnimatedComplaintButton({super.key, required this.onTap});

  @override
  State<AnimatedComplaintButton> createState() => _AnimatedComplaintButtonState();
}

class _AnimatedComplaintButtonState extends State<AnimatedComplaintButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _dotColorAnimation;
  late Animation<Color?> _bgColorAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _dotColorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.green,
    ).animate(_controller);

    _bgColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.red.shade50.withValues(alpha: 0.8),
    ).animate(_controller);

    _glowAnimation = Tween<double>(begin: 2.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            decoration: BoxDecoration(
              color: _bgColorAnimation.value,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _dotColorAnimation.value!.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _dotColorAnimation.value!.withValues(alpha: 0.2),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: _glowAnimation.value / 4,
                )
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _dotColorAnimation.value,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _dotColorAnimation.value!.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      "অভিযোগ করুন",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
