import 'package:flutter/material.dart';
import 'package:vulcan_mobile_playground/l10n/localization/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  Locale get locale => Localizations.localeOf(this);
}
