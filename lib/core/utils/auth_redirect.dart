import 'auth_redirect_stub.dart'
    if (dart.library.html) 'auth_redirect_web.dart';

void openUrlInBrowser(String url) {
  redirectToWebUrl(url);
}

Uri getBrowserUri() {
  return getCurrentUri();
}
