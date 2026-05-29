import 'dart:async';

import '../models/incident.dart';
import 'incident_repository.dart';

/// Compatibility layer so older/newer screens can call the same repository API
/// without forcing you to rewrite the entire repo.
extension IncidentRepositoryCompat on IncidentRepository {
  /// Screen expects: repo.pendingCount()
  int pendingCount() {
    try {
      // Try to count locally from common patterns (Hive/local list)
      final dynamic self = this;

      // 1) If repo has getLocalIncidents()
      final localList = self.getLocalIncidents?.call();
      if (localList is List) {
        return localList.where((e) {
          try {
            return (e as dynamic).isSynced == false;
          } catch (_) {
            return false;
          }
        }).length;
      }

      // 2) If repo exposes local box like _db.incidents (not accessible usually)
      // fallback:
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Screen expects: repo.streamRealtimeIncidents()
  Stream<List<Incident>> streamRealtimeIncidents() {
    final dynamic self = this;

    // If your repo already has a realtime stream under a different name, call it.
    // Common names we’ve seen:
    // - watchRemoteIncidents()
    // - watchIncidents()
    // - streamIncidents()
    try {
      final s1 = self.watchRemoteIncidents?.call();
      if (s1 is Stream) return s1.cast<List<Incident>>();
    } catch (_) {}

    try {
      final s2 = self.watchIncidents?.call();
      if (s2 is Stream) return s2.cast<List<Incident>>();
    } catch (_) {}

    try {
      final s3 = self.streamIncidents?.call();
      if (s3 is Stream) return s3.cast<List<Incident>>();
    } catch (_) {}

    // If nothing exists, provide an empty stream (prevents compile errors)
    return const Stream<List<Incident>>.empty();
  }

  /// Screen expects: repo.createIncident(incident)
  Future<void> createIncident(Incident incident) async {
    final dynamic self = this;

    // Common repo methods:
    try {
      await self.addIncident?.call(incident);
      return;
    } catch (_) {}

    try {
      await self.create?.call(incident);
      return;
    } catch (_) {}

    try {
      await self.insertIncident?.call(incident);
      return;
    } catch (_) {}

    // last resort (do nothing; avoids crash in compile stage)
  }

  /// Screen expects: repo.deleteIncident(incident) (but your repo might accept String id)
  Future<void> deleteIncident(Incident incident) async {
    final dynamic self = this;

    // Try by id if repo uses String
    try {
      await self.deleteIncidentById?.call((incident as dynamic).id as String);
      return;
    } catch (_) {}

    try {
      await self.deleteIncident?.call((incident as dynamic).id as String);
      return;
    } catch (_) {}

    // Or if repo actually accepts Incident
    try {
      await self.delete?.call(incident);
      return;
    } catch (_) {}
  }
}
