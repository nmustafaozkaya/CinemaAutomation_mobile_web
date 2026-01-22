import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> paymentMethods = [];
  bool isLoading = true;
  String? _cachedToken; // Token'ı cache'le

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => isLoading = true);
    
    try {
      // Token'ı cache'ten al, yoksa SharedPreferences'tan yükle
      String? token = _cachedToken;
      if (token == null || token.isEmpty) {
        token = await UserPreferences.getToken();
        if (token != null) {
          _cachedToken = token; // Cache'le
        }
      }
      
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(ApiConnection.paymentMethods),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            paymentMethods = (data['data'] as List)
                .map((item) => PaymentMethod.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401) {
        // Token expire olmuş ama token'ı temizleme, sadece hata göster
        throw Exception('Session expired. Please sign in again.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _deletePaymentMethod(int id) async {
    try {
      // Token'ı cache'ten al, yoksa SharedPreferences'tan yükle
      String? token = _cachedToken ?? await UserPreferences.getToken();
      if (token != null && _cachedToken == null) {
        _cachedToken = token; // Cache'le
      }
      final response = await http.delete(
        Uri.parse(ApiConnection.deletePaymentMethodUrl(id)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _loadPaymentMethods();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment method deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _setDefaultPaymentMethod(int id) async {
    try {
      // Token'ı cache'ten al, yoksa SharedPreferences'tan yükle
      String? token = _cachedToken ?? await UserPreferences.getToken();
      if (token != null && _cachedToken == null) {
        _cachedToken = token; // Cache'le
      }
      final response = await http.post(
        Uri.parse(ApiConnection.setDefaultPaymentMethodUrl(id)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _loadPaymentMethods();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Default payment method updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPaymentMethodDialog(
        onSuccess: _loadPaymentMethods,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: AppColorStyle.appBarColor,
        foregroundColor: AppColorStyle.textPrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentMethods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.credit_card, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No payment methods added',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddPaymentMethodDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment Method'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorStyle.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = paymentMethods[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: AppColorStyle.appBarColor,
                      child: ListTile(
                        leading: Icon(
                          Icons.credit_card,
                          color: _getCardColor(method.cardType),
                          size: 32,
                        ),
                        title: Text(
                          method.cardHolderName,
                          style: const TextStyle(
                            color: AppColorStyle.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '**** **** **** ${method.cardLastFour}',
                              style: const TextStyle(
                                color: AppColorStyle.textSecondary,
                              ),
                            ),
                            Text(
                              'Expires: ${method.expiryMonth}/${method.expiryYear}',
                              style: const TextStyle(
                                color: AppColorStyle.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (method.isDefault)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.green, Colors.teal],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'DEFAULT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert, color: AppColorStyle.textPrimary),
                          color: AppColorStyle.appBarColor,
                          itemBuilder: (context) => [
                            if (!method.isDefault)
                              PopupMenuItem(
                                onTap: () => _setDefaultPaymentMethod(method.id),
                                child: const Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.orange, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Set as Default',
                                      style: TextStyle(
                                        color: AppColorStyle.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            PopupMenuItem(
                              onTap: () => _deletePaymentMethod(method.id),
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: paymentMethods.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddPaymentMethodDialog,
              backgroundColor: AppColorStyle.primaryAccent,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Color _getCardColor(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return AppColorStyle.primaryAccent; // Mavimsi yerine primary accent
      case 'mastercard':
        return Colors.orange;
      case 'amex':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class AddPaymentMethodDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const AddPaymentMethodDialog({super.key, required this.onSuccess});

  @override
  State<AddPaymentMethodDialog> createState() => _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<AddPaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  String _cardType = 'visa';
  bool _isDefault = false;
  bool _isLoading = false;

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await UserPreferences.getToken();
      final response = await http.post(
        Uri.parse(ApiConnection.addPaymentMethod),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'card_holder_name': _cardHolderController.text,
          'card_number': _cardNumberController.text.replaceAll(' ', ''),
          'card_type': _cardType,
          'expiry_month': _expiryMonthController.text,
          'expiry_year': _expiryYearController.text,
          'is_default': _isDefault,
        }),
      );

      if (response.statusCode == 201 && mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColorStyle.appBarColor,
      title: const Text(
        'Add Payment Method',
        style: TextStyle(color: AppColorStyle.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _cardHolderController,
                style: const TextStyle(color: AppColorStyle.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Card Holder Name',
                  labelStyle: TextStyle(color: AppColorStyle.textSecondary),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _cardNumberController,
                style: const TextStyle(
                  color: AppColorStyle.textPrimary,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  labelStyle: TextStyle(color: AppColorStyle.textSecondary),
                  hintText: '1234 5678 9012 3456',
                  hintStyle: TextStyle(color: AppColorStyle.textSecondary, fontSize: 14),
                ),
                keyboardType: TextInputType.number,
                maxLength: 19, // 16 digits + 3 spaces
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(), // 4'lü gruplar
                ],
                validator: (value) {
                  final digitsOnly = value?.replaceAll(' ', '') ?? '';
                  return (digitsOnly.length < 13) ? 'Invalid card number' : null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _cardType,
                style: const TextStyle(color: AppColorStyle.textPrimary),
                dropdownColor: AppColorStyle.appBarColor,
                decoration: const InputDecoration(
                  labelText: 'Card Type',
                  labelStyle: TextStyle(color: AppColorStyle.textSecondary),
                ),
                items: const [
                  DropdownMenuItem(value: 'visa', child: Text('Visa')),
                  DropdownMenuItem(value: 'mastercard', child: Text('Mastercard')),
                  DropdownMenuItem(value: 'amex', child: Text('American Express')),
                ],
                onChanged: (value) => setState(() => _cardType = value!),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryMonthController,
                      style: const TextStyle(color: AppColorStyle.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'MM',
                        labelStyle: TextStyle(color: AppColorStyle.textSecondary),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (value) {
                        final month = int.tryParse(value ?? '');
                        return (month == null || month < 1 || month > 12)
                            ? 'Invalid'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _expiryYearController,
                      style: const TextStyle(color: AppColorStyle.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'YYYY',
                        labelStyle: TextStyle(color: AppColorStyle.textSecondary),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) =>
                          (value?.length ?? 0) != 4 ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                title: const Text(
                  'Set as default',
                  style: TextStyle(color: AppColorStyle.textPrimary),
                ),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value!),
                activeColor: AppColorStyle.primaryAccent,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePaymentMethod,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorStyle.primaryAccent,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    super.dispose();
  }
}

class PaymentMethod {
  final int id;
  final String cardHolderName;
  final String cardLastFour;
  final String cardType;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.cardHolderName,
    required this.cardLastFour,
    required this.cardType,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      cardHolderName: json['card_holder_name'],
      cardLastFour: json['card_last_four'],
      cardType: json['card_type'],
      expiryMonth: json['expiry_month'],
      expiryYear: json['expiry_year'],
      isDefault: json['is_default'] ?? false,
    );
  }
}

// Card number formatter - 4'lü gruplar halinde formatlama
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
