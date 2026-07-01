import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
      onScreenshot: (String screenshotName, List<int> screenshotBytes,
          [Map<String, Object?>? args]) async {
        final dir = Directory('screenshots');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        File('${dir.path}/$screenshotName.png')
            .writeAsBytesSync(screenshotBytes);
        return true;
      },
    );
