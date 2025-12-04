import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/seat.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';
import 'package:sinema_uygulamasi/components/taxes.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/screens/home.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';

class PaymentScreen extends StatefulWidget {
  final Cinema cinema;
  final Movie movie;
  final Showtime showtime;
  final List<Seat> selectedSeats;
  final List<Map<String, dynamic>> selectedTicketDetails;
  final double totalPrice;
  final List<Tax> taxes;
  final double taxAmount;
  final double finalTotal;

  const PaymentScreen({
    super.key,
    required this.cinema,
    required this.movie,
    required this.showtime,
    required this.selectedSeats,
    required this.selectedTicketDetails,
    required this.totalPrice,
    required this.taxes,
    required this.taxAmount,
    required this.finalTotal,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  User? currentUser;
  String? _userToken;
  String _paymentMethod = 'cash';
  String _onlineProvider = 'paypal';
  bool _isLoading = false;
  bool _isFirstPurchase = false;

  // Mobil platform kontrolü (sadece Android / iOS için ilk alışveriş indirimi)
  bool get _isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get _isEligibleForFirstPurchaseDiscount =>
      _isMobilePlatform && _isFirstPurchase;

  double get _firstPurchaseDiscountRate => 0.30; // %30

  double get _firstPurchaseDiscountAmount => _isEligibleForFirstPurchaseDiscount
      ? widget.finalTotal * _firstPurchaseDiscountRate
      : 0.0;

  double get _effectiveFinalTotal =>
      (widget.finalTotal - _firstPurchaseDiscountAmount).clamp(
        0,
        double.infinity,
      );

  @override
  void initState() {
    super.initState();
    _loadUserDataAndToken();

    // Auto-format expiry field as MM/YY while typing
    _cardExpiryController.addListener(() {
      final text = _cardExpiryController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isEmpty) return;

      String formatted;
      if (text.length <= 2) {
        formatted = text;
      } else {
        final mm = text.substring(0, 2);
        final yy = text.substring(2, text.length.clamp(2, 4));
        formatted = '$mm/$yy';
      }

      if (_cardExpiryController.text != formatted) {
        final selectionIndex = formatted.length;
        _cardExpiryController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: selectionIndex),
        );
      }
    });

    // Auto-format card number as 4-4-4-4 while typing
    _cardNumberController.addListener(() {
      final digits = _cardNumberController.text.replaceAll(RegExp(r'\\s+'), '');
      if (digits.isEmpty) return;

      final buffer = StringBuffer();
      for (var i = 0; i < digits.length && i < 16; i++) {
        if (i > 0 && i % 4 == 0) {
          buffer.write(' ');
        }
        buffer.write(digits[i]);
      }
      final formatted = buffer.toString();

      if (_cardNumberController.text != formatted) {
        _cardNumberController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  Future<void> _loadUserDataAndToken() async {
    final fetchedUser = await UserPreferences.readData();
    final fetchedToken = await UserPreferences.getToken();

    if (mounted) {
      setState(() {
        currentUser = fetchedUser;
        _userToken = fetchedToken;
        if (currentUser != null) {
          _nameController.text = currentUser!.name;
          _emailController.text = currentUser!.email;
          if (currentUser!.phone != null && currentUser!.phone!.isNotEmpty) {
            _phoneController.text = currentUser!.phone!;
          }
        }
      });
    }

    // Kullanıcının daha önce bileti var mı kontrol et (ilk alışveriş indirimi için)
    if (fetchedToken != null && fetchedToken.isNotEmpty) {
      await _checkFirstPurchase(fetchedToken);
    }
  }

  /// Kullanıcının hiç bileti yoksa ilk alışveriş için %30 indirim uygular.
  /// Sadece mobil platformlarda geçerlidir.
  Future<void> _checkFirstPurchase(String token) async {
    if (!_isMobilePlatform) return;

    try {
      final response = await http.get(
        Uri.parse(ApiConnection.myTickets),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.startsWith('{') || body.startsWith('[')) {
          final dynamic jsonData = json.decode(body);

          int totalTickets = 0;

          // Laravel paginator: { success: true, data: { total: X, data: [...] } }
          if (jsonData is Map<String, dynamic>) {
            final data = jsonData['data'];
            if (data is Map<String, dynamic>) {
              final totalField = data['total'];
              if (totalField is num) {
                totalTickets = totalField.toInt();
              } else if (data['data'] is List) {
                totalTickets = (data['data'] as List).length;
              }
            } else if (data is List) {
              totalTickets = data.length;
            }
          } else if (jsonData is List) {
            totalTickets = jsonData.length;
          }

          if (mounted) {
            setState(() {
              _isFirstPurchase = totalTickets == 0;
            });
          }
        }
      }
    } catch (_) {
      // Sessizce yutuyoruz; indirim zorunlu değil, hata durumunda normal fiyat devam eder.
    } finally {
      // Hata olsa da kullanıcı normal fiyat üzerinden devam edebilir.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildTicketsPayload() {
    List<Map<String, dynamic>> ticketsPayload = [];
    int seatIndex = 0;

    for (var detail in widget.selectedTicketDetails) {
      int count = detail['count'] as int;
      String customerType = detail['customer_type'] ?? 'adult';

      for (int i = 0; i < count; i++) {
        if (seatIndex < widget.selectedSeats.length) {
          ticketsPayload.add({
            'seat_id': widget.selectedSeats[seatIndex].id,
            'customer_type': customerType,
          });
          seatIndex++;
        } else {
          break;
        }
      }
    }

    return ticketsPayload;
  }

  Map<String, dynamic> _buildTaxCalculationPayload() {
    List<Map<String, dynamic>>
    taxList = widget.taxes.where((t) => t.status == 'active').map((tax) {
      double rate = double.tryParse(tax.rate) ?? 0.0;
      double amount = TaxService.calculateTaxAmount(
        tax,
        widget.totalPrice,
        ticketCount: widget.selectedSeats.length,
      );
      final isPerTicket = tax.type == 'fixed';
      return {
        "name": tax.name,
        "type": tax.type,
        "rate": rate,
        "amount": double.parse(amount.toStringAsFixed(2)),
        "formatted_name": isPerTicket
            ? "${tax.name} (${tax.rate} ₺ x ${widget.selectedSeats.length} tickets)"
            : "${tax.name} (${tax.rate})",
      };
    }).toList();

    final originalTotal = double.parse(widget.finalTotal.toStringAsFixed(2));

    final discountAmount = double.parse(
      _firstPurchaseDiscountAmount.toStringAsFixed(2),
    );
    final totalAfterDiscount = double.parse(
      _effectiveFinalTotal.toStringAsFixed(2),
    );

    final payload = {
      "subtotal": double.parse(widget.totalPrice.toStringAsFixed(2)),
      "taxes": taxList,
      "total_tax_amount": double.parse(widget.taxAmount.toStringAsFixed(2)),
      // Toplam tutar; ilk alışveriş indirimi varsa indirimli toplam
      "total": totalAfterDiscount,
      "ticket_count": widget.selectedSeats.length,
    };

    if (_isEligibleForFirstPurchaseDiscount && discountAmount > 0) {
      payload["first_purchase_discount"] = {
        "rate": _firstPurchaseDiscountRate * 100, // yüzde olarak
        "amount": discountAmount,
        "original_total": originalTotal,
        "description": "Mobile first purchase promotion",
      };
    }

    return payload;
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    // Extra validation based on payment method
    if (_paymentMethod == 'card') {
      if (_cardNameController.text.trim().isEmpty ||
          _cardNumberController.text.trim().isEmpty ||
          _cardExpiryController.text.trim().isEmpty ||
          _cardCvvController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all card details.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_paymentMethod == 'online') {
      if (_onlineProvider.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please choose an online payment provider.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (_userToken == null || _userToken!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Not logged in. Please sign in again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final requestBody = {
      "showtime_id": widget.showtime.id,
      "tickets": _buildTicketsPayload(),
      "customer_name": _nameController.text,
      "customer_email": _emailController.text,
      "customer_phone": _phoneController.text,
      "payment_method": _paymentMethod,
      "payment_details": {
        "type": _paymentMethod,
        if (_paymentMethod == 'cash') ...{
          "note":
              "Customer will pay at cinema box office / concession / ticket counter.",
        },
        if (_paymentMethod == 'card') ...{
          "card_name": _cardNameController.text.trim(),
          "last4": _cardNumberController.text.trim().isNotEmpty
              ? _cardNumberController.text.trim().substring(
                  _cardNumberController.text.trim().length - 4,
                )
              : null,
          "expiry": _cardExpiryController.text.trim(),
        },
        if (_paymentMethod == 'online') ...{"provider": _onlineProvider},
      },
      "tax_calculation": _buildTaxCalculationPayload(),
      "user_id": currentUser?.id,
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConnection.buyTicket),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_userToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  HomePage(currentUser: currentUser!, initialIndex: 3),
            ),
            (route) => false,
          );
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authorization error. Please sign in again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.statusCode}\n${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: AppColorStyle.appBarColor,
        foregroundColor: AppColorStyle.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard(),
            _buildSummaryCard(),
            _buildCustomerInputs(),
            _buildPaymentOptions(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: AppColorStyle.primaryAccent,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Movie & Showtime Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorStyle.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Movie: ${widget.movie.title}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            Text(
              'Cinema: ${widget.cinema.cinemaName}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            Text(
              'Seats: ${widget.selectedSeats.map((s) => s.displayName).join(', ')}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: AppColorStyle.primaryAccent,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorStyle.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ticket Count: ${widget.selectedSeats.length}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            Text(
              'Subtotal: ₺${widget.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            Text(
              'Service Fee: ₺${widget.taxAmount.toStringAsFixed(2)}',
              style: TextStyle(color: AppColorStyle.textSecondary),
            ),
            if (_isEligibleForFirstPurchaseDiscount) ...[
              const SizedBox(height: 8),
              Text(
                'First Mobile Purchase Discount (30%): -₺${_firstPurchaseDiscountAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.greenAccent.shade200,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const Divider(height: 20, thickness: 1),
            if (_isEligibleForFirstPurchaseDiscount) ...[
              Text(
                'Total (After Discount): ₺${_effectiveFinalTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
              ),
            ] else ...[
              Text(
                'Total: ₺${widget.finalTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColorStyle.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField(
          _nameController,
          'Full Name',
          Icons.person,
          validator: (val) =>
              val == null || val.isEmpty ? 'Please enter your full name' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _emailController,
          'Email',
          Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.isEmpty) return 'Please enter your email';
            if (!val.contains('@')) return 'Enter a valid email address';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _phoneController,
          'Phone',
          Icons.phone,
          hintText: '05XXXXXXXXX',
          keyboardType: TextInputType.phone,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please enter a phone number';
            }
            if (!RegExp(r'^05\d{9}$').hasMatch(val)) {
              return 'Enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColorStyle.primaryAccent,
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: AppColorStyle.textSecondary),
        hintStyle: TextStyle(color: AppColorStyle.textSecondary),
      ),
      style: TextStyle(color: AppColorStyle.textPrimary),
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildPaymentOptions() {
    final isCompact = MediaQuery.of(context).size.width < 360;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColorStyle.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          color: AppColorStyle.primaryAccent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: isCompact
                    ? Column(
                        children: [
                          _buildPaymentMethodTile(
                            value: 'cash',
                            icon: Icons.payments_outlined,
                            label: 'Cash',
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentMethodTile(
                            value: 'card',
                            icon: Icons.credit_card,
                            label: 'Credit Card',
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentMethodTile(
                            value: 'online',
                            icon: Icons.phonelink_setup,
                            label: 'Online Payment',
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPaymentMethodTile(
                              value: 'cash',
                              icon: Icons.payments_outlined,
                              label: 'Cash',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPaymentMethodTile(
                              value: 'card',
                              icon: Icons.credit_card,
                              label: 'Credit Card',
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPaymentMethodTile(
                              value: 'online',
                              icon: Icons.phonelink_setup,
                              label: 'Online Payment',
                            ),
                          ),
                        ],
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_paymentMethod == 'cash') ...[
                      Text(
                        'Cash Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColorStyle.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Please pay for your tickets at the cinema box office, concession stand, or ticket counter before the showtime.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColorStyle.textSecondary,
                        ),
                      ),
                    ] else if (_paymentMethod == 'card') ...[
                      Text(
                        'Card Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColorStyle.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCardFields(),
                    ] else if (_paymentMethod == 'online') ...[
                      Text(
                        'Online Payment Providers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColorStyle.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildOnlineProviders(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardFields() {
    return Column(
      children: [
        _buildTextField(
          _cardNameController,
          'Name on Card',
          Icons.person_outline,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Enter the name on the card';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          _cardNumberController,
          'Card Number',
          Icons.credit_card,
          hintText: 'XXXX XXXX XXXX XXXX',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Enter your card number';
            }
            if (val.replaceAll(' ', '').length < 12) {
              return 'Enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _cardExpiryController,
                'Expiry (MM/YY)',
                Icons.calendar_today,
                hintText: 'MM/YY',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter expiry date';
                  }
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(val.trim())) {
                    return 'Use MM/YY format';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                _cardCvvController,
                'CVV',
                Icons.lock_outline,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter CVV';
                  }
                  if (val.trim().length < 3) {
                    return 'Enter valid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOnlineProviders() {
    final providers = [
      {'id': 'paypal', 'label': 'PayPal', 'icon': Icons.account_balance_wallet},
      {'id': 'stripe', 'label': 'Stripe', 'icon': Icons.credit_score},
      {'id': 'apple_pay', 'label': 'Apple Pay', 'icon': Icons.phone_iphone},
      {'id': 'google_pay', 'label': 'Google Pay', 'icon': Icons.android},
    ];

    return Column(
      children: providers.map((p) {
        final isSelected = _onlineProvider == p['id'];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            tileColor: isSelected
                ? AppColorStyle.secondaryAccent.withValues(alpha: 0.15)
                : AppColorStyle.appBarColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected
                    ? AppColorStyle.secondaryAccent
                    : AppColorStyle.primaryAccent.withValues(alpha: 0.4),
              ),
            ),
            leading: Icon(
              p['icon'] as IconData,
              color: isSelected
                  ? AppColorStyle.secondaryAccent
                  : AppColorStyle.textSecondary,
            ),
            title: Text(
              p['label'] as String,
              style: TextStyle(
                color: AppColorStyle.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: AppColorStyle.secondaryAccent)
                : null,
            onTap: () {
              setState(() {
                _onlineProvider = p['id'] as String;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodTile({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _paymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() => _paymentMethod = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorStyle.secondaryAccent.withValues(alpha: 0.2)
              : AppColorStyle.appBarColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 2,
            color: isSelected
                ? AppColorStyle.secondaryAccent
                : AppColorStyle.primaryAccent.withValues(alpha: 0.5),
          ),
        ),
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColorStyle.secondaryAccent
                    : AppColorStyle.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? AppColorStyle.secondaryAccent
                        : AppColorStyle.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Removed deprecated Radio usage; using SegmentedButton above

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorStyle.appBarColor,
          foregroundColor: AppColorStyle.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Complete Payment (₺${_effectiveFinalTotal.toStringAsFixed(2)})',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
