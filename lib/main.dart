import 'package:contel_white_label_app/core/core.dart';
import 'package:contel_white_label_app/design_system/design_system.dart';
import 'package:contel_white_label_app/main.dart' as white_label;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:netcel_app/firebase_options.dart';

void main() async {
  const token = r'9RhPno5zyR1RDAuIVFmxhUQVvjLGfIM6';
  const appName = 'Netcel';
  const copyright = 'NETCEL';
  const whatsappNumber = '08002020999';
  const logoType = CustomerLogoFormatEnum.image;
  const contrastColor = Color(0xFFFFFFFF);
  const brandColor = Color(0xFF0000FF);
  const uuid = 'E414C511-DD31-481F-AEDF-4BBCAF94CAA4';
  const isInternetProvider = false;

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await white_label.main(
    isCustomer: true,
    onInit: (context) {
      final defaultTheme = WhiteLabelColors.light(
        brand: brandColor,
        contrast: contrastColor,
      );

      ThemeManager.instance.changeLightModeColors(defaultTheme);
      ThemeManager.instance.changeDarkModeColors(defaultTheme);

      CustomerManager.instance.appName = appName;
      CustomerManager.instance.whatsappNumber = whatsappNumber;
      CustomerManager.instance.logoType = logoType;
      CustomerManager.instance.copyright = copyright;
      CustomerManager.instance.isInternetProvider = isInternetProvider;
      CustomerManager.instance.uuid = uuid;
      CustomerManager.instance.splashscreenBackgroundColor = brandColor;

      CustomerManager.instance.changeCustomerImageLogo(
        const AssetImage('assets/logo.png'),
      );

      CustomerManager.instance.changeCustomerToken(token);
    },
  );
}
