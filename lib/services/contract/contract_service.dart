import 'package:flutter/material.dart';
import 'package:yack/db/models/contract.dart';
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
}
