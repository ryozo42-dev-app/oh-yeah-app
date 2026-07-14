import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oh_yeah/screens/food_detail_page.dart';
import 'package:oh_yeah/screens/news_list_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:oh_yeah/app_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final List<String> _favoriteKeys = [];
  bool _favoriteHintVisible = false;
  bool _favoriteSparkleVisible = false;
  bool _favoriteHintPlayed = false;
  String? _favoriteAnimationKey;
  bool _favoriteAnimationVisible = false;
  String? _addNoticeMessage;
  bool _showAddNotice = false;

  final Color headerColor = const Color(0xFF4E3329);
  final Color buttonColor = const Color(0xFF5C3A2E);
  final Color bgColor = const Color(0xFFD9CFBE);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    loadDrinks();
    loadFoods();
    _loadFavorites();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showFavoritePrompt();
      }
    });

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
          table: 'drink_categories',
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
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'food_categories',
          callback: (payload) async {
            if (!mounted) return;
            await loadFoods();
          },
        )
        .subscribe((status, error) {});
  }

  Future<void> loadDrinks() async {
    final categoryData =
        await supabase.from('drink_categories').select().order('display_order');

    final data =
        await supabase.from('world_drinks').select().eq('isactive', true);

    categoryData.sort((a, b) {
      return (a['display_order'] ?? 999).compareTo(
        b['display_order'] ?? 999,
      );
    });

    final categories = categoryData
        .map((e) => e['name'].toString())
        .where((e) => e != 'ALL')
        .toList();

    final categoryOrder =
        categoryData.map((e) => e['name'].toString()).toList();

    data.sort((a, b) {
      final idxA = categoryOrder.indexOf(
        a['drinkcategory']?.toString() ?? '',
      );

      final idxB = categoryOrder.indexOf(
        b['drinkcategory']?.toString() ?? '',
      );

      if (idxA != idxB) {
        return idxA.compareTo(idxB);
      }

      return (a['display_order'] ?? 9999).compareTo(
        b['display_order'] ?? 9999,
      );
    });

    if (mounted) {
      setState(() {
        drinks = data;

        drinkCategories = ['ALL', ...categories];

        if (!drinkCategories.contains(selectedDrinkCategory)) {
          selectedDrinkCategory = 'ALL';
        }
      });
    }
  }

  Future<void> loadFoods() async {
    final categoryData =
        await supabase.from('food_categories').select().order('display_order');

    final data =
        await supabase.from('world_foods').select().eq('isactive', true);

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
      final idxA = categories.indexOf(
        a['foodcategory'] ?? '',
      );

      final idxB = categories.indexOf(
        b['foodcategory'] ?? '',
      );

      if (idxA != idxB) {
        return idxA.compareTo(idxB);
      }

      return (a['display_order'] ?? 9999).compareTo(
        b['display_order'] ?? 9999,
      );
    });

    if (mounted) {
      setState(() {
        foods = data;

        foodCategories = ['ALL', ...categories];

        if (!foodCategories.contains(selectedFoodCategory)) {
          selectedFoodCategory = 'ALL';
        }
      });
    }
  }

  Future<void> refreshMenu() async {
    await Future.wait([loadDrinks(), loadFoods()]);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final savedKeys = prefs.getStringList('favorite_keys') ?? <String>[];

    if (!mounted) return;

    setState(() {
      _favoriteKeys
        ..clear()
        ..addAll(savedKeys);
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_keys', _favoriteKeys);
  }

  bool _isFavorite(dynamic item, String type) {
    final key = '$type:${item['id']}';
    return _favoriteKeys.contains(key);
  }

  Future<void> _toggleFavorite(dynamic item, String type) async {
    final key = '$type:${item['id']}';
    final alreadyFavorite = _favoriteKeys.contains(key);

    if (alreadyFavorite) {
      _favoriteKeys.remove(key);
      await _saveFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('お気に入りから削除しました'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    _favoriteKeys.add(key);
    await _saveFavorites();

    if (mounted) {
      setState(() {
        _favoriteAnimationKey = key;
        _favoriteAnimationVisible = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('お気に入りに追加しました'),
          duration: Duration(seconds: 1),
        ),
      );

      Future.delayed(const Duration(milliseconds: 220), () {
        if (mounted) {
          setState(() {
            _favoriteAnimationVisible = false;
          });
        }
      });
    }
  }

  Future<void> _showFavoritePrompt() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('⭐ お気に入り'),
          content: const Text('お気に入りメニューを表示しますか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoritePage(
                      drinks: drinks,
                      foods: foods,
                      favoriteKeys: _favoriteKeys,
                      isFavorite: _isFavorite,
                      onToggleFavorite: _toggleFavorite,
                    ),
                  ),
                );
              },
              child: const Text('お気に入りを見る'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('通常メニューを見る'),
            ),
          ],
        );
      },
    );
  }

  void _showAddNoticeToast(dynamic item) {
    final locale = AppLanguage.selectedLanguageMode;
    String firstLine;
    String secondLine;

    final nameJa = item['name_ja']?.toString() ?? '';
    final nameEn = item['name_en']?.toString() ?? '';
    final nameZh = item['name_zh']?.toString() ?? '';
    final nameKo = item['name_ko']?.toString() ?? '';

    final displayName = locale == 'western'
        ? (nameJa.isNotEmpty ? nameJa : '商品')
        : locale == 'asian'
            ? (nameZh.isNotEmpty ? nameZh : '商品')
            : (nameJa.isNotEmpty ? nameJa : '商品');

    final secondLineName = locale == 'western'
        ? (nameEn.isNotEmpty ? nameEn : displayName)
        : locale == 'asian'
            ? (nameKo.isNotEmpty ? nameKo : displayName)
            : (nameEn.isNotEmpty ? nameEn : displayName);

    if (locale == 'western') {
      firstLine = '$displayNameを追加しました';
      secondLine = '$secondLineName added.';
    } else if (locale == 'asian') {
      firstLine = '已添加：$displayName';
      secondLine = '$secondLineName가 추가되었습니다.';
    } else {
      firstLine = '$displayNameを追加しました';
      secondLine = '$secondLineName added.';
    }

    if (mounted) {
      setState(() {
        _addNoticeMessage = '$firstLine\n$secondLine';
        _showAddNotice = true;
      });
    }

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showAddNotice = false;
          _addNoticeMessage = null;
        });
      }
    });
  }

  void _showFavoriteHint() {
    if (_favoriteHintPlayed) return;
    _favoriteHintPlayed = true;

    setState(() {
      _favoriteHintVisible = true;
    });

    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) {
        setState(() {
          _favoriteSparkleVisible = true;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _favoriteHintVisible = false;
          _favoriteSparkleVisible = false;
        });
      }
    });
  }

  List<dynamic> get filteredDrinks {
    if (selectedDrinkCategory == 'ALL') {
      return drinks;
    }

    if (selectedDrinkCategory == '⭐ お気に入り') {
      return drinks.where((e) => _isFavorite(e, 'drink')).toList();
    }

    return drinks.where((e) {
      return e['drinkcategory'].toString().toLowerCase() ==
          selectedDrinkCategory.toLowerCase();
    }).toList();
  }

  List<dynamic> get filteredFoods {
    if (selectedFoodCategory == 'ALL') {
      return foods;
    }

    if (selectedFoodCategory == '⭐ お気に入り') {
      return foods.where((e) => _isFavorite(e, 'food')).toList();
    }

    return foods.where((e) {
      return e['foodcategory'].toString().toLowerCase() ==
          selectedFoodCategory.toLowerCase();
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
                Navigator.popUntil(context, (route) => route.isFirst);
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
                  Uri.parse('https://www.facebook.com/share/1AtrS2hBh9/'),
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
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFF7F5F4)),
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
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(
                onRefresh: refreshMenu,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 10),
                    _categoryDropdown(
                      categories: [
                        'ALL',
                        '⭐ お気に入り',
                        ...drinkCategories.where((c) => c != 'ALL'),
                      ],
                      value: selectedDrinkCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedDrinkCategory = value!;
                        });
                      },
                      onOpened: _showFavoriteHint,
                      showFavoriteHint: _favoriteHintVisible,
                      showFavoriteSparkle: _favoriteSparkleVisible,
                    ),
                    const SizedBox(height: 10),
                    ...filteredDrinks.map((item) => _drinkCard(item)),
                  ],
                ),
              ),
              RefreshIndicator(
                onRefresh: refreshMenu,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 10),
                    _categoryDropdown(
                      categories: [
                        'ALL',
                        '⭐ お気に入り',
                        ...foodCategories.where((c) => c != 'ALL'),
                      ],
                      value: selectedFoodCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedFoodCategory = value!;
                        });
                      },
                      onOpened: _showFavoriteHint,
                      showFavoriteHint: _favoriteHintVisible,
                      showFavoriteSparkle: _favoriteSparkleVisible,
                    ),
                    const SizedBox(height: 10),
                    ...filteredFoods.map((item) => _foodCard(item)),
                  ],
                ),
              ),
            ],
          ),
          if (_showAddNotice && _addNoticeMessage != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _addNoticeMessage!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryDropdown({
    required List<String> categories,
    required String value,
    required ValueChanged<String?> onChanged,
    required VoidCallback onOpened,
    required bool showFavoriteHint,
    required bool showFavoriteSparkle,
  }) {
    final isFavoriteSelection = value == '⭐ お気に入り';

    return Center(
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
        child: PopupMenuButton<String>(
          offset: const Offset(0, 42),
          color: buttonColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onOpened: onOpened,
          onSelected: onChanged,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isFavoriteSelection) ...[
                  AnimatedRotation(
                    turns: showFavoriteHint ? 0.03 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: const Text('⭐', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: showFavoriteSparkle
                        ? const Text('✨',
                            key: ValueKey('sparkle'),
                            style: TextStyle(fontSize: 14))
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
          itemBuilder: (context) {
            return categories
                .map(
                  (c) => PopupMenuItem<String>(
                    value: c,
                    textStyle: const TextStyle(color: Colors.white),
                    child: Center(
                      child: Text(
                        c == '⭐ お気に入り' ? '⭐ お気に入り' : c,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
                .toList();
          },
        ),
      ),
    );
  }

  Widget _drinkCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF5C3A2E), width: 1.4),
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showAddNoticeToast(item),
            child: const SizedBox(
              width: 36,
              child: Icon(
                Icons.add_circle,
                color: Colors.green,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (AppLanguage.selectedLanguageMode == 'western') ...[
                  Text(
                    item['name_ja'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                Text(
                  item['description'] ?? '',
                  style: const TextStyle(color: Colors.black, fontSize: 13),
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
          const SizedBox(width: 8),
          _favoriteToggleButton(item, 'drink'),
        ],
      ),
    );
  }

  Widget _foodCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailPage(data: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF5C3A2E), width: 1.4),
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
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showAddNoticeToast(item),
              child: const SizedBox(
                width: 36,
                child: Icon(
                  Icons.add_circle,
                  color: Colors.green,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (item['imageurl'] != null &&
                item['imageurl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
                    Text(
                      item['name_ja'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                    style: const TextStyle(color: Colors.black),
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
            const SizedBox(width: 8),
            _favoriteToggleButton(item, 'food'),
          ],
        ),
      ),
    );
  }

  Widget _favoriteToggleButton(dynamic item, String type) {
    final isFavorite = _isFavorite(item, type);
    final key = '$type:${item['id']}';
    final showSparkle =
        _favoriteAnimationKey == key && _favoriteAnimationVisible;

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleFavorite(item, type),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                key: ValueKey(isFavorite),
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? const Color(0xFFB8860B) : Colors.grey,
                size: 24,
              ),
            ),
          ),
          if (showSparkle)
            const Positioned(
              top: 2,
              right: 2,
              child: Text('✨', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class FavoritePage extends StatefulWidget {
  final List<dynamic> drinks;
  final List<dynamic> foods;
  final List<String> favoriteKeys;
  final bool Function(dynamic item, String type) isFavorite;
  final Future<void> Function(dynamic item, String type) onToggleFavorite;

  const FavoritePage({
    super.key,
    required this.drinks,
    required this.foods,
    required this.favoriteKeys,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> _getFavoriteItems() {
    final items = <Map<String, dynamic>>[];

    for (final key in widget.favoriteKeys) {
      if (key.startsWith('drink:')) {
        final id = key.substring('drink:'.length);
        final matches = widget.drinks.where(
          (candidate) => candidate['id'].toString() == id,
        );
        if (matches.isNotEmpty) {
          final item = matches.first;
          items.add({'item': item, 'type': 'drink'});
        }
      } else if (key.startsWith('food:')) {
        final id = key.substring('food:'.length);
        final matches = widget.foods.where(
          (candidate) => candidate['id'].toString() == id,
        );
        if (matches.isNotEmpty) {
          final item = matches.first;
          items.add({'item': item, 'type': 'food'});
        }
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final favoriteItems = _getFavoriteItems();

    return Scaffold(
      backgroundColor: const Color(0xFFD9CFBE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E3329),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '⭐ お気に入り',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: favoriteItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'お気に入りはまだありません。',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'メニューの☆をタップすると\nお気に入りに登録できます。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('通常メニューを見る'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              children: favoriteItems.map((entry) {
                final item = entry['item'];
                final type = entry['type'] as String;
                return _favoriteItemCard(item, type, formatter);
              }).toList(),
            ),
    );
  }

  Widget _favoriteItemCard(dynamic item, String type, NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF5C3A2E), width: 1.4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (AppLanguage.selectedLanguageMode == 'western') ...[
                  Text(
                    item['name_ja'] ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['name_en'] ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
                if (AppLanguage.selectedLanguageMode == 'asian') ...[
                  Text(
                    item['name_ja'] ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['name_zh'] ?? '',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['name_ko'] ?? '',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  item['description'] ?? '',
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '¥${formatter.format(item['price'] ?? 0)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              await widget.onToggleFavorite(item, type);
              if (mounted) {
                setState(() {});
              }
            },
            child: const Icon(Icons.star, color: Color(0xFFB8860B), size: 24),
          ),
        ],
      ),
    );
  }
}
