import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'users';

class User {
  late var userId;
  late var firstName;
  late var lastName;
  late var middleName;
  late var username;
  late var userRole;
  late var userPhone;
  late var userEmail;
  late var sectorId;
  late var emisId;
  late var zoneId;
  late var districtId;
  late var divisionId;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'user_name': username,
      'user_role': userRole,
      'user_email': userEmail,
      'sector_id': sectorId,
      'emis_id': emisId,
      'zone_id': zoneId,
      'district_id': districtId,
      'division_id': divisionId
    };
    return map;
  }

  User(
      {required this.userId,
      required this.firstName,
      required this.userPhone,
      required this.lastName,
      required this.middleName,
      required this.username,
      required this.userRole,
      required this.userEmail,
      required this.sectorId,
      required this.emisId,
      required this.zoneId,
      required this.districtId,
      required this.divisionId});

  User.fromMap(Map<String, Object?> map) {
    userId = map['user_id'];
    firstName = map['first_name'];
    lastName = map['last_name'];
    middleName = map['middle_name'];
    username = map['username'];
    userRole = map['user_role'];
    userPhone = map['user_phone'];
    userEmail = map['user_email'];
    sectorId = map['sector_id'];
    emisId = map['emis_id'];
    zoneId = map['zone_id'];
    districtId = map['district_id'];
    divisionId = map['division_id'];
  }
}

class UserProvider {
  Future<bool> sync(headers) async {
    Database db = await DatabaseConnection().setDatabase();
    User? standard = await UserProvider().getOne(1);
    if (standard?.firstName == null) {
      print("$tableName is empty. syncing...");
      UserProvider().truncate();
      Response response =
          await get(Uri.parse(BaseApi.usersPath), headers: headers);
      List results = jsonDecode(response.body);
      Batch batch = db.batch();
      for (var map in results) {
        User standard = User(
            userId: map['user_id'],
            firstName: map['first_name'],
            lastName: map['last_name'],
            middleName: map['middle_name'],
            username: map['username'],
            userRole: map['user_role'],
            userPhone: map['user_phone'],
            userEmail: map['user_email'],
            sectorId: map['sector_id'],
            emisId: map['emis_id'],
            zoneId: map['zone_id'],
            districtId: map['district_id'],
            divisionId: map['division_id']);
        await UserProvider().insert(standard);
      }
    }
    return true;
  }

  Future<User> insert(User nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, nes.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return nes;
  }

  Future<User?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: [
          'user_id',
          'first_name',
          'last_name',
          'middle_name',
          'user_name',
          'user_role',
          'user_email',
          'sector_id',
          'emis_id',
          'zone_id',
          'district_id',
          'division_id'
        ],
        where: 'user_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  Future<Iterable<User>?> getAll(sector_id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"],
        where: 'user_role = "Inspector" and sector_id = ?',
        whereArgs: [sector_id]);
    if (maps.isNotEmpty) {
      return maps.map((e) => User(
          userId: e['user_id'],
          firstName: e['first_name'],
          lastName: e['last_name'],
          middleName: e['middle_name'],
          username: e['username'],
          userRole: e['user_role'],
          userPhone: e['user_phone'],
          userEmail: e['user_email'],
          sectorId: e['sector_id'],
          emisId: e['emis_id'],
          zoneId: e['zone_id'],
          districtId: e['district_id'],
          divisionId: e['division_id'],));
    }
    return null;
  }
  Future<Iterable<User>?> getLeadInspector(leadId) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"],
        where: 'user_id = ?',
        whereArgs: [leadId]);
    if (maps.isNotEmpty) {
      return maps.map((e) => User(
        userId: e['user_id'],
        firstName: e['first_name'],
        lastName: e['last_name'],
        middleName: e['middle_name'],
        username: e['username'],
        userRole: e['user_role'],
        userPhone: e['user_phone'],
        userEmail: e['user_email'],
        sectorId: e['sector_id'],
        emisId: e['emis_id'],
        zoneId: e['zone_id'],
        districtId: e['district_id'],
        divisionId: e['division_id'],));
    }
    return null;
  }
  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'user_id = ?', whereArgs: [id]);
  }

  Future<bool> truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(User district) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, district.toMap(),
        where: 'user_id = ?', whereArgs: [district.userId]);
  }
}
