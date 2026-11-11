// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

const _key = 'pantas.auth.emailLinkEmail';
String? readEmail() {
  try {
    return web.window.localStorage.getItem(_key);
  } on Object {
    return null;
  }
}

void writeEmail(String? value) {
  try {
    if (value == null) {
      web.window.localStorage.removeItem(_key);
    } else {
      web.window.localStorage.setItem(_key, value);
    }
  } on Object {
    // Browsers may block storage. The student can enter the email again.
  }
}
