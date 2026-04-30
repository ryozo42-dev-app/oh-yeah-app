import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oh_yeah/screens/news_list_page.dart';
import 'package:oh_yeah/screens/menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 1000;

  final PageController _controller =
      PageController(initialPage: 1000, viewportFraction: 0.85);

  final supabase = Supabase.instance.client;

  final Color headerColor = const Color(0xFF4E3329);
  final Color buttonColor = const Color(0xFF5C3A2E);
  final Color bgColor = const Color(0xFFD9CFBE);

  List<dynamic> _docs = [];

  @override
  void initState() {
    super.initState();
    _fetchSliderImages();
    _startAutoSlide();
  }

  Future<void> _fetchSliderImages() async {
    final response = await supabase
        .from('slider_images')
        .select()
        .order('order');

    if (!mounted) return;

    setState(() {
      _docs = response;
    });
  }

  void _startAutoSlide() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted || _docs.isEmpty) continue;

      final nextPage = _current + 1;

      if (_controller.hasClients) {
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      if (mounted) {
        setState(() => _current = nextPage);
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // 🔥 BottomNavigation追加
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          border: const Border(
            top: BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              // HOME
              _bottomItem(
                icon: Icons.home,
                label: "HOME",
                isActive: true,
                onTap: () {},
              ),

              // NEWS
              _bottomItem(
                icon: Icons.article,
                label: "NEWS",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewsListPage(),
                    ),
                  );
                },
              ),

              // FACEBOOK
              _bottomItem(
                icon: Icons.facebook,
                label: "FACEBOOK",
                onTap: () {
                  _openUrl(
                    'https://www.facebook.com/share/1AtrS2hBh9/',
                  );
                },
              ),

              // INSTAGRAM
              _bottomItem(
                icon: Icons.camera_alt,
                label: "Instagram",
                onTap: () {
                  _openUrl(
                    'https://www.instagram.com/oh_yeah_mihama?igsh=MWo2NmY4NmNhZXl1cQ==',
                  );
                },
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [

          // ヘッダー
          Container(
            width: double.infinity,
            height: 200,
            color: headerColor,
            padding: const EdgeInsets.only(
              top: 45,
              bottom: 15,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Expanded(
            child: _docs.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [

                        const SizedBox(height: 30),

                        // スライダー
                        SizedBox(
                          height: 260,
                          child: PageView.builder(
                            controller: _controller,
                            onPageChanged: (index) {
                              setState(() {
                                _current = index;
                              });
                            },
                            itemBuilder: (context, index) {

                              final realIndex =
                                  index % _docs.length;

                              final data =
                                  _docs[realIndex];

                              final imageUrl =
                                  data['imageUrl']
                                      as String?;

                              if (imageUrl == null ||
                                  imageUrl.isEmpty) {
                                return const SizedBox();
                              }

                              return AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 300,
                                ),
                                margin:
                                    const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 260,
                                    child:
                                        CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // インジケーター
                        SmoothPageIndicator(
                          controller: _controller,
                          count: _docs.length,
                          effect: WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor:
                                buttonColor,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // MENU / MAP
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [

                              _menuButton(
                                icon:
                                    Icons.restaurant_menu,
                                label: "MENU",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MenuPage(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              _menuButton(
                                icon: Icons.map,
                                label: "MAP",
                                onTap: () {
                                  _openUrl(
                                    'https://www.google.com/maps/search/?api=1&query=沖縄県中頭郡北谷町美浜9-39',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: buttonColor,
        borderRadius:
            BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(18),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 28,
            ),
            child: Column(
              children: [

                Icon(
                  icon,
                  color: Colors.white,
                  size: 34,
                ),

                const SizedBox(height: 10),

                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}