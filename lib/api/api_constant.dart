class ApiConstants {
  static String baseUrl = 'https://creta-thimesheet.com';

  static String setTimeSheet = '/setTimeSheet';
  static String getTimeSheet = '/getTimeSheet';
  static String getTimeSheetStat = '/getTimeSheetStat';
  static String login = '/login';
  static String getAlarmRecord = '/getAlarmRecord';
  static String getMyFavorite = '/getMyFavorite';
  static String getProjectList = '/getProjectList';
  static String getTeamList = '/getTeamList';
  static String addMyFavorite = '/addMyFavorite';
  static String deleteMyFovorite = '/deleteMyFovorite';

  // 과거 프로젝트를 조회를 위해 추가한 api
  static String getPastProjectList = '/getPastProjectList';
  static String getPastTeamList = '/getPastTeamList';
}
