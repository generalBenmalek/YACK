// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:math';
// // import 'package:cloudinary_flutter/cloudinary_object.dart';
// // import "package:yack/db/offline.dart";
// // import 'package:firebase_database/firebase_database.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'dart:io';
// // import 'package:cloudinary_public/cloudinary_public.dart';

// // Future<String?> uploadAndGetUrl(File file, {CloudinaryResourceType type = CloudinaryResourceType.Auto}) async {
// //   try {
   
// //     final cloudinary = CloudinaryPublic('ddk6okquq', 'flutter_uploads');
// //     final cloudFile = CloudinaryFile.fromFile(file.path, resourceType: type);
// //     final res = await cloudinary.uploadFile(cloudFile);
// //     return res.secureUrl;
// //   } catch (e) {
// //     print('Error: $e');
// //     return null;
// //   }
// // }




// // /// Encryption and Decryption Utilities
// // /// ===================================

// // /// Encrypts data using XOR cipher with the provided key
// // /// 
// // /// [data]: The plain text to encrypt
// // /// [key]: The encryption key
// // /// Returns: Base64 encoded encrypted string
// // String encrypt(String data, String key) {
// //   final dataBytes = utf8.encode(data);
// //   final keyBytes = utf8.encode(key);
// //   final result = List<int>.filled(dataBytes.length, 0);
  
// //   for (int i = 0; i < dataBytes.length; i++) {
// //     result[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
// //   }
  
// //   return base64.encode(result);
// // }

// // /// Decrypts data using XOR cipher with the provided key
// // /// 
// // /// [encryptedData]: The base64 encoded encrypted data
// // /// [key]: The decryption key
// // /// Returns: Decrypted plain text string
// // String decrypt(String encryptedData, String key) {
// //   final dataBytes = base64.decode(encryptedData);
// //   final keyBytes = utf8.encode(key);
// //   final result = List<int>.filled(dataBytes.length, 0);
  
// //   for (int i = 0; i < dataBytes.length; i++) {
// //     result[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
// //   }
  
// //   return utf8.decode(result);
// // }

// // /// Key Generation
// // /// ==============

// // /// Generates a random key for encryption
// // /// 
// // /// [length]: The length of the key to generate (default: 10)
// // /// Returns: Randomly generated key string
// // String generateRandomKey({int length = 10}) {
// //   final random = Random.secure();
// //   const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=[]{}|;:,.<>?';
  
// //   final key = StringBuffer();
// //   for (int i = 0; i < length; i++) {
// //     key.write(chars[random.nextInt(chars.length)]);
// //   }
  
// //   return key.toString();
// // }

// // /// Contract Management
// // /// ===================

// // /// Registers a contract in Firebase after encrypting its data
// // /// 
// // /// [id]: The contract ID
// // /// [contract]: Map containing contract data (title, details, price)
// // /// Returns: Map with status indicating success or failure
// // Future<Map<String, dynamic>> registerContract(String id, Map<String, dynamic> contract) async {
// //   Map<String, dynamic> keySearchResult = await getKey(id);
  
// //   if (keySearchResult["status"] == false) {
// //     return {"status": false};
// //   }
  
// //   String key = keySearchResult["key"];
// //   var securedContract = {
// //     "title": encrypt(contract["title"], key),
// //     "details": encrypt(contract["details"], key),
// //     "price": encrypt(contract["price"].toString(), key)
// //   };
  
// //   DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id");
  
// //   try {
// //     await contractRef.set({
// //       "id": id,
// //       "contract": securedContract
// //     });
// //     return {"status": true};
// //   } catch (e) {
// //     return {"status": false};
// //   }
// // }

// // /// Reads and decrypts a contract from Firebase
// // /// 
// // /// [id]: The contract ID to read
// // /// Returns: Map with status and decrypted contract data
// // Future<Map<String, dynamic>> readContract(String id) async {
// //   Map<String, dynamic> keySearchResult = await getKey(id);
  
// //   if (keySearchResult["status"] == false) {
// //     return {"status": false};
// //   }
  
// //   String key = keySearchResult["key"];
// //   DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id");
  
// //   try {
// //     DatabaseEvent event = await contractRef.once();
// //     final data = event.snapshot.value;
    
// //     if (data != null && data is Map) {
// //       var encryptedContract = data['contracts'];
// //       var decryptedContract = {
// //         "title": decrypt(encryptedContract["title"], key),
// //         "details": decrypt(encryptedContract["details"], key),
// //         "price": decrypt(encryptedContract["price"], key)
// //       };
      
// //       return {"status": true, "contract": decryptedContract};
// //     }
    
// //     return {"status": false};
// //   } catch (e) {
// //     return {"status": false};
// //   }
// // }

// // /// Local Storage Management
// // /// ========================

// // /// Saves contract data to local storage
// // /// 
// // /// [contractData]: Map containing contract data to save
// // Future<void> saveContract(Map<String, dynamic> contractData) async {
// //   final prefs = await SharedPreferences.getInstance();
// //   List<String> contractsJson = prefs.getStringList('contracts') ?? [];
  
// //   contractsJson.add(json.encode(contractData));
// //   await prefs.setStringList('contracts', contractsJson);
// // }


// // Future<List> getAll() async {
// //   final prefs = await SharedPreferences.getInstance();
// //   List<String> contractsJson = prefs.getStringList('contracts') ?? [];
// //   List contracts = [];
// //   for (var i = 0; i < contractsJson.length; i++) {
// //     contracts.add( json.decode(contractsJson[i]) );
// //   }

// //   return contracts;
// // }


// // /// Retrieves encryption key for a specific contract from local storage
// // /// 
// // /// [contractId]: The contract ID to search for
// // /// Returns: Map with key and status
// // Future<Map<String, dynamic>> getKey(String contractId) async {
// //   final prefs = await SharedPreferences.getInstance();
// //   List<String> contractsJson = prefs.getStringList('contracts') ?? [];
  
// //   for (var contractJson in contractsJson) {
// //     var contract = json.decode(contractJson);
// //     if (contract['contractId'] == contractId) {
// //       return {'key': contract['contractkey'], "status": true};
// //     }
// //   }
  
// //   return {"status": false};
// // }

// // /// Invitation System
// // /// =================

// // /// Creates a contract invitation that waits for acceptance
// // /// 
// // /// [id]: The invitation/contract ID
// // /// [title]: Contract title
// // /// [details]: Contract details
// // /// [price]: Contract price
// // /// Returns: Map with status and contract data after acceptance or timeout
// // Future<Map<String, dynamic>> invite(String id, String title, String details, double price) async {
// //   var contract = {
// //     "title": title,
// //     "details": details,
// //     "price": price
// //   };
  
// //   DatabaseReference invitationRef = FirebaseDatabase.instance.ref("invitation/$id");
  
// //   await invitationRef.set({
// //     "accepted": false,
// //     "contract": contract,
// //     "key": 0
// //   });

// //   final completer = Completer<Map<String, dynamic>>();
// //   print(id);
// //   // Set 5-minute timeout
// //   final timeoutTimer = Timer(const Duration(minutes: 5), () {
// //     invitationRef.remove();
// //     completer.complete({"status": false, "contract": contract});
// //   });

// //   // Listen for acceptance
// //   final subscription = invitationRef.onValue.listen((DatabaseEvent event) {
// //     final data = event.snapshot.value;
    
// //     if (data != null && data is Map && data['accepted'] == true) {
// //       timeoutTimer.cancel();
// //       var contractData = {
// //         'contractId': id,
// //         "contractkey": data['key']
// //       };

// //       saveContract(contractData);
// //       registerContract(id , contract );
      
// //       invitationRef.remove();
// //       completer.complete({'status': true, "contract": contract});
// //     }
// //   });

// //   return completer.future;
// // }

// // /// Checks if a contract invitation exists
// // /// 
// // /// [contractId]: The contract ID to check
// // /// Returns: Map indicating if contract exists and its data
// // Future<Map<String, dynamic>> seeInv(String contractId) async {
// //   DatabaseReference ref = FirebaseDatabase.instance.ref("invitation/$contractId");
// //   DatabaseEvent event = await ref.once();
// //   final data = event.snapshot.value;
  
// //   if (data != null && data is Map) {
// //     return {"exists": true, "contract": data['contract']};
// //   }
  
// //   return {"exists": false};
// // }

// // /// Accepts a contract invitation and generates encryption key
// // /// 
// // /// [contractId]: The contract ID to accept
// // /// Returns: Map with acceptance status and generated key
// // Future<Map<String, dynamic>> acceptContract(String contractId) async {
// //   DatabaseReference ref = FirebaseDatabase.instance.ref("invitation/$contractId");
// //   String randomKey = generateRandomKey();
  
// //   await ref.update({
// //     "accepted": true,
// //     "key": randomKey
// //   });
  
// //   var contractData = {
// //     'contractId': contractId,
// //     "contractkey": randomKey
// //   };
  
// //   await saveContract(contractData);
  
// //   return {"status": true, "key": randomKey};
// // }










// // Future <Map<String, dynamic>> addFile (id , String userId , File fichier , String type) async{


// //   Map<String, dynamic> keySearchResult = await getKey(id);
  
// //   if (keySearchResult["status"] == false) {
// //     return {"status": false};
// //   }
// //   String? url = await uploadAndGetUrl(fichier);
// //   if(url == null){
// //         return {"status": false};
// //   }
// //   String key = keySearchResult["key"];
// //   DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/supportDocs");
  
// //   try {
// //     DatabaseEvent event = await contractRef.once();
// //     final data = event.snapshot.value;
// //       var message = {"content" : encrypt(url, key) , "type" :type , 'userId' : userId};
// //     if(data == null){
      
// //         contractRef.set([message]);
// //          return {"status": true};
// //     }

// //     if (data != null && data is List) {
// //       data.add(message);
// //       await contractRef.set(data);
// //       return {"status": true};
// //     }
    
// //     return {"status": false};
// //   } catch (e) {
// //     return {"status": false};
// //   }

// // }







// // Future <Map<String, dynamic>> addText (id , String userId , String text) async{
// //   Map<String, dynamic> keySearchResult = await getKey(id);
  
// //   if (keySearchResult["status"] == false) {
// //     return {"status": false};
// //   }
  
// //   String key = keySearchResult["key"];
// //   DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/supportDocs");
  
// //   try {
// //     DatabaseEvent event = await contractRef.once();
// //     final data = event.snapshot.value;
// //     if(data == null){
// //         var message = {"content" : encrypt(text, key) , "type" : 'text' , 'userId' : userId};
// //         contractRef.set([message]);
// //          return {"status": true};
// //     }

// //     if (data != null && data is List) {
// //       var message = {"content" : encrypt(text, key) , "type" : 'text' , 'userId' : userId};
// //       data.add(message);
// //       await contractRef.set(data);
// //       return {"status": true};
// //     }
    
// //     return {"status": false};
// //   } catch (e) {
// //     return {"status": false};
// //   }

// // }



// // Future <Map<String, dynamic>> readDocuments (id ) async{
// //   Map<String, dynamic> keySearchResult = await getKey(id);
  
// //   if (keySearchResult["status"] == false) {
// //     return {"status": false};
// //   }
  
// //   String key = keySearchResult["key"];
// //   DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/supportDocs");
  
// //   try {
// //     DatabaseEvent event = await contractRef.once();
// //     final data = event.snapshot.value;
    
// //     if (data != null && data is List) {
// //       for (var i = 0; i < data.length; i++) {
// //         data[i]["content"] = decrypt(    data[i]["content"], key);
// //       }
// //     }
// //     print(data);
// //     return {"status": true , "documents" : data};
// //   } catch (e) {
// //     return {"status": false};
// //   }

// // }



// // /// Retrieves and decrypts all contracts for the current user
// // /// 
// // /// Returns: Map with status and list of decrypted contracts
// // Future<Map<String, dynamic>> getAllContracts() async {
// //   try {
// //     List<dynamic> contracts = await getAll();
    
// //     // Return empty list if no contracts found
// //     if (contracts.isEmpty) {
// //       return {"status": true, "contracts": []};
// //     }
    
// //     List<Map<String, dynamic>> contractsDetails = [];
// //     print(' the contracts $contracts');
// //     for (var contract in contracts) {
// //       try {
// //         String id = contract["contractId"];
// //         String key = contract["contractkey"];
// //         print( contract);
// //         // Fetch contract data from Firebase
// //         DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/contract");
// //         DatabaseEvent event = await contractRef.once();
// //         final data = event.snapshot.value;
// //         print(data);

// //         // Verify data exists and has the expected structure
// //         if (data != null && data is Map) {
// //           var decryptedContract = {
// //             "id": id,
// //             "title": decrypt(data["title"], key),
// //             "details": decrypt(data["details"], key),
// //             "price": decrypt(data["price"], key)
// //           };
// //           print(decryptedContract);
// //           contractsDetails.add(decryptedContract);
// //         }

// //       } catch (e) {
// //         // Log error for individual contract but continue processing others
// //         print("Error processing contract $contract: $e");
// //         continue;
// //       }
// //     }
// //     print(contractsDetails);

// //     return {"status": true, "contracts": contractsDetails};
// //   } catch (e) {
// //     print("Error in getAllContracts: $e");
// //     return {"status": false, "error": e.toString()};
// //   }
// // }







// // /// Placeholder Functions
// // /// =====================

// // /// TODO: Implement user ID retrieval logic
// // Future<void> getUserIds() async {
// //   // Implementation pending
// // }

// // /// TODO: Implement main database manager initialization
// // void mainDbManager(String userId) {
// //   // Implementation pending
// // }



























// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:cloudinary_flutter/cloudinary_object.dart';
// import "package:yack/db/offline.dart";
// import 'package:firebase_database/firebase_database.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io';
// import 'package:cloudinary_public/cloudinary_public.dart';

// Future<String?> uploadAndGetUrl(File file, {CloudinaryResourceType type = CloudinaryResourceType.Auto}) async {
//   try {
//     final cloudinary = CloudinaryPublic('ddk6okquq', 'flutter_uploads');
//     final cloudFile = CloudinaryFile.fromFile(file.path, resourceType: type);
//     final res = await cloudinary.uploadFile(cloudFile);
//     return res.secureUrl;
//   } catch (e) {
//     print('Error: $e');
//     return null;
//   }
// }

// /// Encryption and Decryption Utilities
// /// ===================================

// String encrypt(String data, String key) {
//   final dataBytes = utf8.encode(data);
//   final keyBytes = utf8.encode(key);
//   final result = List<int>.filled(dataBytes.length, 0);
  
//   for (int i = 0; i < dataBytes.length; i++) {
//     result[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
//   }
  
//   return base64.encode(result);
// }

// String decrypt(String encryptedData, String key) {
//   final dataBytes = base64.decode(encryptedData);
//   final keyBytes = utf8.encode(key);
//   final result = List<int>.filled(dataBytes.length, 0);
  
//   for (int i = 0; i < dataBytes.length; i++) {
//     result[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
//   }
  
//   return utf8.decode(result);
// }

// /// Key Generation
// /// ==============

// String generateRandomKey({int length = 10}) {
//   final random = Random.secure();
//   const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=[]{}|;:,.<>?';
  
//   final key = StringBuffer();
//   for (int i = 0; i < length; i++) {
//     key.write(chars[random.nextInt(chars.length)]);
//   }
  
//   return key.toString();
// }










// //==========================================

// Future<Map<String, dynamic>> closeContract(String id, String userId) async {
//   Map<String, dynamic> keySearchResult = await getKey(id);
  
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
  
//   String key = keySearchResult["key"];
//   var secureduserid = encrypt(userId, key);
//   // Try online first, fallback to offline
//   try {
//     DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/close");
//      DatabaseEvent event = await contractRef.once();
//   final data = event.snapshot.value;
//   if(data == null){
//      await contractRef.set(secureduserid);
    
//     closeContract_offline( id,  userId);
//   }else{
//      DatabaseReference ref= FirebaseDatabase.instance.ref("contracts/$id");
//      await ref.remove();
//      await removeContract_offline(id);
//   }
   
//     return {"status": true};
//   } catch (e) {

//     return  {"status": false};
//   }
// }
// Future<Map<String, dynamic>> disputeContract(String id, String userId) async {
//   Map<String, dynamic> keySearchResult = await getKey(id);
  
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
  
//   String key = keySearchResult["key"];
//   var secureduserid = encrypt(userId, key);
//   // Try online first, fallback to offline
//   try {
//     DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/users");
//     Map disp = {};
//    DatabaseEvent event = await contractRef.once();
//   final data = event.snapshot.value;
//   if(data !=null && data is List){

//     for (var i = 0; i < data.length; i++) {
//       data[i] = decrypt(data[i], key);
//     }
  
//   }
//    var docs = await readDocuments(id);
//    var con = await readContract(id);
//    disp["contract"] = con;
//    disp["users"] = data;
//    disp["supportDocs"] = docs;
//    disp["data"] = DateTime.now();// enter the date and time of the dispute

//     DatabaseReference dispRef = FirebaseDatabase.instance.ref("dispute/$id");
//     await dispRef.set(disp);
//     dispute_offline(id, userId);
//     return {"status": true};
//   } catch (e) {

//     return  {"status": false};
//   }
// }


// /// Contract Management with Offline Fallback
// /// =========================================

// Future<Map<String, dynamic>> registerContract(String id, Map<String, dynamic> contract , users) async {
//   Map<String, dynamic> keySearchResult = await getKey(id);
  
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
  
//   String key = keySearchResult["key"];
//   var securedContract = {
//     "title": encrypt(contract["title"], key),
//     "details": encrypt(contract["details"], key),
//     "price": encrypt(contract["price"].toString(), key)
//   };
  
//   // Try online first, fallback to offline
//   try {
//     DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id");
//     await contractRef.set({
//       "id": id,
//       "contract": securedContract ,
//       "users" : users
//     });
    
//     // Also save to offline storage for redundancy
//     await registerContract_offline(id, contract);
    
//     return {"status": true};
//   } catch (e) {
//     print('Online registration failed, falling back to offline: $e');
//     // Fallback to offline storage
//     return await registerContract_offline(id, contract);
//   }
// }

// Future<Map<String, dynamic>> readContract(String id) async {
//   Map<String, dynamic> keySearchResult = await getKey(id);
  
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
  
//   // Try online first, fallback to offline
//   try {
//     String key = keySearchResult["key"];
//     DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id");
    
//     DatabaseEvent event = await contractRef.once();
//     final data = event.snapshot.value;
    
//     if (data != null && data is Map) {
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
//     print('Online read failed, falling back to offline: $e');
//     // Fallback to offline storage
//     return readContract_offline(id);
//   }
// }

// /// Local Storage Management (Hybrid - SharedPreferences + Hive)
// /// ============================================================

// Future<void> saveContract(Map<String, dynamic> contractData) async {
//   // Save to both SharedPreferences (for backward compatibility) and Hive
//   final prefs = await SharedPreferences.getInstance();
//   List<String> contractsJson = prefs.getStringList('contracts') ?? [];
  
//   contractsJson.add(json.encode(contractData));
//   await prefs.setStringList('contracts', contractsJson);
  
//   // Also save to Hive offline storage
//    saveContract_offline(contractData);
// }

// Future<List> getAll() async {
//   final prefs = await SharedPreferences.getInstance();
//   List<String> contractsJson = prefs.getStringList('contracts') ?? [];
//   List contracts = [];
//   for (var i = 0; i < contractsJson.length; i++) {
//     contracts.add(json.decode(contractsJson[i]));
//   }
//   return contracts;
// }

// Future<Map<String, dynamic>> getKey(String contractId) async {
//   // Try SharedPreferences first, then fallback to Hive
//   final prefs = await SharedPreferences.getInstance();
//   List<String> contractsJson = prefs.getStringList('contracts') ?? [];
  
//   for (var contractJson in contractsJson) {
//     var contract = json.decode(contractJson);
//     if (contract['contractId'] == contractId) {
//       return {'key': contract['contractkey'], "status": true};
//     }
//   }
  
//   // Fallback to Hive offline storage
//   return getKey_offline(contractId);
// }

// /// Invitation System (Online Only - No Changes)
// /// ============================================

// Future<Map<String, dynamic>> invite(String id, String title, String details, double price , String userId) async {
//   var contract = {
//     "title": title,
//     "details": details,
//     "price": price
//   };
  
//   DatabaseReference invitationRef = FirebaseDatabase.instance.ref("invitation/$id");
  
//   await invitationRef.set({
//     "accepted": false,
//     "contract": contract,
//     "key": 0
//   });

//   final completer = Completer<Map<String, dynamic>>();
//   print(id);
  
//   // Set 5-minute timeout
//   final timeoutTimer = Timer(const Duration(minutes: 5), () {
//     invitationRef.remove();
//     completer.complete({"status": false, "contract": contract});
//   });

//   // Listen for acceptance
//   final subscription = invitationRef.onValue.listen((DatabaseEvent event) {
//     final data = event.snapshot.value;
    
//     if (data != null && data is Map && data['accepted'] == true) {
//       timeoutTimer.cancel();
//       var contractData = {
//         'contractId': id,
//         "contractkey": data['key']
//       };
//       String key = data['key'];
//       var extuserId = data["userId"];
//       var users= [ encrypt(userId, key) ,encrypt(extuserId, key)];
//       saveContract(contractData);
//       registerContract(id, contract , users);
      
//       invitationRef.remove();
//       completer.complete({'status': true, "contract": contract});
//     }
//   });

//   return completer.future;
// }

// Future<Map<String, dynamic>> seeInv(String contractId) async {
//   DatabaseReference ref = FirebaseDatabase.instance.ref("invitation/$contractId");
//   DatabaseEvent event = await ref.once();
//   final data = event.snapshot.value;
  
//   if (data != null && data is Map) {
//     return {"exists": true, "contract": data['contract']};
//   }
  
//   return {"exists": false};
// }

// Future<Map<String, dynamic>> acceptContract(String contractId) async {
//   DatabaseReference ref = FirebaseDatabase.instance.ref("invitation/$contractId");
//   String randomKey = generateRandomKey();
  
//   await ref.update({
//     "accepted": true,
//     "key": randomKey
//   });
  
//   var contractData = {
//     'contractId': contractId,
//     "contractkey": randomKey
//   };
  
//   await saveContract(contractData);
  
//   return {"status": true, "key": randomKey};
// }

// /// Support Documents with Offline Fallback
// /// =======================================

// Future<Map<String, dynamic>> addFile(String id, String userId, File fichier, String type) async {
//   Map<String, dynamic> keySearchResult = await getKey(id);
  
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
  
//   String? url = await uploadAndGetUrl(fichier);
//   if (url == null) {
//     return {"status": false};
//   }
  
//   String key = keySearchResult["key"];
  
//   // Try online first, fallback to offline
//   try {
//     DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/supportDocs");
    
//     DatabaseEvent event = await contractRef.once();
//     final data = event.snapshot.value;
//     var message = {"content": encrypt(url, key), "type": type, 'userId': userId};
    
//     if (data == null) {
//       await contractRef.set([message]);
//       return {"status": true};
//     }

//     if (data != null && data is List) {
//       data.add(message);
//       await contractRef.set(data);
//       return {"status": true};
//     }
    
//     return {"status": false};
//   } catch (e) {
//     print('Online addFile failed, falling back to offline backup: $e');
//     // Add to offline backup queue for sync later
//     add_text_backup_offline(id, userId, url);
//     return {"status": true}; // Return true since it's queued for later sync
//   }
// }

// Future<Map<String, dynamic>> addText(String id, String userId, String text) async {
//   Map<String, dynamic> keySearchResult = await getKey(id);
  
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
  
//   String key = keySearchResult["key"];
  
//   // Try online first, fallback to offline
//   try {
//     DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/supportDocs");
    
//     DatabaseEvent event = await contractRef.once();
//     final data = event.snapshot.value;
    
//     if (data == null) {
//       var message = {"content": encrypt(text, key), "type": 'text', 'userId': userId};
//       await contractRef.set([message]);
//       return {"status": true};
//     }

//     if (data != null && data is List) {
//       var message = {"content": encrypt(text, key), "type": 'text', 'userId': userId};
//       data.add(message);
//       await contractRef.set(data);
//       return {"status": true};
//     }
    
//     return {"status": false};
//   } catch (e) {
//     print('Online addText failed, falling back to offline: $e');
//     // Try offline storage
//   add_text_backup_offline(id, userId, text);
   
//     return {"status": false , "offline" : true}; // Return false  but offline true since it's stored locally and will be added later
//   }
// }

// Future<Map<String, dynamic>> readDocuments(String id) async {
//   Map<String, dynamic> keySearchResult = await getKey(id);
  
//   if (keySearchResult["status"] == false) {
//     return {"status": false};
//   }
  
//   // Try online first, fallback to offline
//   try {
//     String key = keySearchResult["key"];
//     DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/supportDocs");
    
//     DatabaseEvent event = await contractRef.once();
//     final data = event.snapshot.value;
    
//     if (data != null && data is List) {
//       for (var i = 0; i < data.length; i++) {
//         data[i]["content"] = decrypt(data[i]["content"], key);
//       }
//     }
//     print(data);
//     return {"status": true, "documents": data};
//   } catch (e) {
//     print('Online readDocuments failed, falling back to offline: $e');
//     // Fallback to offline storage
//     return readDocuments_offline(id);
//   }
// }

// /// Contract Retrieval with Offline Fallback
// /// ========================================

// Future<Map<String, dynamic>> getAllContracts() async {
//   // Try online first
//   try {
//     List<dynamic> contracts = await getAll();
    
//     if (contracts.isEmpty) {
//       return {"status": true, "contracts": []};
//     }
    
//     List<Map<String, dynamic>> contractsDetails = [];
//     print(' the contracts $contracts');
    
//     for (var contract in contracts) {
//       try {
//         String id = contract["contractId"];
//         String key = contract["contractkey"];
//         print(contract);
        
//         // Try to fetch from Firebase
//         DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/contract");
//         DatabaseEvent event = await contractRef.once();
//         final data = event.snapshot.value;
//         print(data);

//         if (data != null && data is Map) {
//           var decryptedContract = {
//             "id": id,
//             "title": decrypt(data["title"], key),
//             "details": decrypt(data["details"], key),
//             "price": decrypt(data["price"], key)
//           };
//           print(decryptedContract);
//           contractsDetails.add(decryptedContract);
//         }
//       } catch (e) {
//         print("Error processing online contract $contract: $e");
//         // Try offline fallback for this specific contract
//         try {
//           var offlineContract = readContract_offline(contract["contractId"]);
//           if (offlineContract["status"] == true) {
//             var decrypted = offlineContract["contract"];
//             decrypted["id"] = contract["contractId"];
//             contractsDetails.add(decrypted);
//           }
//         } catch (offlineError) {
//           print("Offline fallback also failed for contract $contract: $offlineError");
//           continue;
//         }
//       }
//     }

//     return {"status": true, "contracts": contractsDetails};
//   } catch (e) {
//     print("Online getAllContracts failed, falling back to offline: $e");
//     // Complete fallback to offline storage
//     return getAllContracts_offline();
//   }
// }

// /// Sync Offline Data When Online
// /// =============================

// Future<void> syncOfflineData() async {
//   try {
//     // Get all queued offline messages
//     List<Map<String, dynamic>> offlineMessages = getOfflineMessages_offline();
    
//     for (var message in offlineMessages) {
//       try {
//         String id = message['id'];
//         String userId = message['userId'];
//         String content = decrypt(message['content'], (await getKey(id))['key']);
        
//         // Try to sync the message
//         if (message['type'] == 'text') {
//           await addText(id, userId, content);
//         }
//         // Remove from queue after successful sync
//         removeOfflineMessageById_offline(id);
//       } catch (e) {
//         print('Failed to sync offline message: $e');
//         // Keep in queue for next sync attempt
//       }
//     }
//   } catch (e) {
//     print('Error during offline data sync: $e');
//   }
// }

// /// Placeholder Functions
// /// =====================

// Future<void> getUserIds() async {
//   // Implementation pending
// }

// void mainDbManager(String userId) {
//   // Implementation pending
// }














import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import "package:yack/db/offline.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

Future<String?> uploadAndGetUrl(File file, {CloudinaryResourceType type = CloudinaryResourceType.Auto}) async {
  try {
    final cloudinary = CloudinaryPublic('ddk6okquq', 'flutter_uploads');
    final cloudFile = CloudinaryFile.fromFile(file.path, resourceType: type);
    final res = await cloudinary.uploadFile(cloudFile);
    return res.secureUrl;
  } catch (e) {
    print('Cloudinary Upload Error: $e');
    return null;
  }
}

/// Encryption and Decryption Utilities
String encrypt(String data, String key) {
  final dataBytes = utf8.encode(data);
  final keyBytes = utf8.encode(key);
  final result = List<int>.filled(dataBytes.length, 0);
  
  for (int i = 0; i < dataBytes.length; i++) {
    result[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
  }
  
  return base64.encode(result);
}

String decrypt(String encryptedData, String key) {
  try {
    final dataBytes = base64.decode(encryptedData);
    final keyBytes = utf8.encode(key);
    final result = List<int>.filled(dataBytes.length, 0);
    
    for (int i = 0; i < dataBytes.length; i++) {
      result[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    
    return utf8.decode(result);
  } catch (e) {
    print('Decryption Error: $e');
    return '';
  }
}

/// Key Generation
String generateRandomKey({int length = 10}) {
  final random = Random.secure();
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=[]{}|;:,.<>?';
  
  final key = StringBuffer();
  for (int i = 0; i < length; i++) {
    key.write(chars[random.nextInt(chars.length)]);
  }
  
  return key.toString();
}

/// Close Contract - Fixed logic with proper status handling
Future<Map<String, dynamic>> closeContract(String id, String userId) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);
    
    if (keySearchResult["status"] == false) {
      print('Close Contract Error: Key not found for contract $id');
      return {"status": false, "error": "Key not found"};
    }
    
    String key = keySearchResult["key"];
    var securedUserId = encrypt(userId, key);
    
    DatabaseReference dispRef = FirebaseDatabase.instance.ref("dispute/$id");
     DatabaseEvent eventdisp = await dispRef.once();
    final disp = eventdisp.snapshot.value;
    if(disp != null) return {"status": false};
    
    DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/close");
    DatabaseEvent event = await contractRef.once();
    final data = event.snapshot.value;
    
    if (data == null) {
      // First user requesting close
      await contractRef.set(securedUserId);
      closeContract_offline(id, userId);
      return {"status": true, "message": "Close request sent, waiting for confirmation"};
    } else {
      // Second user confirming - remove entire contract
      DatabaseReference ref = FirebaseDatabase.instance.ref("contracts/$id");
      await ref.remove();
      await removeContract_offline(id);
      return {"status": true, "message": "Contract closed successfully"};
    }
  } catch (e) {
    print('Close Contract Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Dispute Contract - Creates dispute with all contract data
Future<Map<String, dynamic>> disputeContract(String id, String userId) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);
    
    if (keySearchResult["status"] == false) {
      print('Dispute Contract Error: Key not found for contract $id');
      return {"status": false, "error": "Key not found"};
    }
    
    String key = keySearchResult["key"];
    
    // Get users
    DatabaseReference usersRef = FirebaseDatabase.instance.ref("contracts/$id/users");
    DatabaseEvent usersEvent = await usersRef.once();
    final usersData = usersEvent.snapshot.value;
    
    List<String> decryptedUsers = [];
    if (usersData != null && usersData is List) {
      for (var i = 0; i < usersData.length; i++) {
        try {
          decryptedUsers.add(decrypt(usersData[i], key));
        } catch (e) {
          print('Error decrypting user $i: $e');
        }
      }
    }
    
    // Get documents
    var docs = await readDocuments(id);
    
    // Get contract details
    var con = await readContract(id);
    
    if (con["status"] == false) {
      return {"status": false, "error": "Contract not found"};
    }
    
    // Prepare dispute data
    Map<String, dynamic> disp = {
      "contract": con["contract"],
      "users": decryptedUsers,
      "supportDocs": docs["status"] == true ? docs["documents"] : [],
      "date": DateTime.now().toIso8601String(),
      "disputedBy": userId
    };
    
    // Save dispute
    DatabaseReference dispRef = FirebaseDatabase.instance.ref("dispute/$id");
    await dispRef.set(disp);
    
    // Mark as disputed offline
    dispute_offline(id, userId);
    
    return {"status": true, "message": "Dispute created successfully"};
  } catch (e) {
    print('Dispute Contract Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// View All Disputes (Admin function with password protection)
Future<Map<String, dynamic>> viewAllDisputes(String password) async {
  try {
    // Check password against Firebase
    DatabaseReference passwordRef = FirebaseDatabase.instance.ref("admin/disputePassword");
    DatabaseEvent event = await passwordRef.once();
    final storedPassword = event.snapshot.value;
    
    if (storedPassword == null || storedPassword != password) {
      return {"status": false, "error": "Invalid password"};
    }
    
    // Password correct - fetch all disputes
    DatabaseReference disputeRef = FirebaseDatabase.instance.ref("dispute");
    DatabaseEvent disputeEvent = await disputeRef.once();
    final data = disputeEvent.snapshot.value;
    
    if (data == null || data is! Map) {
      return {"status": true, "disputes": []};
    }
    
    List<Map<String, dynamic>> disputes = [];
    data.forEach((key, value) {
      if (value is Map) {
        Map<String, dynamic> dispute = Map<String, dynamic>.from(value);
        dispute['id'] = key;
        disputes.add(dispute);
      }
    });
    
    return {"status": true, "disputes": disputes};
  } catch (e) {
    print('View All Disputes Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Register Contract with improved error handling
Future<Map<String, dynamic>> registerContract(String id, Map<String, dynamic> contract, List<String> users) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);
    
    if (keySearchResult["status"] == false) {
      print('Register Contract Error: Key not found for contract $id');
      return {"status": false, "error": "Key not found"};
    }
    
    String key = keySearchResult["key"];
    var securedContract = {
      "title": encrypt(contract["title"], key),
      "details": encrypt(contract["details"], key),
      "price": encrypt(contract["price"].toString(), key)
    };
    
    // Encrypt user IDs
    List<String> encryptedUsers = users.toList();
    
    DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id");
    await contractRef.set({
      "id": id,
      "contract": securedContract,
      "users": encryptedUsers
    });
    
    // Save to offline storage
    await registerContract_offline(id, contract);
    
    return {"status": true};
  } catch (e) {
    print('Register Contract Error: $e - Falling back to offline');
    return await registerContract_offline(id, contract);
  }
}

/// Read Contract with improved error handling
Future<Map<String, dynamic>> readContract(String id) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);
    
    if (keySearchResult["status"] == false) {
      print('Read Contract Error: Key not found for contract $id');
      return readContract_offline(id);
    }
    
    String key = keySearchResult["key"];
    DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id");
    
    DatabaseEvent event = await contractRef.once();
    final data = event.snapshot.value;
    
    if (data != null && data is Map) {
      var encryptedContract = data['contract'];
      
      String status = "pending";
      if (data["close"] != null) {
        status = data["close"] == "on dispute" ? "on dispute" : "to close";
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
    print('Read Contract Online Error: $e - Falling back to offline');
    return readContract_offline(id);
  }
}

/// Local Storage Management
Future<void> saveContract(Map<String, dynamic> contractData) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    List<String> contractsJson = prefs.getStringList('contracts') ?? [];
    
    contractsJson.add(json.encode(contractData));
    await prefs.setStringList('contracts', contractsJson);
    
    // Also save to offline storage
    saveContract_offline(contractData);
  } catch (e) {
    print('Save Contract Error: $e');
  }
}

Future<List> getAll() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    List<String> contractsJson = prefs.getStringList('contracts') ?? [];
    List contracts = [];
    for (var i = 0; i < contractsJson.length; i++) {
      contracts.add(json.decode(contractsJson[i]));
    }
    return contracts;
  } catch (e) {
    print('Get All Error: $e');
    return [];
  }
}

Future<Map<String, dynamic>> getKey(String contractId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    List<String> contractsJson = prefs.getStringList('contracts') ?? [];
    
    for (var contractJson in contractsJson) {
      var contract = json.decode(contractJson);
      if (contract['contractId'] == contractId) {
        return {'key': contract['contractkey'], "status": true};
      }
    }
    
    // Fallback to offline storage
    return getKey_offline(contractId);
  } catch (e) {
    print('Get Key Error: $e');
    return {"status": false};
  }
}

/// Invitation System - Fixed with proper cleanup
Future<Map<String, dynamic>> invite(String id, String title, String details, double price, String userId) async {
  var contract = {
    "title": title,
    "details": details,
    "price": price
  };
  
  try {
    DatabaseReference invitationRef = FirebaseDatabase.instance.ref("invitation/$id");
    
    await invitationRef.set({
      "accepted": false,
      "contract": contract,
      "key": 0,
      "invitedBy": userId
    });

    final completer = Completer<Map<String, dynamic>>();
    StreamSubscription? subscription;
    
    // Set 5-minute timeout
    final timeoutTimer = Timer(const Duration(minutes: 5), () {
      subscription?.cancel();
      invitationRef.remove();
      if (!completer.isCompleted) {
        completer.complete({"status": false, "contract": contract, "error": "Invitation timeout"});
      }
    });

    // Listen for acceptance
    subscription = invitationRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      
      if (data != null && data is Map && data['accepted'] == true) {
        timeoutTimer.cancel();
        subscription?.cancel();
        
        var contractData = {
          'contractId': id,
          "contractkey": data['key']
        };
        String key = data['key'];
        var extUserId = data["userId"];
        var users = [encrypt(userId, key), encrypt(extUserId, key)];
        
        saveContract(contractData);
        registerContract(id, contract, users);
        
        invitationRef.remove();
        
        if (!completer.isCompleted) {
          completer.complete({'status': true, "contract": contract});
        }
      }
    });

    return completer.future;
  } catch (e) {
    print('Invite Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

Future<Map<String, dynamic>> seeInv(String contractId) async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref("invitation/$contractId");
    DatabaseEvent event = await ref.once();
    final data = event.snapshot.value;
    
    if (data != null && data is Map) {
      return {"exists": true, "contract": data['contract']};
    }
    
    return {"exists": false};
  } catch (e) {
    print('See Invitation Error: $e');
    return {"exists": false, "error": e.toString()};
  }
}

/// Accept Contract - Fixed to include userId
Future<Map<String, dynamic>> acceptContract(String contractId, String userId) async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref("invitation/$contractId");
    String randomKey = generateRandomKey();
    
    await ref.update({
      "accepted": true,
      "key": randomKey,
      "userId": userId
    });
    
    var contractData = {
      'contractId': contractId,
      "contractkey": randomKey
    };
    
    await saveContract(contractData);
    
    return {"status": true, "key": randomKey};
  } catch (e) {
    print('Accept Contract Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Add File with improved error handling
Future<Map<String, dynamic>> addFile(String id, String userId, File fichier, String type) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);
    
    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }
    
    String? url = await uploadAndGetUrl(fichier);
    if (url == null) {
      return {"status": false, "error": "File upload failed"};
    }
    
    String key = keySearchResult["key"];
    DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/supportDocs");
    
    DatabaseEvent event = await contractRef.once();
    final data = event.snapshot.value;
    var message = {"content": encrypt(url, key), "type": type, 'userId': userId};
    
    if (data == null) {
      await contractRef.set([message]);
      return {"status": true};
    }

    if (data is List) {
      data.add(message);
      await contractRef.set(data);
      return {"status": true};
    }
    
    return {"status": false, "error": "Invalid data structure"};
  } catch (e) {
    print('Add File Error: $e');
    return {"status": false, "error": e.toString()};
  }
}

/// Add Text - Only backs up offline for later sync
Future<Map<String, dynamic>> addText(String id, String userId, String text) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);
    
    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }
    
    String key = keySearchResult["key"];
    DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/supportDocs");
    
    DatabaseEvent event = await contractRef.once();
    final data = event.snapshot.value;
    
    if (data == null) {
      var message = {"content": encrypt(text, key), "type": 'text', 'userId': userId};
      await contractRef.set([message]);
      return {"status": true};
    }

    if (data is List) {
      var message = {"content": encrypt(text, key), "type": 'text', 'userId': userId};
      data.add(message);
      await contractRef.set(data);
      return {"status": true};
    }
    
    return {"status": false, "error": "Invalid data structure"};
  } catch (e) {
    print('Add Text Online Failed: $e - Backing up for later sync');
    // Backup for sync when online
    add_text_backup_offline(id, userId, text);
    return {"status": true, "offline": true, "queued": true};
  }
}

/// Read Documents with improved error handling
Future<Map<String, dynamic>> readDocuments(String id) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);
    
    if (keySearchResult["status"] == false) {
      return readDocuments_offline(id);
    }
    
    String key = keySearchResult["key"];
    DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/supportDocs");
    
    DatabaseEvent event = await contractRef.once();
    final data = event.snapshot.value;
    
    if (data != null && data is List) {
      for (var i = 0; i < data.length; i++) {
        data[i]["content"] = decrypt(data[i]["content"], key);
      }
      return {"status": true, "documents": data};
    }
    
    return {"status": true, "documents": []};
  } catch (e) {
    print('Read Documents Online Error: $e - Falling back to offline');
    return readDocuments_offline(id);
  }
}

/// Get All Contracts with improved error handling
Future<Map<String, dynamic>> getAllContracts() async {
  try {
    List<dynamic> contracts = await getAll();
    
    if (contracts.isEmpty) {
      return {"status": true, "contracts": []};
    }
    
    List<Map<String, dynamic>> contractsDetails = [];
    
    for (var contract in contracts) {
      try {
        String id = contract["contractId"];
        String key = contract["contractkey"];
        
        DatabaseReference contractRef = FirebaseDatabase.instance.ref("contracts/$id/contract");
        DatabaseEvent event = await contractRef.once();
        final data = event.snapshot.value;

        if (data != null && data is Map) {
          var decryptedContract = {
            "id": id,
            "title": decrypt(data["title"], key),
            "details": decrypt(data["details"], key),
            "price": decrypt(data["price"], key)
          };
          contractsDetails.add(decryptedContract);
        }
      } catch (e) {
        print("Error processing contract ${contract['contractId']}: $e - Trying offline");
        
        // Fallback to offline for this contract
        try {
          var offlineContract = readContract_offline(contract["contractId"]);
          if (offlineContract["status"] == true) {
            var decrypted = offlineContract["contract"];
            decrypted["id"] = contract["contractId"];
            contractsDetails.add(decrypted);
          }
        } catch (offlineError) {
          print("Offline fallback also failed: $offlineError");
          continue;
        }
      }
    }

    return {"status": true, "contracts": contractsDetails};
  } catch (e) {
    print("Get All Contracts Error: $e - Falling back to offline");
    return getAllContracts_offline();
  }
}

/// Sync Offline Data When Online
Future<void> syncOfflineData() async {
  try {
    List<Map<String, dynamic>> offlineMessages = getOfflineMessages_offline();
    
    for (var message in offlineMessages) {
      try {
        String id = message['id'];
        String userId = message['userId'];
        String content = message['content'];
        
        var keyResult = await getKey(id);
        if (keyResult["status"] == false) {
          print('Sync failed for message ${message['id']}: Key not found');
          continue;
        }
        
        String key = keyResult['key'];
        String decryptedContent = decrypt(content, key);
        
        // Try to sync the message
        if (message['type'] == 'text') {
          var result = await addText(id, userId, decryptedContent);
          if (result["status"] == true && result["offline"] != true) {
            // Successfully synced - remove from queue
            removeOfflineMessageById_offline(id);
          }
        }
      } catch (e) {
        print('Failed to sync offline message ${message['id']}: $e');
      }
    }
  } catch (e) {
    print('Error during offline data sync: $e');
  }
}