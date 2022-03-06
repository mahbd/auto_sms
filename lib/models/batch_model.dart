import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 1)
class Batch {
  @HiveField(10)
  final String name;
  @HiveField(11)
  final String startTime;

  const Batch(this.name, this.startTime);

  Batch.fromMap(Map<dynamic, dynamic> map)
      : name = map['name'],
        startTime = map['startTime'];
  Map<String, dynamic> toMap() => {'name': name, 'startTime': startTime};
}

class BatchAdapter extends TypeAdapter<Batch> {
  @override
  final typeId = 1;

  @override
  Batch read(BinaryReader reader) {
    return Batch.fromMap(reader.read());
  }

  @override
  void write(BinaryWriter writer, Batch obj) {
    writer.write(obj.toMap());
  }
}

void saveBatch(Box box, Batch batch) {
  List<Batch> contacts = box.get('batches') ?? [];
  bool found = false;
  for (var i = 0; i < contacts.length; i++) {
    if (contacts[i].name == batch.name) {
      contacts[i] = batch;
      found = true;
      break;
    }
  }
  if (!found) {
    contacts.add(batch);
  }
  box.put('batches', contacts);
}

void saveBatchReplace(Box box, Batch batch, Batch newBatch) {
  List<Batch> contacts = box.get('batches') ?? [];
  for (var i = 0; i < contacts.length; i++) {
    if (contacts[i].name == batch.name) {
      contacts[i] = newBatch;
      break;
    }
  }
  box.put('batches', contacts);
}

void deleteBatch(Box box, Batch batch) {
  List<Batch> contacts = box.get('batches') ?? [];
  for (var i = 0; i < contacts.length; i++) {
    if (contacts[i].name == batch.name) {
      contacts.removeAt(i);
      break;
    }
  }
  box.put('batches', contacts);
}
