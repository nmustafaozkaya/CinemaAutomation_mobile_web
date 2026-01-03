import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/my_ticket_screen.dart';
import 'package:sinema_uygulamasi/screens/home.dart';

class TicketSuccessScreen extends StatelessWidget {
  final double totalAmount;
  final int ticketCount;
  final List<String> seatNumbers;
  final String ticketTypes;
  final User currentUser;

  const TicketSuccessScreen({
    super.key,
    required this.totalAmount,
    required this.ticketCount,
    required this.seatNumbers,
    required this.ticketTypes,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 80),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Ticket purchase successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColorStyle.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Your tickets have been created successfully.\n',
                    ),
                    TextSpan(text: 'You can view all details on the '),
                    TextSpan(
                      text: 'My Tickets',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' page.'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Details Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColorStyle.appBarColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColorStyle.primaryAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Total',
                      '₺${totalAmount.toStringAsFixed(2)}',
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Tickets', ticketTypes),
                    const SizedBox(height: 16),
                    _buildDetailRow('Seats', seatNumbers.join(', ')),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Go to My Tickets Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MyTicketsPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.confirmation_number, size: 24),
                  label: const Text(
                    'Go to My Tickets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Close Button
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HomePage(currentUser: currentUser, initialIndex: 0),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColorStyle.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: AppColorStyle.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.green : AppColorStyle.textPrimary,
            ),
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
