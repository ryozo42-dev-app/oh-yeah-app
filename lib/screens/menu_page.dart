import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oh_yeah/screens/food_detail_page.dart';
import 'package:oh_yeah/screens/news_list_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {

  final supabase = Supabase.instance.client;

  late TabController _tabController;

  List<dynamic> drinks = [];
  List<dynamic> foods = [];

  List<String> drinkCategories = ['ALL'];
  List<String> foodCategories = ['ALL'];

  String selectedDrinkCategory = 'ALL';
  String selectedFoodCategory = 'ALL';

  final Color headerColor = const Color(0xFF4E3329);
  final Color buttonColor = const Color(0xFF5C3A2E);
  final Color bgColor = const Color(0xFFD9CFBE);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    loadDrinks();
    loadFoods();
  }

  // =========================
  // DRINK
  // =========================

  Future<void> loadDrinks() async {

    final categoryData = await supabase
        .from('drink_categories')
        .select()
        .order('display_order');

    final data = await supabase
        .from('menu_drinks')
        .select()
        .eq('isactive', true);

    categoryData.sort((a, b) {
      return (a['display_order'] ?? 999).compareTo(
        b['display_order'] ?? 999,
      );
    });

    final categories = categoryData
        .map((e) => e['name'].toString())
        .where((e) => e != 'ALL')
        .toList();

    final orderMap = <String, int>{};
    for (final item in categoryData) {
      orderMap[item['name'].toString().toLowerCase()] =
          item['display_order'] ?? 999;
    }

    data.sort((a, b) {
      final categoryA = orderMap[a['drinkcategory']
                  ?.toString()
                  .toLowerCase()] ??
          999;

      final categoryB = orderMap[b['drinkcategory']
                  ?.toString()
                  .toLowerCase()] ??
          999;

      // display_order順
      if (categoryA != categoryB) {
        return categoryA.compareTo(categoryB);
      }

      // 名前順
      return (a['name'] ?? '')
          .toString()
          .compareTo(
            (b['name'] ?? '')
                .toString(),
          );
    });

    if (mounted) {
      setState(() {

        drinks = data;

        drinkCategories = [
          'ALL',
          ...categories,
        ];

        if (!drinkCategories.contains(
          selectedDrinkCategory,
        )) {
          selectedDrinkCategory = 'ALL';
        }
      });
    }
  }

  // =========================
  // FOOD
  // =========================

  Future<void> loadFoods() async {

    final categoryData = await supabase
        .from('food_categories')
        .select()
        .order('display_order');

    final data = await supabase
        .from('menu_foods')
        .select()
        .eq('isactive', true);

    categoryData.sort((a, b) {
      return (a['display_order'] ?? 999).compareTo(
        b['display_order'] ?? 999,
      );
    });

    final categories = categoryData
        .map((e) => e['name'].toString())
        .where((e) => e != 'ALL')
        .toList();

    final orderMap = <String, int>{};
    for (final item in categoryData) {
      orderMap[item['name'].toString().toLowerCase()] =
          item['display_order'] ?? 999;
    }

    data.sort((a, b) {
      final categoryA = orderMap[a['foodcategory']
                  ?.toString()
                  .toLowerCase()] ??
          999;

      final categoryB = orderMap[b['foodcategory']
                  ?.toString()
                  .toLowerCase()] ??
          999;

      // display_order順
      if (categoryA != categoryB) {
        return categoryA.compareTo(categoryB);
      }

      // 名前順
      final nameCompare =
          (a['name'] ?? '')
              .toString()
              .compareTo(
                (b['name'] ?? '')
                    .toString(),
              );

      if (nameCompare != 0) {
        return nameCompare;
      }

      // 価格順
      return (a['price'] ?? 0)
          .compareTo(
            b['price'] ?? 0,
          );
    });

    if (mounted) {
      setState(() {

        foods = data;

        foodCategories = [
          'ALL',
          ...categories,
        ];

        if (!foodCategories.contains(
          selectedFoodCategory,
        )) {
          selectedFoodCategory = 'ALL';
        }
      });
    }
  }

  // =========================
  // FILTER
  // =========================

  List<dynamic> get filteredDrinks {

    if (selectedDrinkCategory == 'ALL') {
      return drinks;
    }

    return drinks.where((e) {

      return e['drinkcategory']
          .toString()
          .toLowerCase() ==
          selectedDrinkCategory
              .toLowerCase();

    }).toList();
  }

  List<dynamic> get filteredFoods {

    if (selectedFoodCategory == 'ALL') {
      return foods;
    }

    return foods.where((e) {

      return e['foodcategory']
          .toString()
          .toLowerCase() ==
          selectedFoodCategory
              .toLowerCase();

    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bgColor,

      bottomNavigationBar: Container(
        color: headerColor,
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: 0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: headerColor,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 13,
            unselectedFontSize: 13,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            iconSize: 30,
            onTap: (index) async {
              if (index == 0) {
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                );
              }
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NewsListPage(),
                  ),
                );
              }
              if (index == 2) {
                launchUrl(
                  Uri.parse(
                    'https://www.facebook.com/share/1AtrS2hBh9/',
                  ),
                );
              }
              if (index == 3) {
                launchUrl(
                  Uri.parse(
                    'https://www.instagram.com/oh_yeah_mihama?igsh=MWo2NmY4NmNhZXl1cQ==',
                  ),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: 'NEWS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.facebook),
                label: 'FACEBOOK',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Instagram',
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: headerColor,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFFF7F5F4),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'MENU',
          style: TextStyle(
            color: Color(0xFFF7F5F4),
            fontWeight: FontWeight.bold,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,

          tabs: const [
            Tab(text: 'Drink'),
            Tab(text: 'Food'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,

        children: [

          // =====================
          // DRINK
          // =====================

          Column(
            children: [

              const SizedBox(height: 10),

              _categoryDropdown(
                categories: drinkCategories,
                value: selectedDrinkCategory,
                onChanged: (value) {
                  setState(() {
                    selectedDrinkCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredDrinks.length,

                  itemBuilder: (context, index) {

                    final item =
                        filteredDrinks[index];

                    return _drinkCard(item);
                  },
                ),
              ),
            ],
          ),

          // =====================
          // FOOD
          // =====================

          Column(
            children: [

              const SizedBox(height: 10),

              _categoryDropdown(
                categories: foodCategories,
                value: selectedFoodCategory,
                onChanged: (value) {
                  setState(() {
                    selectedFoodCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredFoods.length,

                  itemBuilder: (context, index) {

                    final item =
                        filteredFoods[index];

                    return _foodCard(item);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // DROPDOWN
  // =========================

  Widget _categoryDropdown({
    required List<String> categories,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {

    return Center(
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF1ECEF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            alignment: Alignment.center,
            items: categories.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Center(
                  child: Text(
                    e,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // =========================
  // DRINK CARD
  // =========================

  Widget _drinkCard(dynamic item) {

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F4),
        borderRadius:
            BorderRadius.circular(14),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  item['name'] ?? '',

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  item['name_en'] ?? '',

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  item['description'] ?? '',

                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '¥${item['price']}',

            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // FOOD CARD
  // =========================

  Widget _foodCard(dynamic item) {

    return GestureDetector(

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FoodDetailPage(
              data: item,
            ),
          ),
        );
      },

      child: Container(
        margin:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),

        padding:
            const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: const Color(0xFFF7F5F4),
          borderRadius:
              BorderRadius.circular(14),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          children: [

            if (item['image_url'] != null &&
                item['image_url']
                    .toString()
                    .isNotEmpty)

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),

                child: Image.network(
                  item['image_url'],

                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),

            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    item['name'] ?? '',

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item['name_en'] ?? '',

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item['description'] ?? '',

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Text(
              '¥${item['price']}',

              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}