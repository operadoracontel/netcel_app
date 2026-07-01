import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Realiza o login na tela de autenticação do white label.
///
/// Funciona em dois cenários:
/// - Emulador limpo (sem credenciais salvas): LoginPage aparece, toca em
///   "Entrar na conta" para ir à tela de senha.
/// - Emulador com sessão anterior: vai direto para PasswordLoginPage.
Future<void> performLogin(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  assert(email.isNotEmpty, 'TEST_EMAIL dart-define é obrigatório');
  assert(password.isNotEmpty, 'TEST_PASSWORD dart-define é obrigatório');

  // Aguarda splash e checagem de SecureStorage
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();

  // Se LoginPage está visível (emulador limpo), vai para a tela de senha
  if (find.text('Entrar na conta').evaluate().isNotEmpty) {
    await tester.tap(find.text('Entrar na conta'));
    await tester.pumpAndSettle();
  }

  // PasswordLoginPage: 2 TextFormFields — email (primeiro) e senha (último, obscureText)
  await tester.enterText(find.byType(TextFormField).first, email);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).last, password);
  await tester.pumpAndSettle();

  // Fecha teclado e toca em "Entrar na Conta"
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.tap(find.text('Entrar na Conta'));
  await tester.pump(); // inicia o async

  // Aguarda resposta da API e navegação para Home (até 20s).
  // Nota: após o login o app pode exibir o dialog nativo de permissão de
  // notificações do Android. Como é UI de sistema (fora do Flutter), o teste
  // não consegue interagir com ele — mas ele não bloqueia o widget tree.
  // Para evitar que apareça nos screenshots, conceda a permissão antes de
  // rodar o teste:
  //   adb shell pm grant <package_name> android.permission.POST_NOTIFICATIONS
  bool chegouHome = false;
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.text('Recarregar').evaluate().isNotEmpty) {
      chegouHome = true;
      break;
    }
  }

  expect(chegouHome, isTrue,
      reason: 'Home não apareceu após o login. '
          'Verifique as credenciais (TEST_EMAIL / TEST_PASSWORD) e a conexão com a API.');
  await tester.pumpAndSettle();
}
