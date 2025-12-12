// Modify as needed for your project structure.

class TempContract {
  final String tempId;
  final String? contractId;
  final String? hash;
  final String? userAId;
  final String? userAName;
  final String? userBId;
  final String? userBName;
  final bool userASigned;
  final bool userBSigned;
  final DateTime? updatedAt;

  const TempContract({
    required this.tempId,
    this.contractId,
    this.hash,
    this.userAId,
    this.userAName,
    this.userBId,
    this.userBName,
    this.userASigned = false,
    this.userBSigned = false,
    this.updatedAt,
  });

  TempContract copyWith({
    String? tempId,
    String? contractId,
    String? hash,
    String? userAId,
    String? userAName,
    String? userBId,
    String? userBName,
    bool? userASigned,
    bool? userBSigned,
    DateTime? updatedAt,
  }) {
    return TempContract(
      tempId: tempId ?? this.tempId,
      contractId: contractId ?? this.contractId,
      hash: hash ?? this.hash,
      userAId: userAId ?? this.userAId,
      userAName: userAName ?? this.userAName,
      userBId: userBId ?? this.userBId,
      userBName: userBName ?? this.userBName,
      userASigned: userASigned ?? this.userASigned,
      userBSigned: userBSigned ?? this.userBSigned,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Creates a ContractPreview from a decoded JSON map.
  factory TempContract.fromJson(Map<String, dynamic> json) {
    final parsed = _sanitize(json);
    final tempId = parsed['tempID'] ?? parsed['tempId'] ?? parsed['_id'] ?? parsed['id'];
    if (tempId == null || tempId.toString().isEmpty) {
      throw ArgumentError('tempId is required to build TempContract');
    }

    final userAData = parsed['userA'];
    final userBData = parsed['userB'];

    return TempContract(
      tempId: tempId.toString(),
      contractId: parsed['contractId']?.toString(),
      hash: parsed['hash']?.toString(),
      userAId: _readUserId(userAData) ?? parsed['userAId']?.toString(),
      userAName: _readUserName(userAData, fallback: parsed['userAName']?.toString()),
      userBId: _readUserId(userBData) ?? parsed['userBId']?.toString(),
      userBName: _readUserName(userBData, fallback: parsed['userBName']?.toString()),
      userASigned: _asBool(parsed['userASigned'] ?? parsed['userA_signed']),
      userBSigned: _asBool(parsed['userBSigned'] ?? parsed['userB_signed']),
      updatedAt: _parseDate(parsed['updatedAt'] ?? parsed['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tempID': tempId,
      'contractId': contractId,
      'hash': hash,
      'userAId': userAId,
      'userAName': userAName,
      'userBId': userBId,
      'userBName': userBName,
      'userASigned': userASigned,
      'userBSigned': userBSigned,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    return json.map((key, value) => MapEntry(key.toString(), value));
  }

  static String? _readUserId(dynamic value) {
    if (value is Map) {
      final id = value['id'] ?? value['_id'];
      if (id != null && id.toString().isNotEmpty) {
        return id.toString();
      }
    } else if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static String? _readUserName(dynamic value, {String? fallback}) {
    if (value is Map) {
      final first = value['firstName']?.toString() ?? '';
      final last = value['lastName']?.toString() ?? '';
      final combined = '$first $last'.trim();
      if (combined.isNotEmpty) return combined;
      final name = value['name']?.toString();
      if (name != null && name.isNotEmpty) return name;
    } else if (value is String && value.isNotEmpty) {
      return value;
    }
    return fallback;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }
}
