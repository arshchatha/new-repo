class Quote {
  final String quotedByUsername;
  final double price;
  final String message;

  Quote({
    required this.quotedByUsername,
    required this.price,
    required this.message,
  });

  /// Factory constructor to create a Quote from a string representation.
  /// Expected string format: "quotedByUsername|price|message"
  /// Example: "john_doe|250.0|Fast delivery"
  factory Quote.fromString(String str) {
    final parts = str.split('|');
    if (parts.length < 3) {
      throw FormatException('Invalid quote format, expected 3 parts but found \${parts.length}: "\$str"');
    }

    final username = parts[0];
    final priceStr = parts[1];
    final message = parts.sublist(2).join('|'); // Join back in case message contains '|'

    final price = double.tryParse(priceStr);
    if (price == null) {
      throw FormatException('Invalid price value in quote: "\$priceStr"');
    }

    return Quote(
      quotedByUsername: username,
      price: price,
      message: message,
    );
  }

  @override
  String toString() {
    return '\$quotedByUsername|\$price|\$message';
  }
}
