import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

bool _surfaceConverted = false;

/// Captura um screenshot e o registra no [binding].
///
/// O arquivo PNG é entregue ao host via VM service quando o teste é
/// executado com `flutter drive --driver=test_driver/integration_test.dart`
/// (ver `onScreenshot` em test_driver/integration_test.dart) — não escreve
/// nada no storage do device, evitando tanto o scoped storage do Android
/// quanto a perda do arquivo quando o app é desinstalado ao fim do teste.
Future<void> saveScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  // Esconde status bar e navigation bar antes de capturar.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await tester.pumpAndSettle();

  // convertFlutterSurfaceToImage() só pode ser chamada uma vez por sessão —
  // chamadas subsequentes falham com "Surface already converted".
  if (!_surfaceConverted) {
    await binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
  await tester.pumpAndSettle();
  await binding.takeScreenshot(name);
}
