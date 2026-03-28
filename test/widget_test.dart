import 'package:flutter_test/flutter_test.dart';
import 'package:liveshop_saas/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LiveShopApp());
  });
}
