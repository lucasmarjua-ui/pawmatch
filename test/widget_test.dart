import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pawmatch/main.dart';

void main() {
  testWidgets('Shows the sign-in form when signed out', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Pawmatch'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('Signing in with valid credentials reaches Discover', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).at(0), 'lucas@pawmatch.app');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign in');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
  });

  testWidgets('Rejects an invalid email before calling the auth service', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign in');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.byIcon(Icons.explore_outlined), findsNothing);
  });

  testWidgets('Signing up leads to profile creation before Discover', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.widgetWithText(GestureDetector, 'Sign up').first);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(0), 'newowner@pawmatch.app');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    final createAccountButton = find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    // Debe aterrizar en CreateProfileScreen, no directo en Discover.
    expect(find.text("Let's meet your dog"), findsOneWidget);
    expect(find.byIcon(Icons.explore_outlined), findsNothing);

    // Paso 1: datos básicos del perro.
    await tester.enterText(find.byKey(const Key('dogNameField')), 'Nala');
    await tester.enterText(find.byKey(const Key('breedField')), 'Poodle');
    await tester.enterText(find.byKey(const Key('ageField')), '3');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // Paso 2: foto — sin campos obligatorios.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // Paso 3: qué busca — hay que elegir al menos un propósito.
    await tester.tap(find.text('Walking buddy'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // Paso 4: personalidad — opcional.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();

    // Paso 5: sobre ti — el nombre del dueño es obligatorio.
    await tester.enterText(find.byKey(const Key('ownerNameField')), 'Sam');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
  });
}
