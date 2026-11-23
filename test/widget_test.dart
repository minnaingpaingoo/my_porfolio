import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_porfolio/main.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';

void main() {
  test('Dynamic daily passcode formula matches (day+7)(month+7)(year+7)', () {
    final sampleDate = DateTime(2026, 11, 23);
    expect(PortfolioRepository.generateDailyPasscode(sampleDate), '30182033');
    expect(
      PortfolioRepository.instance
          .signInWithPasskey('30182033', date: sampleDate),
      isTrue,
    );
  });

  testWidgets(
      'Admin login is hidden and tapping Version 5 times opens Admin Passcode modal',
      (WidgetTester tester) async {
    await PortfolioRepository.instance.signOutAdmin();
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify no visible 'Admin' button exists
    expect(find.text('Admin'), findsNothing);

    // Scroll to footer where Version 1.0.0 is displayed
    final versionFinder = find.text('Version 1.0.0');
    await tester.ensureVisible(versionFinder);
    await tester.pumpAndSettle();

    // Tap version 5 times to unlock the hidden Admin Passcode dialog
    for (int i = 0; i < 5; i++) {
      await tester.tap(versionFinder);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    expect(find.text('Admin Panel Passcode'), findsOneWidget);
  });
}
