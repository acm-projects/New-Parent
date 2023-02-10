class DayStats {
  DateTime date;
  List<DateTime> diaperChanges;
  List<DateTime> feedings;
  Map<DateTime, DateTime> sleep;
  String notes;

  DayStats(
      {required this.date,
      required this.diaperChanges,
      required this.feedings,
      required this.sleep,
      required this.notes});
}