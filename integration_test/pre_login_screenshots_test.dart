import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:netcel_app/main.dart' as app;

import 'helpers/screenshot_steps.dart';

/// Screenshots das telas visíveis antes do login — todas mostram o logo do
/// cliente, então servem para validar o branding do white label sem
/// depender de conta de teste. Não requer TEST_EMAIL/TEST_PASSWORD.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pre_login_screenshots', (tester) async {
    final testErrorHandler = FlutterError.onError;
    app.main();

    // Splashscreen é a rota inicial (initialPath) e mostra o logo do cliente
    // enquanto checkCustomerSettings/checkAutoLogin rodam em background e
    // navegam para o Login (sem sessão salva no emulador limpo da CI). Só um
    // pump (sem pumpAndSettle) para capturar antes dessa transição automática.
    await tester.pump();
    await saveScreenshot(binding, tester, '01_splashscreen');

    // Aguarda o auto-login falhar e navegar para o Login antes de restaurar
    // o handler de erro (mesmo motivo do screenshot_test.dart: main() nos
    // apps clientes é fire-and-forget e sobrescreve FlutterError.onError com
    // o Crashlytics).
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    FlutterError.onError = testErrorHandler;

    bool chegouLogin = false;
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
      if (find.text('Entrar na conta').evaluate().isNotEmpty) {
        chegouLogin = true;
        break;
      }
    }
    expect(chegouLogin, isTrue, reason: 'Página de Login não carregou');
    await tester.pumpAndSettle();
    await saveScreenshot(binding, tester, '02_login');

    // Tela de senha (a partir do Login) — sem preencher/enviar o formulário.
    await tester.tap(find.text('Entrar na conta'));
    await tester.pump();
    bool chegouSenha = false;
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
      if (find.text('Entre em sua conta').evaluate().isNotEmpty) {
        chegouSenha = true;
        break;
      }
    }
    expect(chegouSenha, isTrue, reason: 'Página de senha não carregou');
    await tester.pumpAndSettle();
    await saveScreenshot(binding, tester, '03_password_login');
  });
}
