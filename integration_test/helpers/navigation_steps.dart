import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Aguarda [text] aparecer na árvore de widgets, tentando por até
/// [timeoutSeconds]. Falha o teste com [reason] se o texto não aparecer.
Future<void> waitForText(
  WidgetTester tester,
  String text, {
  String? reason,
  int timeoutSeconds = 10,
}) async {
  bool chegou = false;
  for (int i = 0; i < timeoutSeconds; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.text(text).evaluate().isNotEmpty) {
      chegou = true;
      break;
    }
  }
  expect(chegou, isTrue, reason: reason ?? 'Texto "$text" não apareceu a tempo');
  await tester.pumpAndSettle();
}

/// Toca no botão "Recarregar" da Home e aguarda a página de Recarga carregar.
Future<void> goToRecharge(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  await waitForText(tester, 'Escolha seu plano', reason: 'Página de Recarga não carregou');
}

/// Abre o drawer lateral (endDrawer) da Home e aguarda renderizar.
Future<void> openDrawer(WidgetTester tester) async {
  (tester.state(find.byType(Scaffold).first) as ScaffoldState).openEndDrawer();
  await tester.pumpAndSettle();
  expect(find.text('Gerencie sua conta'), findsOneWidget);
}

/// Fecha o drawer lateral sem navegar para nenhuma tela.
Future<void> closeDrawer(WidgetTester tester) async {
  (tester.state(find.byType(Scaffold).first) as ScaffoldState).closeEndDrawer();
  await tester.pumpAndSettle();
}

/// Estando com o drawer aberto, toca em "Pagamentos" e aguarda a página carregar.
Future<void> goToPaymentsFromDrawer(WidgetTester tester) async {
  await tester.tap(find.text('Pagamentos'));
  await tester.pump();
  await waitForText(tester, 'Seus últimos pagamentos processados',
      reason: 'Página de Pagamentos não carregou');
}

/// Estando com o drawer aberto, toca em "Linhas" e aguarda a página carregar.
///
/// O subtítulo "Gerencie, solicite..." é estático e aparece mesmo com a
/// lista ainda carregando (spinner) — esperar só por ele não garante que os
/// dados da API já chegaram em `UserStore.listLines`. Isso importa porque
/// `maskSensitiveUserData` precisa rodar DEPOIS da lista carregar de verdade,
/// senão a máscara aplica em cima de uma lista vazia e os dados reais
/// aparecem no card assim que o fetch (assíncrono) completa. Por isso espera
/// também por um card de linha (InkWell) ou o estado vazio antes de retornar.
Future<void> goToPhoneLinesFromDrawer(WidgetTester tester) async {
  await tester.tap(find.text('Linhas'));
  await tester.pump();
  await waitForText(tester, 'Gerencie, solicite e faça portabilidade',
      reason: 'Página de Linhas não carregou');

  bool carregou = false;
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.byType(InkWell).evaluate().isNotEmpty ||
        find.text('Linhas não encontradas').evaluate().isNotEmpty) {
      carregou = true;
      break;
    }
  }
  expect(carregou, isTrue, reason: 'Lista de linhas não terminou de carregar a tempo');
  await tester.pumpAndSettle();
}

/// Estando na tela de Linhas, toca no primeiro card de linha e aguarda a
/// página de Detalhes da Linha carregar. Falha se não houver nenhuma linha
/// (não deveria acontecer, já que a conta de teste precisa ter linha ativa).
Future<void> goToFirstLineDetails(WidgetTester tester) async {
  final lineCards = find.byType(InkWell);
  expect(lineCards, findsWidgets, reason: 'Nenhuma linha encontrada para abrir detalhes');
  await tester.tap(lineCards.first);
  await tester.pump();
  await waitForText(tester, 'Sua Linha', reason: 'Página de Detalhes da Linha não carregou');
}

/// Estando na tela de Linhas, toca em "Nova Linha" e aguarda o primeiro passo
/// do fluxo de adicionar linha carregar (sem preencher/enviar o formulário).
Future<void> goToNewLineStep1(WidgetTester tester) async {
  await tester.tap(find.text('Nova Linha'));
  await tester.pump();
  await waitForText(tester, 'Adicionar Linha', reason: 'Página de Nova Linha não carregou');
}

/// Estando com o drawer aberto, toca em "Minha Conta" e aguarda a página carregar.
Future<void> goToMyAccountFromDrawer(WidgetTester tester) async {
  await tester.tap(find.text('Minha Conta'));
  await tester.pump();
  await waitForText(tester, 'Seus cadastros com a gente',
      reason: 'Página de Minha Conta não carregou');
}

/// Estando na tela de Minha Conta, toca em "Dados de acesso" e aguarda carregar.
///
/// Usa um texto exclusivo da tela de destino (não o título "Dados de acesso",
/// que também aparece no card de origem — a tela anterior continua montada
/// por baixo da nova rota, então checar o mesmo texto do gatilho daria falso
/// positivo mesmo se a navegação não tivesse ocorrido).
Future<void> goToAccessData(WidgetTester tester) async {
  await tester.tap(find.text('Dados de acesso'));
  await tester.pump();
  await waitForText(tester, 'Para alterar o e-mail consulte nossa central',
      reason: 'Página de Dados de acesso não carregou');
}

/// Estando na tela de Minha Conta, toca em "Dados pessoais" e aguarda carregar.
/// Mesmo motivo do comentário acima: usa um texto exclusivo da tela de destino.
Future<void> goToPersonalData(WidgetTester tester) async {
  await tester.tap(find.text('Dados pessoais'));
  await tester.pump();
  await waitForText(tester, 'Telefone de contato',
      reason: 'Página de Dados pessoais não carregou');
}

/// Estando com o drawer aberto, toca em "Histórico" e aguarda a página carregar.
Future<void> goToHistoryFromDrawer(WidgetTester tester) async {
  await tester.tap(find.text('Histórico'));
  await tester.pump();
  await waitForText(tester, 'Quanto do plano você utilizou neste período',
      reason: 'Página de Histórico não carregou');
}

/// Estando com o drawer aberto, toca em "Portabilidade" e aguarda o primeiro
/// passo do fluxo carregar (sem preencher/enviar o formulário).
Future<void> goToPortabilityStep1FromDrawer(WidgetTester tester) async {
  await tester.tap(find.text('Portabilidade'));
  await tester.pump();
  await waitForText(tester, 'Digite o número da portabilidade',
      reason: 'Página de Portabilidade não carregou');
}

/// Estando com o drawer aberto, toca em "Ajuda" e aguarda a página carregar.
Future<void> goToHelpFromDrawer(WidgetTester tester) async {
  await tester.tap(find.text('Ajuda'));
  await tester.pump();
  await waitForText(tester, 'Separamos tópicos comuns para te ajudar',
      reason: 'Página de Ajuda não carregou');
}

/// Estando com o drawer aberto, tenta ir para "Ganhe descontos" (Indicação).
/// O item só aparece se o programa de indicação estiver habilitado nesta
/// conta — se não existir, fecha o drawer e retorna false sem falhar o teste.
Future<bool> maybeGoToIndicationFromDrawer(WidgetTester tester) async {
  final finder = find.text('Ganhe descontos');
  if (finder.evaluate().isEmpty) {
    await closeDrawer(tester);
    return false;
  }
  await tester.tap(finder);
  await tester.pump();
  await waitForText(tester, 'Meu clube', reason: 'Página de Indicação não carregou');
  return true;
}

/// Estando com o drawer aberto, tenta ir para "Ativar Chip". O item só
/// aparece se `showActivation` estiver habilitado nesta conta — se não
/// existir, fecha o drawer e retorna false sem falhar o teste. A tela inicial
/// (step 0) é uma splash que auto-navega para o próximo passo em alguns
/// segundos — o screenshot capturará o que estiver visível nesse momento.
Future<bool> maybeGoToActivateChipFromDrawer(WidgetTester tester) async {
  final finder = find.text('Ativar Chip');
  if (finder.evaluate().isEmpty) {
    await closeDrawer(tester);
    return false;
  }
  await tester.tap(finder);
  // Step 0 faz fetchAllInformation() + delay fixo de 3s antes de se auto-pop
  // e empurrar o próximo passo — espera bem além disso para não competir com
  // o pop automático no goBack() logo depois do screenshot.
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
  return true;
}

/// Volta para a tela anterior (equivalente ao botão back).
Future<void> goBack(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}
