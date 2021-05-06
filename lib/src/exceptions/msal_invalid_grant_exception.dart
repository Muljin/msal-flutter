import '../../msal_flutter.dart';

class MsalInvalidGrantException extends MsalException {
  MsalInvalidGrantException() : super("Invalid grant.");
}
