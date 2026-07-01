import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Toca no botão "Recarregar" da Home e aguarda a página de Recarga carregar.
Future<void> goToRecharge(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  bool chegou = false;
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.text('Escolha seu plano').evaluate().isNotEmpty) {
      chegou = true;
      break;
    }
  }
  expect(chegou, isTrue, reason: 'Página de Recarga não carregou');
  await tester.pumpAndSettle();
}

/// Abre o drawer lateral (endDrawer) da Home e aguarda renderizar.
Future<void> openDrawer(WidgetTester tester) async {
  (tester.state(find.byType(Scaffold).first) as ScaffoldState).openEndDrawer();
  await tester.pumpAndSettle();
  expect(find.text('Gerencie sua conta'), findsOneWidget);
}

/// Estando com o drawer aberto, toca em "Pagamentos" e aguarda a página carregar.
Future<void> goToPaymentsFromDrawer(WidgetTester tester) async {
  await tester.tap(find.text('Pagamentos'));
  await tester.pump();
  bool chegou = false;
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.text('Seus últimos pagamentos processados').evaluate().isNotEmpty) {
      chegou = true;
      break;
    }
  }
  expect(chegou, isTrue, reason: 'Página de Pagamentos não carregou');
  await tester.pumpAndSettle();
}

/// Estando com o drawer aberto, toca em "Linhas" e aguarda a página carregar.
Future<void> goToPhoneLinesFromDrawer(WidgetTester tester) async {
  await tester.tap(find.text('Linhas'));
  await tester.pump();
  bool chegou = false;
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.text('Gerencie, solicite e faça portabilidade').evaluate().isNotEmpty) {
      chegou = true;
      break;
    }
  }
  expect(chegou, isTrue, reason: 'Página de Linhas não carregou');
  await tester.pumpAndSettle();
}

/// Volta para a tela anterior (equivalente ao botão back).
Future<void> goBack(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}
