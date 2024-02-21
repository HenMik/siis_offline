class Recommendation{
  int? id;
  var description;
  var nesCategory;
  var recommendationType;
  var visitId;
  var sync;
  var createdAt;
  var nesId;
  var startDate;
  var endDate;

  recommendationMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['recommendation_id'] = id ?? null;
    mappingg['recommendation_description'] = description!;
    mappingg['category_id'] = nesCategory;
    mappingg['nes_id'] = nesId ?? null;
    mappingg['sync'] = sync;
    mappingg['visit_id'] = visitId;
    mappingg['created_at'] = createdAt;
    mappingg['recommendation_type'] = recommendationType;








    return mappingg;
  }
}