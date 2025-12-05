
// import 'package:hive_flutter/adapters.dart';
// import 'package:yack/core/db/online.dart';
// import 'package:yack/screens/contract_agr/contract_agreement.dart'; // Assuming this contains shared utils like encrypt/decrypt/generateRandomKey

// Future<Map<String, dynamic>> registerContract_offline(String id, Map<String, dynamic> contract) async {
//   var keySearchResult = getKey_offline(id);
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
//   String key = keySearchResult["key"];
//   var securedContract = {
//     "title": encrypt(contract["title"], key),
//     "details": encrypt(contract["details"], key),
//     "price": encrypt(contract["price"].toString(), key) ,
//     "status": contract["close"] == null?  "pending" :  ( contract["close"] == "on dispute" ? "on dispute":  "to close")
//   };
//   var contractsBox = Hive.box('contracts');
//   try {
//     var contractsMap = contractsBox.get("contracts") ?? {"contracts": <String, dynamic>{}};
//     contractsMap["contracts"][id] = {"id": id, "contract": securedContract};
//     contractsBox.put('contracts', contractsMap);
//     return {"status": true};
//   } catch (e) {
//     return {"status": false};
//   }
// }

// /// Reads and decrypts a contract from local Hive storage
// ///
// /// Serves: Offline equivalent of readContract; retrieves and decrypts from Hive.
// /// [id]: The contract ID to read
// /// Returns: Map with status and decrypted contract data
// Map<String, dynamic> readContract_offline(String id) {
//   var keySearchResult = getKey_offline(id);
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
//   String key = keySearchResult["key"];
//   var contractsBox = Hive.box('contracts');
//   try {
//     var contracts = contractsBox.get("contracts") ?? {"contracts": <String, dynamic>{}};
//     final data = contracts["contracts"][id];
//     if (data != null && data is Map<String, dynamic>) {
//       var encryptedContract = data['contract'];
//       var decryptedContract = {
//         "title": decrypt(encryptedContract["title"], key),
//         "details": decrypt(encryptedContract["details"], key),
//         "price": decrypt(encryptedContract["price"], key),
//         "status": data["close"] == null?  "pending" :  ( data["close"] == "on dispute" ? "on dispute":  "to close")
//       };
//       return {"status": true, "contract": decryptedContract};
//     }
//     return {"status": false};
//   } catch (e) {
//     return {"status": false};
//   }
// }



// Map<String, dynamic> removeContract_offline(String id)  {
//   var contractsBox = Hive.box('contracts');
  
//   try {
//     // Remove from contracts data
//     var contractsMap = contractsBox.get("contracts") ?? {"contracts": <String, dynamic>{}};
//     if (contractsMap["contracts"] is Map) {
//       contractsMap["contracts"].remove(id);
//       contractsBox.put('contracts', contractsMap);
//     }
    
//     // Remove from keys
//     var keys = contractsBox.get("keys") ?? <String, String>{};
//     keys.remove(id);
//     contractsBox.put("keys", keys);
    
//     // Remove from IDs list
//     List<String> ids = List<String>.from(contractsBox.get('ids') ?? []);
//     ids.remove(id);
//     contractsBox.put("ids", ids);
    
//     // Remove from support documents
//     var supportDocs = contractsBox.get('supportdocs') ?? <String, List<dynamic>>{};
//     supportDocs.remove(id);
//     contractsBox.put('supportdocs', supportDocs);
    
//     // Remove from closed contracts
//     var closedContracts = contractsBox.get('closed') ?? <String, String>{};
//     closedContracts.remove(id);
//     contractsBox.put('closed', closedContracts);
    
//     // Remove any offline messages for this contract
//     List<dynamic> offlineMessages = List.from(contractsBox.get('offline') ?? []);
//     offlineMessages.removeWhere((msg) => msg['id'] == id);
//     contractsBox.put('offline', offlineMessages);
    
//     return {"status": true};
//   } catch (e) {
//     return {"status": false, "error": e.toString()};
//   }
// }




// Map<String, dynamic> closeContract_offline(String id, String userId)  {
//   var keySearchResult = getKey_offline(id);
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
//   String key = keySearchResult["key"];
//   var contractsBox = Hive.box('contracts');
//   var localcon = contractsBox.get("contracts");

//   try {
//        localcon[id]["close" ] = encrypt(user, key);
//        contractsBox.put('contracts', localcon);

//     return {"status": true};
//   } catch (e) {

//     return  {"status": false};
//   }
// }

// Map<String, dynamic> dispute_offline(String id, String userId)  {
//   var keySearchResult = getKey_offline(id);
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }

//   var contractsBox = Hive.box('contracts');
//   var localcon = contractsBox.get("contracts");

//   try {
//        localcon[id]["close" ] = "on dispute";
//        contractsBox.put('contracts', localcon);

//     return {"status": true};
//   } catch (e) {

//     return  {"status": false};
//   }
// }




// // === Local Storage Management (Offline) ===
// /// Saves contract data to local Hive storage
// ///
// /// Serves: Offline equivalent of saveContract; stores contract metadata (id, key) in Hive.
// /// [contractData]: Map containing contract data to save (e.g., {'contractId': id, 'contractkey': key})
// void saveContract_offline(Map<String, dynamic> contractData)  {
//   String id = contractData["contractId"];
//   String key = contractData['contractkey'];
//   var contractsBox = Hive.box('contracts');
//   List<String> ids = List<String>.from(contractsBox.get('ids') ?? []);
//   if (!ids.contains(id)) {
//     ids.add(id);
//     contractsBox.put("ids", ids);
//   }
//   var keys = contractsBox.get("keys") ?? <String, String>{};
//   keys[id] = key;
//   contractsBox.put("keys", keys);
// }

// /// Retrieves all saved contracts from local Hive storage
// ///
// /// Serves: Offline equivalent of getAll; decodes and returns list of contract metadata.
// /// Returns: List of contract maps
// List<Map<String, dynamic>> getAll_offline() {
//   var contractsBox = Hive.box('contracts');
//   var keys = contractsBox.get("keys") ?? <String, String>{};
//   if (keys.isEmpty) return [];
//   List<String> ids = List<String>.from(contractsBox.get('ids') ?? []);
//   List<Map<String, dynamic>> cons = [];
//   for (var id in ids) {
//     if (keys[id] != null) {
//       var cn = {"contractkey": keys[id], 'contractId': id};
//       cons.add(cn);
//     }
//   }
//   return cons;
// }

// /// Retrieves encryption key for a specific contract from local Hive storage
// ///
// /// Serves: Offline equivalent of getKey; searches local keys.
// /// [contractId]: The contract ID to search for
// /// Returns: Map with key and status
// Map<String, dynamic> getKey_offline(String contractId) {
//   var contractsBox = Hive.box('contracts');
//   var keys = contractsBox.get("keys") ?? <String, String>{};
//   if (keys[contractId] == null) return {"status": false};
//   return {'key': keys[contractId], "status": true};
// }

// /// Retrieves and decrypts all contracts for the current user from local storage
// ///
// /// Serves: Offline equivalent of getAllContracts; fetches, decrypts, and returns all local contracts.
// /// Returns: Map with status and list of decrypted contracts
// Map<String, dynamic> getAllContracts_offline() {
//   try {
//     List<Map<String, dynamic>> contracts = getAll_offline();
//     if (contracts.isEmpty) {
//       return {"status": true, "contracts": []};
//     }
//     List<Map<String, dynamic>> contractsDetails = [];
//     for (var contract in contracts) {
//       try {
//         String id = contract["contractId"];
//         String key = contract["contractkey"];
//         var contractData = readContract_offline(id);
//         if (contractData["status"] == true) {
//           var decrypted = contractData["contract"];
//           decrypted["id"] = id; // Add ID to the contract
//           contractsDetails.add(decrypted);
//         }
//       } catch (e) {
//         // Skip individual errors
//         continue;
//       }
//     }
//     return {"status": true, "contracts": contractsDetails};
//   } catch (e) {
//     return {"status": false, "error": e.toString()};
//   }
// }

// // === Support Documents (Offline) ===
// /// Adds text to local contract support docs
// ///
// /// Serves: Offline equivalent of addText; stores encrypted text locally.
// /// [id]: Contract ID
// /// [userId]: User ID
// /// [text]: Text content
// /// Returns: Map with status
// Map<String, dynamic> addText_offline(String id, String userId, String text) {
//   var keySearchResult = getKey_offline(id);
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
//   String key = keySearchResult["key"];
//   var contractsBox = Hive.box('contracts');
//   var supportDocs = contractsBox.get('supportdocs') ?? <String, List<dynamic>>{};
//   List<dynamic> docs = List.from(supportDocs[id] ?? []);
//   var message = {"content": encrypt(text, key), "type": 'text', 'userId': userId};
//   docs.add(message);
//   supportDocs[id] = docs;
//   contractsBox.put('supportdocs', supportDocs);
//   return {"status": true};
// }

// /// Reads and decrypts support documents for a contract from local storage
// ///
// /// Serves: Offline equivalent of readDocuments; retrieves and decrypts local docs.
// /// [id]: Contract ID
// /// Returns: Map with status and decrypted documents list
// Map<String, dynamic> readDocuments_offline(String id) {
//   var keySearchResult = getKey_offline(id);
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
//   String key = keySearchResult["key"];
//   var contractsBox = Hive.box('contracts');
//   var supportDocs = contractsBox.get('supportdocs') ?? <String, List<dynamic>>{};
//   List<dynamic> data = List.from(supportDocs[id] ?? []);
//   try {
//     for (var i = 0; i < data.length; i++) {
//       data[i]["content"] = decrypt(data[i]["content"], key);
//     }
//     return {"status": true, "documents": data};
//   } catch (e) {
//     return {"status": false};
//   }
// }

// // === Offline Backup Queue (For Sync Later) ===
// /// Adds text to offline backup queue (for later sync when online)
// ///
// /// Serves: Queues unsynced messages for batch upload to Firebase later.
// /// [id]: Message/Contract ID
// /// [userId]: User ID
// /// [text]: Text to queue
// void add_text_backup_offline(String id, String userId, String text) {
//   var searchkey = getKey_offline(id);
//   if (searchkey["status"] == false) return;
//   String key = searchkey["key"];
//   var contractsBox = Hive.box('contracts');
//   List<dynamic> ofl = List.from(contractsBox.get('offline') ?? []);
//   var message = {
//     "content": encrypt(text, key),
//     "type": 'text',
//     'userId': userId,
//     'id': id,
//     'timestamp': DateTime.now().toIso8601String() // For ordering
//   };
//   ofl.add(message);
//   contractsBox.put('offline', ofl);
// }

// /// Gets all queued offline messages
// ///
// /// Serves: Retrieves queue for sync processing.
// /// Returns: List of queued messages
// List<Map<String, dynamic>> getOfflineMessages_offline() {
//   var contractsBox = Hive.box('contracts');
//   return List<Map<String, dynamic>>.from(contractsBox.get('offline') ?? []);
// }

// /// Removes all queued offline messages (after successful sync)
// ///
// /// Serves: Clears queue post-sync.
// void removeOfflineMessages_offline() {
//   var contractsBox = Hive.box('contracts');
//   contractsBox.put('offline', <dynamic>[]);
// }

// /// Removes specific offline message by ID (for selective sync)
// ///
// /// Serves: Removes individual item after sync.
// /// [messageId]: ID of message to remove
// void removeOfflineMessageById_offline(String messageId) {
//   var contractsBox = Hive.box('contracts');
//   List<dynamic> offlineMessages = List.from(contractsBox.get('offline') ?? []);
//   offlineMessages.removeWhere((msg) => msg['id'] == messageId);
//   contractsBox.put('offline', offlineMessages);
// }
import 'package:hive_flutter/adapters.dart';
import 'package:yack/core/db/online.dart';
import 'package:yack/core/db/isar_adapter.dart';

/// Register Contract Offline with improved error handling
Future<Map<String, dynamic>> registerContract_offline(String id, Map<String, dynamic> contract) async {
  try {
    var keySearchResult = getKey_offline(id);
    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }
    
    String key = keySearchResult["key"];
    var securedContract = {
      "title": encrypt(contract["title"], key),
      "details": encrypt(contract["details"], key),
      "price": encrypt(contract["price"].toString(), key),
      "status": "pending"
    };
    
    var contractsBox = Hive.box('contracts');
    var contractsMap = contractsBox.get("contracts") ?? {"contracts": <String, dynamic>{}};
    contractsMap["contracts"][id] = {"id": id, "contract": securedContract};
    await contractsBox.put('contracts', contractsMap);

    // sync to isar : Chadli
    await saveContractToIsar(
      externalId: id,
      name: contract["title"],
      description: contract["details"] ?? '',
      price: double.tryParse(contract["price"].toString()) ?? 0.0,
      userA: '',
      userB: '',
      status: 'pending',
    );
    
    return {"status": true};
  } catch (e) {
    print('Register Contract Offline Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Read Contract Offline
Map<String, dynamic> readContract_offline(String id) {
  try {
    var keySearchResult = getKey_offline(id);
    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }
    
    String key = keySearchResult["key"];
    var contractsBox = Hive.box('contracts');
    var contracts = contractsBox.get("contracts") ?? {"contracts": <String, dynamic>{}};
    final data = contracts["contracts"][id];
    
    if (data != null && data is Map<String, dynamic>) {
      var encryptedContract = data['contract'];
      
      String status = "pending";
      if (encryptedContract["status"] != null) {
        status = encryptedContract["status"];
      }
      
      var decryptedContract = {
        "title": decrypt(encryptedContract["title"], key),
        "details": decrypt(encryptedContract["details"], key),
        "price": decrypt(encryptedContract["price"], key),
        "status": status
      };
      return {"status": true, "contract": decryptedContract};
    }
    
    return {"status": false, "error": "Contract not found"};
  } catch (e) {
    print('Read Contract Offline Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Remove Contract Offline - Complete cleanup
Future<Map<String, dynamic>> removeContract_offline(String id) async { // changed
  try {
    var contractsBox = Hive.box('contracts');
    
    // Remove from contracts data
    var contractsMap = contractsBox.get("contracts") ?? {"contracts": <String, dynamic>{}};
    if (contractsMap["contracts"] is Map) {
      contractsMap["contracts"].remove(id);
      contractsBox.put('contracts', contractsMap);
    }
    
    // Remove from keys
    var keys = contractsBox.get("keys") ?? <String, String>{};
    keys.remove(id);
    contractsBox.put("keys", keys);
    
    // Remove from IDs list
    List<String> ids = List<String>.from(contractsBox.get('ids') ?? []);
    ids.remove(id);
    contractsBox.put("ids", ids);
    
    // Remove from support documents
    var supportDocs = contractsBox.get('supportdocs') ?? <String, List<dynamic>>{};
    supportDocs.remove(id);
    contractsBox.put('supportdocs', supportDocs);
    
    // Remove from closed contracts
    var closedContracts = contractsBox.get('closed') ?? <String, String>{};
    closedContracts.remove(id);
    contractsBox.put('closed', closedContracts);
    
    // Remove any offline messages for this contract
    List<dynamic> offlineMessages = List.from(contractsBox.get('offline') ?? []);
    offlineMessages.removeWhere((msg) => msg['id'] == id);
    contractsBox.put('offline', offlineMessages);

    // remove from isar: Chadli
    await deleteContractFromIsar(id);
    
    return {"status": true};
  } catch (e) {
    print('Remove Contract Offline Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Close Contract Offline - Fixed variable name
Future<Map<String, dynamic>> closeContract_offline(String id, String userId) async { // modified
  try {
    var keySearchResult = getKey_offline(id);
    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }
    
    String key = keySearchResult["key"];
    var contractsBox = Hive.box('contracts');
    var localcon = contractsBox.get("contracts") ?? {"contracts": <String, dynamic>{}};

    if (localcon["contracts"] != null && localcon["contracts"][id] != null) {
      localcon["contracts"][id]["close"] = encrypt(userId, key); // Fixed: was 'user', now 'userId'
      contractsBox.put('contracts', localcon);

      // Update Isar status: Chadli
      await updateContractStatusInIsar(id, 'completed');
      return {"status": true};
    }
    
    return {"status": false, "error": "Contract not found"};
  } catch (e) {
    print('Close Contract Offline Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Dispute Contract Offline
Future<Map<String, dynamic>> dispute_offline(String id, String userId) async { // modified
  try {
    var keySearchResult = getKey_offline(id);
    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }

    var contractsBox = Hive.box('contracts');
    var localcon = contractsBox.get("contracts") ?? {"contracts": <String, dynamic>{}};

    if (localcon["contracts"] != null && localcon["contracts"][id] != null) {
      localcon["contracts"][id]["contract"]["status"] = "on dispute";
      contractsBox.put('contracts', localcon);

      // update isar status: Chadli
      await updateContractStatusInIsar(id, 'on dispute');
      return {"status": true};
    }
    
    return {"status": false, "error": "Contract not found"};
  } catch (e) {
    print('Dispute Contract Offline Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Save Contract Offline
void saveContract_offline(Map<String, dynamic> contractData) {
  try {
    String id = contractData["contractId"];
    String key = contractData['contractkey'];
    var contractsBox = Hive.box('contracts');
    
    // Save to IDs list
    List<String> ids = List<String>.from(contractsBox.get('ids') ?? []);
    if (!ids.contains(id)) {
      ids.add(id);
      contractsBox.put("ids", ids);
    }
    
    // Save key
    var keys = contractsBox.get("keys") ?? <String, String>{};
    keys[id] = key;
    contractsBox.put("keys", keys);
  } catch (e) {
    print('Save Contract Offline Error: $e');
  }
}

/// Get All Contracts Offline
List<Map<String, dynamic>> getAll_offline() {
  try {
    var contractsBox = Hive.box('contracts');
    var keys = contractsBox.get("keys") ?? <String, String>{};
    
    if (keys.isEmpty) return [];
    
    List<String> ids = List<String>.from(contractsBox.get('ids') ?? []);
    List<Map<String, dynamic>> cons = [];
    
    for (var id in ids) {
      if (keys[id] != null) {
        var cn = {"contractkey": keys[id], 'contractId': id};
        cons.add(cn);
      }
    }
    
    return cons;
  } catch (e) {
    print('Get All Offline Error: $e');
    return [];
  }
}

/// Get Key Offline
Map<String, dynamic> getKey_offline(String contractId) {
  try {
    var contractsBox = Hive.box('contracts');
    var keys = contractsBox.get("keys") ?? <String, String>{};
    
    if (keys[contractId] == null) {
      return {"status": false, "error": "Key not found"};
    }
    
    return {'key': keys[contractId], "status": true};
  } catch (e) {
    print('Get Key Offline Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Get All Contracts Offline with Details
Map<String, dynamic> getAllContracts_offline() {
  try {
    List<Map<String, dynamic>> contracts = getAll_offline();
    
    if (contracts.isEmpty) {
      return {"status": true, "contracts": []};
    }
    
    List<Map<String, dynamic>> contractsDetails = [];
    
    for (var contract in contracts) {
      try {
        String id = contract["contractId"];
        var contractData = readContract_offline(id);
        
        if (contractData["status"] == true) {
          var decrypted = contractData["contract"];
          decrypted["id"] = id;
          contractsDetails.add(decrypted);
        }
      } catch (e) {
        print('Error processing offline contract ${contract["contractId"]}: $e');
        continue;
      }
    }
    
    return {"status": true, "contracts": contractsDetails};
  } catch (e) {
    print('Get All Contracts Offline Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Add Text Offline
Map<String, dynamic> addText_offline(String id, String userId, String text) {
  try {
    var keySearchResult = getKey_offline(id);
    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }
    
    String key = keySearchResult["key"];
    var contractsBox = Hive.box('contracts');
    var supportDocs = contractsBox.get('supportdocs') ?? <String, List<dynamic>>{};
    
    List<dynamic> docs = List.from(supportDocs[id] ?? []);
    var message = {"content": encrypt(text, key), "type": 'text', 'userId': userId};
    docs.add(message);
    supportDocs[id] = docs;
    contractsBox.put('supportdocs', supportDocs);
    
    return {"status": true};
  } catch (e) {
    print('Add Text Offline Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Read Documents Offline
Map<String, dynamic> readDocuments_offline(String id) {
  try {
    var keySearchResult = getKey_offline(id);
    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }
    
    String key = keySearchResult["key"];
    var contractsBox = Hive.box('contracts');
    var supportDocs = contractsBox.get('supportdocs') ?? <String, List<dynamic>>{};
    List<dynamic> data = List.from(supportDocs[id] ?? []);
    
    for (var i = 0; i < data.length; i++) {
      data[i]["content"] = decrypt(data[i]["content"], key);
    }
    
    return {"status": true, "documents": data};
  } catch (e) {
    print('Read Documents Offline Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Add Text to Backup Queue for Later Sync
void add_text_backup_offline(String id, String userId, String text) {
  try {
    var searchkey = getKey_offline(id);
    if (searchkey["status"] == false) {
      print('Cannot backup text: Key not found for contract $id');
      return;
    }
    
    String key = searchkey["key"];
    var contractsBox = Hive.box('contracts');
    List<dynamic> ofl = List.from(contractsBox.get('offline') ?? []);
    
    var message = {
      "content": encrypt(text, key),
      "type": 'text',
      'userId': userId,
      'id': id,
      'timestamp': DateTime.now().toIso8601String()
    };
    
    ofl.add(message);
    contractsBox.put('offline', ofl);
  } catch (e) {
    print('Add Text Backup Offline Error: $e');
  }
}

/// Get All Offline Messages (for sync)
List<Map<String, dynamic>> getOfflineMessages_offline() {
  try {
    var contractsBox = Hive.box('contracts');
    return List<Map<String, dynamic>>.from(contractsBox.get('offline') ?? []);
  } catch (e) {
    print('Get Offline Messages Error: $e');
    return [];
  }
}

/// Remove All Offline Messages (after successful sync)
void removeOfflineMessages_offline() {
  try {
    var contractsBox = Hive.box('contracts');
    contractsBox.put('offline', <dynamic>[]);
  } catch (e) {
    print('Remove Offline Messages Error: $e');
  }
}

/// Remove Specific Offline Message by ID
void removeOfflineMessageById_offline(String messageId) {
  try {
    var contractsBox = Hive.box('contracts');
    List<dynamic> offlineMessages = List.from(contractsBox.get('offline') ?? []);
    offlineMessages.removeWhere((msg) => msg['id'] == messageId);
    contractsBox.put('offline', offlineMessages);
  } catch (e) {
    print('Remove Offline Message By ID Error: $e');
  }
}