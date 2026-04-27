enum HistorySessionStatus { completed, interrupted, skipped, unknown }

extension HistorySessionStatusX on HistorySessionStatus {
  static HistorySessionStatus fromValue(String? value) {
    return switch (value) {
      'completed' => HistorySessionStatus.completed,
      'interrupted' => HistorySessionStatus.interrupted,
      'skipped' => HistorySessionStatus.skipped,
      _ => HistorySessionStatus.unknown,
    };
  }

  String get label {
    return switch (this) {
      HistorySessionStatus.completed => 'Completada',
      HistorySessionStatus.interrupted => 'Interrumpida',
      HistorySessionStatus.skipped => 'Omitida',
      HistorySessionStatus.unknown => 'Sin estado',
    };
  }
}

class HistorySessionItem {
  const HistorySessionItem({
    required this.id,
    required this.routineTitle,
    required this.startedAt,
    required this.completedAt,
    required this.status,
    required this.assignmentContext,
  });

  final String id;
  final String routineTitle;
  final DateTime startedAt;
  final DateTime? completedAt;
  final HistorySessionStatus status;
  final String assignmentContext;
}

class HistoryEmotionItem {
  const HistoryEmotionItem({
    required this.id,
    required this.sessionId,
    required this.recordedAt,
    required this.preEmotion,
    required this.preIntensity,
    this.postEmotion,
    this.postIntensity,
  });

  final String id;
  final String? sessionId;
  final DateTime recordedAt;
  final String preEmotion;
  final int preIntensity;
  final String? postEmotion;
  final int? postIntensity;

  bool get hasPost => postEmotion != null && postIntensity != null;
}

class HistoryThoughtItem {
  const HistoryThoughtItem({
    required this.id,
    required this.createdAt,
    required this.preview,
  });

  final String id;
  final DateTime createdAt;
  final String preview;
}

class HistorySummary {
  const HistorySummary({
    required this.totalSessions,
    required this.completedSessions,
    required this.totalThoughts,
    required this.totalEmotionLogs,
  });

  final int totalSessions;
  final int completedSessions;
  final int totalThoughts;
  final int totalEmotionLogs;
}

class ProgressMetrics {
  const ProgressMetrics({
    required this.activeDaysInRange,
    required this.completedSessionsInRange,
    required this.weeklyActiveDays,
    this.weeklyTargetDays = 7,
    required this.improvedSessions,
    required this.assessableSessions,
  });

  const ProgressMetrics.empty()
    : activeDaysInRange = 0,
      completedSessionsInRange = 0,
      weeklyActiveDays = 0,
      weeklyTargetDays = 7,
      improvedSessions = 0,
      assessableSessions = 0;

  final int activeDaysInRange;
  final int completedSessionsInRange;
  final int weeklyActiveDays;
  final int weeklyTargetDays;
  final int improvedSessions;
  final int assessableSessions;

  double get improvementRate {
    if (assessableSessions <= 0) return 0;
    return improvedSessions / assessableSessions;
  }
}
