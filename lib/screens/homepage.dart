import 'package:hive_flutter/hive_flutter.dart';

import '../models/batch_model.dart';
import 'batches.dart';
import '../screens/messages.dart';
import '../screens/contacts.dart';
import '../screens/everybody.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _mainButtons = [
    {
      'text': 'Everybody',
      'fun': (BuildContext context) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EveryBody(),
            ),
          ),
    },
    {
      'text': 'Batches',
      'fun': (BuildContext context) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Batches(),
            ),
          ),
    },
    {
      'text': 'Previous',
      'fun': (BuildContext context) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Messages(),
            ),
          ),
    },
    {
      'text': 'Contacts',
      'fun': (BuildContext context) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllContacts(),
            ),
          ),
    },
  ];
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
        title: const Text("Home"),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).backgroundColor,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              padding: const EdgeInsets.all(10),
              children: List.generate(
                4,
                (index) => GestureDetector(
                  onTap: () {
                    _mainButtons[index]['fun'](context);
                  },
                  child: Container(
                    child: Center(
                      child: Text(
                        _mainButtons[index]['text'],
                        style: TextStyle(
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme
                              ?.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
            ),
            width: MediaQuery.of(context).size.width,
            child: Text(
              "Batches",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline6?.color ??
                    Colors.black,
                backgroundColor: Theme.of(context).backgroundColor,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Batch>>(
              future: openBox(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No data'),
                    );
                  }

                  List<Batch> _batches = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.all(10),
                    separatorBuilder: (context, index) =>
                        const Divider(height: 10),
                    itemCount: _batches.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          tileColor: Theme.of(context).primaryColor,
                          title: Text(_batches[index].name),
                          leading: CircleAvatar(
                            child: Text('$index'),
                          ),
                          subtitle: Text(_batches[index].startTime),
                        ),
                      );
                    },
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}
