import '../db_helper/repository.dart';
import '../models/good_practices.dart';


class GoodPracticesService
{
  late Repository _repository;
  GoodPracticesService(){
    _repository = Repository();
  }

  SaveGoodPractices(GoodPracticesModel good_practices) async{
    good_practices.sync = '1';
    return await _repository.insertGoodPractices('good_practices', good_practices.goodPracticesMap());
  }
  readAllGoodPracticessByVisitId(String visitId) async{
    return await _repository.readGoodPracticesByVisitId('good_practices', visitId);
  }
  // Edit good practice
  UpdateGoodPractice(GoodPracticesModel good_practices) async{
    good_practices.sync = '2';
    return await _repository.updateGoodPractice('good_practices', good_practices.goodPracticesMap());
  }
  // Delete the good practice
  deleteGoodPractice(good_practice_id) async {
    return await _repository.deleteGoodPractice('good_practices', good_practice_id);
  }

}