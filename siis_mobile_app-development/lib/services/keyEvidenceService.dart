import 'package:siis_offline/models/key_evidence.dart';

import '../db_helper/repository.dart';
import '../models/recommendation.dart';
import '../screens/Inspector/key_evidence.dart';


class KeyEvidenceService
{
  late Repository _repository;
  KeyEvidenceService(){
    _repository = Repository();
  }

  SaveKeyEvidence(KeyEvidenceModel key_evidence) async{
    key_evidence.sync = '1';
    return await _repository.insertKeyEvidence('key_evidence', key_evidence.KeyEvidenceMap());
  }

  readAllKeyEvidences(String visitId) async{
    return await _repository.readKeyEvidence('key_evidence', visitId);
  }
  readAllKeyEvidencesByRequirement(String visitId) async{
    return await _repository.readKeyEvidenceByRequirement('key_evidence', visitId);
  }
  readAllKeyEvidencesByNes(String visitId) async{
    return await _repository.readKeyEvidenceByNesId('key_evidence', visitId);

  }

  readAllByNesId(String visitId) async{
    return await _repository.readKeyByNes('key_evidence', visitId);
  }
  readAllRequirementsAchieved(String visitId) async{
    return await _repository.readRequirementsAchieved('key_evidence', visitId);
  }
  readAllRequirementsAchievedAndNes(String visitId, String nesId) async{
    return await _repository.readRequirementsAchievedAndNes('key_evidence', visitId, nesId);
  }
  readNesLevelsAchieved(String visitId) async{
    return await _repository.readNesLevelAchieved('key_evidence', visitId);
  }
  deleteKeyEvidence(nesId, visitId) async {
    return await _repository.deleteKeyEvidence('key_evidence', nesId, visitId);
  }

}