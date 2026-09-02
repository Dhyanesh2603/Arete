// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

void redirectToWebUrl(String url) {
  // Open in a new tab so localhost:8080 never gets unloaded
  html.window.open(url, '_blank');
}

Uri getCurrentUri() {
  return Uri.parse(html.window.location.href);
}
