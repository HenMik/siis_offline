import '../db_helper/repository.dart';
import '../models/area_of_improvement.dart';


class AreaOfImprovementService
{
  late Repository _repository;
  AreaOfImprovementService(){
    _repository = Repository();
  }

  SaveAreaOfImprovement(AreaOfImprovementModel area_of_improvement) async{
    area_of_improvement.sync = 1;
    return await _repository.insertAreaOfImprovement('weaknesses', area_of_improvement.areaofimprovementMap());
  }
  readAllAreaOfImprovementsByVisitId(String visitId) async{
    return await _repository.readAreaOfImprovementByVisitId('weaknesses', visitId);
  }

  UpdateAreaOfImprovement(AreaOfImprovementModel area_of_improvement) async{
    area_of_improvement.sync = '2';
    return await _repository.UpdateAreaOfImprovement('weaknesses', area_of_improvement.areaofimprovementMap());
  }
  deleteAreaOfImprovement(weakness_id) async {
    return await _repository.deleteAreaOfImprovement('weaknesses', weakness_id);
  }

}