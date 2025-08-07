class Invoice {
  final String id;
  final String loadId;
  final String createdBy;
  final String billedTo;
  final String origin;
  final String destination;
  final String pickupDate;
  final String deliveryDate;
  final double amount;
  final String currency;
  final double tax;
  final String status; // e.g., Draft, Sent, Paid, Disputed
  final String paymentMethod;
  final String dueDate;
  final String? podUrl; // Proof of delivery
  final DateTime createdAt;

  final bool ocrVerified;
  final String ocrText;

  Invoice({
    required this.id,
    required this.loadId,
    required this.createdBy,
    required this.billedTo,
    required this.origin,
    required this.destination,
    required this.pickupDate,
    required this.deliveryDate,
    required this.amount,
    required this.currency,
    required this.tax,
    required this.status,
    required this.paymentMethod,
    required this.dueDate,
    this.podUrl,
    required this.createdAt,
    this.ocrVerified = false,
    this.ocrText = '',
  });

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      loadId: map['loadId'],
      createdBy: map['createdBy'],
      billedTo: map['billedTo'],
      origin: map['origin'],
      destination: map['destination'],
      pickupDate: map['pickupDate'],
      deliveryDate: map['deliveryDate'],
      amount: map['amount'],
      currency: map['currency'],
      tax: map['tax'],
      status: map['status'],
      paymentMethod: map['paymentMethod'],
      dueDate: map['dueDate'],
      podUrl: map['podUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      ocrVerified: map['ocrVerified'] ?? false,
      ocrText: map['ocrText'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loadId': loadId,
      'createdBy': createdBy,
      'billedTo': billedTo,
      'origin': origin,
      'destination': destination,
      'pickupDate': pickupDate,
      'deliveryDate': deliveryDate,
      'amount': amount,
      'currency': currency,
      'tax': tax,
      'status': status,
      'paymentMethod': paymentMethod,
      'dueDate': dueDate,
      'podUrl': podUrl,
      'createdAt': createdAt.toIso8601String(),
      'ocrVerified': ocrVerified,
      'ocrText': ocrText,
    };
  }

  Invoice copyWith({
    String? id,
    String? loadId,
    String? createdBy,
    String? billedTo,
    String? origin,
    String? destination,
    String? pickupDate,
    String? deliveryDate,
    double? amount,
    String? currency,
    double? tax,
    String? status,
    String? paymentMethod,
    String? dueDate,
    String? podUrl,
    DateTime? createdAt,
    bool? ocrVerified,
    String? ocrText,
  }) {
    return Invoice(
      id: id ?? this.id,
      loadId: loadId ?? this.loadId,
      createdBy: createdBy ?? this.createdBy,
      billedTo: billedTo ?? this.billedTo,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      tax: tax ?? this.tax,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      dueDate: dueDate ?? this.dueDate,
      podUrl: podUrl ?? this.podUrl,
      createdAt: createdAt ?? this.createdAt,
      ocrVerified: ocrVerified ?? this.ocrVerified,
      ocrText: ocrText ?? this.ocrText,
    );
  }
}
