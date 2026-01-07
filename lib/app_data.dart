import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:attender/dsl_parser.dart';
import 'package:attender/helpers.dart';
import 'package:attender/api_representation.dart';

class Data {
  Data._privateConstructor();

  static final Data _instance = Data._privateConstructor();

  factory Data() {
    return _instance;
  }

  int lastWorkspaceIndex = -1;
  List<Workspace> workspaces = [];
  int currentWorkID = -1;

  void fillData(List<dynamic> data, int lastOpenedWorkspace) {
    currentWorkID = lastOpenedWorkspace;
    for (var work in data) {
      if (work["id"]>lastWorkspaceIndex) {
        lastWorkspaceIndex = work["id"];
      }
      workspaces.add(Workspace(work));
    }
  }

  Map<String, dynamic> jsonize() {
    Map<String, dynamic> map = {
      "lastOpenedWorkspace": currentWorkID,
      "data": List.generate(workspaces.length, (index) {
        return workspaces[index].jsonize();
      })
    };
    return map;
  }

  Workspace getCurrentWorkspace() {
    for (var work in workspaces) {
      if (work.id == currentWorkID) {
        return work;
      }
    }
    // The bottom return will never be used as current workspace will always be in the List
    return Workspace.empty();
  }

  void addNewWorkspace() {
    currentWorkID = lastWorkspaceIndex += 1;
    workspaces.add(Workspace.create(id: currentWorkID, title: "New Workspace"));
    appUpdate();
    jsonizeAndWrite("dataFile");
  }

  void changeWorkspace(int id) {
    for (var work in workspaces) {
      if (work.id==id) {
        currentWorkID = id;
      }
    }
    appUpdate();
  }

  VoidCallback appCallback = () {};
  void setAppUpdate(VoidCallback callback) {
    appCallback = callback;
  }

  void appUpdate() {
    appCallback();
  }

  VoidCallback drawerCallback = () {};
  void setDrawerUpdate(VoidCallback callback) {
    drawerCallback = callback;
  }

  void drawerUpdate() {
    drawerCallback();
  }

  DateTime deleteStart = DateTime.now();
  int deleteTimes = 0;
  bool isDeleted = false;
  void deleteCurrentWorkspace() {
    isDeleted = false;
    DateTime now = DateTime.now();
    if (deleteTimes==0) {
      deleteStart = now;
    }
    if (deleteTimes==3 && now.difference(deleteStart).inSeconds<5) {
      int i;
      for (i=0; i<workspaces.length; i++) {
        if (getCurrentWorkspace().id==workspaces[i].id) {
          workspaces.removeAt(i);
          jsonizeAndWrite("dataFile");
          if (workspaces.isNotEmpty) {
            currentWorkID = workspaces[0].id;
          } else {
            currentWorkID = -1;
          }
          deleteTimes = 0;
          isDeleted = true;
          break;
        }
      }
   }
    // Delete button has to be pressed 3 times for workspace to delete
    if (deleteTimes<3 && now.difference(deleteStart).inSeconds>=5) {
      deleteStart = now;
      isDeleted = false;
    }
    deleteTimes += 1;
  }

  Map<String, dynamic> dateData = {};
  void fillDateData(String data) {
    dateData = json.decode(data); 
  }
}
