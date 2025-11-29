import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/seat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:intl/intl.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';
import 'package:sinema_uygulamasi/components/seat_reservation_response.dart';
import 'package:sinema_uygulamasi/screens/reservation_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Cinema currentCinema;
  final Movie currentMovie;
  final Showtime selectedShowtime;
  final int totalTicketsToSelect;
  final List<Map<String, dynamic>> selectedTicketDetails;

  const SeatSelectionScreen({
    super.key,
    required this.currentCinema,
    required this.currentMovie,
    required this.selectedShowtime,
    required this.totalTicketsToSelect,
    required this.selectedTicketDetails,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  CinemaSeatResponse? seatResponse;
  List<Seat> selectedSeats = [];
  bool isLoading = true;
  String? errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loadSeats();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        loadSeats(isManualRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadSeats({bool isManualRefresh = true}) async {
    try {
      if (!mounted) return;

      if (isManualRefresh) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final response = await getAvailableSeats(widget.selectedShowtime.id);

      if (!mounted) return;

      setState(() {
        seatResponse = response;
        isLoading = false;

        List<Seat> newlySelectedSeats = [];
        List<Seat> removedSeats = [];

        for (var selectedSeat in selectedSeats) {
          bool stillAvailableOrPending =
              response.data.seats.available.any(
                (s) => s.id == selectedSeat.id,
              ) ||
              response.data.seats.pending.any((s) => s.id == selectedSeat.id);

          if (stillAvailableOrPending) {
            Seat? updatedSeat;
            try {
              updatedSeat = response.data.seats.available.firstWhere(
                (s) => s.id == selectedSeat.id,
              );
            } catch (_) {
              try {
                updatedSeat = response.data.seats.pending.firstWhere(
                  (s) => s.id == selectedSeat.id,
                );
              } catch (_) {}
            }
            if (updatedSeat != null) {
              newlySelectedSeats.add(updatedSeat);
            } else {
              removedSeats.add(selectedSeat);
            }
          } else {
            removedSeats.add(selectedSeat);
          }
        }

        selectedSeats = newlySelectedSeats;

        if (removedSeats.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              for (var seat in removedSeats) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Seat ${seat.displayName} was reserved by another user!',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<CinemaSeatResponse> getAvailableSeats(int showtimeId) async {
    final uri = Uri.parse(ApiConnection.getAvailableSeatsUrl(showtimeId));
    FormatException? lastJsonError;

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await http.get(
          uri,
          headers: const {'Accept': 'application/json', 'Connection': 'close'},
        );

        if (response.statusCode == 200) {
          if (response.bodyBytes.isEmpty) {
            throw Exception('Empty response received from server.');
          }

          final Map<String, dynamic> jsonResponse = _decodeSeatJson(
            response.bodyBytes,
          );

          // Debug: API'den gelen veriyi yazdır
          debugPrint('🔍 API Response: ${jsonResponse.toString()}');
          if (jsonResponse['data'] != null &&
              jsonResponse['data']['seats'] != null) {
            final seats = jsonResponse['data']['seats'];
            debugPrint(
              '🔍 Seats structure: available=${seats['available']?.length ?? 0}, occupied=${seats['occupied']?.length ?? 0}, pending=${seats['pending']?.length ?? 0}',
            );
            if (seats['available'] != null && seats['available'].isNotEmpty) {
              debugPrint('🔍 First available seat: ${seats['available'][0]}');
            }
          }

          return CinemaSeatResponse.fromJson(jsonResponse);
        } else {
          throw Exception(
            'Server error: ${response.statusCode}. response: ${response.body}',
          );
        }
      } on FormatException catch (e) {
        lastJsonError = e;
        if (attempt == 0) {
          await Future.delayed(const Duration(milliseconds: 250));
          continue;
        }
        throw Exception('Seat data parse error: ${e.message}');
      } catch (e) {
        throw Exception('Error while fetching seat data: $e');
      }
    }

    throw Exception(
      'Error while fetching seat data: ${lastJsonError?.message ?? 'Unknown error'}',
    );
  }

  Map<String, dynamic> _decodeSeatJson(Uint8List bodyBytes) {
    String rawBody = utf8.decode(bodyBytes, allowMalformed: true).trim();

    if (rawBody.isEmpty) {
      throw const FormatException('Empty JSON body received.');
    }

    try {
      final decoded = json.decode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw FormatException(
        'Unexpected JSON root type: ${decoded.runtimeType}',
      );
    } on FormatException {
      final repaired = _attemptRepairJson(rawBody);
      if (repaired != null) {
        final decoded = json.decode(repaired);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      rethrow;
    }
  }

  String? _attemptRepairJson(String rawBody) {
    if (rawBody.isEmpty) return null;

    final lastBraceIndex = rawBody.lastIndexOf('}');
    if (lastBraceIndex == -1) return null;

    var candidate = rawBody.substring(0, lastBraceIndex + 1);

    final openCount = _countOccurrences(candidate, '{');
    final closeCount = _countOccurrences(candidate, '}');

    if (openCount == 0) return null;

    if (openCount > closeCount) {
      final buffer = StringBuffer(candidate);
      final missing = openCount - closeCount;
      for (var i = 0; i < missing; i++) {
        buffer.write('}');
      }
      candidate = buffer.toString();
    }

    return candidate;
  }

  int _countOccurrences(String source, String pattern) {
    return RegExp(RegExp.escape(pattern)).allMatches(source).length;
  }

  Future<bool> reserveSeat(Seat seat) async {
    final url = Uri.parse(
      ApiConnection.reserveSeatUrl(widget.selectedShowtime.id),
    );
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'seat_id': seat.id.toString()});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (!mounted) return false;

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final SeatReservationResponse reservationResponse =
            SeatReservationResponse.fromJson(jsonResponse);

        if (reservationResponse.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Seat ${seat.displayName} successfully reserved.'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          String message = reservationResponse.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${seat.displayName} could not be reserved: $message',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      } else {
        String errorMsg = 'Seat reserve server error';
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          } else if (errorJson['error'] != null) {
            errorMsg = errorJson['error'];
          } else {
            errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
          }
        } catch (_) {
          errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${seat.displayName} could not be reserved: $errorMsg',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${seat.displayName} reserve request failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> unreserveSeat(Seat seat) async {
    final url = Uri.parse(ApiConnection.releaseSeatUrl(seat.id));
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, headers: headers);

      if (!mounted) return false;

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Seat ${seat.displayName} has been released.'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          String message = jsonResponse['message'] ?? 'Unknown error!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${seat.displayName} could not be released: $message',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      } else {
        String errorMsg = 'Server error! Could not be released';
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          } else if (errorJson['error'] != null) {
            errorMsg = errorJson['error'];
          } else {
            errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
          }
        } catch (_) {
          errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${seat.displayName} could not be released: $errorMsg',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${seat.displayName} release request failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void toggleSeatSelection(Seat seat) async {
    final isAlreadySelected = selectedSeats.any((s) => s.id == seat.id);

    if (isAlreadySelected) {
      final success = await unreserveSeat(seat);
      if (success) {
        setState(() {
          selectedSeats.removeWhere((s) => s.id == seat.id);
        });

        await loadSeats();
      }
    } else {
      if (!seat.isSelectable) return;

      if (seat.status != SeatStatus.available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${seat.displayName} not selectable or already reserved.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (selectedSeats.length >= widget.totalTicketsToSelect) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only select ${widget.totalTicketsToSelect} seat(s).',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await reserveSeat(seat);
      if (success) {
        setState(() {
          selectedSeats.add(seat);
        });
        await loadSeats();
      }
    }
  }

  Color getSeatColor(Seat seat) {
    final isSelected = selectedSeats.any((s) => s.id == seat.id);
    if (isSelected) {
      return const Color(0xFFf8e71c); // Your Selection
    }

    switch (seat.status) {
      case SeatStatus.available:
        return const Color(0xFF10b981); // Blank
      case SeatStatus.occupied:
        return const Color(0xFFcbcbcb); // Filled
      case SeatStatus.pending:
        return const Color(0xFFff4061); // In Another Basket
    }
  }

  Widget buildSeatButton(Seat seat) {
    return GestureDetector(
      onTap: () => toggleSeatSelection(seat),
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: getSeatColor(seat),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: seat.isSelectable
                ? AppColorStyle.textSecondary
                : AppColorStyle.appBarColor,
            width: 1,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                seat.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSeatMap() {
    if (seatResponse == null) {
      return Center(
        child: isLoading
            ? CircularProgressIndicator(color: AppColorStyle.primaryAccent)
            : Text(
                errorMessage ?? 'Failed to load seat map.',
                style: const TextStyle(color: Colors.red),
              ),
      );
    }

    final groupedSeats = seatResponse!.data.seats.getSeatsByRowGrouped();
    final sortedRows = groupedSeats.keys.toList()..sort();

    return Column(
      children: [
        // Seat Map
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...sortedRows.map((row) {
                  final seats = groupedSeats[row]!;
                  final seatButtons = seats
                      .map((seat) => buildSeatButton(seat))
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            row,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColorStyle.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: seatButtons),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        // Screen (en altta)
        Container(
          width: double.infinity,
          height: 30,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColorStyle.appBarColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              'SCREEN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColorStyle.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLegend() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: AppColorStyle.appBarColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildLegendItem(const Color(0xFFf8e71c), 'Your Selection'),
            _buildLegendItem(const Color(0xFFff4061), 'In Another Basket'),
            _buildLegendItem(const Color(0xFFcbcbcb), 'Filled'),
            _buildLegendItem(const Color(0xFF10b981), 'Blank'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColorStyle.textSecondary),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget buildBottomBar() {
    double totalPrice = 0;
    for (var detail in widget.selectedTicketDetails) {
      totalPrice += detail['totalPrice'] as double;
    }

    final isSelectionComplete =
        selectedSeats.length == widget.totalTicketsToSelect;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorStyle.appBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Seats: ${selectedSeats.map((s) => s.displayName).join(', ')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColorStyle.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (selectedSeats.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Total Selected: ${selectedSeats.length}',
                            style: TextStyle(
                              color: AppColorStyle.textSecondary,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Seats Remaining: ${widget.totalTicketsToSelect - selectedSeats.length} more to select',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelectionComplete
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                      Text(
                        'Subtotal Amount: ${totalPrice.toStringAsFixed(2)} ₺',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColorStyle.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isSelectionComplete
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservationScreen(
                                cinema: widget.currentCinema,
                                movie: widget.currentMovie,
                                showtime: widget.selectedShowtime,
                                selectedSeats: selectedSeats,
                                selectedTicketDetails:
                                    widget.selectedTicketDetails,
                                totalPrice: totalPrice,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelectionComplete
                        ? Colors.amber.shade700
                        : Colors.grey.shade700,
                    foregroundColor: AppColorStyle.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Proceed', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Select Seat',
          style: TextStyle(color: AppColorStyle.textPrimary),
        ),

        backgroundColor: AppColorStyle.appBarColor,
        foregroundColor: AppColorStyle.textPrimary,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: AppColorStyle.appBarColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.currentMovie.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColorStyle.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cinema: ${widget.currentCinema.cinemaName}',
                    style: TextStyle(color: AppColorStyle.textSecondary),
                  ),
                  Text(
                    'Hall: ${widget.selectedShowtime.hallname}',
                    style: TextStyle(color: AppColorStyle.textSecondary),
                  ),
                  Text(
                    'Showtime: ${DateFormat('dd.MM.yyyy HH:mm').format(widget.selectedShowtime.startTime)}',
                    style: TextStyle(color: AppColorStyle.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          buildLegend(),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColorStyle.primaryAccent,
                    ),
                  )
                : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: $errorMessage',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => loadSeats(isManualRefresh: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorStyle.primaryAccent,
                            foregroundColor: AppColorStyle.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  )
                : buildSeatMap(),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }
}
