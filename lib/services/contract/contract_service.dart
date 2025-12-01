import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yack/db/models/contract.dart';
import 'package:yack/models/contract/contract_preview.dart';
import 'package:yack/services/network/http_handler.dart';

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
      ..description = description
      ..price = price
      ..userA = "" // will fill after join
      ..userB = ""
      ..status = ContractStatus.pending
      ..createdAt = DateTime.now();

    // ---------------------------
    // 3. Return result
    // ---------------------------
    return CreateContractResult(
      contract: contract,
      hash: hash,
      tempId: tempId,
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

      final preview = ContractPreview.fromJson(jsonMap);

      // ---------------------------------------------
      // 4. BACKEND CALL: join the temporary contract
      // ---------------------------------------------
      final response = await _http.post(
        "/contracts/join",
        body: {
          "tempID": preview.id,  // backend "tempID"
        },
      );


      return preview;

    } on FormatException {
      throw const FormatException('invalid_contract_qr');
    } catch (e) {
      // backend error
      throw Exception('failed_to_join_contract: $e');
    }
  }
}
