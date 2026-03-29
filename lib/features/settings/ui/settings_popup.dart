import 'package:flutter/material.dart';

class SettingsPopup extends StatelessWidget {
  const SettingsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final textColor = tt.bodyLarge!.color;

    return Stack(
      children: [
        // Dim background
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),

        // Settings window (aligned with NavigationRail)
        Positioned(
          left: 120,
          top: 120,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5E82).withOpacity(0.95),
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
                    "Settings",
                    style: tt.titleLarge!.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 20),

                  _settingsItem(context, "Language", textColor, () {}),
                  _settingsItem(context, "Theme", textColor, () {}),

                  // SUPPORT — with popup dialog
                  _settingsItem(context, "Support", textColor, () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor:
                          const Color(0xFF6C5E82).withOpacity(0.95),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text(
                            "Support",
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            "If you experience any issues or have questions,\n"
                                "please contact us at:\n\n"
                                "tiia_app_support@gmail.com",
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Close",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),

                  _settingsItem(context, "About app", textColor, () {}),
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
