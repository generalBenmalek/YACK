import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yack/db/models/contract.dart';
import 'package:yack/models/contract/contract_preview.dart';
import 'package:yack/services/network/http_handler.dart';

import 'accept_contract_result.dart';
import 'create_contract_result.dart';

class ContractService {
  static final HttpHandler _http = HttpHandler();

  static Future<CreateContractResult> createContract(
      GlobalKey<FormState> formKey,
      String name,
      String description,
      double price,
      String hash,
      ) async {

    // if (!formKey.currentState!.validate()) {
    //   throw Exception("form_invalid");
    // }

    // ---------------------------
    // 1. Call backend
    // ---------------------------
    final response = await _http.post(
      "/contracts/create",
      body: {
        "hash": hash,
      },
    );

    final tempId = response["tempID"];
    if (tempId == null) {
      throw Exception("missing_temp_id_from_server");
    }

    // ---------------------------
    // 2. Create local in-memory Contract object (NOT saved)
    // ---------------------------
    final Contract contract = Contract()
      ..name = name
      ..mongoId = tempId  // use tempId as mongoId for in-memory object
      ..description = description
      ..price = price
      ..userA = 'Me'
      ..userB = ""
      ..status = ContractStatus.pending
      ..createdAt = DateTime.now();

    // ---------------------------
    // 3. Return result
    // ---------------------------
    return CreateContractResult(
      contract: contract,
      hash: hash,
    );
  }


  static Future<ContractPreview> joinContractFromQr(String code) async {
    // 1. Validate prefix / scheme
    if (!code.startsWith('yack://contract')) {
      throw const FormatException('invalid_contract_qr');
    }

    final uri = Uri.tryParse(code);
    if (uri == null) {
      throw const FormatException('invalid_contract_qr');
    }

    // 2. Extract base64 data
    final encodedData = uri.queryParameters['data'];
    if (encodedData == null || encodedData.isEmpty) {
      throw const FormatException('missing_contract_data');
    }

    try {
      // ---------------------------------------------
      // 3. Decode base64 => JSON => local preview object
      // ---------------------------------------------
      final jsonString = utf8.decode(base64Url.decode(encodedData));
      final Map<String, dynamic> jsonMap = json.decode(jsonString);


      // ---------------------------------------------
      // 4. BACKEND CALL: join the temporary contract
      // ---------------------------------------------
      final response = await _http.post(
        "/contracts/join",
        body: {
          "tempID": jsonMap['id'], // backend requires "tempID"
        },
      );

      // ---------------------------------------------
      // 5. Inject userA first + last name from backend
      // ---------------------------------------------

      jsonMap['userA'] = response['userAFullName'] ?? jsonMap['userA'];
      final preview = ContractPreview.fromJson(jsonMap);
      return preview;

    } on FormatException {
      throw const FormatException('invalid_contract_qr');
    } catch (e) {
      throw Exception('failed_to_join_contract: $e');
    }
  }

  static Future<AcceptContractResult> acceptContract(String tempId) async {
    final response = await _http.post(
      "/contracts/sign",
      body: {
        "tempID": tempId,
      },
    );

    // Case 1: Contract fully completed
    if (response["completed"] == true) {
      return AcceptContractResult(
        signed: true,
        completed: true,
        finalContractId: response["contractID"],
      );
    }

    // Case 2: Only this user signed (waiting for other)
    return AcceptContractResult(
      signed: true,
      completed: false,
      finalContractId: null,
    );
  }

}
