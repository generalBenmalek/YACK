import 'package:isar/isar.dart';
import 'package:yack/db/models/contract.dart';
import 'package:yack/main.dart';


// save contract to isar db using externalId as unique identifier
Future<void> saveContractToIsar({
  required String externalId, // firebase id
  required String name,
  required String description,
  required double price,
  required String userA,
  required String userB,
  String status = 'pending',
}) async {
  // Check if contract already exists
  final existing = await isar.contracts.filter().externalIdEqualTo(externalId).findFirst();
  if(existing != null) {
    // update existing contract
    await isar.writeTxn(() async {
      existing.name = name;
      existing.description = description;
      existing.price = price;
      existing.userA = userA;
      existing.userB = userB;
      existing.updatedAt = DateTime.now();
      existing.status = _mapStringToStatus(status); // definition of function below
      await isar.contracts.put(existing);
    });
  }
  else {
    // create new contract
    final contract = Contract()
    ..externalId = externalId
    ..name = name
    ..description = description
    ..price = price
    ..userA = userA
    ..userB = userB
    ..status = _mapStringToStatus(status)
    ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.contracts.put(contract);
    });
  } 
}

// Helper function to map string status to ContractStatus enum
ContractStatus _mapStringToStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return ContractStatus.pending;

    case 'accepted':
      return ContractStatus.accepted;

    case 'completed': 
    case 'closed':
      return ContractStatus.completed;

    case 'rejected':
    case 'declined':
      return ContractStatus.rejected;
    
    case 'on dispute':
    case 'disputed':
      return ContractStatus.onDispute; // added new enum value (status)
    
    default:
      return ContractStatus.pending;
  }
}

// function to update contract status in Isar
Future<void> updateContractStatusInIsar(String externalId, String status) async {
  final contract = await isar.contracts.filter().externalIdEqualTo(externalId).findFirst();

  if (contract != null) {
    await isar.writeTxn(() async {
      contract.status = _mapStringToStatus(status);
      contract.updatedAt = DateTime.now();
      await isar.contracts.put(contract);
    });
  }
}

// function to delete a contract from Isar given its id
Future<void> deleteContractFromIsar(String externalId) async {
  final contract = await isar.contracts.filter().externalIdEqualTo(externalId).findFirst();

  if (contract != null) {
    await isar.writeTxn(() async {
      await isar.contracts.delete(contract.id);
    });
  }
}