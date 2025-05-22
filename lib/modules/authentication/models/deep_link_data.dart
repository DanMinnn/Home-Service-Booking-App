import '../../../providers/log_provider.dart';

class DeepLinkData {
  static String? path;
  static Map<String, String>? queryParams;
  static bool hasData() => path != null;

  static void store(String pathValue, Map<String, String> params) {
    path = pathValue;
    queryParams = params;
    _logger.log('Stored deeplink data: path=$path, params=$queryParams');
  }

  static void clear() {
    path = null;
    queryParams = null;
    _logger.log('Cleared deeplink data');
  }

  static final _logger = LogProvider('DEEP-LINK-DATA:::');
}
