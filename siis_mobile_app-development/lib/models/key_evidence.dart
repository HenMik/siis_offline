class KeyEvidenceModel{
  int? id;
  int? recomId;
  var description;
  var followUpComments;
  var status;
  var extraFollowUp;
  var keyEvidenceStatus;
  var visitId;
  var createdAt;
  var nesId;
  var requirementId;
  var requirementName;
  var nesLevelId;
  var sync;
  var presentVisitationDate;

  KeyEvidenceMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['key_evidence_id'] = id ?? null;
    mappingg['key_evidence_description'] = description!;
    mappingg['key_evidence_status'] = keyEvidenceStatus!;
    mappingg['visit_id'] = visitId!;
    mappingg['created_at'] = createdAt!;
    mappingg['nes_id'] = nesId!;
    mappingg['requirement_id'] = requirementId!;
    mappingg['nes_level_id'] = nesLevelId!;
    mappingg['sync'] = sync;

    return mappingg;
  }
}