class StockHistory {
  final int? id;
  final String productId;
  final int change;
  final DateTime timestamp;

  StockHistory({
    this.id,
    required this.productId,
    required this.change,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'change': change,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory StockHistory.fromMap(Map<String, dynamic> map) {
    return StockHistory(
      id: map['id'],
      productId: map['productId'],
      change: map['change'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
