import 'package:flutter_test/flutter_test.dart';
import 'package:cogni_app/main.dart';
import 'package:cogni_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('CogniApp launches and displays brand title', (WidgetTester tester) async {
    await tester.pumpWidget(const CogniApp());
    await tester.pump();

    // Verify brand text is shown on splash
    expect(find.text('Cogni'), findsOneWidget);
    expect(find.text('Short focus games'), findsOneWidget);

    // Let the 800ms splash delay complete
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
  });
}
