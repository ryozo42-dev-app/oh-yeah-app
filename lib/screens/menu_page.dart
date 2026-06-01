import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oh_yeah/screens/food_detail_page.dart';
import 'package:oh_yeah/screens/news_list_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:oh_yeah/app_language.dart';

class MenuPage extends StatefulWidget {
  final String selectedLanguageMode;

  const MenuPage({super.key, required this.selectedLanguageMode});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {

  final NumberFormat formatter = NumberFormat('#,###');
  final supabase = Supabase.instance.client;
  RealtimeChannel? menuChannel;

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

    menuChannel = supabase.channel('menu-realtime');

    menuChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'world_drinks',
          callback: (payload) async {

            if (!mounted) return;

            await loadDrinks();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'world_foods',
          callback: (payload) async {

            if (!mounted) return;

            await loadFoods();
          },
        )
        .subscribe((status, error) {
        });
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
        .from('world_drinks')
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

    data.sort((a, b) {
      // display_order順
      return (a['display_order'] ?? 9999)
          .compareTo(
            b['display_order'] ?? 9999,
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
        .from('world_foods')
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

    data.sort((a, b) {
      // display_order順
      return (a['display_order'] ?? 9999)
          .compareTo(
            b['display_order'] ?? 9999,
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

  Future<void> refreshMenu() async {
    await Future.wait([
      loadDrinks(),
      loadFoods(),
    ]);
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
  void dispose() {
    menuChannel?.unsubscribe();
    _tabController.dispose();
    super.dispose();
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
                    builder: (_) => NewsListPage(
                      selectedLanguageMode: widget.selectedLanguageMode,
                    ),
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
                label: 'HOME', // 必要に応じてここも多言語化
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: 'NEWS', // 必要に応じてここも多言語化
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.facebook),
                label: 'FACEBOOK',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.instagram),
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

          tabs: const [Tab(text: 'Drink'), Tab(text: 'Food')],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // =====================
          // DRINK
          // =====================
          RefreshIndicator(
            onRefresh: refreshMenu,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                ...filteredDrinks.map(
                  (item) => _drinkCard(item),
                ),
              ],
            ),
          ),

          // =====================
          // FOOD
          // =====================
          RefreshIndicator(
            onRefresh: refreshMenu,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                ...filteredFoods.map(
                  (item) => _foodCard(item),
                ),
              ],
            ),
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
        width: 260,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
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
            items: categories.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Center(
                  child: Text(c),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF5C3A2E),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
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
                if (AppLanguage.selectedLanguageMode == 'western') ...[
                  // Japanese name
                  Text(
                    item['name_ja'] ?? '',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  // English name
                  Text(
                    item['name_en'] ?? '',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
                if (AppLanguage.selectedLanguageMode == 'asian') ...[
                  Text(
                    item['name_ja'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    item['name_zh'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    item['name_ko'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(item['description'] ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '¥${formatter.format(item['price'] ?? 0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
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
            builder: (_) => FoodDetailPage(
              data: item,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF5C3A2E),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (item['imageurl'] != null && item['imageurl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  10,
                ),
                child: Image.network(
                  item['imageurl'],
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (AppLanguage.selectedLanguageMode == 'western') ...[
                    // Japanese name
                    Text(
                      item['name_ja'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // English name
                    Text(
                      item['name_en'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                  if (AppLanguage.selectedLanguageMode == 'asian') ...[
                    Text(
                      item['name_ja'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item['name_zh'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item['name_ko'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    item['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '¥${formatter.format(item['price'] ?? 0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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