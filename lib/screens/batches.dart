import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/batch_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Batches extends StatefulWidget {
  const Batches({Key? key}) : super(key: key);

  @override
  State<Batches> createState() => _BatchesState();
}

class _BatchesState extends State<Batches> {
  Box? box;

  Future<List<Batch>> openBox() async {
    try {
      box ??= await Hive.openBox('database');
      if (box!.get('batches') is List<Batch>) {
      } else {
        box!.put('batches', [const Batch('Test', 'test')]);
      }
      List<Batch> contacts = box!.get('batches');
      return contacts;
    } catch (e) {
      throw Exception('Failed to open box');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Batches'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder<List<Batch>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) return const Center(child: Text('No data'));
            final List<Batch> contacts = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                  height: 10,
                ),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            showDeleteBatchDialog(context, contacts[index]);
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            showEditGroupDialog(context, contacts[index]);
                          },
                          backgroundColor: const Color(0xFF21B7CA),
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      tileColor: Theme.of(context).primaryColor,
                      title: Text(contacts.elementAt(index).name),
                      subtitle: Text(contacts.elementAt(index).startTime),
                      onLongPress: () {
                        showDeleteBatchDialog(context, contacts[index]);
                      },
                      onTap: () {},
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        future: openBox(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showAddBatchDialog(context);
        },
      ),
    );
  }

  void showAddBatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String name = "";
        String startTime = "";
        return AlertDialog(
          title: const Text('Add Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                ),
                onChanged: (value) {
                  startTime = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Batch person = Batch(name, startTime);
                if (box != null) {
                  saveBatch(box!, person);
                }
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void showEditGroupDialog(BuildContext context, Batch contact) {
    showDialog(
      context: context,
      builder: (context) {
        String name = contact.name;
        String startTime = contact.startTime;
        return AlertDialog(
          title: const Text('Edit Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: contact.name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextFormField(
                initialValue: contact.startTime,
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                ),
                onChanged: (value) {
                  startTime = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Batch batch = Batch(name, startTime);
                if (box != null) {
                  saveBatchReplace(box!, contact, batch);
                }
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteBatchDialog(BuildContext context, Batch contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: const Text('Are you sure you want to delete this batch?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                if (box != null) {
                  deleteBatch(box!, contact);
                }
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }
}
