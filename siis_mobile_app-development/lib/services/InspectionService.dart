import 'package:siis_offline/models/Inspection.dart';

import '../db_helper/repository.dart';
import '../models/inspUpdate.dart';


class InspectionService
{
  late Repository _repository;
  InspectionService(){
    _repository = Repository();
  }
  //Save User
  SaveInspection(Inspection inspection) async{
    inspection.sync = 1;
    return await _repository.insertData('inspections', inspection.inspectionMap());
  }
  readAllInspectionsByVisitType(String? sectorId) async{
    return await _repository.readDataByVisitType('inspections', sectorId!);
  }
  //Read All Users
  readAllInspections(String sectorId) async{
    return await _repository.readData('inspections', sectorId);
  }
  readAllInspectionsByZoneId(String sectorId, String zoneId) async{
    return await _repository.readDataZoneId('inspections', sectorId, zoneId);
  }
  readAllInspectionsByVisitId(String visitId) async{
    return await _repository.readDataByVisitId('inspections', visitId);
  }
  readInspections(String sectorId) async{
    return await _repository.readPercentageInspection('inspections', sectorId);
  }
  readAllSchoolsFromInspection(String sectorId) async{
    return await _repository.readSchoolFromInspection('inspections', sectorId);
  }

  readAllInspectionsByZone(String zoneId) async{
    return await _repository.readDataByZone('inspections', zoneId);
  }

  //Edit Inspection
  UpdateInspection(Inspection inspection) async{
    return await _repository.updateData('inspections', inspection.inspectionMap());
  }
  UpdateInsp(InspectionUp inspectionUp) async{
    inspectionUp.sync = '2';
    return await _repository.updateInsp('inspections', inspectionUp.InspectionUpMap());
  }
  deleteInspection(inspectionId) async {
    return await _repository.deleteDataById('inspections', inspectionId);
  }

}