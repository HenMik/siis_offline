import '../db_helper/repository.dart';
import '../models/critical_issues.dart';


class CriticalIssuesService
{
  late Repository _repository;
  CriticalIssuesService(){
    _repository = Repository();
  }

  SaveCriticalIssues(CriticalIssuesModel critical_issues) async{
    critical_issues.sync = '1';
    return await _repository.insertCriticalIssues('critical_issues', critical_issues.criticalissuesMap());
  }
  readAllCriticalIssuessByVisitId(String visitId) async{
    return await _repository.readCriticByVisitId('critical_issues', visitId);
  }


  UpdateCriticalIssue(CriticalIssuesModel critical_issues) async{
    critical_issues.sync = '2';
    return await _repository.UpdateCriticalIssue('critical_issues', critical_issues.criticalissuesMap());
  }
  // Delete the good practice
  deleteCriticalIssue(critical_issue_id) async {
    return await _repository.deleteCriticalIssue('critical_issues', critical_issue_id);
  }

}