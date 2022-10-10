abstract class MSALTokenParameters {
  List<String> scopes;

  Map<String, dynamic>? extraQueryParameters;
  String? correlationId;
  MSALTokenParameters({
    required this.scopes,
    this.extraQueryParameters,
    this.correlationId,
  });
}
