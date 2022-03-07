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
            return ListView.builder(
              itemCount: msgPhoneList.length,
              itemBuilder: (context, index) {
                Map<String, Person> people = snapshot.data!;
                if (people.containsKey(msgPhoneList[index])) {
                  Person person = people[msgPhoneList[index]]!;
                  return ListTile(
                    title: Text(person.name),
                    subtitle: Text(person.phone),
                  );
                }
                return ListTile(
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
