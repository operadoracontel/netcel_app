import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Falha o teste se houver um [SnackBar] visível na tela.
///
/// No app, chamadas de API que falham geralmente aparecem para o usuário
/// como um SnackBar com a mensagem de erro (`SnackBar(content:
/// Text(_controller.errorMessage!))` ou `WLSnackbar(type:
/// WLSnackbarType.error, ...)`). Chamar isso depois de cada tela carregar
/// detecta esses casos — se aparecer um SnackBar quando estamos apenas
/// navegando (sem enviar nenhum formulário), é sinal de uma chamada de API
/// que falhou.
///
/// Usa `byWidgetPredicate` (não `byType`) porque `WLSnackbar` é uma
/// subclasse de `SnackBar` — `find.byType(SnackBar)` exige tipo exato e não
/// encontraria instâncias de `WLSnackbar`.
///
/// Limitação conhecida: nem toda tela sinaliza erro de API via SnackBar —
/// Pagamentos, Linhas, Histórico, Ajuda e Indicação mostram apenas um estado
/// "vazio" genérico (ex: "Linhas não encontradas") que é indistinguível de
/// um erro real de API sem mudar a arquitetura do app. Essa checagem cobre
/// os fluxos que de fato emitem SnackBar de erro (Nova Linha, Dados
/// Pessoais, entre outros).
void expectNoErrorSnackbar(WidgetTester tester, {required String screen}) {
  final snackbars = find.byWidgetPredicate((widget) => widget is SnackBar);
  if (snackbars.evaluate().isNotEmpty) {
    final texts = tester
        .widgetList<SnackBar>(snackbars)
        .map((s) => (s.content is Text) ? (s.content as Text).data : s.content)
        .join(', ');
    fail('SnackBar inesperado em "$screen": $texts');
  }
}
