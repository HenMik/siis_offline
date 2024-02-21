import '../db_helper/repository.dart';
import '../models/major_strengths.dart';
import '../screens/Inspector/major_strengths/major_strengths.dart';


class MajorStrengthsService
{
  late Repository _repository;
  MajorStrengthsService(){
    _repository = Repository();
  }

  SaveMajorStrengths(MajorStrengthModel major_strengths) async{
    major_strengths.sync = '1';
    return await _repository.insertMajorStrengths('strengths', major_strengths.majorStrengthsMap());
  }
  readAllMajorStrengthssByVisitId(String visitId) async{
    return await _repository.readMajorStrengthsByVisitId('strengths', visitId);
  }
  //Edit User
  UpdateMajorStrength(MajorStrengthModel major_strengths) async{
    major_strengths.sync = '2';
    return await _repository.updateMajor('strengths', major_strengths.majorStrengthsMap());
  }
  deleteMajorStrength(majorStrengthId) async {
    return await _repository.deleteMajor('strengths', majorStrengthId);
  }
}