enum Addon {
  internetObserver(
    remoteName: 'connection_observer',
    displayName: 'Internet observer',
  ),
  apiProvider(
    remoteName: 'api_provider',
    displayName: 'HTTP provider',
  ),
  websocketProvider(
    remoteName: 'websocket_provider',
    displayName: 'Websocket provider',
  ),
  driftDatabase(
    remoteName: 'drift_database',
    displayName: 'Drift database',
  );

  final String remoteName;
  final String displayName;

  const Addon({
    required this.remoteName,
    required this.displayName,
  });
}
