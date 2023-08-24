class MsalException implements Exception {
  String errorMessage;
  String? errorDetails;
  MsalException(this.errorMessage, {this.errorDetails});
}
