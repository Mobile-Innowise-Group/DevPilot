abstract class LocalDataProvider {
  Future<void> write({required String key, required String value});

  Future<String?> read(String key);

  Future<void> delete(String key);

  Future<void> deleteAll();

  Future<bool> contains(String key);
}

class LocalDataProviderImpl implements LocalDataProvider{
  @override
  Future<bool> contains(String key) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String key) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll() {
    // TODO: implement deleteAll
    throw UnimplementedError();
  }

  @override
  Future<String?> read(String key) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<void> write({required String key, required String value}) {
    // TODO: implement write
    throw UnimplementedError();
  }

}