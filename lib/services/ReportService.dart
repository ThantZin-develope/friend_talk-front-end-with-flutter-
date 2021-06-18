import 'package:flutter/cupertino.dart';
import 'package:my_app/objects/SystemReports.dart';
import 'package:my_app/util/RequestApi.dart';

class ReportService {
  static Future<dynamic> getReports(BuildContext context) async {
    try {
      var result = await RequestApi.getRequest(true, "/api/reports", context);
      return result;
    } catch (error) {
      return null;
    }
  }

  static Future<dynamic> respondReport(
      BuildContext context, String action, SystemReports report) async {
    try {
      var body = report.toJSON();
      var result = await RequestApi.putRequest(
          true, "/api/respond-report", body, context,
          params: {"action": action});
      return result;
    } catch (error) {
      return null;
    }
  }

  static Future<dynamic> report(
      BuildContext context, SystemReports report) async {
    try {
      var body = report.toJSON();
      var result =
          await RequestApi.postRequest(true, "/api/report", body, context);
      return result;
    } catch (error) {
      return null;
    }
  }
}
