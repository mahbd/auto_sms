import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  Future<List<SmsMessage>> readMessages() async {
    final Telephony telephony = Telephony.instance;
    try {
      List<SmsMessage> messages = await telephony.getSentSms();
      return messages;
    } catch (e) {
      throw Exception("Error reading messages");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: FutureBuilder<List<SmsMessage>>(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (!snapshot.hasData) return const Text('No messages');
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final SmsMessage message = snapshot.data![index];
                  return ListTile(
                    title: Text(message.body ?? ""),
                    subtitle: Text(message.address ?? ""),
                    trailing: Text(message.date.toString()),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
          future: readMessages()),
    );
  }
}
