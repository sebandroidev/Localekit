import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localekit/main.dart';

void main() {
  testWidgets('LocaleKitApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LocaleKitApp()),
    );
    expect(find.byType(LocaleKitApp), findsOneWidget);
  });
}
