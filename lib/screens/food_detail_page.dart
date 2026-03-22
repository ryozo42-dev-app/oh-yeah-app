import 'package:flutter/material.dart';

class FoodDetailPage extends StatelessWidget {

  final Map<String, dynamic> food;

  const FoodDetailPage(this.food, {super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        children: [

          /// 背景スクロール
          SingleChildScrollView(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                /// 料理画像
                Image.network(
                  food["imageUrl"],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),

                const SizedBox(height: 20),

                Padding(

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      /// 商品名
                      Text(
                        food["name"],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 英語名
                      Text(
                        food["name_en"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// カテゴリー
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          food["foodCategory"],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 説明
                      Text(
                        food["description"],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// 価格
                      Text(
                        "¥${food["price"]}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 40),

                    ],

                  ),

                )

              ],

            ),

          ),

          /// 戻るボタン
          Positioned(

            top: 40,
            left: 10,

            child: IconButton(

              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),

              onPressed: () {
                Navigator.pop(context);
              },

            ),

          ),

        ],

      ),

    );

  }

}