class MsalHttp {
    MsalHttp({
        this.connectTimeout=10000,
        this.readTimeout=30000,
    });

    int connectTimeout;
    int readTimeout;

    Map<String, dynamic> toMap() => {
        "connect_timeout": connectTimeout,
        "read_timeout": readTimeout,
    };
}
