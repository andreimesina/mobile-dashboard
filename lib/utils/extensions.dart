import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobile_dashboard/domain/models.dart';

extension SnapshotGetters on DocumentSnapshot {
  T? getOrDefault<T>(String key, T? defaultValue) =>
      data().toString().contains(key) ? get(key) : defaultValue;
}

extension UserFilter<T> on Query<T> {
  Query<T> whereCurrentUser(bool currentUser) {
    if (currentUser) {
      return where("owner_id", isEqualTo: "DbFozTWYpTFe3VmJhWnu");
    } else {
      return this;
    }
  }
}

extension TaskDate on Task {
  DateTime? createdDateObject() => DateTime.tryParse(createdDate);

  DateTime? startedDateObject() => DateTime.tryParse(startedDate ?? "");

  DateTime? completedDateObject() => DateTime.tryParse(completedDate ?? "");
}

extension SprintDate on Sprint {
  DateTime? startDateObject() => DateTime.tryParse(startDate ?? "");

  DateTime? endDateObject() => DateTime.tryParse(endDate ?? "");
}

extension DateFormatter on DateTime {
  String truncatedToDay() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(this);
  }
}