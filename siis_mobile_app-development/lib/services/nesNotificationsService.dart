import 'package:siis_offline/models/nes_notifications.dart';
import '../db_helper/repository.dart';
import '../models/nes_notifications.dart';
import '../models/recommendation.dart';


class NesNotificationsService
{
  late Repository _repository;
  NesNotificationsService(){
    _repository = Repository();
  }

  SaveNesNotifications(NesNotifications nes_notifications) async{
    return await _repository.insertNesNotifications('nes_notifications', nes_notifications.nesNotificationMap());
  }

  readAllNesNotifications(String nesId, String visitId) async{
    return await _repository.readNesNotifications('nes_notifications', nesId, visitId);
  }

  deleteNesNotifications(nesId, visitId) async {
    return await _repository.deleteNesNotifications('nes_notifications', nesId, visitId);
  }

}