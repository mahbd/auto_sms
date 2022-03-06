import 'package:telephony/telephony.dart';

Future<bool> sendSMS(String to, String message, [Function? listener]) async {
  try {
    if (listener != null) {
      await Telephony.instance.sendSms(to: to, message: message);
    } else {
      await Telephony.instance.sendSms(to: to, message: message);
    }
  } catch (e) {
    print(e);
    return false;
  }
  return true;
}

final SmsSendStatusListener listener = (SendStatus status) {};
