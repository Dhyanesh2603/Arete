void redirectToWebUrl(String url) {
  // No-op for non-web environments (tests)
}

Uri getCurrentUri() {
  return Uri.base;
}
