class DailyChallengeDay {
  static const int boundaryHourUtc = 7;

  final DateTime date;

  DailyChallengeDay._(this.date);

  factory DailyChallengeDay.fromInstant(DateTime instant) {
    final shifted = instant.toUtc().subtract(
          const Duration(hours: boundaryHourUtc),
        );
    return DailyChallengeDay._(
      DateTime.utc(shifted.year, shifted.month, shifted.day),
    );
  }

  factory DailyChallengeDay.fromKey(String key) {
    final parsed = DateTime.tryParse(key);
    if (parsed == null) {
      throw FormatException('Invalid daily challenge day: $key');
    }
    return DailyChallengeDay._(
      DateTime.utc(parsed.year, parsed.month, parsed.day),
    );
  }

  String get key {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime get startsAtUtc => date.add(const Duration(hours: boundaryHourUtc));

  DateTime get endsAtUtc => startsAtUtc.add(const Duration(days: 1));

  Duration remainingAt(DateTime instant) {
    final remaining = endsAtUtc.difference(instant.toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  bool operator ==(Object other) {
    return other is DailyChallengeDay && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}
