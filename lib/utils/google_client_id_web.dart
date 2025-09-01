// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
// dart:html is only available on web
import 'dart:html' as html;

String? getGoogleWebClientId() {
  final element = html.document.querySelector('meta[name="google-signin-client_id"]');
  return element?.getAttribute('content');
}
