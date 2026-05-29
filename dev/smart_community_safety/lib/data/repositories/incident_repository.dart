import 'package:cloud_firestore/cloud_firestore.dart';
import '../local/local_db.dart';
import '../models/incident.dart';

class CreateResult {
  final bool savedLocal;
  final bool syncedRemote;
  const CreateResult({required this.savedLocal, required this.syncedRemote});
}

class IncidentRepository {
  IncidentRepository({
    required FirebaseFirestore firestore,
    required LocalDb localDb,
  })  : _firestore = firestore,
        _db = localDb;

  final FirebaseFirestore _firestore;
  final LocalDb _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('incidents');

  int pendingCount() {
    return _db.incidents.values.where((e) => e.isSynced == false).length;
  }

  Stream<List<Incident>> streamRealtimeIncidents() {
    return _col.orderBy('createdAt', descending: true).snapshots().map((snap) {
      final list = <Incident>[];
      for (final doc in snap.docs) {
        final merged = <String, dynamic>{
          'id': int.tryParse(doc.id) ?? 0,
          ...doc.data(),
        };
        final inc = Incident.fromFirestore(merged);
        list.add(inc);
        try {
          _db.incidents.put(inc.id, inc);
        } catch (_) {}
      }
      return list;
    });
  }

  List<Incident> localIncidents() {
    final vals = _db.incidents.values.toList();
    vals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return vals;
  }

  Future<CreateResult> createIncident(Incident incident) async {
    final local = incident.copyWith(isSynced: false);
    await _db.incidents.put(local.id, local);

    // try remote
    try {
      await _col.doc(local.id.toString()).set(
        local.toFirestore(),
        SetOptions(merge: true),
      );
      await _db.incidents.put(local.id, local.copyWith(isSynced: true));
      return const CreateResult(savedLocal: true, syncedRemote: true);
    } catch (_) {
      // offline / rules / unavailable → still saved locally
      return const CreateResult(savedLocal: true, syncedRemote: false);
    }
  }

  Future<void> updateIncident(Incident incident) async {
    final local = incident.copyWith(isSynced: false);
    await _db.incidents.put(local.id, local);

    try {
      await _col.doc(local.id.toString()).set(local.toFirestore(), SetOptions(merge: true));
      await _db.incidents.put(local.id, local.copyWith(isSynced: true));
    } catch (_) {}
  }

  Future<void> deleteIncidentById(int id) async {
    await _db.incidents.delete(id);
    try {
      await _col.doc(id.toString()).delete();
    } catch (_) {}
  }

  Future<void> syncPending() async {
    final pending = _db.incidents.values.where((e) => e.isSynced == false).toList();
    for (final inc in pending) {
      try {
        await _col.doc(inc.id.toString()).set(inc.toFirestore(), SetOptions(merge: true));
        await _db.incidents.put(inc.id, inc.copyWith(isSynced: true));
      } catch (_) {}
    }
  }
}