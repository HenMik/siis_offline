import '../db_helper/repository.dart';
import '../models/recommendation.dart';
import '../models/recommendationUpdate.dart';


class RecommendationService
{
  late Repository _repository;
  RecommendationService(){
    _repository = Repository();
  }

  SaveRecommendation(Recommendation recommendation) async{
    recommendation.sync = '1';
    return await _repository.insertRecommendation('recommendations', recommendation.recommendationMap());
  }
  readAllRecommendationsByVisitId(String visitId) async{
    return await _repository.readRecoByVisitId('recommendations', visitId);
  }
  readStartAndEndDate(String recomId) async{
    return await _repository.readSEdate('recommendations', recomId);
  }

  readAllRecommendationsByVisitIdAndType(String visitId) async{
    return await _repository.readRecoByVisitIdAndType('recommendations', visitId);
  }
  deleteRecommendationWithKeyEvidence(nesId, visitId) async {
    return await _repository.deleteRecommendation('recommendations', nesId, visitId);
  }
  deleteRecommendation2(recoId) async {
    return await _repository.deleteRecommendation2('recommendations', recoId);
  }
  deleteActionByRecommendation(recoId) async {
    return await _repository.deleteActionByRecommendation('action_plans', recoId);
  }
  UpdateRecommendation(Recommendation recommendation) async {
    recommendation.sync = '2';
    return await _repository.UpdateRecommendation('recommendations', recommendation.recommendationMap());
  }
  UpdateRecomm(RecommendationUp recommendation) async{
    return await _repository.updateReco('recommendations', recommendation.recommendationUpMap());
  }
}