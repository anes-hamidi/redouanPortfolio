import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_strings.dart';

/// Floating WhatsApp Action Button Widget
class FloatingWhatsappButton extends StatelessWidget {
  final String phoneNumber;

  const FloatingWhatsappButton({
    super.key,
    this.phoneNumber = AppStrings.whatsappNumber,
  });

  void _openWhatsApp() async {
    const message = 'Bonjour Cheb Redouane, je vous contacte depuis votre site internet concernant une réservation.';
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');

    try {
      bool launched = false;
      try {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Error opening WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _openWhatsApp,
      backgroundColor: const Color(0xFF25D366),
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.chat, size: 22),
      label: const Text(
        'Contactez-Nous',
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
