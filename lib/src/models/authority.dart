class Authority {
    Authority({
        this.type ='B2C',
        this.authorityDefault= false,
        required this.authorityUrl,
    });

    String type;
    bool authorityDefault;
    Uri authorityUrl;


    Map<String, dynamic> toMap() => {
        "type": type,
        "default": authorityDefault,
        "authority_url": authorityUrl.toString(),
    };
}