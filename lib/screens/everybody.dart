import '../models/person_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EveryBody extends StatefulWidget {
  const EveryBody({Key? key}) : super(key: key);

  @override
  State<EveryBody> createState() => _EveryBodyState();
}

class _EveryBodyState extends State<EveryBody> {
  Box? box;

  Future<List<Person>> openBox() async {
    try {
      box ??= await Hive.openBox('database');
      if (box!.get('contacts') is List<Person>) {
      } else {
        box!.put('contacts', [Person("Test2", "test phone")]);
      }
      List<Person> contacts = box!.get('contacts');
      return contacts;
    } catch (e) {
      throw Exception('Failed to open box');
    }
  }

  final Map<String, bool> _checkBox = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Everybody'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder<List<Person>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final List<Person> contacts = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(fontSize: 17),
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelText: 'Write a message',
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add');
                    },
                    color: Theme.of(context).primaryColor,
                    child: const Text('Send'),
                  ),
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                        height: 10,
                      ),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        if (!_checkBox.containsKey(contacts[index].phone)) {
                          _checkBox[contacts[index].phone] = true;
                        }

                        return CheckboxListTile(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          tileColor: Theme.of(context).primaryColor,
                          title: Text(contacts.elementAt(index).name),
                          subtitle: Text(contacts.elementAt(index).phone),
                          value: _checkBox[contacts[index].phone],
                          onChanged: (value) {
                            setState(() {
                              _checkBox[contacts[index].phone] = value ?? false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
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
    );
  }
}
