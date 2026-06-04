import 'package:flutter/material.dart';
import '../utils/locale_service.dart';
import '../../app/app.dart';
import '../theme/theme_service.dart';
import '../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class SettingsPopup extends StatelessWidget {
  const SettingsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final textColor = tt.bodyLarge!.color;
    final l10n = AppLocalizations.of(context)!;
    final monochrome = AppTheme.isMonochrome(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),

        Positioned(
          left: 120,
          top: 120,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: monochrome
                    ? Colors.black.withValues(alpha: 0.98)
                    : const Color(0xFF6C5E82).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settings,
                    style: tt.titleLarge!.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 20),

                  // LANGUAGE
                  _settingsItem(context, l10n.language, textColor, () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text(l10n.chooseLanguage),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text("English"),
                                onTap: () {
                                  LocaleService.saveLocale("en");
                                  MyApp.setLocale(context, const Locale("en"));
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Русский"),
                                onTap: () {
                                  LocaleService.saveLocale("ru");
                                  MyApp.setLocale(context, const Locale("ru"));
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Suomi"),
                                onTap: () {
                                  LocaleService.saveLocale("fi");
                                  MyApp.setLocale(context, const Locale("fi"));
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),

                  // THEME SWITCHER
                  _settingsItem(context, l10n.settingsTheme, textColor, () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text(l10n.chooseTheme),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(l10n.darkTheme),
                                onTap: () {
                                  MyApp.setTheme(context, AppThemeMode.dark);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(l10n.lightTheme),
                                onTap: () {
                                  MyApp.setTheme(context, AppThemeMode.light);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(l10n.monochromeTheme),
                                onTap: () {
                                  MyApp.setTheme(
                                    context,
                                    AppThemeMode.monochrome,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),

                  // SUPPORT
                  _settingsItem(context, l10n.settingsSupport, textColor, () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: monochrome
                              ? Colors.black
                              : const Color(0xFF6C5E82).withOpacity(0.95),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            l10n.support,
                            style: const TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            "${l10n.supportMessage}\n\ntiia_app_support@gmail.com",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                l10n.close,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),

                  _settingsItem(context, l10n.settingsAbout, textColor, () {}),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsItem(
      BuildContext context,
      String text,
      Color? textColor,
      VoidCallback onTap,
      ) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          text,
          style: tt.bodyLarge!.copyWith(color: textColor),
        ),
      ),
    );
  }
}
