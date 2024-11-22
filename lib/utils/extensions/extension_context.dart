import 'package:flutter/material.dart';
import 'package:jigpu_1/utils/components/component_language_code.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension ExtensionContext on BuildContext {
  Future<T?> goUntil<T extends Object?>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamedAndRemoveUntil(routeName, (route) => false, arguments: arguments);
  }

  Future<T?> go<T extends Object?>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<T?> goPage<T extends Object?>(Widget page) {
    return Navigator.of(this).push(MaterialPageRoute(
      builder: (context) => page,
    ));
  }

  pop({Object? arguments}) {
    Navigator.of(this).pop(arguments);
  }

  arguments() {
    return ModalRoute.of(this)!.settings.arguments;
  }

  // AppLocalizations get language => ComponentLanguageCode.language;

  unFocus() {
    FocusScope.of(this).requestFocus(FocusNode());
    // FocusManager.instance.primaryFocus?.unfocus();
  }
}
