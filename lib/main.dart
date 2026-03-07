import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  runApp(const MyApp());
}

/* ===========================
   MAIN
=========================== */

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
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
    FirebaseMessaging.instance.subscribeToTopic("news");
  }

  void requestPermission() async {
    NotificationSettings settings =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 Permission: ${settings.authorizationStatus}');
  }

  void getToken() async {
    String? token = await _messaging.getToken();
    print("🔥 FCM Token: $token");
  }

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
              print("ConnectionState: ${snapshot.connectionState}");
              print("HasData: ${snapshot.hasData}");
              print("HasError: ${snapshot.hasError}");

              if (snapshot.hasError) {
                return Center(
                  child: Text("ERROR: ${snapshot.error}"),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                    child:
                        CircularProgressIndicator());
              }

              final docs =
                  snapshot.data!.docs;
              print("Docs length: ${docs.length}");

              if (docs.isEmpty) {
                return const Center(
                    child: Text(
                        "スライダー画像がありません"));
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                        height: 35),
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
                        // 画像URLがない場合の安全策
                        final imageUrl = data['imageUrl'] as String?;
                        if (imageUrl == null || imageUrl.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                          child:
                              Image.network(
                            imageUrl,
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
                                  color: _current == e.key
                                      ? Colors.brown.withOpacity(0.9)
                                      : Colors.brown.withOpacity(0.4),
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

class MenuPage extends StatefulWidget {
  final VoidCallback onBack;

  const MenuPage({super.key, required this.onBack});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String selectedCategory = "ALL";
  List<String> drinkCategories = ["ALL"];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('menu_items')
          .where('category', isEqualTo: 'drink')
          .get();

      final categories = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return data.containsKey('drinkCategory')
                ? data['drinkCategory'].toString()
                : null;
          })
          .where((e) => e != null)
          .cast<String>()
          .toSet()
          .toList();

      categories.sort();

      if (mounted) {
        setState(() {
          drinkCategories = ["ALL", ...categories];
        });
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF3E2723),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          "MENU",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.brown,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.brown,
              tabs: [
                Tab(text: "Drink"),
                Tab(text: "Food"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  buildDrinkMenu(),
                  buildFoodMenu(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrinkMenu() {
    Query query = FirebaseFirestore.instance
        .collection('menu_items')
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: 'drink');

    if (selectedCategory != "ALL") {
      query = query.where('drinkCategory', isEqualTo: selectedCategory);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            alignment: Alignment.center,
            items: drinkCategories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Center(
                  child: Text(
                    cat,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: query.orderBy('order').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("ERROR: ${snapshot.error}"));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text("メニューがありません"),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['name']?.toString() ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "¥${data['price']?.toString() ?? '-'}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['name_en']?.toString() ?? "",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data['description'] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFoodMenu() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('menu_items')
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: 'food')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return Center(child: Text("ERROR: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {

            final data = docs[index].data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 画像
                  if (data['imageUrl'] != null && data['imageUrl'] != "")
                    ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: Image.network(
                        data['imageUrl'],
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 日本語 + 価格
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['name'] ?? "",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "¥${data['price']}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        /// 英語
                        Text(
                          data['name_en'] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// 説明
                        Text(
                          data['description'] ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.4,
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('news')
            .where('isPublished', isEqualTo: true)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print("ConnectionState: ${snapshot.connectionState}");
          print("HasData: ${snapshot.hasData}");
          print("HasError: ${snapshot.hasError}");

          if (snapshot.hasError) {
            return Center(
              child: Text("ERROR: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          print("Docs length: ${docs.length}");
          if (docs.isEmpty) {
            return const Center(child: Text('お知らせはありません'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String title = data['title'] ?? 'No Title';
              final String content = data['content'] ?? '';
              final Timestamp? timestamp = data['date'] as Timestamp?;
              final DateTime date = timestamp?.toDate() ?? DateTime.now();
              final String? imageUrl =
                  data.containsKey('imageUrl') ? data['imageUrl'] as String? : null;
              final String dateStr = DateFormat('yyyy.MM.dd').format(date);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(
                        title: title,
                        content: content,
                        date: date,
                        imageUrl: imageUrl,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 画像
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      /// テキスト
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// 日付
                            Text(
                              dateStr,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 6),

                            /// タイトル
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String dateStr = DateFormat('yyyy.MM.dd').format(date);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF3E2723),
        title: const Text(
          'NEWS DETAIL',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const Divider(height: 40, thickness: 1),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
