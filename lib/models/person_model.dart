import 'package:hive_flutter/hive_flutter.dart';

import '../models/batch_model.dart';

@HiveType(typeId: 0)
class Person {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String phone;
  @HiveField(3)
  final String? studentId;
  @HiveField(4)
  final String? address;
  @HiveField(5)
  final Batch? batch;

  Person(this.name, this.phone, {this.studentId, this.address, this.batch});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'studentId': studentId,
      'address': address,
      'batch': batch,
    };
  }

  factory Person.fromMap(Map<dynamic, dynamic> map) {
    return Person(
      map['name'] as String,
      map['phone'] as String,
      studentId: map['studentId'] as String?,
      address: map['address'] as String?,
      batch: map['batch'] as Batch?,
    );
  }
}

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final typeId = 0;

  @override
  Person read(BinaryReader reader) {
    return Person.fromMap(reader.read());
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer.write(obj.toMap());
  }
}

void savePerson(Box box, Person person) {
  List<Person> contacts = box.get('contacts') ?? [];
  bool found = false;
  for (var i = 0; i < contacts.length; i++) {
    if (contacts[i].phone == person.phone) {
      contacts[i] = person;
      found = true;
      break;
    }
  }
  if (!found) {
    contacts.add(person);
  }
  box.put('contacts', contacts);
}

void savePersonReplace(Box box, Person person, Person newPerson) {
  List<Person> contacts = box.get('contacts') ?? [];
  for (var i = 0; i < contacts.length; i++) {
    if (contacts[i].phone == person.phone) {
      contacts[i] = newPerson;
      break;
    }
  }
  box.put('contacts', contacts);
}

void deletePerson(Box box, Person person) {
  List<Person> contacts = box.get('contacts') ?? [];
  for (var i = 0; i < contacts.length; i++) {
    if (contacts[i].phone == person.phone) {
      contacts.removeAt(i);
      break;
    }
  }
  box.put('contacts', contacts);
}
