enum Addon {
  internetObserver(
    remoteName: 'connection_observer',
    displayName: 'Internet observer',
  ),
  apiProvider(
    remoteName: 'api_provider',
    displayName: 'HTTP provider',
  );

  final String remoteName;
  final String displayName;

  const Addon({
    required this.remoteName,
    required this.displayName,
  });
}
