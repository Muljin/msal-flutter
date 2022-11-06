import 'android_log_level.dart';

class AndroidLoggerConfiguration {
  final bool piiEnabled;
  final AndroidLogLevel logLevel;
  final bool logcatEnabled;

  const AndroidLoggerConfiguration({
    this.piiEnabled = false,
    this.logLevel = AndroidLogLevel.WARNING,
    this.logcatEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'pii_enabled': piiEnabled,
      'log_level': logLevel.name,
      'logcat_enabled': logcatEnabled,
    };
  }
}
