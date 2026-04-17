import 'dart:io' show Platform;

String getApiHostPlatform() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:9090';
  }
  return 'http://localhost:9090';
}
