import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';
import 'package:sinema_uygulamasi/components/ticket_price.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/seat_selection_screen.dart';

class TicketSelectionScreen extends StatefulWidget {
  final Cinema currentCinema;
  final Movie currentMovie;
  final Showtime selectedShowtime;

  const TicketSelectionScreen({
    super.key,
    required this.currentCinema,
    required this.currentMovie,
    required this.selectedShowtime,
  });

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  static const double _serviceFeePerTicket = 2.0;
  List<TicketType> ticketTypes = [];
  String basePrice = "0";
  Map<int, int> selectedCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTicketTypes();
  }

  Future<void> _fetchTicketTypes() async {
    try {
      final url = ApiConnection.getTicketPricesUrl(widget.selectedShowtime.id);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final parsed = TicketTypesResponse.fromJson(jsonDecode(response.body));
        setState(() {
          basePrice = parsed.data.basePrice;
          ticketTypes = parsed.data.types;
          for (var t in ticketTypes) {
            selectedCounts[t.id] = 0;
          }
          isLoading = false;
        });
      } else {
        throw Exception("Invalid response from server");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load ticket types.")),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  double get totalPrice {
    double total = 0;
    final base = double.tryParse(basePrice) ?? 0;
    for (var ticket in ticketTypes) {
      int count = selectedCounts[ticket.id] ?? 0;
      double discountRate = double.tryParse(ticket.discountRate) ?? 0;
      double discountedPrice = base * (1 - discountRate / 100);
      total += discountedPrice * count;
    }
    return total;
  }

  double get serviceFeeTotal => totalSelectedTickets * _serviceFeePerTicket;

  double get grandTotal => totalPrice + serviceFeeTotal;

  bool get anySelected => selectedCounts.values.any((count) => count > 0);

  List<Map<String, dynamic>> get selectedTicketDetails {
    List<Map<String, dynamic>> details = [];
    for (var ticket in ticketTypes) {
      int count = selectedCounts[ticket.id] ?? 0;
      if (count > 0) {
        final basePriceValue = double.tryParse(basePrice) ?? 0;
        final discountRate = double.tryParse(ticket.discountRate) ?? 0;
        final discountedPrice = basePriceValue * (1 - discountRate / 100);

        details.add({
          'ticketType': ticket,
          'count': count,
          'unitPrice': discountedPrice,
          'totalPrice': discountedPrice * count,
          'customer_type': ticket.code,
        });
      }
    }
    return details;
  }

  int get totalSelectedTickets {
    return selectedCounts.values.fold(0, (sum, count) => sum + count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColorStyle.appBarColor,
        iconTheme: IconThemeData(color: AppColorStyle.textPrimary),
        title: Text(
          'Select Ticket Type',
          style: TextStyle(color: AppColorStyle.textPrimary),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket selection',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColorStyle.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You\'ve selected the movie and showtime — now choose your ticket type.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColorStyle.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ticketTypes.length,
                      itemBuilder: (context, index) {
                        final ticket = ticketTypes[index];
                        final basePriceValue = double.tryParse(basePrice) ?? 0;
                        final discountRate =
                            double.tryParse(ticket.discountRate) ?? 0;
                        final discountedPrice =
                            basePriceValue * (1 - discountRate / 100);
                        int count = selectedCounts[ticket.id] ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColorStyle.appBarColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            title: Text(
                              ticket.name,
                              style: TextStyle(
                                color: AppColorStyle.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text(
                              ticket.description,
                              style: TextStyle(
                                color: AppColorStyle.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "${discountedPrice.toStringAsFixed(2)} ₺",
                                    style: TextStyle(
                                      color: AppColorStyle.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: count > 0
                                          ? AppColorStyle.primaryAccent
                                          : Colors.grey,
                                    ),
                                    onPressed: count > 0
                                        ? () {
                                            setState(() {
                                              selectedCounts[ticket.id] =
                                                  count - 1;
                                            });
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '$count',
                                    style: TextStyle(
                                      color: AppColorStyle.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: AppColorStyle.primaryAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedCounts[ticket.id] = count + 1;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(color: AppColorStyle.textSecondary),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColorStyle.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (selectedTicketDetails.isNotEmpty) ...[
                          ...selectedTicketDetails.map((detail) {
                            final ticketType = detail['ticketType'];
                            final count = detail['count'] as int;
                            final totalPrice = detail['totalPrice'] as double;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${ticketType.name} x$count',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColorStyle.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${totalPrice.toStringAsFixed(2)} ₺',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColorStyle.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Divider(
                            color: AppColorStyle.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else ...[
                          Text(
                            'No tickets selected',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColorStyle.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              totalSelectedTickets > 0
                                  ? 'Service fee ($totalSelectedTickets x ${_serviceFeePerTicket.toStringAsFixed(2)} ₺)'
                                  : 'Service fee (₺${_serviceFeePerTicket.toStringAsFixed(2)} / ticket)',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColorStyle.textSecondary,
                              ),
                            ),
                            Text(
                              '${serviceFeeTotal.toStringAsFixed(2)} ₺',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColorStyle.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          color: AppColorStyle.textSecondary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total (incl. service fee):',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColorStyle.textPrimary,
                              ),
                            ),
                            Text(
                              '${grandTotal.toStringAsFixed(2)} ₺',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColorStyle.primaryAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: anySelected
                            ? Colors.amber
                            : Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: anySelected
                          ? () async {
                              try {
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeatSelectionScreen(
                                      currentCinema: widget.currentCinema,
                                      selectedShowtime: widget.selectedShowtime,
                                      currentMovie: widget.currentMovie,
                                      totalTicketsToSelect: totalSelectedTickets,
                                      selectedTicketDetails:
                                          selectedTicketDetails,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          : null,
                      child: Text(
                        'Continue to Seat Selection',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
