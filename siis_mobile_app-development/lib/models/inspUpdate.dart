class InspectionUp{
  int? id;
  var sync;

  InspectionUpMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['visit_id'] = id ?? null;
    mappingg['sync'] = sync;


    return mappingg;
  }
}