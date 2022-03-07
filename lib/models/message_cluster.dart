import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 2)
class MessageCluster {
  @HiveField(20)
  final String messageBody;
  @HiveField(21)
  final Map<String, String> messagesStatus;
  @HiveField(22)
  int pendingCount;
  @HiveField(23)
  int failedCount;
  @HiveField(24)
  int sentCount;
  @HiveField(25)
  int deliveredCount;

  MessageCluster(
    this.messageBody,
    this.messagesStatus, {
    this.pendingCount = 0,
    this.failedCount = 0,
    this.sentCount = 0,
    this.deliveredCount = 0,
  });

  MessageCluster.fromMap(Map<dynamic, dynamic> map)
      : messageBody = map['messageBody'],
        messagesStatus = map['messagesStatus'],
        pendingCount = map['pendingCount'],
        failedCount = map['failedCount'],
        sentCount = map['sentCount'],
        deliveredCount = map['deliveredCount'];

  Map<String, dynamic> toMap() {
    return {
      'messageBody': messageBody,
      'messagesStatus': messagesStatus,
      'pendingCount': pendingCount,
      'failedCount': failedCount,
      'sentCount': sentCount,
      'deliveredCount': deliveredCount,
    };
  }
}

class MessageClusterAdapter extends TypeAdapter<MessageCluster> {
  @override
  final typeId = 2;

  @override
  MessageCluster read(BinaryReader reader) {
    return MessageCluster.fromMap(reader.read());
  }

  @override
  void write(BinaryWriter writer, MessageCluster obj) {
    writer.write(obj.toMap());
  }
}

void saveBatch(Box box, MessageCluster cluster) {
  List<MessageCluster> clusters = box.get('clusters') ?? [];
  bool found = false;
  for (var i = 0; i < clusters.length; i++) {
    if (clusters[i].messageBody == cluster.messageBody) {
      clusters[i] = cluster;
      found = true;
      break;
    }
  }
  if (!found) {
    clusters.add(cluster);
  }
  box.put('batches', clusters);
}

void saveBatchReplace(
    Box box, MessageCluster cluster, MessageCluster newCluster) {
  List<MessageCluster> clusters = box.get('clusters') ?? [];
  for (var i = 0; i < clusters.length; i++) {
    if (clusters[i].messageBody == cluster.messageBody) {
      clusters[i] = newCluster;
      break;
    }
  }
  box.put('batches', clusters);
}

void deleteBatch(Box box, MessageCluster cluster) {
  List<MessageCluster> clusters = box.get('batches') ?? [];
  for (var i = 0; i < clusters.length; i++) {
    if (clusters[i].messageBody == cluster.messageBody) {
      clusters.removeAt(i);
      break;
    }
  }
  box.put('batches', clusters);
}
