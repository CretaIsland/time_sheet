import 'package:flutter/foundation.dart';
import 'data_model.dart';

ProjectDataManager? projectDataHolder;
class ProjectDataManager extends ChangeNotifier {

  // UI에서 표시되는 프로젝트 리스트
  Set<ProjectModel> projectList = {};
  Map<String, Set<String>> projectOthers = {};
  Set<String> projectDescList = {};

  // 작년 프로젝트 리스트
  Set<ProjectModel> pastProjectList = {};
  Map<String, Set<String>> pastProjectOthers = {};
  Set<String> pastProjectDescList = {};

  // 금년 프로젝트 리스트
  Set<ProjectModel> presentProjectList = {};
  Map<String, Set<String>> presentProjectOthers = {};
  Set<String> presentProjectDescList = {};

  String? selectTeamId;


  void setProjectList(List<dynamic> presentPrjData, List<dynamic>? presentOtherPrjData, List<String> presentTeamData,
                        List<dynamic> pastPrjData, List<dynamic>? pastOtherPrjData, List<String> pastTeamData) {
  
    for(var element in presentPrjData) {
      Map<String, String> project = Map<String, String>.from(element);
      if(project['code']==null || project['name']==null) continue;
      ProjectModel projectModel = ProjectModel(code: project['code']!, name: project['name']!);
      presentProjectList.add(projectModel);
      presentProjectDescList.add('${projectModel.code}/${projectModel.name}');
    }
    if(presentOtherPrjData!=null) {
      for(var element in presentOtherPrjData) {
        Map<String, String> project = Map<String, String>.from(element);
        if(project['code']==null || project['name']==null || project['tm_id']==null) continue;
        ProjectModel projectModel = ProjectModel(code: project['code']!, name: project['name']!);
        String tmId = project['tm_id']!;

        for(var team in presentTeamData) {
          if(team.length > tmId.length && team.substring(0, tmId.length) == tmId) {
            tmId = team;
            break;
          }
        }
        if(presentProjectOthers[tmId] == null) {
          presentProjectOthers[tmId] = {};
        }
        presentProjectOthers[tmId]!.add('${projectModel.code}/${projectModel.name}');
      }
    }

    // 과거 프로젝트 리스트 정의
    for(var element in pastPrjData) {
      Map<String, String> project = Map<String, String>.from(element);
      if(project['code']==null || project['name']==null) continue;
      ProjectModel projectModel = ProjectModel(code: project['code']!, name: project['name']!);
      pastProjectList.add(projectModel);
      pastProjectDescList.add('${projectModel.code}/${projectModel.name}');
    }
    if(pastOtherPrjData!=null) {
      for(var element in pastOtherPrjData) {
        Map<String, String> project = Map<String, String>.from(element);
        if(project['code']==null || project['name']==null || project['tm_id']==null) continue;
        ProjectModel projectModel = ProjectModel(code: project['code']!, name: project['name']!);
        String tmId = project['tm_id']!;

        for(var team in pastTeamData) {
          if(team.length > tmId.length && team.substring(0, tmId.length) == tmId) {
            tmId = team;
            break;
          }
        }
        if(pastProjectOthers[tmId] == null) {
          pastProjectOthers[tmId] = {};
        }
        pastProjectOthers[tmId]!.add('${projectModel.code}/${projectModel.name}');
      }
    }

    projectList = presentProjectList;
    projectOthers = presentProjectOthers;
    projectDescList = presentProjectDescList;
    selectTeamId = projectOthers.keys.first;
  }

  void selectTeam(String selectTeamData) {
    selectTeamId = selectTeamData;
    notifyListeners();
  }

  void changeProjectData(String dateYear) {
    // 금년
    if(DataManager.formatter.format(DateTime.now()).substring(0,4) == dateYear) {
      projectList = presentProjectList;
      projectOthers = presentProjectOthers;
      projectDescList = presentProjectDescList;
      selectTeamId = projectOthers.keys.first;
    } else { // 작년
      projectList = pastProjectList;
      projectOthers = pastProjectOthers;
      projectDescList = pastProjectDescList;
      selectTeamId = pastProjectOthers.keys.first;
    }
    notifyListeners();
  }


}