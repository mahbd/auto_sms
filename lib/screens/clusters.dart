import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../screens/cluster_messages.dart';
import '../models/message_cluster.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  Box? box;

  Future<List<MessageCluster>> openBox() async {
    try {
      box ??= await Hive.openBox('database');
      if (box!.get('clusters') is List<MessageCluster>) {
      } else {
        box!.put('clusters', [MessageCluster('Test', <String, String>{})]);
      }
      List<MessageCluster> contacts = box!.get('clusters');
      return contacts;
    } catch (e) {
      print(e);
      throw Exception('Failed to open box');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clusters'),
      ),
      body: FutureBuilder<List<MessageCluster>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) return const Text('No messages');
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final MessageCluster cluster = snapshot.data![index];
                return ListTile(
                  title: Text(cluster.messageBody),
                  subtitle: Text(
                      'Sent: ${cluster.sentCount} Delivered: ${cluster.deliveredCount} Failed: ${cluster.failedCount} Pending: ${cluster.pendingCount}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClusterMessages(cluster: cluster),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
        future: openBox(),
      ),
    );
  }
}
