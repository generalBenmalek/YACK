class AcceptContractResult {
  final bool signed;
  final bool completed;
  final String? finalContractId; // only when completed

  AcceptContractResult({
    required this.signed,
    required this.completed,
    this.finalContractId,
  });
}
