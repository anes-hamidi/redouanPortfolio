import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_strings.dart';

enum BookingFormStatus { idle, submitting, success, error }

/// Booking Form State Model
class BookingState {
  final String name;
  final String phone;
  final String eventType;
  final DateTime? eventDate;
  final String city;
  final String message;
  final BookingFormStatus status;
  final String? bookingReference;
  final String? errorMessage;

  const BookingState({
    this.name = '',
    this.phone = '',
    this.eventType = 'Mariage',
    this.eventDate,
    this.city = '',
    this.message = '',
    this.status = BookingFormStatus.idle,
    this.bookingReference,
    this.errorMessage,
  });

  BookingState copyWith({
    String? name,
    String? phone,
    String? eventType,
    DateTime? eventDate,
    String? city,
    String? message,
    BookingFormStatus? status,
    String? bookingReference,
    String? errorMessage,
  }) {
    return BookingState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      city: city ?? this.city,
      message: message ?? this.message,
      status: status ?? this.status,
      bookingReference: bookingReference ?? this.bookingReference,
      errorMessage: errorMessage,
    );
  }
}

/// Riverpod StateNotifier for managing Booking & Contact form submission + WhatsApp integration
class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  void setName(String name) => state = state.copyWith(name: name);
  void setPhone(String phone) => state = state.copyWith(phone: phone);
  void setEventType(String eventType) => state = state.copyWith(eventType: eventType);
  void setEventDate(DateTime date) => state = state.copyWith(eventDate: date);
  void setCity(String city) => state = state.copyWith(city: city);
  void setMessage(String msg) => state = state.copyWith(message: msg);

  Future<bool> submitBooking() async {
    state = state.copyWith(status: BookingFormStatus.submitting);

    // Simulate async booking network operation
    await Future.delayed(const Duration(milliseconds: 1000));

    final randomRef = 'RED-${Random().nextInt(899999) + 100000}';
    state = state.copyWith(
      status: BookingFormStatus.success,
      bookingReference: randomRef,
    );
    return true;
  }

  /// Launch WhatsApp with pre-filled reservation details
  Future<bool> sendWhatsAppReservation({String targetPhone = AppStrings.whatsappNumber}) async {
    final refCode = state.bookingReference ?? 'RED-${Random().nextInt(899999) + 100000}';
    state = state.copyWith(
      status: BookingFormStatus.submitting,
      bookingReference: refCode,
    );

    final dateStr = state.eventDate != null
        ? '${state.eventDate!.day.toString().padLeft(2, '0')}/${state.eventDate!.month.toString().padLeft(2, '0')}/${state.eventDate!.year}'
        : 'Non spécifiée';

    final textMessage = '''
Bonjour Cheb Redouane Tlemcani 👋,

Je souhaite effectuer une réservation pour mon événement :
📌 Réf: $refCode
👤 Nom: ${state.name.isNotEmpty ? state.name : 'Non renseigné'}
📞 Tél: ${state.phone.isNotEmpty ? state.phone : 'Non renseigné'}
🎉 Événement: ${state.eventType}
📅 Date: $dateStr
📍 Ville/Wilaya: ${state.city.isNotEmpty ? state.city : 'Non renseignée'}
💬 Message: ${state.message.isNotEmpty ? state.message : 'Aucune remarque'}

Merci de me recontacter pour la confirmation et le devis.
''';

    final cleanPhone = targetPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrl = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(textMessage)}');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
      }
      state = state.copyWith(status: BookingFormStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(status: BookingFormStatus.error, errorMessage: 'Impossible d\'ouvrir WhatsApp.');
      return false;
    }
  }

  void resetForm() {
    state = const BookingState();
  }
}

/// Global Riverpod Provider for Booking Form
final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});
