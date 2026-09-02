// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

void redirectToWebUrl(String url) {
  html.window.location.href = url;
}

Uri getCurrentUri() {
  return Uri.parse(html.window.location.href);
}
