class AreaOfImprovementModel{
  int? id;
  var description;
  var visitId;
  var createdAt;
  var sync;

  areaofimprovementMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['weakness_id'] = id ?? null;
    mappingg['weakness_description'] = description!;
    mappingg['visit_id'] = visitId;
    mappingg['created_at'] = createdAt;
    mappingg['sync'] = sync;


    return mappingg;
  }
}