import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/cross_common_job.dart';
import '../common/logger.dart';
import 'api_constant.dart';

class ApiService {
  static final Map<String, String> _headers = {'Content-Type': 'application/json'};
  static Future<dynamic> _apiCall(
    String uri,
    Map<String, String> body, {
    bool useCross = false,
  }) async {
    String errMsg = 'Unkown error';
    try {
      var url = Uri.parse(uri);
      http.Client client = http.Client();

      if (useCross) {
        CrossCommonJob ccj = CrossCommonJob();
        ccj.changeHttpWithCredentials(client);
      }

      var response = await client.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        logger.finest('api call succeed');
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      logger.finest('api call fail statusCode=${response.statusCode}');
      return jsonDecode('{ "errMsg" : "statusCode=${response.statusCode}" }');
    } catch (e) {
      errMsg = e.toString();
      logger.finest('api call fail error=$errMsg');
    }
    return jsonDecode('{ "errMsg" : "$errMsg" }');
  }

  static Future<dynamic> login(String userId, String pwd) async {
    Map<String, String> body = {};
    body['userId'] = userId;
    body['pwd'] = pwd;

    return _apiCall(ApiConstants.baseUrl + ApiConstants.login, body, useCross: true);
  }

  static Future<dynamic> setTimeSheet(String sabun, String jsonData) async {
    logger.finest('setTimeSheet($sabun, $jsonData)');
    final bytes = utf8.encode(jsonData);
    final base64Str = base64.encode(bytes);

    Map<String, String> body = {};
    body['id'] = sabun;
    body['data'] = base64Str;
    logger.finest('setTimeSheet($sabun, $base64Str)');

    return _apiCall(ApiConstants.baseUrl + ApiConstants.setTimeSheet, body);
  }

  static Future<dynamic> getTimeSheet(String sabun, String dateFrom, String dateTo) async {
    logger.finest('getTimeSheet($sabun, $dateFrom, $dateTo)');

    final dateFromStr = base64.encode(utf8.encode(dateFrom));
    final dateToStr = base64.encode(utf8.encode(dateTo));

    Map<String, String> body = {};
    body['id'] = sabun;
    body['dateStart'] = dateFromStr;
    body['dateEnd'] = dateToStr;
    logger.finest('getTimeSheet($sabun, $dateFromStr, $dateToStr)');
    return _apiCall(ApiConstants.baseUrl + ApiConstants.getTimeSheet, body);
  }

  static Future<dynamic> getTimeSheetStat(String tmId, String dateFrom, String dateTo) async {
    logger.finest('getTimeSheetStat($tmId, $dateFrom, $dateTo)');

    final dateFromStr = base64.encode(utf8.encode(dateFrom));
    final dateToStr = base64.encode(utf8.encode(dateTo));

    Map<String, String> body = {};
    body['tmid'] = tmId;
    body['dateStart'] = dateFromStr;
    body['dateEnd'] = dateToStr;
    logger.finest('getTimeSheetStat($tmId, $dateFromStr, $dateToStr)');
    return _apiCall(ApiConstants.baseUrl + ApiConstants.getTimeSheetStat, body);
  }

  static Future<dynamic> getAlarmRecord(String sabun) async {
    Map<String, String> body = {};
    body['id'] = sabun;

    return _apiCall(ApiConstants.baseUrl + ApiConstants.getAlarmRecord, body);
  }

  static Future<dynamic> getMyFavorite(String sabun) async {
    Map<String, String> body = {};
    body['id'] = sabun;

    return _apiCall(ApiConstants.baseUrl + ApiConstants.getMyFavorite, body);
  }

  static Future<dynamic> getTeamList() async {
    Map<String, String> body = {};

    return _apiCall(ApiConstants.baseUrl + ApiConstants.getTeamList, body);
  }

  static Future<dynamic> getProjectList(String tmId) async {
    Map<String, String> body = {};
    body['tm_id'] = tmId;

    return _apiCall(ApiConstants.baseUrl + ApiConstants.getProjectList, body);
  }

  static Future<dynamic> addMyFavorite(String sabun, String projectCode) async {
    Map<String, String> body = {};
    body['id'] = sabun;
    body['projectCode'] = projectCode;

    return _apiCall(ApiConstants.baseUrl + ApiConstants.addMyFavorite, body);
  }

  static Future<dynamic> deleteMyFovorite(String sabun, String projectCode) async {
    Map<String, String> body = {};
    body['id'] = sabun;
    body['projectCode'] = projectCode;

    return _apiCall(ApiConstants.baseUrl + ApiConstants.deleteMyFovorite, body);
  }
}
