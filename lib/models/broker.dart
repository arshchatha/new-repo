class Broker {
  final String id;
  final String name;
  final String logoUrl;
  final String description;
  final String websiteUrl;

  Broker({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.websiteUrl,
  });

  factory Broker.fromMap(Map<String, dynamic> map) {
    return Broker(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      description: map['description'] ?? '',
      websiteUrl: map['websiteUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'websiteUrl': websiteUrl,
    };
  }
}
