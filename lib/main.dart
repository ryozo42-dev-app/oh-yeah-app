import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        primaryColor: const Color(0xFF3E2723),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

/* ===========================
   NAVIGATION
=========================== */

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> _getPages() {
    return [
      HomePage(
        onMenuTap: () => setState(() => _selectedIndex = 1),
        onMapTap: _openMap,
      ),
      MenuPage(onBack: () => setState(() => _selectedIndex = 0)),
      NewsPage(onBack: () => setState(() => _selectedIndex = 0)),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _launchUrl('https://www.facebook.com/ohyeahmihama');
    } else if (index == 3) {
      _launchUrl('https://www.instagram.com/oh_yeah_mihama/');
    } else {
      setState(() {
        if (index == 1) {
          _selectedIndex = 2;
        } else {
          _selectedIndex = 0;
        }
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    await launchUrl(url,
        mode: LaunchMode.externalApplication);
  }

  Future<void> _openMap() async {
    final Uri url = Uri.parse(
        'https://maps.apple.com/?q=Cafe+Bar+Oh+Yeah');
    await launchUrl(url,
        mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    int displayIndex =
        (_selectedIndex == 2) ? 1 : 0;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _getPages(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            const Color(0xFF3E2723),
        selectedItemColor: Colors.white,
        unselectedItemColor:
            Colors.grey[400],
        currentIndex: displayIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME'),
          BottomNavigationBarItem(
              icon: Icon(Icons.newspaper),
              label: 'NEWS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.facebook),
              label: 'FACEBOOK'),
          BottomNavigationBarItem(
              icon:
                  Icon(Icons.camera_alt_outlined),
              label: 'Instagram'),
        ],
      ),
    );
  }
}

/* ===========================
   HOME PAGE（Firestore版）
=========================== */

class HomePage extends StatefulWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onMapTap;

  const HomePage(
      {super.key,
      required this.onMenuTap,
      required this.onMapTap});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 160,
          color:
              const Color(0xFF3E2723),
          padding:
              const EdgeInsets.only(
                  top: 40),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        Expanded(
          child: StreamBuilder<
              QuerySnapshot>(
            stream: FirebaseFirestore
                .instance
                .collection('slider_images')
                
                .snapshots(),
            builder:
                (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child:
                        CircularProgressIndicator());
              }

              final docs =
                  snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                    child: Text(
                        "スライダー画像がありません"));
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                        height: 60),
                    CarouselSlider(
                      options:
                          CarouselOptions(
                        height: 320,
                        enlargeCenterPage:
                            true,
                        autoPlay: true,
                        onPageChanged:
                            (index, _) {
                          setState(() =>
                              _current =
                                  index);
                        },
                      ),
                      items: docs
                          .map((doc) {
                        final data =
                            doc.data()
                                as Map<
                                    String,
                                    dynamic>;
                        return ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                          child:
                              Image.network(
                            data['imageUrl'],
                            fit: BoxFit
                                .cover,
                            width: double
                                .infinity,
                          ),
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: docs
                          .asMap()
                          .entries
                          .map((e) =>
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets
                                    .symmetric(
                                    vertical:
                                        20,
                                    horizontal:
                                        4),
                                decoration:
                                    BoxDecoration(
                                  shape:
                                      BoxShape
                                          .circle,
                                  color: Colors.brown.withValues(
  alpha: _current == e.key ? 0.9 : 0.4,
),
                                ),
                              ))
                          .toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets
                          .symmetric(
                              horizontal:
                                  20),
                      child: Row(
                        children: [
                          _btn(
                              Icons
                                  .restaurant_menu,
                              'MENU',
                              widget
                                  .onMenuTap),
                          const SizedBox(
                              width: 15),
                          _btn(
                              Icons.map,
                              'MAP',
                              widget
                                  .onMapTap),
                        ],
                      ),
                    ),
                    const SizedBox(
                        height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _btn(
      IconData icon,
      String label,
      VoidCallback onTap) {
    return Expanded(
      child: Material(
        color:
            const Color(0xFF3E2723),
        borderRadius:
            BorderRadius.circular(
                15),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(
                  15),
          child: Padding(
            padding:
                const EdgeInsets
                    .symmetric(
                        vertical: 22),
            child: Column(
              children: [
                Icon(icon,
                    color:
                        Colors.white,
                    size: 32),
                const SizedBox(
                    height: 8),
                Text(label,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight
                              .bold,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================
   MENU PAGE
=========================== */

class MenuPage extends StatelessWidget {
  final VoidCallback onBack;

  const MenuPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3E2723),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
          title: const Text(
            'OUR MENU',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: Icon(Icons.local_drink),
                text: 'DRINK',
              ),
              Tab(
                icon: Icon(Icons.restaurant),
                text: 'FOOD',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MenuCategoryList(category: 'DRINK'),
            _MenuCategoryList(category: 'FOOD'),
          ],
        ),
      ),
    );
  }
}

class _MenuCategoryList
    extends StatelessWidget {
  final String category;

  const _MenuCategoryList(
      {required this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot>(
      stream: FirebaseFirestore
          .instance
          .collection('oh-yeah-001')
          .where('category',
              isEqualTo: category)
          .snapshots(),
      builder:
          (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child:
                  CircularProgressIndicator());
        }

        final docs =
            snapshot.data!.docs;

        return ListView.builder(
          padding:
              const EdgeInsets.all(
                  15),
          itemCount: docs.length,
          itemBuilder:
              (context, index) {
            final data =
                docs[index].data()
                    as Map<
                        String,
                        dynamic>;
            final String? imageUrl = data['imageUrl'] as String?;

            return Card(
              margin:
                  const EdgeInsets
                      .only(
                          bottom: 20),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(15),
              ),
              child: Column(
                children: [
                  if (imageUrl !=
                      null && imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      height: 200,
                      width: double
                          .infinity,
                      fit: BoxFit
                          .cover,
                    ),
                  Padding(
                    padding:
                        const EdgeInsets
                            .all(15),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          data['name'] ??
                              '',
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: Colors
                                .brown,
                          ),
                        ),
                        Text(
                          '¥${data['price'] ?? ''}',
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: Colors
                                .brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/* ===========================
   NEWS PAGE（ダミー）
=========================== */

class NewsPage extends StatelessWidget {
  final VoidCallback onBack;

  const NewsPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final dummyNews = [
      {
        'title': '新メニュー登場',
        'content': '春の限定メニュー開始！',
        'date': DateTime.now(),
      }
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF3E2723),
        leading: IconButton(
            icon: const Icon(
                Icons.arrow_back,
                color: Colors.white),
            onPressed: onBack),
        title: const Text(
          'NEWS',
          style: TextStyle(
              color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount:
            dummyNews.length,
        itemBuilder:
            (context, index) {
          final item =
              dummyNews[index];
          return ListTile(
            title:
                Text(item['title']?.toString() ?? ''),
            subtitle: Text(
                DateFormat(
                        'yyyy.MM.dd')
                    .format(
                        item['date']
                            as DateTime)),
          );
        },
      ),
    );
  }
}
