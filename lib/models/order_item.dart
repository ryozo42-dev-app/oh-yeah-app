class OrderItem {
  final String id;
  final String nameJa;
  final String nameEn;
  final String nameZh;
  final String nameKo;
  final int price;
  final int quantity;

  OrderItem({
    required this.id,
    required this.nameJa,
    required this.nameEn,
    required this.nameZh,
    required this.nameKo,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameJa': nameJa,
      'nameEn': nameEn,
      'nameZh': nameZh,
      'nameKo': nameKo,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      nameJa: json['nameJa']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      nameZh: json['nameZh']?.toString() ?? '',
      nameKo: json['nameKo']?.toString() ?? '',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
    );
  }
}
