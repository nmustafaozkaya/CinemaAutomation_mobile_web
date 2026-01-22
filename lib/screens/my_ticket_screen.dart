import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'dart:convert';
import "package:sinema_uygulamasi/components/mytickets.dart";
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/login_screen.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  List<Ticket> tickets = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  dynamic currentUser;
  String? _userToken;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadUserDataAndToken();
    await fetchMyTickets();
  }

  Future<void> _loadUserDataAndToken() async {
    final fetchedUser = await UserPreferences.readData();
    final fetchedToken = await UserPreferences.getToken();

    if (mounted) {
      setState(() {
        currentUser = fetchedUser;
        _userToken = fetchedToken;
      });
    }
  }

  Future<void> fetchMyTickets() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Token'ı her zaman yeniden yükle (güncel olsun)
      await _loadUserDataAndToken();

      // Token kontrolü - eğer yoksa ama kullanıcı bilgileri varsa, token expire olmuş demektir
      if (_userToken == null || _userToken!.isEmpty) {
        if (!mounted) return;
        setState(() {
          tickets = [];
          isLoading = false;
          hasError = true;
          // Kullanıcı bilgileri varsa, token expire olmuş veya kaybolmuş demektir
          if (currentUser != null) {
            errorMessage =
                'Your session has expired. Please sign in again to refresh your session.';
          } else {
            errorMessage = 'Please sign in to view your tickets.';
          }
        });
        return;
      }

      // Token var ama geçersiz olabilir - API'yi dene

      final response = await http.get(
        Uri.parse(ApiConnection.myTickets),
        headers: {
          'Authorization': 'Bearer $_userToken',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('{') ||
            response.body.trim().startsWith('[')) {
          try {
            final jsonData = json.decode(response.body);
            final ticketsResponse = MyTicketsResponse.fromJson(jsonData);

            setState(() {
              tickets = ticketsResponse.data.tickets;
              isLoading = false;
              hasError = false;
            });
          } catch (jsonError) {
            // JSON parse error - show error with details
            setState(() {
              tickets = [];
              isLoading = false;
              hasError = true;
              errorMessage = 'Error loading tickets: $jsonError';
            });
          }
        } else {
          // Non-JSON response
          setState(() {
            tickets = [];
            isLoading = false;
            hasError = true;
            errorMessage = 'Invalid response from server';
          });
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid (401)
        // Eğer kullanıcı bilgileri varsa, token expire olmuş demektir
        // Token'ı temizleme, sadece hata göster
        if (!mounted) return;
        setState(() {
          tickets = [];
          isLoading = false;
          hasError = true;
          // Kullanıcı bilgileri varsa daha açıklayıcı mesaj
          if (currentUser != null) {
            errorMessage =
                'Your session has expired. Please sign in again to refresh your session.';
          } else {
            errorMessage = 'Please sign in to view your tickets.';
          }
          // Token'ı koru, temizleme
        });
      } else {
        // Error loading tickets
        setState(() {
          tickets = [];
          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      // Connection error
      if (!mounted) return;
      setState(() {
        tickets = [];
        isLoading = false;
        hasError = true;
        errorMessage =
            'Unable to connect to server. Please check your internet connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('My Tickets'),
        backgroundColor: AppColorStyle.appBarColor,
        foregroundColor: AppColorStyle.textPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchMyTickets,
        color: AppColorStyle.primaryAccent,
        backgroundColor: AppColorStyle.scaffoldBackground,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColorStyle.primaryAccent),
      );
    }

    if (hasError) {
      // Check if this is a session expiry error
      bool isSessionExpired =
          errorMessage.toLowerCase().contains('session') ||
          errorMessage.toLowerCase().contains('expired') ||
          errorMessage.toLowerCase().contains('sign in');

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSessionExpired
                      ? Colors.orange.withValues(alpha: 0.2)
                      : AppColorStyle.errorColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  isSessionExpired ? Icons.lock_clock : Icons.error_outline,
                  size: 48,
                  color: isSessionExpired
                      ? Colors.orange
                      : AppColorStyle.errorColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSessionExpired ? 'Session Expired' : 'Error',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColorStyle.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (isSessionExpired) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Login ekranına git ve geri dönüş için await
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );

                      // Login başarılı olduysa (result == true), biletleri yeniden yükle
                      if (result == true && mounted) {
                        await _loadUserDataAndToken();
                        await fetchMyTickets();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorStyle.primaryAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: fetchMyTickets,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorStyle.primaryAccent,
                    foregroundColor: AppColorStyle.textPrimary,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (tickets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: AppColorStyle.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'You have no tickets yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColorStyle.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your cinema tickets will appear here automatically',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return TicketCard(ticket: tickets[index]);
      },
    );
  }
}

class TicketCard extends StatefulWidget {
  final Ticket ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  // Bilet tarihinin geçip geçmediğini kontrol et
  bool get isExpired {
    final now = DateTime.now();
    final showtimeDateTime = DateTime(
      widget.ticket.showtime.date.year,
      widget.ticket.showtime.date.month,
      widget.ticket.showtime.date.day,
      widget.ticket.showtime.startTime.hour,
      widget.ticket.showtime.startTime.minute,
    );
    return showtimeDateTime.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    final Ticket ticket = widget.ticket;
    // Renkleri duruma göre belirle
    final Color borderColor = isExpired
        ? const Color(0xFFE53935) // Kırmızı
        : const Color(0xFF4CAF50); // Yeşil

    final Color gradientColor = isExpired
        ? const Color(0xFFE53935) // Kırmızı
        : const Color(0xFF4CAF50); // Yeşil

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: AppColorStyle.appBarColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor.withValues(alpha: 0.6), width: 2.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorStyle.appBarColor,
              gradientColor.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Otomatik Film Posteri
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ColorFiltered(
                              colorFilter: isExpired
                                  ? const ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode.saturation,
                                    )
                                  : const ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.multiply,
                                    ),
                              child: Image.network(
                                ApiConnection.resolveMediaUrl(
                                  ticket.showtime.movie.posterUrl,
                                ),
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 90,
                                    color: AppColorStyle.secondaryAccent,
                                    child: const Icon(
                                      Icons.movie,
                                      color: AppColorStyle.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.showtime.movie.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isExpired
                                    ? AppColorStyle.textSecondary
                                    : AppColorStyle.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket.showtime.hall.cinema.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColorStyle.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket.showtime.hall.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColorStyle.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Fiyat
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isExpired
                              ? Colors.grey
                              : AppColorStyle.primaryAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '₺${ticket.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColorStyle.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColorStyle.scaffoldBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isExpired
                            ? Colors.grey
                            : AppColorStyle.primaryAccent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailItem(
                              'Date',
                              _formatDate(ticket.showtime.date),
                            ),
                            _buildDetailItem(
                              'Time',
                              _formatTime(ticket.showtime.startTime),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailItem(
                              'Seat',
                              '${ticket.seat.row}${ticket.seat.number}',
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _buildDetailItem(
                                  'Ticket Type',
                                  _getCustomerTypeText(ticket.customerType),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (ticket.discountRate >= 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDetailItem(
                                'Discount',
                                '%${ticket.discountRate.toStringAsFixed(0)}',
                              ),
                              _buildDetailItem(
                                'Original Price',
                                '      ₺${ticket.showtime.price.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Purchase Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColorStyle.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Purchase Date: ${_formatDate(ticket.createdAt)} ${_formatTime(ticket.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorStyle.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Status + Payment Method
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ticket.status),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(
                                ticket.status,
                              ).withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isExpired ? Icons.cancel : Icons.check_circle,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusText(ticket.status),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (ticket.paymentMethod != null)
                        Text(
                          'Payment: ${_getPaymentMethodText(ticket.paymentMethod!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColorStyle.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
            // "EXPIRED" badge overlay for past tickets
            if (isExpired)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.block, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'EXPIRED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColorStyle.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColorStyle.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  String _getCustomerTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'adult':
        return 'Adult';
      case 'student':
        return 'Student';
      case 'child':
        return 'Child';
      case 'senior':
        return 'Senior';
      default:
        return type;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50); // Parlak yeşil
      case 'deactive':
        return const Color(0xFFE53935); // Parlak kırmızı
      case 'sold':
        return const Color(0xFF4CAF50); // Parlak yeşil
      case 'cancelled':
        return const Color(0xFFE53935); // Parlak kırmızı
      case 'pending':
        return Colors.orange;
      default:
        return AppColorStyle.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'ACTIVE';
      case 'deactive':
        return 'DEACTIVE';
      case 'sold':
        return 'ACTIVE';
      case 'cancelled':
        return 'CANCELLED';
      case 'pending':
        return 'PENDING';
      default:
        return status.toUpperCase();
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash (pay at cinema)';
      case 'card':
        return 'Credit Card';
      case 'online':
        return 'Online Payment';
      default:
        return method;
    }
  }
}
