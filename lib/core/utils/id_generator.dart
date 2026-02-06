import 'package:uuid/uuid.dart';

class IdGenerator {
  static final _uuid = Uuid();

  static String generate() {
    try {
      return _uuid.v7();
    } catch (_) {
      return _uuid.v4();
    }
  }
}
