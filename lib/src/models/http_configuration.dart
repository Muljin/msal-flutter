class HttpConfiguration {
  final int readTimeout;

  final int connectTimeout;

  const HttpConfiguration(
      {this.readTimeout = 30000, this.connectTimeout = 10000});

  Map<String, dynamic> toMap() {
    return {
      'read_timeout': readTimeout,
      'connect_timeout': connectTimeout,
    };
  }
}
