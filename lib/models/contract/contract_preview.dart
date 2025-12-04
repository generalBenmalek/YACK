// A temporary model representing decoded contract data from a QR code.
// This simulates receiving contract data from a backend.
class ContractPreview {
  final String id; // firebase/external id
  final String name;
  final double price;
  final String? description;
  final String userA;
  final String userAName; // Display name of userA

  const ContractPreview({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.userA,
    required this.userAName,
  });

  // Creates a ContractPreview from a decoded JSON map.
  factory ContractPreview.fromJson(Map<String, dynamic> json) {
    return ContractPreview(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      userA: json['userA'] as String? ?? '',
      userAName: json['userAName'] as String? ?? 'Unknown', // Don't fall back to userA UID
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'userA': userA,
      'userAName': userAName,
    };
  }
}
