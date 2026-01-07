// This file contains functions that parses the Attender Domain Specific Language

import 'package:attender/app_data.dart';

/*
* The way the app creates roll numbers is based on rule syntax. As it will be tedious to give all roll numbers
* its better to use quick rule syntax
*/

/*
*  Converts a range of form [num1..num2] to a list [num1, num1+1, num1+2, ..., num2]
* First number can have a minimum width and add a number to it
*   [0..10]  -> [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
*   [00..15] -> [00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10]
*/
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

// The output after parsing all rules
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

// This function checks if rule is of format [a..b] or [a, b, c]
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

// Converts a rule to string
/*
*  The only current way to declare quick rules is using []
*     24CSE10[01, 02, 03] -> [24CSE1001, 24CSE1002, 24CSE1003]
*     24CSE10[01..03]     -> [24CSE1001, 24CSE1002, 24CSE1003]
*     24CSE[10, 11][00..03] -> [24CSE1000, 24CSE1001, 24CSE1002, 24CSE1003, 24CSE1100, 24CSE1101, 24CSE1102, 24CSE1103]
*/
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