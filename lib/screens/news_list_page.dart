import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:oh_yeah/screens/news_detail_page.dart';

class NewsListPage extends StatelessWidget {
  const NewsListPage({super.key});

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
                  Navigator.pop(context);
                },
              ),

              // NEWS
              _bottomItem(
                icon: Icons.article,
                label: "NEWS",
                isActive: true,
                onTap: () {},
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

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('news')
            .stream(primaryKey: ['id']),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "ERROR: ${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!
            ..sort(
              (a, b) =>
                  (b['createdAt'] ?? '')
                      .compareTo(
                a['createdAt'] ?? '',
              ),
            );

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "ニュースなし",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,

            separatorBuilder:
                (context, index) {
              return Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[400],
              );
            },

            itemBuilder:
                (context, index) {

              final data = docs[index];

              final title =
                  data['title'] ?? '';

              final imageUrl =
                  data['imageUrl'];

              final createdAt =
                  _formatDate(
                data['createdAt'],
              );

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NewsDetailPage(
                        id: data['id'].toString(),
                      ),
                    ),
                  );
                },

                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // 画像
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          8,
                        ),

                        child: imageUrl != null &&
                                imageUrl
                                    .toString()
                                    .isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 110,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 110,
                                height: 80,
                                color: Colors.grey,
                              ),
                      ),

                      const SizedBox(width: 12),

                      // 右側
                      Expanded(
                        child: SizedBox(
                          height: 80,

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              // タイトル
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color: Color(
                                      0xFF4E3329,
                                    ),
                                  ),
                                ),
                              ),

                              // 日付
                              Align(
                                alignment:
                                    Alignment
                                        .bottomRight,
                                child: Text(
                                  createdAt,
                                  style:
                                      TextStyle(
                                    fontSize: 13,
                                    color: Colors
                                        .grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
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