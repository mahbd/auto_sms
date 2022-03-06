import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/person_model.dart';

class AllContacts extends StatefulWidget {
  const AllContacts({Key? key}) : super(key: key);

  @override
  State<AllContacts> createState() => _AllContactsState();
}

class _AllContactsState extends State<AllContacts> {
  Box? box;

  Future<List<Person>> openBox() async {
    try {
      box ??= await Hive.openBox('database');
      if (box!.get('contacts') is List<Person>) {
      } else {
        box!.put('contacts', [Person('Test', 'test')]);
      }
      List<Person> contacts = box!.get('contacts');
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
        title: const Text('All Contacts'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder<List<Person>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) return const Center(child: Text('No data'));
            final List<Person> contacts = snapshot.data!;
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
                            showDeleteContactDialog(context, contacts[index]);
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            showEditContactDialog(context, contacts[index]);
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
                      subtitle: Text(contacts.elementAt(index).phone),
                      onTap: () {
                        showEditContactDialog(context, contacts[index]);
                      },
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
          addContactDialog(context);
        },
      ),
    );
  }

  void addContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String name = "";
        String phone = "";
        List<dynamic> _batches = box!.get('batches');
        String batchIndex = _batches[0].name;
        return StatefulBuilder(
          builder: (context, setState2) => AlertDialog(
            title: const Text('Add Contact'),
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
                    labelText: 'Phone',
                  ),
                  onChanged: (value) {
                    phone = value;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Batch'),
                    DropdownButton(
                      value: batchIndex,
                      items: List.generate(
                        box!.get('batches').length,
                        (index) => DropdownMenuItem(
                          child:
                              Text(box!.get('batches').elementAt(index).name),
                          value: box!.get('batches').elementAt(index).name,
                        ),
                      ),
                      onChanged: (value) {
                        batchIndex = value.toString();
                        setState2(() {});
                      },
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                )
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
                  Person person = Person(name, phone,
                      batch: _batches[_batches.indexWhere(
                          (element) => element.name == batchIndex)]);
                  if (box != null) {
                    savePerson(box!, person);
                  }
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showEditContactDialog(BuildContext context, Person contact) {
    showDialog(
      context: context,
      builder: (context) {
        String name = contact.name;
        String phone = contact.phone;
        List<dynamic> _batches = box!.get('batches');
        String batchIndex = contact.batch?.name ?? _batches[0].name;
        return StatefulBuilder(
          builder: (context, setState2) => AlertDialog(
            title: const Text('Edit Contact'),
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
                  initialValue: contact.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                  ),
                  onChanged: (value) {
                    phone = value;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Batch'),
                    DropdownButton(
                      value: batchIndex,
                      items: List.generate(
                        box!.get('batches').length,
                        (index) => DropdownMenuItem(
                          child:
                              Text(box!.get('batches').elementAt(index).name),
                          value: box!.get('batches').elementAt(index).name,
                        ),
                      ),
                      onChanged: (value) {
                        batchIndex = value.toString();
                        setState2(() {});
                      },
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
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
                  Person person = Person(name, phone,
                      batch: _batches[_batches.indexWhere(
                          (element) => element.name == batchIndex)]);
                  if (box != null) {
                    savePersonReplace(box!, contact, person);
                  }
                  setState(() {});
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> showDeleteContactDialog(
      BuildContext context, Person contact) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: const Text('Are you sure you want to delete this contact?'),
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
                  deletePerson(box!, contact);
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
