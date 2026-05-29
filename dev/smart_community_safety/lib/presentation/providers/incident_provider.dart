import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/models/incident.dart';
import '../../data/repositories/incident_repository.dart';

class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._repo);

  final IncidentRepository _repo;

  StreamSubscription<List<Incident>>? _sub;

  List<Incident> _realtime = [];
  List<Incident> get realtime => _realtime;

  // ✅ cache local so UI updates immediately
  List<Incident> _localCache = [];
  List<Incident> get local => _localCache;

  int get pendingCount => _repo.pendingCount();

  void _refreshLocal() {
    _localCache = _repo.localIncidents();
  }

  void startRealtime() {
    // ✅ Load local instantly (before Firestore responds)
    _refreshLocal();
    notifyListeners();

    _sub?.cancel();
    _sub = _repo.streamRealtimeIncidents().listen((list) {
      _realtime = list;
      _refreshLocal(); // keep local updated too
      notifyListeners();
    });
  }

  Future<void> createIncident({
    required String category,
    required String description,
    required int severity,
    required double lat,
    required double lng,
    required List<String> photoPaths,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final inc = Incident(
      id: now,
      category: category,
      description: description,
      severity: severity,
      lat: lat,
      lng: lng,
      photoPaths: photoPaths,
      createdAt: now,
      isSynced: false,
    );

    await _repo.createIncident(inc);

    // ✅ THIS makes dashboard update immediately
    _refreshLocal();
    notifyListeners();
  }

  Future<void> sync() async {
    await _repo.syncPending();
    _refreshLocal();
    notifyListeners();
  }

  Future<void> deleteIncidentById(int id) async {
    await _repo.deleteIncidentById(id);
    _refreshLocal();
    notifyListeners();
  }
  Future<void> updateIncident(Incident incident) async {
    await _repo.updateIncident(incident);
    _refreshLocal();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
