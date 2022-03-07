import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/message_cluster.dart';
import '../models/person_model.dart';

class ClusterMessages extends StatefulWidget {
  const ClusterMessages({Key? key, required this.cluster}) : super(key: key);
  final MessageCluster cluster;

  @override
  State<ClusterMessages> createState() => _ClusterMessagesState();
}

class _ClusterMessagesState extends State<ClusterMessages> {
  Box? box;

  Future<Map<String, Person>> openBox() async {
    Map<String, Person> people = <String, Person>{};
    try {
      box ??= await Hive.openBox('database');
      if (box!.get('contacts') is List<Person>) {
      } else {
        box!.put('contacts', [Person('Test', 'test')]);
      }
      List<Person> contacts = box!.get('contacts');
      for (Person contact in contacts) {
        people[contact.phone] = contact;
      }
      return people;
    } catch (e) {
      print(e);
      throw Exception('Failed to open box');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cluster Messages'),
      ),
      body: FutureBuilder<Map<String, Person>>(
        future: openBox(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<String> msgPhoneList =
                widget.cluster.messagesStatus.keys.toList();
            return ListView.separated(
              padding: const EdgeInsets.all(10),
              separatorBuilder: (context, index) => const Divider(
                height: 10,
              ),
              itemCount: msgPhoneList.length,
              itemBuilder: (context, index) {
                Map<String, Person> people = snapshot.data!;
                Color color = Theme.of(context).backgroundColor;
                if (widget.cluster.messagesStatus[msgPhoneList[index]] ==
                    "Sending") {
                  color = Colors.yellow;
                } else if (widget.cluster.messagesStatus[msgPhoneList[index]] ==
                    "Sent") {
                  color = Colors.blue;
                } else if (widget.cluster.messagesStatus[msgPhoneList[index]] ==
                    "Delivered") {
                  color = Colors.green;
                } else if (widget.cluster.messagesStatus[msgPhoneList[index]] ==
                    "Failed") {
                  color = Colors.red;
                }

                if (people.containsKey(msgPhoneList[index])) {
                  Person person = people[msgPhoneList[index]]!;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: color,
                    title: Text(person.name),
                    subtitle: Text(person.phone),
                  );
                }
                return ListTile(
                  tileColor: color,
                  title: const Text("Unknown User"),
                  subtitle: Text(msgPhoneList[index]),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
