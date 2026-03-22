import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';


// バックグラウンドでメッセージを処理するためのトップレベル関数
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigationScreen(
        onMenuTap: () {},
        onMapTap: () {},
      ),
    );
  }
}

/* ===========================
   NAVIGATION
=========================== */

class MainNavigationScreen extends StatefulWidget {

  final VoidCallback? onMenuTap;
  final VoidCallback? onMapTap;

  const MainNavigationScreen({
    super.key,
    this.onMenuTap,
    this.onMapTap,
  });

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
    setupPush();
  }

  void setupPush() {
    requestPermission();
    getToken();
    FirebaseMessaging.instance.subscribeToTopic("news");
    FirebaseMessaging.instance.subscribeToTopic("all");
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
                              CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.black12,
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
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

class MenuPage extends StatefulWidget {
  final VoidCallback onBack;

  const MenuPage({super.key, required this.onBack});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String selectedCategory = "ALL";
  String selectedFoodCategory = "ALL";
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
        Center(
          child: SizedBox(
            width: 200,
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
                          color: Colors.black.withValues(alpha: 0.3),
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
    .collection('menu_foods')
    .where('isActive', isEqualTo: true)
    .orderBy('order', descending: false)
    .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return Center(child: Text("ERROR: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final filteredDocs = selectedFoodCategory == "ALL"
            ? docs
            : docs.where((d) => d['foodCategory'] == selectedFoodCategory).toList();

        if (docs.isEmpty) {
          return const Center(child: Text("Foodメニューがありません"));
        }

        final categories = docs
            .map((doc) => (doc.data() as Map<String, dynamic>)['foodCategory']?.toString() ?? "")
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();
        categories.sort();

        return Column(
          children: [
            Center(
              child: SizedBox(
                width: 200,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: categories.contains(selectedFoodCategory) ? selectedFoodCategory : "ALL",
                  items: ["ALL", ...categories].map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Center(
                        child: Text(c),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFoodCategory = value!;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: filteredDocs.map((doc) => FoodCard(doc)).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FoodDetailPage extends StatelessWidget {

  final Map<String,dynamic> data;

  const FoodDetailPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF3E2723),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "FOOD",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      backgroundColor: const Color(0xFFF5EFE6),

      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 料理写真
            CachedNetworkImage(
              imageUrl: data['imageUrl'],
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.black12,
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 日本語
                  Text(
                    data['name'] ?? "",
                    style: const TextStyle(
                      fontSize:26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height:6),

                  /// 英語（日本語と同じサイズ）
                  Text(
                    data['name_en'] ?? "",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height:18),

                  /// 説明（濃く見やすく）
                  Text(
                    data['description'] ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height:26),

                  /// 価格（大きく）
                  Text(
                    "¥${data['price']}",
                    style: const TextStyle(
                      fontSize: 32,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF3E2723),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "HOME",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "MENU",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: "NEWS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: "Instagram",
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const FoodCard(this.doc, {super.key});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailPage(data: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: data['imageUrl'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.black12,
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 日本語名
                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  /// 英語名（濃くする）
                  Text(
                    data['name_en'],
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  /// 価格
                  Text(
                    "¥${data['price']}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.black12,
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
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
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  placeholder: (context, url) => Container(
                    color: Colors.black12,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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
