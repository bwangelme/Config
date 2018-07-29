function FindProxyForURL(url, host) {
    if (shExpMatch(host, "*.douban.com")) {
        return "PROXY 172.16.17.65:8888";
    } else {
        return "DIRECT";
    }
}
