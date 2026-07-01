import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:netcel_app/main.dart' as app;

import 'helpers/login_steps.dart';
import 'helpers/navigation_steps.dart';
import 'helpers/screenshot_steps.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const email = String.fromEnvironment('TEST_EMAIL');
  const password = String.fromEnvironment('TEST_PASSWORD');

  testWidgets('screenshots', (tester) async {
    // Salva o handler do framework de teste antes de app.main() sobrescrevê-lo
    // com o Crashlytics (FlutterError.onError = crashlytics.recordFlutterFatalError).
    //
    // Não dá para usar `await app.main()`: no template, main() é
    // `Future<void> main()`, mas nos apps clientes gerados pelo
    // create_white_label.py é `void main() async { ... }` — um "fire-and-forget"
    // do Dart (tipo de retorno void em função async não pode ser aguardado,
    // mesmo executando de forma assíncrona internamente). Por isso chamamos
    // sem await e damos um tempo para a cadeia (Firebase init + main do white
    // label) terminar antes de seguir.
    final testErrorHandler = FlutterError.onError;
    app.main();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    FlutterError.onError = testErrorHandler;

    await performLogin(tester, email: email, password: password);
    await saveScreenshot(binding, tester, '01_home');

    // Recarga
    await goToRecharge(tester);
    await saveScreenshot(binding, tester, '02_recharge');
    await goBack(tester);

    // Drawer
    await openDrawer(tester);
    await saveScreenshot(binding, tester, '03_drawer');

    // Pagamentos (a partir do drawer)
    await goToPaymentsFromDrawer(tester);
    await saveScreenshot(binding, tester, '04_payments');
    await goBack(tester);

    // Linhas (abre o drawer novamente)
    await openDrawer(tester);
    await goToPhoneLinesFromDrawer(tester);
    await saveScreenshot(binding, tester, '05_linhas');
    await goBack(tester);
  });
}
