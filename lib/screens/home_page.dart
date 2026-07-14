import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oh_yeah/screens/news_list_page.dart';
import 'package:oh_yeah/screens/menu_page.dart';
import 'package:oh_yeah/screens/news_detail_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oh_yeah/app_language.dart';
import 'package:oh_yeah/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  int _current = 0;

  bool hasUnreadNews = false;

  late final PageController _controller;

  final supabase = Supabase.instance.client;

  final Color headerColor = const Color(0xFF4E3329);

  final Color buttonColor = const Color(0xFF5C3A2E);

  final Color bgColor = const Color(0xFFD9CFBE);

  List<dynamic> _docs = [];

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      viewportFraction: 0.85,
      initialPage: 5000,
    );

    _fetchSliderImages();

    _checkUnreadNews();

    _startAutoSlide();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.subscribe(
      this,
      ModalRoute.of(context)!,
    );
  }

  Future<void> _fetchSliderImages() async {
    try {
      debugPrint(
        "SLIDER START",
      );

      final response =
          await supabase.from('slider_images').select().order('order');

      debugPrint(
        response.toString(),
      );

      if (!mounted) return;

      setState(() {
        _docs = response;
      });
    } catch (e) {
      debugPrint(
        "SLIDER ERROR",
      );

      debugPrint(
        e.toString(),
      );
    }
  }

  Future<void> _checkUnreadNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lastRead = prefs.getString('last_news_read_at');

      final latestNews = await supabase
          .from('world_news')
          .select('createdat')
          .order('createdat', ascending: false)
          .limit(1)
          .single();

      final String? latestCreatedAt = latestNews['createdat'];

      if (latestCreatedAt != null) {
        setState(() {
          if (lastRead == null) {
            hasUnreadNews = true;
          } else {
            final latest = DateTime.parse(
              latestCreatedAt,
            );

            final read = DateTime.parse(
              lastRead,
            );

            hasUnreadNews = latest.isAfter(read);
          }
        });
      }

      debugPrint(
        "CHECK NEWS: $latestNews",
      );
    } catch (e) {
      debugPrint(
        "CHECK NEWS ERROR: $e",
      );
    }
  }

  void _startAutoSlide() {
    Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        if (!mounted) {
          timer.cancel();

          return;
        }

        if (_docs.isEmpty) return;

        final nextPage = _controller.page!.round() + 1;

        if (_controller.hasClients) {
          _controller.animateToPage(
            nextPage,
            duration: const Duration(
              milliseconds: 500,
            ),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  Future<void> _openUrl(
    String url,
  ) async {
    final uri = Uri.parse(Uri.encodeFull(url));

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint(
        'URLを開けませんでした: $e',
      );
    }
  }

  @override
  void didPopNext() {
    _fetchSliderImages();
    _checkUnreadNews();

    debugPrint(
      "HOME RETURN -> RELOAD",
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: bgColor,
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
              _bottomItem(
                icon: Icons.home,
                label: "HOME",
                isActive: true,
                onTap: () {},
              ),
              _bottomItem(
                icon: Icons.article,
                label: "NEWS",
                showBadge: hasUnreadNews,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();

                  await prefs.setString(
                    'last_news_read_at',
                    DateTime.now().toIso8601String(),
                  );

                  setState(() {
                    hasUnreadNews = false;
                  });

                  if (!context.mounted) return;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsListPage(
                        selectedLanguageMode: AppLanguage.selectedLanguageMode,
                      ),
                    ),
                  );
                },
              ),
              _bottomItem(
                icon: Icons.facebook,
                label: "FACEBOOK",
                onTap: () {
                  _openUrl(
                    'https://www.facebook.com/share/1AtrS2hBh9/',
                  );
                },
              ),
              _bottomItem(
                icon: FontAwesomeIcons.instagram,
                label: "Instagram",
                onTap: () {
                  _openUrl(
                    'https://www.instagram.com/oh_yeah_mihama',
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // HEADER
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
                        const SizedBox(
                          height: 20,
                        ),

                        // LANGUAGE
                        Center(
                          child: Container(
                            width: 260,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: buttonColor,
                              borderRadius: BorderRadius.circular(
                                18,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: AppLanguage.selectedLanguageMode,
                                isExpanded: true,
                                dropdownColor: buttonColor,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'western',
                                    child: Text(
                                      '🌍 日本語 / English',
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'asian',
                                    child: Text(
                                      '🌍 繁體中文 / 한국어',
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    AppLanguage.selectedLanguageMode = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 26,
                        ),

                        // SLIDER
                        SizedBox(
                          height: 260,
                          child: PageView.builder(
                            reverse: false,
                            controller: _controller,
                            itemCount: 100000,
                            onPageChanged: (index) {
                              setState(() {
                                _current = index % _docs.length;
                              });
                            },
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              final realIndex = index % _docs.length;

                              final data = _docs[realIndex];

                              final imageUrl = data['imageUrl'] as String?;

                              final newsId = data['newsId'];

                              final isLinkActive = data['isActive'] ?? true;

                              if (imageUrl == null || imageUrl.isEmpty) {
                                return const SizedBox();
                              }

                              return _SliderItem(
                                imageUrl: imageUrl,
                                newsId: newsId,
                                isLinkActive: isLinkActive,
                              );
                            },
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        SmoothPageIndicator(
                          controller: _controller,
                          count: _docs.length,
                          textDirection: TextDirection.ltr,
                          effect: WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: buttonColor,
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // MENU / MAP
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              _menuButton(
                                icon: Icons.restaurant_menu,
                                label: "MENU",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MenuPage(
                                        selectedLanguageMode:
                                            AppLanguage.selectedLanguageMode,
                                      ),
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
                                  final mapUrl = defaultTargetPlatform ==
                                          TargetPlatform.iOS
                                      ? 'https://maps.apple.com/?q=Oh Yeah ! 沖縄県中頭郡北谷町美浜9-39 2F'
                                      : 'https://maps.google.com/?q=Oh Yeah ! 沖縄県中頭郡北谷町美浜9-39 2F';

                                  _openUrl(mapUrl);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 40,
                        ),
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
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 28,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
    bool showBadge = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
                if (showBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              label,
              style: const TextStyle(
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

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    _controller.dispose();

    super.dispose();
  }
}

// SLIDER ITEM
class _SliderItem extends StatefulWidget {
  final String imageUrl;

  final dynamic newsId;

  final bool isLinkActive;

  const _SliderItem({
    required this.imageUrl,
    required this.newsId,
    required this.isLinkActive,
  });

  @override
  State<_SliderItem> createState() => _SliderItemState();
}

class _SliderItemState extends State<_SliderItem> {
  double _scale = 1.0;

  void _onTapDown(
    TapDownDetails _,
  ) {
    if (!mounted || !widget.isLinkActive) {
      return;
    }

    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(
    TapUpDetails _,
  ) {
    if (!mounted || !widget.isLinkActive) {
      return;
    }

    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    if (!mounted || !widget.isLinkActive) {
      return;
    }

    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: widget.isLinkActive && widget.newsId != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewsDetailPage(
                    id: widget.newsId.toString(),
                  ),
                ),
              );
            }
          : null,
      onTapDown: widget.isLinkActive ? _onTapDown : null,
      onTapUp: widget.isLinkActive ? _onTapUp : null,
      onTapCancel: widget.isLinkActive ? _onTapCancel : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(
          milliseconds: 150,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              20,
            ),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
