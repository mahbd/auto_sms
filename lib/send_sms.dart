import 'package:auto_sms/models/message_cluster.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:telephony/telephony.dart';

Future<bool> sendSMS(String to, String message,
    [Function(SendStatus)? listener]) async {
  try {
    if (listener != null) {
      await Telephony.instance
          .sendSms(to: to, message: message, statusListener: listener);
    } else {
      await Telephony.instance.sendSms(to: to, message: message);
    }
  } catch (e) {
    print(e);
    return false;
  }
  return true;
}

MessageCluster sendMessages(Box box, String message, List<String> phones) {
  MessageCluster cluster = MessageCluster(message, <String, String>{});
  for (String phone in phones) {
    cluster.messagesStatus[phone] = 'Sending';
    box.put(phone, cluster);

    sendSMS(phone, message, (SendStatus status) {
      if (status == SendStatus.DELIVERED) {
        cluster.messagesStatus[phone] = 'Delivered';
      } else if (status == SendStatus.SENT) {
        cluster.messagesStatus[phone] = 'Sent';
      } else {
        cluster.messagesStatus[phone] = 'Failed';
      }
      box.put(phone, cluster);
    });
  }
  List<MessageCluster>? clusters = box.get('clusters');
  clusters ??= <MessageCluster>[];
  clusters.add(cluster);
  box.put('clusters', clusters);
  return cluster;
}
