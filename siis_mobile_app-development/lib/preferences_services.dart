




import 'package:shared_preferences/shared_preferences.dart';
import 'package:siis_offline/models/Inspection.dart';
import 'package:siis_offline/models/inspector_model.dart';
import 'package:siis_offline/models/model.dart';

class PreferencesService {
  Future saveSettings(InspectorModel settings) async {
    final  preferences = await SharedPreferences.getInstance();
    await preferences.setString('YearofEstablishment', settings.yearOfEstablishment ?? '');
    await preferences.setString('post', settings.schoolAddress ?? '');
    await preferences.setString('establishment', settings.establishment ?? '');
    await preferences.setString('division', settings.divisionId ?? '');
    await preferences.setString('district', settings.districtId ?? '');
    await preferences.setString('cluster', settings.zoneId ?? '');
    await preferences.setString('school', settings.schoolId ?? '');
    await preferences.setString('head', settings.headTeacher ?? '');
    await preferences.setString('headphone', settings.phoneNumber ?? '');
    await preferences.setString('qualified', settings.nofqTeachers ?? '');
    await preferences.setString('uqualified', settings.noufqTeachers ?? '');
    await preferences.setString('enrolledb', settings.totalEnrolledBoys ?? '');
    await preferences.setString('enrolledg', settings.totalEnrolledGirls ?? '');
    await preferences.setString('attendb', settings.totalAttendanceBoys ?? '');
    await preferences.setString('attendg', settings.totalAttendanceGirls ?? '');
    await preferences.setString('PVD1', settings.presentVisitationDate?? '');
    await preferences.setString('PVD2', settings.previousVisitationDate??'');
    await preferences.setString('advisor', settings.advisor??'');
    await preferences.setString('SGC', settings.schoolGovernanceChair??'');
    await preferences.setString('leadInspector', settings.leadInspectorName??'');
    await preferences.setString('firstInspector', settings.firstInspectorName??'');
    await preferences.setString('secondInspector', settings.secondInspectorName??'');



    print('Saved settings');
  }
  Future<InspectorModel> getSettings() async{
    final preferences = await SharedPreferences.getInstance();
    final post = preferences.getString('post');
    final YearofEstablishment = preferences.getString('YearofEstablishment');
    final establishment = preferences.getString('establishment');
    final division = preferences.getString('division');
    final district = preferences.getString('district');
    final cluster = preferences.getString('cluster');
    final school = preferences.getString('school');
    final head = preferences.getString('head');
    final headphone = preferences.getString('headphone');
    final qualified = preferences.getString('qualified');
    final uqualified = preferences.getString('uqualified');
    final enrolledb = preferences.getString('enrolledb');
    final enrolledg = preferences.getString('enrolledg');
    final attendb = preferences.getString('attendb');
    final attendg = preferences.getString('attendg');
    final PVD1 = preferences.getString('PVD1');
    final PVD2 = preferences.getString('PVD2');
    final advisor = preferences.getString('advisor');
    final SGC = preferences.getString('SGC');
    final leadInspector = preferences.getString('leadInspector');
    final firstInspector = preferences.getString('firstInspector');
    final secondInspector = preferences.getString('secondInspector');
//utu

    return InspectorModel(
      schoolAddress: post,
      yearOfEstablishment: YearofEstablishment,
      establishment: establishment,
      divisionId: division,
      districtId: district,
      zoneId: cluster,
      schoolId: school,
      headTeacher: head,
      phoneNumber: headphone,
      nofqTeachers: qualified,
      noufqTeachers: uqualified,
      totalEnrolledBoys: enrolledb,
      totalEnrolledGirls: enrolledg,
      totalAttendanceBoys: attendb,
      totalAttendanceGirls: attendg,
      presentVisitationDate: PVD1,
      previousVisitationDate: PVD2,
      advisor: advisor,
      schoolGovernanceChair: SGC,
      leadInspectorName: leadInspector,
      firstInspectorName: firstInspector,
      secondInspectorName: secondInspector,
    );
  }
}