import 'package:flutter/material.dart' hide CarouselController;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailPage extends StatelessWidget {
  final String id;

  const NewsDetailPage({
    super.key,
    required this.id,
  });

  Future<void> _openFacebook() async {
    final Uri url = Uri.parse(
      'https://www.facebook.com/',
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openInstagram() async {
    final Uri url = Uri.parse(
      'https://www.instagram.com/',
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';

    try {
      final date = DateTime.parse(
        value.toString(),
      );

      return
          '${date.year}.${date.month}.${date.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    const Color headerColor = Color(0xFF4E3329);
    const Color buttonColor = Color(0xFF5C3A2E);
    const Color bgColor = Color(0xFFD9CFBE);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'NEWS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // BottomNavigation
      bottomNavigationBar: Container(
        color: buttonColor,
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
                onTap: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },
              ),

              // NEWS
              _bottomItem(
                icon: Icons.article,
                label: "NEWS",
                isActive: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // FACEBOOK
              _bottomItem(
                icon: Icons.facebook,
                label: "FACEBOOK",
                onTap: _openFacebook,
              ),

              // INSTAGRAM
              _bottomItem(
                icon: Icons.camera_alt,
                label: "Instagram",
                onTap: _openInstagram,
              ),
            ],
          ),
        ),
      ),

      body: FutureBuilder(
        future: supabase
            .from('news')
            .select()
            .eq('id', id)
            .single(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data
                  as Map<String, dynamic>;

          final title =
              data['title'] ?? '';

          final imageUrl =
              data['imageUrl'];

          final createdAt =
              _formatDate(
            data['createdAt'],
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // 画像
                if (imageUrl != null &&
                    imageUrl
                        .toString()
                        .isNotEmpty)

                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  ),

                Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      // 日付
                      Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Colors.grey[700],
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // タイトル
                      Text(
                        title,
                        style:
                            const TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                          color: Color(
                            0xFF4E3329,
                          ),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // 本文
                      Text(
                        data['body'] ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}