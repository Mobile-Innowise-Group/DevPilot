import 'dart:ui';

class AppLocalization {
  static const String langsFolderPath = 'core/resources/langs';

  /// In case if you need more locales just create another
  /// const variable and add created locale to [supportedLocales]
  /// also you may need to get locale from local store that was
  /// previously set so here is an example how you can update [fallbackLocale] :
  /// appLocator<PrefsProvider>().getLocale() ?? _enLocale
  static List<Locale> get supportedLocales => <Locale>[_enLocale];

  static Locale get fallbackLocale => _enLocale;
  static const Locale _enLocale = Locale('en', 'US');
}
