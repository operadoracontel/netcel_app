import 'package:contel_white_label_app/app/features/auth/interactor/stores/user_store.dart';
import 'package:contel_white_label_app/core/entities/auth/user_entity.dart';
import 'package:contel_white_label_app/core/entities/general/phone_vo.dart';
import 'package:contel_white_label_app/injector.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Substitui nome, CPF, data de nascimento e telefones do usuário de teste —
/// na memória do app, sem tocar em backend — por dados fictícios, antes de
/// qualquer screenshot. Os screenshots gerados pela CI podem ser commitados
/// no repositório do app (Fastlane) ou revisados por outras pessoas; sem
/// isso, telas como "Dados pessoais" exporiam CPF e nome reais da conta de
/// teste.
///
/// `UserEntity` é imutável (campos `final`) — precisa reconstruir a
/// instância inteira. Já `UserLineDataEntity` (linha atual + lista de
/// linhas) tem campos mutáveis, então dá para sobrescrever direto.
Future<void> maskSensitiveUserData(WidgetTester tester) async {
  final userStore = injector.get<UserStore>();
  final user = userStore.user;
  if (user == null) return;

  const fakeName = 'Cliente Teste';
  const fakeDocument = '00000000000'; // formata como 000.000.000-00
  const fakePhoneDigits = '11999999999'; // (11) 99999-9999
  final fakeBirthDate = DateTime(2000, 1, 1);

  userStore.user = UserEntity(
    id: user.id,
    name: fakeName,
    nickName: user.nickName,
    document: fakeDocument,
    birthDate: fakeBirthDate,
    email: user.email,
    contactPhone: fakePhoneDigits,
    contactEmail: user.contactEmail,
    currentLine: user.currentLine,
  );

  final fakePhone = PhoneVo.instance(value: fakePhoneDigits);
  if (user.currentLine != null) {
    user.currentLine!.linha = fakePhone;
    user.currentLine!.nomeIdentificacao = 'Linha Teste';
  }
  for (final line in userStore.listLines) {
    line.linha = fakePhone;
    line.nomeIdentificacao = 'Linha Teste';
  }

  // userStore.notifyListeners() só alcança widgets que de fato escutam o
  // UserStore. Telas como Linhas escutam o próprio LinesController — mutar
  // UserStore.listLines não força esse widget a reconstruir, então o
  // último frame renderizado (com dados reais) continuaria na tela. Um
  // reassemble força TODA a árvore montada a rodar build() de novo e ler
  // os dados já mascarados, independente de qual notifier cada tela escuta
  // (mesmo mecanismo do hot reload — não recria estado, não chama initState).
  userStore.notifyListeners();
  await WidgetsBinding.instance.reassembleApplication();
  await tester.pumpAndSettle();
}
