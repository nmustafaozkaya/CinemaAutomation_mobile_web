import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';

class TaxResponse {
  final bool success;
  final List<Tax> data;

  TaxResponse({required this.success, required this.data});

  factory TaxResponse.fromJson(Map<String, dynamic> json) {
    return TaxResponse(
      success: json['success'],
      data: List<Tax>.from(json['data'].map((x) => Tax.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

class Tax {
  final int id;
  final String name;
  final String type;
  final String rate;
  final String status;
  final int priority;
  final String description;
  final String? createdAt;
  final String? updatedAt;

  Tax({
    required this.id,
    required this.name,
    required this.type,
    required this.rate,
    required this.status,
    required this.priority,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      rate: json['rate'],
      status: json['status'],
      priority: json['priority'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'rate': rate,
      'status': status,
      'priority': priority,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TaxService {
  static Tax _defaultServiceFee() {
    final now = DateTime.now().toIso8601String();
    return Tax(
      id: -1,
      name: 'Service Fee',
      type: 'fixed',
      rate: '2.00',
      status: 'active',
      priority: 1,
      description: 'Service fee per ticket',
      createdAt: now,
      updatedAt: now,
    );
  }

  static bool _isServiceFee(Tax tax) {
    final lowerName = tax.name.toLowerCase();
    return lowerName.contains('hizmet') || lowerName.contains('service');
  }

  static Tax fallbackServiceFee() => _defaultServiceFee();

  static Future<List<Tax>> fetchTaxes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConnection.taxes),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final TaxResponse taxResponse = TaxResponse.fromJson(jsonData);

        if (taxResponse.success) {
          List<Tax> taxes = taxResponse.data
              .where(_isServiceFee)
              .toList();

          if (taxes.isEmpty) {
            taxes = [_defaultServiceFee()];
          }

          return taxes;
        } else {
          throw Exception('API responded with success: false');
        }
      } else {
        throw Exception('Failed to load taxes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching taxes: $e');
    }
  }

  static Future<List<Tax>> fetchActiveTaxes() async {
    try {
      final List<Tax> allTaxes = await fetchTaxes();
      return allTaxes.where((tax) => tax.status == 'active').toList();
    } catch (e) {
      throw Exception('Error fetching active taxes: $e');
    }
  }

  static Future<List<Tax>> fetchActiveTaxesSorted() async {
    try {
      final List<Tax> activeTaxes = await fetchActiveTaxes();
      activeTaxes.sort((a, b) => a.priority.compareTo(b.priority));
      return activeTaxes;
    } catch (e) {
      throw Exception('Error fetching sorted active taxes: $e');
    }
  }

  static double calculateTaxAmount(
    Tax tax,
    double baseAmount, {
    int ticketCount = 1,
  }) {
    switch (tax.type) {
      case 'percentage':
        return baseAmount * (double.parse(tax.rate) / 100);
      case 'fixed':
        return double.parse(tax.rate) * ticketCount;
      case 'fixed_total':
        return double.parse(tax.rate);
      default:
        return 0.0;
    }
  }

  static double calculateTotalTax(
    List<Tax> taxes,
    double baseAmount, {
    int ticketCount = 1,
  }) {
    double totalTax = 0.0;

    for (Tax tax in taxes) {
      if (tax.status == 'active') {
        totalTax += calculateTaxAmount(
          tax,
          baseAmount,
          ticketCount: ticketCount,
        );
      }
    }

    return totalTax;
  }
}

class ReservationScreenTaxLoader {
  static Future<List<Tax>> loadTaxesForReservation() async {
    try {
      return await TaxService.fetchActiveTaxesSorted();
    } catch (_) {
      return [TaxService._defaultServiceFee()];
    }
  }
}
