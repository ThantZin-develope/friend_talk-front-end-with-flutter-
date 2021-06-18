import 'User.dart';

class SystemReports {
  int report_id;
	// if type == 1 user request type == 2 user warning
	 int report_type;
	
	int no_of_reports;
	
	User user;
	
	int created_id;
	
	int updated_id;
	
	String created_date;
	
	String updated_date;

  SystemReports({
    this.report_id,
    this.report_type,
    this.no_of_reports,
    this.user,
    this.created_id,
    this.updated_id,
    this.created_date,
    this.updated_date
  });


  SystemReports.fromJSON(Map<String , dynamic> jsonData){
    this.report_id= jsonData["report_id"];
    this.report_type = jsonData["report_type"];
    this.no_of_reports = jsonData["no_of_reports"];
    this.user = User.fromJSON(jsonData["user"]);
    this.created_id = jsonData["created_id"];
    this.updated_id = jsonData["updated_id"];
    this.created_date = jsonData["created_date"];
    this.updated_date = jsonData["updated_date"];
  }

  Map<String , dynamic> toJSON(){
    return {
      "report_id" : this.report_id,
      "report_type" : this.report_type,
      "no_of_reports" : this.no_of_reports,
      "user" : this.user.toJSON(),
      "created_id" : this.created_id,
      "updated_id" : this.updated_id,
      "created_date" : this.created_date,
      "updated_date" : this.updated_date
    };
  }
}