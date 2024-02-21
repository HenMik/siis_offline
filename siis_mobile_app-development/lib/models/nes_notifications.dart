class NesNotifications{
  int? id;
  var nesId;
  var departmentId;
  var visitId;

  nesNotificationMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['notification_id'] = id ?? null;
    mappingg['nes_id'] = nesId;
    mappingg['visit_id'] = visitId;
    mappingg['department_id'] = departmentId;
    return mappingg;
  }
}