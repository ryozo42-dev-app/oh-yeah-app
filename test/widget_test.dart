import 'package:flutter_test/flutter_test.dart';
import 'package:bar_app_new/main.dart';

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    // アプリ起動
    await tester.pumpWidget(const MyApp());

    // 初期フレーム描画
    await tester.pump();

    // MyApp が存在することを確認
    expect(find.byType(MyApp), findsOneWidget);
  });
}