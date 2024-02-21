class RecommendationUp{
  int? id;
  var followUpComments;
  var status;
  var extraFollowUp;

  recommendationUpMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['recommendation_id'] = id ?? null;
    mappingg['followup_comments'] = followUpComments;
    mappingg['need_extra_followup'] = status;
    mappingg['extra_comments'] = extraFollowUp ?? null;


    return mappingg;
  }
}