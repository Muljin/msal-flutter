import 'dart:convert';

import 'package:msal_flutter/src/models/msal_token_parameters.dart';

import 'msal_prompt_type.dart';

class MSALInteractiveTokenParameters extends MSALTokenParameters {
  MSALPromptType? promptType;
  Uri? authority;
  List<String>? extraScopesToConsent;
  String? loginHint;
  MSALInteractiveTokenParameters(
      {required super.scopes,
      super.extraQueryParameters,
      super.correlationId,
      this.authority,
      this.extraScopesToConsent,
      this.loginHint,
      this.promptType});

  Map<String, dynamic> toMap() {
    return {
      'scopes': scopes,
      'correlationId': correlationId,
      'extraQueryParameters': extraQueryParameters,
      'promptType': promptType?.name,
      'authority': authority?.toString(),
      'extraScopesToConsent': extraScopesToConsent,
      'loginHint': loginHint,
    };
  }
}
