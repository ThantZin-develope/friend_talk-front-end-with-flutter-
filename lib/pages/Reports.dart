import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/objects/SystemReports.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/extensions/SystemExtensions.dart';
import 'package:my_app/services/ReportService.dart';
import 'package:my_app/util/SystemException.dart';

class Report extends StatefulWidget {
  final User currentUser;
  final String authToken;
  Report({Key key, this.currentUser, this.authToken}) : super(key: key);
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  bool hasInitialzie = false;
  List<SystemReports> reports = [];

  @override
  void initState() {
    super.initState();
    this.initialize();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initialize() async {
    try {
      var result = await ReportService.getReports(context);
      if (result == null ) {
        throw new SystemException("System Exception Occured");
      }
      for (var i = 0; i < result["data"].length; i++) {
        this.reports.add(SystemReports.fromJSON(result["data"][i]));
      }

      setState(() {
        hasInitialzie = true;
      });
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  _respondReport(int action, SystemReports report) async {
    try {
      var result =
          await ReportService.respondReport(context, action.toString(), report);
      if (result == null) {
        throw new SystemException("System Exception Occurs");
      }
      this
          .reports
          .removeWhere((element) => element.report_id == report.report_id);
      setState(() {});
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  Widget reportsBodyWidget() {
    if (!hasInitialzie) {
      return Center(
        child: Container(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            backgroundColor: Colors.green,
          ),
        ),
      );
    }

    if (hasInitialzie && reports.length == 0) {
      return Center(
        child: Text("No Reports Yet"),
      );
    }

    if (hasInitialzie && reports.length > 0) {
      return ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              constraints:
                  BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  this.reports[index].report_type == 1
                      ? Text(reports[index].user.userName +
                          " with id " +
                          reports[index].user.user_id.toString() +
                          " born at " +
                          reports[index].user.birthDate +
                          " wanted to join!")
                      : Text("More than 5 people reports " +
                          reports[index].user.userName),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    this.reports[index].updated_date.forPostDate(),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _respondReport(1, this.reports[index]);
                        },
                        child: Text(
                          "Approved",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            onPrimary: Colors.white,
                            primary: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _respondReport(0, this.reports[index]);
                        },
                        child: Text(
                          "Reject",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            onPrimary: Colors.white,
                            primary: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 1,
            );
          },
          itemCount: reports.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(7),
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: reportsBodyWidget(),
    );
  }
}
