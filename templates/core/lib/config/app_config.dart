enum Flavor {
  dev,
}

class AppConfig {
  final Flavor flavor;
  final String baseUrl;
  final String webSocketUrl;

  AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.webSocketUrl,
  });

  factory AppConfig.fromFlavor(Flavor flavor) {
    String baseUrl;
    String webSocketUrl;
    switch (flavor) {
      case Flavor.dev:
        baseUrl = '';
        webSocketUrl = '';
        break;
    }

    return AppConfig(
      flavor: flavor,
      baseUrl: baseUrl,
      webSocketUrl: webSocketUrl,
    );
  }
}
