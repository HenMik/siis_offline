import 'package:shared_preferences/shared_preferences.dart';

class BaseApi{
  static String url = 'https://backendv2.technixlabs.org/api';
  static String loginPath = '$url/users/login';
  static String nationalStandardsPath = '$url/national_standards';
  static String districtPath = '$url/districts';
  static String divisionPath = '$url/divisions';
  static String nesCategoriesPath = '$url/nes_categories';
  static String nesLevelsPath = '$url/nes_levels';
  static String nesRequirementPath = '$url/nes_requirements';
  static String schoolsPath = '$url/schools';
  static String usersPath = '$url/users';
  static String zonePath = '$url/zones';
  static String goodPracticesPath = '$url/good_practices';
  static String requirementsCountPath = '$url/requirements_counts';
  static String strengthPath = '$url/strengths';
  static String weaknessesPath = '$url/weaknesses';
  static String schoolVisitPath = '$url/inspection_visits';
  static String followUpPath = '$url/inspection_visits/followup';
  static String keyEvidencePath = '$url/key_evidences';
  static String recommendationPath = '$url/recommendations/major';
  static String minorRecommendationPath = '$url/recommendations/minor';
  static String criticalIssuesPath = '$url/critical_issues';
  static String actionPlanPath = '$url/action_plans';
  static const String keyToken = 'api_token';
  static const String user = 'auth_user';
  static Map<String,String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };
}