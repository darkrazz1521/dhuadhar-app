class OfflineSale {
  final String customerName;
  final String category;
  final int quantity;
  final int paid;
  final DateTime createdAt;

  OfflineSale({
    required this.customerName,
    required this.category,
    required this.quantity,
    required this.paid,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'customerName': customerName,
    'category': category,
    'quantity': quantity,
    'paid': paid,
    'createdAt': createdAt.toIso8601String(),
  };
}
