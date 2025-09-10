class CartItem {
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String currency;

  CartItem({
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    this.currency = "AUD",
  });

  double get total => quantity * price;

  Map<String, dynamic> toPaypalItem() {
    return {
      "name": name,
      "description": description,
      "quantity": quantity,
      "price": price.toStringAsFixed(2),
      "currency": currency,
    };
  }
}
