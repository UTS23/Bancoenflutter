import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Utils {
  static String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('d \'de\' MMMM \'de\' yyyy, h:mm:ss a').format(date);
  }
}
