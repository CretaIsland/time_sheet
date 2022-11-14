import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../common/cross_common_job.dart';
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
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return jsonDecode('{ "errMsg" : "statusCode=${response.statusCode}" }');
    } catch (e) {
      errMsg = e.toString();
      log(errMsg);
    }
    return jsonDecode('{ "errMsg" : "$errMsg" }');
  }

  static Future<dynamic> login(String userId, String pwd) async {
    Map<String, String> body = {};
    body['userId'] = userId;
    body['pwd'] = pwd;

    return _apiCall(ApiConstants.baseUrl + ApiConstants.login, body);
  }

  static Future<dynamic> setTimeSheet(String sabun, String jsonData) async {
    Map<String, String> body = {};
    body['id'] = sabun;
    body['data'] = jsonData;

    return _apiCall(ApiConstants.baseUrl + ApiConstants.setTimeSheet, body);
  }

  static Future<dynamic> getTimeSheet(String sabun, String dateFrom, String dateTo) async {
    Map<String, String> body = {};
    body['id'] = sabun;
    body['dateFrom'] = dateFrom;
    body['dateTo'] = dateTo;

    return _apiCall(ApiConstants.baseUrl + ApiConstants.getTimeSheet, body);
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

  static Future<dynamic> getProjectList(String sabun) async {
    Map<String, String> body = {};
    body['id'] = sabun;

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
