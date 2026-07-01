import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:netcel_app/main.dart' as app;

import 'helpers/login_steps.dart';
import 'helpers/mask_data_steps.dart';
import 'helpers/navigation_steps.dart';
import 'helpers/screenshot_steps.dart';
import 'helpers/validation_steps.dart';

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
    // Nome, CPF, data de nascimento e telefones reais da conta de teste são
    // substituídos por dados fictícios logo após o login. Algumas telas
    // (Linhas, principalmente) buscam a lista de linhas de novo da API toda
    // vez que são visitadas, sobrescrevendo a máscara — por isso chamamos de
    // novo antes de cada screenshot, não só uma vez aqui.
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Home');
    await saveScreenshot(binding, tester, '01_home');

    // Recarga
    await goToRecharge(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Recarga');
    await saveScreenshot(binding, tester, '02_recharge');
    await goBack(tester);

    // Drawer
    await openDrawer(tester);
    await maskSensitiveUserData(tester);
    await saveScreenshot(binding, tester, '03_drawer');

    // Pagamentos (a partir do drawer)
    await goToPaymentsFromDrawer(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Pagamentos');
    await saveScreenshot(binding, tester, '04_payments');
    await goBack(tester);

    // Linhas (abre o drawer novamente)
    await openDrawer(tester);
    await goToPhoneLinesFromDrawer(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Linhas');
    await saveScreenshot(binding, tester, '05_linhas');

    // Detalhes da linha (a partir de Linhas)
    await goToFirstLineDetails(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Detalhes da Linha');
    await saveScreenshot(binding, tester, '06_linha_detalhes');
    await goBack(tester); // volta para Linhas

    // Nova Linha — apenas o passo 1, sem preencher/enviar
    await goToNewLineStep1(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Nova Linha');
    await saveScreenshot(binding, tester, '07_nova_linha');
    await goBack(tester); // volta para Linhas
    await goBack(tester); // volta para Home

    // Minha Conta (abre o drawer novamente)
    await openDrawer(tester);
    await goToMyAccountFromDrawer(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Minha Conta');
    await saveScreenshot(binding, tester, '08_minha_conta');

    // Dados de acesso (a partir de Minha Conta) — sem tocar em "Atualizar"
    await goToAccessData(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Dados de Acesso');
    await saveScreenshot(binding, tester, '09_dados_acesso');
    await goBack(tester); // volta para Minha Conta

    // Dados pessoais (a partir de Minha Conta) — sem tocar em "Atualizar"
    await goToPersonalData(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Dados Pessoais');
    await saveScreenshot(binding, tester, '10_dados_pessoais');
    await goBack(tester); // volta para Minha Conta
    await goBack(tester); // volta para Home

    // Histórico (abre o drawer novamente)
    await openDrawer(tester);
    await goToHistoryFromDrawer(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Histórico');
    await saveScreenshot(binding, tester, '11_historico');
    await goBack(tester);

    // Portabilidade — apenas o passo 1, sem preencher/enviar
    await openDrawer(tester);
    await goToPortabilityStep1FromDrawer(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Portabilidade');
    await saveScreenshot(binding, tester, '12_portabilidade');
    await goBack(tester);

    // Ajuda
    await openDrawer(tester);
    await goToHelpFromDrawer(tester);
    await maskSensitiveUserData(tester);
    expectNoErrorSnackbar(tester, screen: 'Ajuda');
    await saveScreenshot(binding, tester, '13_ajuda');
    await goBack(tester);

    // Ganhe descontos / Indicação — condicional (feature flag da conta)
    await openDrawer(tester);
    final wentToIndication = await maybeGoToIndicationFromDrawer(tester);
    if (wentToIndication) {
      await maskSensitiveUserData(tester);
      expectNoErrorSnackbar(tester, screen: 'Indicação');
      await saveScreenshot(binding, tester, '14_indicacao');
      await goBack(tester);
    }

    // Ativar Chip — condicional (feature flag da conta); tela inicial é uma
    // splash que auto-navega em alguns segundos, o screenshot captura o que
    // estiver visível nesse momento.
    await openDrawer(tester);
    final wentToActivateChip = await maybeGoToActivateChipFromDrawer(tester);
    if (wentToActivateChip) {
      await maskSensitiveUserData(tester);
      expectNoErrorSnackbar(tester, screen: 'Ativar Chip');
      await saveScreenshot(binding, tester, '15_ativar_chip');
      await goBack(tester);
    }
  });
}
