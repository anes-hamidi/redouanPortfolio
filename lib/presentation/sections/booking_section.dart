import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/booking_provider.dart';
import '../components/section_header.dart';

/// Booking & Contact Form Section Component with Riverpod & WhatsApp Integration
class BookingSection extends ConsumerStatefulWidget {
  final GlobalKey sectionKey;
  final bool isMobile;

  const BookingSection({
    super.key,
    required this.sectionKey,
    required this.isMobile,
  });

  @override
  ConsumerState<BookingSection> createState() => _BookingSectionState();
}

class _BookingSectionState extends ConsumerState<BookingSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _dateController = TextEditingController();
  final _messageController = TextEditingController();

  final List<String> _eventTypes = [
    'Mariage',
    'Anniversaire',
    'Événement Privé / VIP',
    'Concert Public / Festival',
    'Autre',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _dateController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final bookingNotifier = ref.read(bookingProvider.notifier);
    final bookingState = ref.read(bookingProvider);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: bookingState.eventDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navy,
              onPrimary: AppColors.gold,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      bookingNotifier.setEventDate(picked);
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _submitWhatsApp() async {
    if (_formKey.currentState!.validate()) {
      final bookingNotifier = ref.read(bookingProvider.notifier);
      bookingNotifier.setName(_nameController.text);
      bookingNotifier.setPhone(_phoneController.text);
      bookingNotifier.setCity(_cityController.text);
      bookingNotifier.setMessage(_messageController.text);

      await bookingNotifier.sendWhatsAppReservation();
    }
  }

 

 
  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return Container(
      key: widget.sectionKey,
      color: AppColors.cream,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Header
              const SectionHeader(
                tagline: AppStrings.contactTagline,
                title: AppStrings.contactTitle,
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: const Text(
                  AppStrings.contactSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 16,
                    color: AppColors.bodyText,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Responsive Form & Contact Details Split
              widget.isMobile
                  ? Column(
                      children: [
                        _buildContactCard(),
                        const SizedBox(height: 48),
                        _buildBookingForm(bookingState),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildContactCard()),
                        const SizedBox(width: 48),
                        Expanded(flex: 7, child: _buildBookingForm(bookingState)),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.contactDirectHeader,
            style: TextStyle(
              fontFamily: 'serif',
              color: AppColors.gold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildContactInfoRow(Icons.phone, AppStrings.contactPhone),
          const SizedBox(height: 20),
          _buildContactInfoRow(Icons.email, AppStrings.contactEmail),
          const SizedBox(height: 20),
          _buildContactInfoRow(Icons.location_on, AppStrings.contactLocation),
          const SizedBox(height: 36),

          // Direct WhatsApp Button in Contact Card
          ElevatedButton.icon(
            onPressed: () => ref.read(bookingProvider.notifier).sendWhatsAppReservation(),
            icon: const Icon(Icons.chat, color: Colors.white, size: 20),
            label: const Text(
              'Discuter sur WhatsApp (${AppStrings.whatsappDisplayPhone})',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),

          Text(
            'Disponible pour déplacements dans toutes les Wilayas d’Algérie ainsi qu’à l’étranger (France, Canada, UAE...).',
            style: TextStyle(
              fontFamily: 'sans-serif',
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: AppColors.gold, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'sans-serif',
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingForm(BookingState bookingState) {
    final bookingNotifier = ref.read(bookingProvider.notifier);
    final isSubmitting = bookingState.status == BookingFormStatus.submitting;

    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name & Phone Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nameController,
                    label: AppStrings.labelFullName,
                    icon: Icons.person_outline,
                    validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _phoneController,
                    label: AppStrings.labelPhone,
                    icon: Icons.phone_outlined,
                    validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Event Type Dropdown & Date Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.labelEventType,
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: bookingState.eventType,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.event_seat_outlined, color: AppColors.gold, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.gold, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: _eventTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type, style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            bookingNotifier.setEventType(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dateController,
                        label: AppStrings.labelEventDate,
                        icon: Icons.calendar_today_outlined,
                        hint: 'Sélectionner la date',
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // City
            _buildTextField(
              controller: _cityController,
              label: AppStrings.labelCity,
              icon: Icons.location_city_outlined,
              validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 20),

            // Message
            _buildTextField(
              controller: _messageController,
              label: AppStrings.labelMessage,
              icon: Icons.chat_bubble_outline,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Primary WhatsApp Reservation Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submitWhatsApp,
                icon: const Icon(Icons.chat, color: Colors.white, size: 22),
                label: const Text(
                  'Réserver Instantanément via WhatsApp',
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 3,
                ),
              ),
            ),
         ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.gold, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
      ],
    );
  }
}
