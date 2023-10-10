import 'msal_exceptions.dart';

class MsalUserInteractionRequired extends MsalException {
  MsalUserInteractionRequired() : super("User interaction required to login.");
}
