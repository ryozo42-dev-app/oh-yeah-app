import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oh_yeah/screens/news_list_page.dart';

class FoodDetailPage extends StatelessWidget {

  final Map data;

  const FoodDetailPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {

    const Color headerColor =
        Color(0xFF4E3329);

    const Color bgColor =
        Color(0xFFD9CFBE);

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

        title: const Text(
          'FOOD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            if (data['image_url'] != null)

              Image.network(
                data['image_url'],
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
              ),

            Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    data['name'] ?? '',

                    style:
                        const TextStyle(
                      fontSize: 34,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    data['name_en'] ?? '',

                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    data['description'] ?? '',

                    style:
                        const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    '¥${data['price']}',

                    style:
                        const TextStyle(
                      fontSize: 38,
                      fontWeight:
                          FontWeight.bold,
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