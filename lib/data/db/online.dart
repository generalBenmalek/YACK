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
import "package:yack/data/db/offline.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:yack/data/repositories/isar_adapter.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

Future<String?> uploadAndGetUrl(
  File file, {
  CloudinaryResourceType type = CloudinaryResourceType.Auto,
}) async {
  try {
    final cloudinary = CloudinaryPublic('ddk6okquq', 'flutter_uploads');
    final cloudFile = CloudinaryFile.fromFile(file.path, resourceType: type);
    final res = await cloudinary.uploadFile(cloudFile);
    return res.secureUrl;
  } catch (e) {
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
    return '';
  }
}

/// Key Generation
String generateRandomKey({int length = 10}) {
  final random = Random.secure();
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_-+=[]{}|;:,.<>?';

  final key = StringBuffer();
  for (int i = 0; i < length; i++) {
    key.write(chars[random.nextInt(chars.length)]);
  }

  return key.toString();
}

/// Close Contract - Requires both parties to confirm (Chadli)
Future<Map<String, dynamic>> closeContract(String id, String userId) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);

    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }

    String key = keySearchResult["key"];
    var securedUserId = encrypt(userId, key);

    // Check for disputes (Chadli)
    DatabaseReference dispRef = FirebaseDatabase.instance.ref("dispute/$id");
    DatabaseEvent eventdisp = await dispRef.once();
    final disp = eventdisp.snapshot.value;
    if (disp != null) return {"status": false, "error": "Contract is disputed"};

    DatabaseReference closeRef = FirebaseDatabase.instance.ref(
      "contracts/$id/close",
    );
    DatabaseEvent event = await closeRef.once();
    final data = event.snapshot.value;

    if (data == null) {
      // First user requesting close (Chadli)
      await closeRef.set(securedUserId);
      return {
        "status": true,
        "message": "Close request sent, waiting for confirmation",
      };
    } else {
      // Someone already requested - check if it's the same user (Chadli)
      String existingUserId = '';
      try {
        existingUserId = decrypt(data.toString(), key);
      } catch (_) {}

      // Same user clicking again - just return waiting status (Chadli)
      if (existingUserId == userId) {
        return {
          "status": true,
          "message": "Close request sent, waiting for confirmation",
        };
      }

      // Different user confirming - mark as completed (Chadli)
      DatabaseReference completedRef = FirebaseDatabase.instance.ref(
        "completedContracts/$id",
      );
      await completedRef.set({
        'completedAt': ServerValue.timestamp,
        'confirmedBy': securedUserId,
        'requestedBy': data.toString(),
      });

      // Update local status (Chadli)
      await updateContractStatusInIsar(id, 'completed');

      // Remove from active contracts (Chadli)
      DatabaseReference ref = FirebaseDatabase.instance.ref("contracts/$id");
      await ref.remove();

      return {"status": true, "message": "Contract closed successfully"};
    }
  } catch (e) {
    return {"status": false, "error": e.toString()};
  }
}

/// Decline completion request (Chadli)
Future<void> declineCompletion(String id) async {
  try {
    DatabaseReference closeRef = FirebaseDatabase.instance.ref(
      "contracts/$id/close",
    );
    await closeRef.remove();
  } catch (_) {}
}

/// Check and sync completed contracts status on app startup (Chadli)
Future<void> syncCompletedContractsStatus() async {
  try {
    final contracts = await getAll();

    for (var contract in contracts) {
      final id = contract['contractId'];
      if (id == null) continue;

      // Check if this contract was completed (Chadli)
      final completedRef = FirebaseDatabase.instance.ref(
        'completedContracts/$id',
      );
      final snapshot = await completedRef.get();

      if (snapshot.exists && snapshot.value != null) {
        await updateContractStatusInIsar(id, 'completed');
      }
    }
  } catch (_) {}
}

/// Dispute Contract - Creates dispute with all contract data
Future<Map<String, dynamic>> disputeContract(String id, String userId) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);

    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }

    String key = keySearchResult["key"];

    // Get users
    DatabaseReference usersRef = FirebaseDatabase.instance.ref(
      "contracts/$id/users",
    );
    DatabaseEvent usersEvent = await usersRef.once();
    final usersData = usersEvent.snapshot.value;

    List<String> decryptedUsers = [];
    if (usersData != null && usersData is List) {
      for (var i = 0; i < usersData.length; i++) {
        try {
          decryptedUsers.add(decrypt(usersData[i], key));
        } catch (_) {}
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
      "disputedBy": userId,
    };

    // Save dispute
    DatabaseReference dispRef = FirebaseDatabase.instance.ref("dispute/$id");
    await dispRef.set(disp);

    // Mark as disputed offline
    dispute_offline(id, userId);

    // update isar status: Chadli
    await updateContractStatusInIsar(id, 'disputed');

    return {"status": true, "message": "Dispute created successfully"};
  } catch (e) {
    return {"status": false, "error": e.toString()};
  }
}

/// View All Disputes (Admin function with password protection)
Future<Map<String, dynamic>> viewAllDisputes(String password) async {
  try {
    // Check password against Firebase
    DatabaseReference passwordRef = FirebaseDatabase.instance.ref(
      "admin/disputePassword",
    );
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
    return {"status": false, "error": e.toString()};
  }
}

/// Register Contract with improved error handling
Future<Map<String, dynamic>> registerContract(
  String id,
  Map<String, dynamic> contract,
  List<String> users,
) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);

    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }

    String key = keySearchResult["key"];
    var securedContract = {
      "title": encrypt(contract["title"], key),
      "details": encrypt(contract["details"], key),
      "price": encrypt(contract["price"].toString(), key),
    };

    // Encrypt user IDs
    List<String> encryptedUsers = users.toList();

    DatabaseReference contractRef = FirebaseDatabase.instance.ref(
      "contracts/$id",
    );
    await contractRef.set({
      "id": id,
      "contract": securedContract,
      "users": encryptedUsers,
    });

    // Save to offline storage
    await registerContract_offline(id, contract);

    // Sync to isar
    await saveContractToIsar(
      externalId: id,
      name: contract["title"] ?? '',
      description: contract["details"] ?? '',
      price: double.tryParse(contract["price"].toString()) ?? 0.0,
      userA: users.isNotEmpty ? decrypt(users[0], key) : '',
      userB: users.length > 1 ? decrypt(users[1], key) : '',
      status: 'accepted',
    );

    return {"status": true};
  } catch (e) {
    return await registerContract_offline(id, contract);
  }
}

/// Read Contract with improved error handling
Future<Map<String, dynamic>> readContract(String id) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);

    if (keySearchResult["status"] == false) {
      return readContract_offline(id);
    }

    String key = keySearchResult["key"];
    DatabaseReference contractRef = FirebaseDatabase.instance.ref(
      "contracts/$id",
    );

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
        "status": status,
      };

      return {"status": true, "contract": decryptedContract};
    }

    return {"status": false, "error": "Contract not found"};
  } catch (e) {
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

    saveContract_offline(contractData);
  } catch (_) {}
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

    return getKey_offline(contractId);
  } catch (e) {
    return {"status": false};
  }
}

/// Active invitation listeners - used for cleanup when user navigates away (Chadli)
Map<String, StreamSubscription?> _activeInvitations = {};
Map<String, Timer?> _activeTimers = {};
Map<String, Completer<Map<String, dynamic>>?> _activeCompleters = {};

/// Invitation System - Fixed with proper cleanup
Future<Map<String, dynamic>> invite(
  String id,
  String title,
  String details,
  double price,
  String userId,
) async {
  var contract = {"title": title, "details": details, "price": price};

  try {
    DatabaseReference invitationRef = FirebaseDatabase.instance.ref(
      "invitation/$id",
    );

    await invitationRef.set({
      "accepted": false,
      "contract": contract,
      "key": 0,
      "invitedBy": userId,
    });

    final completer = Completer<Map<String, dynamic>>();
    _activeCompleters[id] = completer;
    StreamSubscription? subscription;

    // Set 5-minute timeout
    final timeoutTimer = Timer(const Duration(minutes: 5), () {
      _cleanupInvitation(id);
      invitationRef.remove();
      if (!completer.isCompleted) {
        completer.complete({
          "status": false,
          "contract": contract,
          "error": "Invitation timeout",
        });
      }
    });
    _activeTimers[id] = timeoutTimer;

    // Listen for acceptance
    subscription = invitationRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;

      if (data != null && data is Map && data['accepted'] == true) {
        _cleanupInvitation(id);

        var contractData = {'contractId': id, "contractkey": data['key']};
        String key = data['key'];
        var extUserId = data["userId"];
        var extUserName = data["userName"]; // Get userB's display name (Chadli)
        var users = [encrypt(userId, key), encrypt(extUserId, key)];

        // CRITICAL: Must await saveContract before registerContract (Chadli)
        await saveContract(contractData);

        // Save contract key to Firebase for cross-device sync (Chadli)
        await _saveUserContractKey(userId, id, key);

        await registerContract(id, contract, users);

        await invitationRef.remove();

        if (!completer.isCompleted) {
          // Return userB info so caller can update local contract (Chadli)
          completer.complete({
            'status': true,
            'contract': contract,
            'userB': extUserId,
            'userBName': extUserName,
          });
        }
      }
    });
    _activeInvitations[id] = subscription;

    return completer.future;
  } catch (e) {
    return {"status": false, "error": e.toString()};
  }
}

/// Cleanup active invitation listeners and timers (Chadli)
void _cleanupInvitation(String id) {
  _activeTimers[id]?.cancel();
  _activeTimers.remove(id);
  _activeInvitations[id]?.cancel();
  _activeInvitations.remove(id);
  _activeCompleters.remove(id);
}

Future<Map<String, dynamic>> seeInv(String contractId) async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      "invitation/$contractId",
    );
    DatabaseEvent event = await ref.once();
    final data = event.snapshot.value;

    if (data != null && data is Map) {
      return {"exists": true, "contract": data['contract']};
    }

    return {"exists": false};
  } catch (e) {
    return {"exists": false, "error": e.toString()};
  }
}

/// Accept Contract - Fixed to include userId and userName (Chadli)
Future<Map<String, dynamic>> acceptContract(
  String contractId,
  String userId,
  String userName,
  Map<String, dynamic> contractDetails,
  String inviterId,
) async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      "invitation/$contractId",
    );

    final snapshot = await ref.get();
    String randomKey = generateRandomKey();

    if (snapshot.exists) {
      // Update existing invitation with userName (Chadli)
      await ref.update({
        "accepted": true,
        "key": randomKey,
        "userId": userId,
        "userName": userName,
      });
    } else {
      // Create new invitation entry (for testing or if inviter didn't start properly)
      await ref.set({
        "accepted": true,
        "key": randomKey,
        "userId": userId,
        "userName": userName,
        "contract": contractDetails,
      });
    }

    var contractData = {'contractId': contractId, "contractkey": randomKey};

    await saveContract(contractData);

    // Save contract key to user's Firebase storage for cross-device sync (Chadli)
    await _saveUserContractKey(userId, contractId, randomKey);
    await _saveUserContractKey(inviterId, contractId, randomKey);

    // Register contract in Firebase immediately (Chadli)
    // This ensures the contract exists even if the inviter is offline
    var users = [encrypt(inviterId, randomKey), encrypt(userId, randomKey)];
    await registerContract(contractId, contractDetails, users);

    return {"status": true, "key": randomKey};
  } catch (e) {
    return {"status": false, "error": e.toString()};
  }
}

/// Save contract key to user's Firebase storage for cross-device sync (Chadli)
Future<void> _saveUserContractKey(
  String userId,
  String contractId,
  String key,
) async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      "userContracts/$userId/$contractId",
    );
    await ref.set({'key': key, 'addedAt': ServerValue.timestamp});
  } catch (_) {}
}

/// Add File with improved error handling
Future<Map<String, dynamic>> addFile(
  String id,
  String userId,
  File fichier,
  String type,
) async {
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
    DatabaseReference contractRef = FirebaseDatabase.instance.ref(
      "contracts/$id/supportDocs",
    );

    DatabaseEvent event = await contractRef.once();
    final data = event.snapshot.value;
    var message = {
      "content": encrypt(url, key),
      "type": type,
      'userId': userId,
    };

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
    return {"status": false, "error": e.toString()};
  }
}

/// Add Text - Only backs up offline for later sync
Future<Map<String, dynamic>> addText(
  String id,
  String userId,
  String text,
) async {
  try {
    Map<String, dynamic> keySearchResult = await getKey(id);

    if (keySearchResult["status"] == false) {
      return {"status": false, "error": "Key not found"};
    }

    String key = keySearchResult["key"];
    DatabaseReference contractRef = FirebaseDatabase.instance.ref(
      "contracts/$id/supportDocs",
    );

    DatabaseEvent event = await contractRef.once();
    final data = event.snapshot.value;

    if (data == null) {
      var message = {
        "content": encrypt(text, key),
        "type": 'text',
        'userId': userId,
      };
      await contractRef.set([message]);
      return {"status": true};
    }

    if (data is List) {
      var message = {
        "content": encrypt(text, key),
        "type": 'text',
        'userId': userId,
      };
      data.add(message);
      await contractRef.set(data);
      return {"status": true};
    }

    return {"status": false, "error": "Invalid data structure"};
  } catch (e) {
    // Backup for sync when online (Chadli)
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
    DatabaseReference contractRef = FirebaseDatabase.instance.ref(
      "contracts/$id/supportDocs",
    );

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

        DatabaseReference contractRef = FirebaseDatabase.instance.ref(
          "contracts/$id/contract",
        );
        DatabaseEvent event = await contractRef.once();
        final data = event.snapshot.value;

        if (data != null && data is Map) {
          var decryptedContract = {
            "id": id,
            "title": decrypt(data["title"], key),
            "details": decrypt(data["details"], key),
            "price": decrypt(data["price"], key),
          };
          contractsDetails.add(decryptedContract);
        }
      } catch (e) {
        // Fallback to offline for this contract (Chadli)
        try {
          var offlineContract = readContract_offline(contract["contractId"]);
          if (offlineContract["status"] == true) {
            var decrypted = offlineContract["contract"];
            decrypted["id"] = contract["contractId"];
            contractsDetails.add(decrypted);
          }
        } catch (offlineError) {
          continue;
        }
      }
    }

    return {"status": true, "contracts": contractsDetails};
  } catch (e) {
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
        // Sync failed for message, will retry later (Chadli)
      }
    }
  } catch (e) {
    // Offline sync error, will retry later (Chadli)
  }
}

/// Cancel an invitation and clean up Firebase (Chadli)
Future<void> cancelInvitation(String contractId) async {
  try {
    // First cleanup local listeners/timers
    _cleanupInvitation(contractId);

    // Complete the completer if it exists and is not completed
    final completer = _activeCompleters[contractId];
    if (completer != null && !completer.isCompleted) {
      completer.complete({
        "status": false,
        "error": "Invitation cancelled by user",
      });
    }

    // Remove from Firebase
    DatabaseReference invitationRef = FirebaseDatabase.instance.ref(
      "invitation/$contractId",
    );
    await invitationRef.remove();
  } catch (_) {}
}

/// Sync contracts from Firebase to Isar for the current user (Chadli)
/// Called after login to restore contracts on new device
Future<void> syncContractsFromFirebase(String userId) async {
  try {
    // Get all contracts where this user is a participant
    DatabaseReference contractsRef = FirebaseDatabase.instance.ref("contracts");
    DatabaseEvent event = await contractsRef.once();
    final data = event.snapshot.value;

    if (data == null || data is! Map) return;

    // Iterate through all contracts
    for (var entry in data.entries) {
      try {
        final contractId = entry.key;
        final contractData = entry.value;

        if (contractData == null || contractData is! Map) continue;

        // Check if user is a participant
        final users = contractData['users'];
        if (users == null || users is! List) continue;

        // We need to check if user is in the encrypted users list
        // First, we need to find the key for this contract
        var keyResult = await getKey(contractId);

        bool isParticipant = false;
        String? userAId;
        String? userBId;

        if (keyResult["status"] == true) {
          // We have the key - decrypt and check
          String key = keyResult["key"];
          for (int i = 0; i < users.length; i++) {
            try {
              String decryptedUser = decrypt(users[i], key);
              if (i == 0) userAId = decryptedUser;
              if (i == 1) userBId = decryptedUser;
              if (decryptedUser == userId) {
                isParticipant = true;
              }
            } catch (_) {}
          }
        }

        if (!isParticipant) continue;

        // User is a participant - sync this contract to Isar
        final contractInfo = contractData['contract'];
        if (contractInfo == null || contractInfo is! Map) continue;

        String key = keyResult["key"];

        // Decrypt contract data
        String title = '';
        String details = '';
        double price = 0.0;

        try {
          title = decrypt(contractInfo["title"] ?? '', key);
          details = decrypt(contractInfo["details"] ?? '', key);
          price =
              double.tryParse(decrypt(contractInfo["price"] ?? '0', key)) ??
              0.0;
        } catch (_) {
          continue;
        }

        // Determine status
        String status = 'accepted';
        if (contractData['close'] != null) {
          status = 'pending'; // Waiting for close confirmation
        }

        // Check if disputed
        DatabaseReference dispRef = FirebaseDatabase.instance.ref(
          "dispute/$contractId",
        );
        final dispSnapshot = await dispRef.get();
        if (dispSnapshot.exists) {
          status = 'disputed';
        }

        // Check if completed
        DatabaseReference completedRef = FirebaseDatabase.instance.ref(
          "completedContracts/$contractId",
        );
        final completedSnapshot = await completedRef.get();
        if (completedSnapshot.exists) {
          status = 'completed';
        }

        // Save to Isar
        await saveContractToIsar(
          externalId: contractId,
          name: title,
          description: details,
          price: price,
          userA: userAId ?? '',
          userB: userBId ?? '',
          status: status,
        );

        // Also save contract key to SharedPreferences if not already there
        final prefs = await SharedPreferences.getInstance();
        List<String> contractsJson = prefs.getStringList('contracts') ?? [];
        bool keyExists = contractsJson.any((c) {
          try {
            var parsed = json.decode(c);
            return parsed['contractId'] == contractId;
          } catch (_) {
            return false;
          }
        });

        if (!keyExists) {
          contractsJson.add(
            json.encode({'contractId': contractId, 'contractkey': key}),
          );
          await prefs.setStringList('contracts', contractsJson);
        }
      } catch (_) {
        // Error processing this contract, continue to next
      }
    }
  } catch (_) {
    // Sync error
  }
}

/// Fetch user's contracts by checking Firebase for contracts where user is participant (Chadli)
/// This uses a different approach - checks the user's stored keys
Future<void> syncContractsUsingStoredKeys(String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    List<String> contractsJson = prefs.getStringList('contracts') ?? [];

    for (var contractJson in contractsJson) {
      try {
        var contract = json.decode(contractJson);
        String contractId = contract['contractId'];
        String key = contract['contractkey'];

        // Check if contract exists in Firebase
        DatabaseReference contractRef = FirebaseDatabase.instance.ref(
          "contracts/$contractId",
        );
        DatabaseEvent event = await contractRef.once();
        final data = event.snapshot.value;

        if (data == null || data is! Map) continue;

        final contractInfo = data['contract'];
        if (contractInfo == null || contractInfo is! Map) continue;

        // Decrypt contract data
        String title = '';
        String details = '';
        double price = 0.0;
        String? userAId;
        String? userBId;

        try {
          title = decrypt(contractInfo["title"] ?? '', key);
          details = decrypt(contractInfo["details"] ?? '', key);
          price =
              double.tryParse(decrypt(contractInfo["price"] ?? '0', key)) ??
              0.0;

          // Decrypt users
          final users = data['users'];
          if (users != null && users is List) {
            if (users.isNotEmpty) userAId = decrypt(users[0], key);
            if (users.length > 1) userBId = decrypt(users[1], key);
          }
        } catch (_) {
          continue;
        }

        // Determine status
        String status = 'accepted';
        if (data['close'] != null) {
          status = 'pending';
        }

        // Check if disputed
        DatabaseReference dispRef = FirebaseDatabase.instance.ref(
          "dispute/$contractId",
        );
        final dispSnapshot = await dispRef.get();
        if (dispSnapshot.exists) {
          status = 'disputed';
        }

        // Check if completed
        DatabaseReference completedRef = FirebaseDatabase.instance.ref(
          "completedContracts/$contractId",
        );
        final completedSnapshot = await completedRef.get();
        if (completedSnapshot.exists) {
          status = 'completed';
        }

        // Save to Isar
        await saveContractToIsar(
          externalId: contractId,
          name: title,
          description: details,
          price: price,
          userA: userAId ?? '',
          userB: userBId ?? '',
          status: status,
        );
      } catch (_) {
        // Error processing this contract
      }
    }
  } catch (_) {
    // Sync error
  }
}

/// Sync contracts from Firebase userContracts node (Chadli)
/// This fetches the contract keys stored per user for cross-device sync
Future<void> syncContractsFromUserNode(String userId) async {
  try {
    print('Starting syncContractsFromUserNode for user: $userId');

    // Fetch user's contract keys from Firebase
    DatabaseReference userContractsRef = FirebaseDatabase.instance.ref(
      "userContracts/$userId",
    );
    DatabaseEvent event = await userContractsRef.once();
    final data = event.snapshot.value;

    print('User contracts data from Firebase: $data');

    if (data == null || data is! Map) {
      print('No user contracts found in Firebase for user: $userId');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> contractsJson = prefs.getStringList('contracts') ?? [];
    bool keysUpdated = false;

    // Process each contract
    for (var entry in data.entries) {
      try {
        final contractId = entry.key.toString();
        final contractMeta = entry.value;

        print('Processing contract: $contractId');

        if (contractMeta == null || contractMeta is! Map) {
          print('Invalid contract meta for $contractId');
          continue;
        }

        String? key = contractMeta['key']?.toString();
        if (key == null || key.isEmpty) {
          print('No key found for contract $contractId');
          continue;
        }

        // Check if we already have this key locally
        bool keyExists = contractsJson.any((c) {
          try {
            var parsed = json.decode(c);
            return parsed['contractId'] == contractId;
          } catch (_) {
            return false;
          }
        });

        // Save key locally if not exists - CRITICAL for decryption
        if (!keyExists) {
          print('Adding key for contract $contractId to local storage');
          contractsJson.add(
            json.encode({'contractId': contractId, 'contractkey': key}),
          );
          keysUpdated = true;

          // Also save to Hive offline storage
          saveContract_offline({'contractId': contractId, 'contractkey': key});
        }

        // Save keys immediately before trying to fetch contract data
        if (keysUpdated) {
          await prefs.setStringList('contracts', contractsJson);
          keysUpdated = false;
        }

        // Now fetch and sync the contract data
        DatabaseReference contractRef = FirebaseDatabase.instance.ref(
          "contracts/$contractId",
        );
        DatabaseEvent contractEvent = await contractRef.once();
        final contractData = contractEvent.snapshot.value;

        print('Contract data from Firebase for $contractId: $contractData');

        if (contractData == null || contractData is! Map) {
          print(
            'Contract $contractId not found in active contracts, checking completed...',
          );

          // Check if it's a completed contract
          DatabaseReference completedRef = FirebaseDatabase.instance.ref(
            "completedContracts/$contractId",
          );
          final completedSnapshot = await completedRef.get();
          if (completedSnapshot.exists) {
            // Try to get contract info from completed data if available
            print('Contract $contractId is completed');
          }
          continue;
        }

        final contractInfo = contractData['contract'];
        if (contractInfo == null || contractInfo is! Map) {
          print('Invalid contract info for $contractId');
          continue;
        }

        // Decrypt contract data
        String title = '';
        String details = '';
        double price = 0.0;
        String? userAId;
        String? userBId;

        try {
          title = decrypt(contractInfo["title"]?.toString() ?? '', key);
          details = decrypt(contractInfo["details"]?.toString() ?? '', key);
          price =
              double.tryParse(
                decrypt(contractInfo["price"]?.toString() ?? '0', key),
              ) ??
              0.0;

          // Decrypt users
          final users = contractData['users'];
          if (users != null && users is List) {
            if (users.isNotEmpty) userAId = decrypt(users[0].toString(), key);
            if (users.length > 1) userBId = decrypt(users[1].toString(), key);
          }

          print('Decrypted contract $contractId: title=$title, price=$price');
        } catch (e) {
          print('Error decrypting contract $contractId: $e');
          continue;
        }

        // Determine status
        String status = 'accepted';
        if (contractData['close'] != null) {
          status = 'pending'; // Close requested, waiting for confirmation
        }

        // Check if disputed
        DatabaseReference dispRef = FirebaseDatabase.instance.ref(
          "dispute/$contractId",
        );
        final dispSnapshot = await dispRef.get();
        if (dispSnapshot.exists) {
          status = 'disputed';
        }

        // Check if completed
        DatabaseReference completedRef = FirebaseDatabase.instance.ref(
          "completedContracts/$contractId",
        );
        final completedSnapshot = await completedRef.get();
        if (completedSnapshot.exists) {
          status = 'completed';
        }

        print('Saving contract $contractId to Isar with status: $status');

        // Save to Isar
        await saveContractToIsar(
          externalId: contractId,
          name: title,
          description: details,
          price: price,
          userA: userAId ?? '',
          userB: userBId ?? '',
          status: status,
        );

        print('Successfully synced contract $contractId');
      } catch (e) {
        print('Error processing contract in syncContractsFromUserNode: $e');
      }
    }

    // Save any remaining key updates to SharedPreferences
    if (keysUpdated) {
      await prefs.setStringList('contracts', contractsJson);
    }

    print('Completed syncContractsFromUserNode for user: $userId');
  } catch (e) {
    print('Error in syncContractsFromUserNode: $e');
  }
}

/// Changes or sets the user's profile picture
///
/// [userId]: The user ID
/// [file]: The image file to upload
/// Returns: Map with status and URL on success
Future<Map<String, dynamic>> changeProfilePic(String userId, File file) async {
  try {
    // Upload to Cloudinary
    String? url = await uploadAndGetUrl(
      file,
      type: CloudinaryResourceType.Image,
    );
    if (url == null) {
      return {"status": false, "error": "Upload failed"};
    }

    // Set in Firebase (overwrites if exists)
    DatabaseReference picRef = FirebaseDatabase.instance.ref(
      "profilePic/$userId",
    );
    await picRef.set(url);

    return {"status": true, "url": url};
  } catch (e) {
    return {"status": false, "error": e.toString()};
  }
}

/// Gets the user's profile picture URL
///
/// [userId]: The user ID
/// Returns: Map with status and URL (null if none)
Future<Map<String, dynamic>> getProfilePic(String userId) async {
  try {
    DatabaseReference picRef = FirebaseDatabase.instance.ref(
      "profilePic/$userId",
    );
    DatabaseEvent event = await picRef.once();
    final data = event.snapshot.value;

    String? url = data?.toString();
    return {"status": true, "url": url};
  } catch (e) {
    return {"status": false, "error": e.toString()};
  }
}

/// Removes the user's profile picture
///
/// [userId]: The user ID
/// Returns: Map with status
Future<Map<String, dynamic>> removeProfilePic(String userId) async {
  try {
    DatabaseReference picRef = FirebaseDatabase.instance.ref(
      "profilePic/$userId",
    );
    await picRef.remove();

    return {"status": true, "message": "Profile pic removed"};
  } catch (e) {
    return {"status": false, "error": e.toString()};
  }
}
