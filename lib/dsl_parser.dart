// This file contains functions that parses the Attender Domain Specific Language

import 'package:attender/app_data.dart';

List<String> range(String rule) {
  String num1 = "", num2 = "";
  bool firstNum = true;
  List<String> builds = [];
  for (int i=0; i<rule.length; i++) {
    if (rule[i]=='.') {
      firstNum = false;
      continue;
    }
    if (firstNum) {
      num1 += rule[i];
    } else {
      num2 += rule[i];
    }
  }
  try {
    for (int i=int.parse(num1); i<=int.parse(num2); i++) {
      int numLen = "$i".length;
      if (numLen>num1.length) {
        builds.add("$i");
      } else {
        String sub = num1.substring(0, num1.length-numLen);
        builds.add("$sub$i");
      }
    }
    return builds;
  } catch (e) {
    return [];
  }
}

List<String> parseSection(int id, String type) {
  List<String> ret = [];
  for (var section in Data().getCurrentWorkspace().sections) {
    if (section.id==id) {
      for (var val in section.outputValues) {
        if ((section.markingType==type && val.$2) || (section.markingType!=type && !val.$2)) {
          ret.add(val.$1);
        }
      }
    }
  }
  return ret;
}

List<String> parseOutRules(String rule) {
  DateTime now = DateTime.now();
  String nowTime = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  if (rule=="Date.today") {
    return [nowTime];
  }
  String testForSection = "";
  int sectionId = -1;
  bool isSectionRule = false;
  int i;
  for (i=0; i<rule.length; i++) {
    if (!isSectionRule) {
      testForSection += rule[i];
      if (testForSection=="section") {
        isSectionRule = true;
        testForSection = "";
        continue;
      }
    }
    if (isSectionRule && sectionId==-1) {
      if (rule[i]==".") {
        sectionId = int.parse(testForSection);
        testForSection = "";
        continue;
      } else {
        testForSection += rule[i];
      }
    }
    if (isSectionRule && sectionId>=0) {
      testForSection += rule[i];
    }
  }
  if (isSectionRule) {
    return parseSection(sectionId, testForSection);
  }
  return [];
}

List<String> getRuleCards(String rule) {
  List<String> builds = [];
  if (rule.contains("..")) {
    builds = range(rule);
  }
  if (rule.contains(",")) {
    builds = rule.split(",");
  }
  return builds;
}

List<String> parseRule(String data, {int i=0}) {
  List<String> builds = [];
  String persists = "";
  String rule = "";
  bool isRuleStarted = false;
  for (; i<data.length; i++) {
    if (data[i]=='\\') {
      persists += '\\';
      if (i+1<data.length) {
        persists += data[i+1];
      }
      i += 1;
      continue;
    }
    if (data[i]=='[') {
      isRuleStarted = true;
      continue;
    }
    if (data[i]==']') {
      isRuleStarted = false;
      List<String> lists = getRuleCards(rule);
      //List<String> append = parseRule(data, i:i);
      //append = (append.isNotEmpty)?append: [""];
      for (var list in lists) {
        for (var app in [""]) {
          builds.add("$persists$list$app");
        }
      }
      continue;
    }
    if (isRuleStarted) {
      rule += data[i];
    } else {
      persists += data[i];
    }
  }

  return builds;
}