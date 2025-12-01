// A temporary model representing decoded contract data from a QR code.
// This simulates receiving contract data from a backend.
class ContractPreview {

  final String id; // temp id of the contract
  final String name;
  final double price;
  final String? description;
  final String userA;

  const ContractPreview({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.userA,
  });

  // Creates a ContractPreview from a decoded JSON map.
  factory ContractPreview.fromJson(Map<String, dynamic> json) {
    return ContractPreview(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      userA: json['userA'] as String? ?? '',
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'userA': userA,
    };
  }
}
