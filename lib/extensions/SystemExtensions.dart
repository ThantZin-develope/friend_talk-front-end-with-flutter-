import 'package:intl/intl.dart';

extension systemDate on String {
  DateTime changetoSystemDate() => DateTime.parse(this);
  String forShowStringDate() =>
      new DateFormat("dd-MM-yyyy").format(DateTime.parse(this));
  String forPostDate() {
    DateTime postDate = this.changetoSystemDate();
    if (postDate.isBefore(DateTime.now()) &&
        DateTime.now().day > postDate.day) {
 
   
      var daydifference = DateTime.now().day - postDate.day;
      if (daydifference <= 15) {
        if (daydifference == 1) {
          return "yesterday";
        }
        return daydifference.toString() + " days ago";
      } else {
        return this.forShowStringDate();
      }
    } else {
      var hourDifference = DateTime.now().hour - postDate.hour;
      var minuteDifference = DateTime.now().minute - postDate.minute;

      if (hourDifference > 0) {
        return hourDifference.toString() + " hour ago";
      }
      if (minuteDifference > 0) {
        return minuteDifference.toString() + " minute ago";
      }
      return "just now";
    }
  }
}

extension systemStringDate on DateTime {
  String changetoSystemStringDate() =>
      new DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(this);
}

extension removeDulplicate on List {
  List<dynamic> removeDuplicate() {
    Set<dynamic> seen = new Set();
    this.removeWhere((element) => !seen.add(element));

    return this;
  }

  List<dynamic> removeDuplicateComments(){
    Set<dynamic> seen = new Set();
    this.removeWhere((element) => !seen.add(element.comment_id));
    return this;
  }

  List<dynamic> removeDuplicatePosts(){
    Set<dynamic> seen = new Set();
    this.removeWhere((element) => !seen.add(element.post_id));
    return this;
  }
   List<dynamic> removeDuplicateNotiss(){
    Set<dynamic> seen = new Set();
    this.removeWhere((element) => !seen.add(element.noti_id));
    return this;
  }
}
