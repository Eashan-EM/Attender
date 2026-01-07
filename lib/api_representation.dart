import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:attender/helpers.dart';
import 'package:attender/app_data.dart';
import 'package:attender/dsl_parser.dart';

(int, int) isInvalidRule(String text) {
  return (0, 0);
}

// Serialize/Deserialize class for each Rule
class Rule {
  int id = 0;
  String statement = "";

  Rule(dynamic rule) {
    id = rule["id"];
    statement = rule["statement"];
  }

  Rule.create(int i) {
    id = i;
    statement = "New Rule";
    jsonizeAndWrite("dataFile");
  }

  bool addStatement(dynamic rule) {
    statement = rule["statement"];
    jsonizeAndWrite("dataFile");
    return true;
  }

  Map<String, dynamic> jsonize() {
    Map<String, dynamic> map = {
      "id": id,
      "statement": statement
    };
    print("System.Out printing $statement");
    return map;
  }
}

// Serialize/Deserialize class for each Section
class Section {
  int id = 0;
  String markingType = "Presentees";
  String title = "";
  List<Rule> rules = [];
  int lastRuleIndex = 0;
  List<(String, bool)> outputValues = [];

  Section.create(int i) {
    id = i;
    title = "Section$id";
    jsonizeAndWrite("dataFile");
  }

  Section(dynamic section) {
    id = section["id"];
    title = section["title"];
    markingType = section["markingType"];
    for (var rule in section["rules"]) {
      if (rule["id"]>lastRuleIndex) {
        lastRuleIndex = rule["id"];
      }
      rules.add(Rule(rule));
    }
  }

  void addRule() {
    lastRuleIndex += 1;
    rules.add(Rule.create(lastRuleIndex));
    Data().appUpdate();
    jsonizeAndWrite("dataFile");
  }

  void deleteRule(int id) {
    for (int i=0; i<rules.length; i++) {
      if (rules[i].id==id) {
        rules.removeAt(i);
        Data().appUpdate();
        break;
      }
    }
    jsonizeAndWrite("dataFile");
  }

  Map<String, dynamic> jsonize() {
    Map<String, dynamic> map = {
      "id": id,
      "title": title,
      "markingType": markingType,
      "rules": List.generate(rules.length, (index) {
        return rules[index].jsonize();
      }),
    };
    return map;
  }

  List<Row> buildUI(BuildContext context) {
    TextEditingController textController = TextEditingController(text: title);
    (int, int) err = (0, 0);
    String errRuleTitle = "";
    List<Row> builds = [
      Row(
        spacing: 0.0,
        children: [
          Text("Section$id: "),
          Expanded(
              child: TextField(
                controller: textController,
                onSubmitted: (val) {
                  title = val;
                  Data().appUpdate();
                },
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Enter Section Name",
                    isDense: true,
                    contentPadding: const EdgeInsets.only(
                        left: 0.0,
                        right: 0.0,
                        top: 0.0,
                        bottom: 1.0
                    )
                ),
              )
          ),
          IconButton(
            onPressed: () {
              addRule();
            },
            icon: const Icon(Icons.add),
            padding: EdgeInsets.zero,
            iconSize: 20,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            onPressed: () {
              Data().getCurrentWorkspace().deleteSection(id);
            },
            icon: const Icon(Icons.delete),
            color: Colors.red,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            iconSize: 25,
          )
        ],
      )
    ];
    builds.addAll(List.generate(rules.length, (index) {
      Rule rule = rules[index];
      TextEditingController textController = TextEditingController(text: rule.statement);
      return Row(
        children: [
          SizedBox(width: 10,),
          Expanded(
              child: TextField(
                controller: textController,
                onSubmitted: (val) {
                  err = isInvalidRule(val);
                  rule.statement = val;
                  if (err.$1>0) {
                    errRuleTitle = val;
                  }
                  Data().appUpdate();
                  jsonizeAndWrite("dataFile");
                },
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Enter Rule",
                    isDense: true,
                    contentPadding: const EdgeInsets.only(
                        left: 0.0,
                        right: 0.0,
                        top: 0.0,
                        bottom: 1.0
                    )
                ),
              )
          ),
          IconButton(
            onPressed: () {
              deleteRule(rule.id);
            },
            icon: const Icon(Icons.delete),
            color: Colors.red,
            padding: EdgeInsets.zero,
            iconSize: 20,
            constraints: const BoxConstraints(),
          ),
        ],
      );
    }));
    List<String> errStatementsArr = [];
    if (err.$1>0) {
      builds.add(Row(
        children: [
          Text(
            "Error in Rule '$errRuleTitle', in Column ${err.$1}: ${errStatementsArr[err.$2]}",
            style: TextStyle(
                fontFamily: "Monospace",
                color: Colors.red
            ),
          )
        ],
      ));
    }
    return builds;
  }

  List<Widget> outputCards(BuildContext context) {
    List<String> outputStrings = [];
    for (var rule in rules) {
      if (rule.statement.contains('[')) {
        outputStrings.addAll(parseRule(rule.statement));
      } else {
        outputStrings.add(rule.statement);
      }
    }

    List<(String, bool)> temp = [];
    bool added;
    for (var build in outputStrings) {
      added = false;
      for (var val in outputValues) {
        if (val.$1==build) {
          added = true;
          temp.add((build, val.$2));
        }
      }
      if (!added) {
        temp.add((build, false));
      }
    }
    outputValues = temp;

    List<Widget> builds = List.generate(outputValues.length, (index) {
      return Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 3.0,
                  color: Theme.of(context).colorScheme.secondary
              ),
              color: (outputValues[index].$2)?((markingType=="Presentees"?Colors.green.shade200:Colors.red.shade200)):Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0)
          ),
          child: TextButton(
            onPressed: () {
              outputValues[index] = (outputValues[index].$1, !outputValues[index].$2);
              Data().appUpdate();
            },
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero
            ),
            child: Text(
                outputValues[index].$1,
                style: TextStyle(
                    fontFamily: "Monospace",
                    fontSize: 20.0
                )
            ),
          )
      );
    });

    return builds;
  }
}

// Serialize/Deserialize class for each Workspace
class Workspace {
  int id = 0;
  String title = "";
  List<String> alwaysPresent = [];
  List<String> sometimesPresent = [];
  int sometimesPresentAbsentPercent = 0;
  List<String> alwaysAbsent = [];
  List<Section> sections = [];
  int lastSectionIndex = -1;
  String outputFormatter = "";

  // Added due to redundancy of getCurrentWorkspace, so it can create Workspace without any arguments
  Workspace.empty();

  Workspace.create({this.id=0, this.title="New Workspace"}) {
    alwaysPresent = [];
    sometimesPresent = [];
    sometimesPresentAbsentPercent = 0;
    alwaysAbsent = [];
    sections = [];
    lastSectionIndex = -1;
    outputFormatter = "";
  }

  Workspace(dynamic data) {
    id = data["id"];
    title = data["title"];
    alwaysPresent = (data["alwaysPresent"] as List).map((e)=>e.toString()).toList();
    sometimesPresent = (data["sometimesPresent"] as List).map((e)=>e.toString()).toList();
    sometimesPresentAbsentPercent = data["somePreAbsPercent"];
    alwaysAbsent = (data["alwaysAbsent"] as List).map((e)=>e.toString()).toList();
    outputFormatter = data["outputFormatter"];
    for (var section in data["sections"]) {
      if (section["id"]>lastSectionIndex) {
        lastSectionIndex = section["id"];
      }
      sections.add(Section(section));
    }
  }

  Map<String, dynamic> jsonize() {
    Map<String, dynamic> map = {
      "id": id,
      "title": title,
      "alwaysPresent": alwaysPresent,
      "sometimesPresent": sometimesPresent,
      "somePreAbsPercent": sometimesPresentAbsentPercent,
      "alwaysAbsent": alwaysAbsent,
      "outputFormatter": outputFormatter,
      "sections": List.generate(sections.length, (index) {
        return sections[index].jsonize();
      })
    };
    return map;
  }

  List<Widget> buildRulesUI(BuildContext context) {
    List<Widget> builds = [];
    for (var section in sections) {
      builds.addAll(section.buildUI(context));
    }
    builds.add(
      SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              lastSectionIndex += 1;
              sections.add(Section.create(lastSectionIndex));
              Data().appUpdate();
            },
            label: Text("Add Section"),
            icon: const Icon(Icons.add),
            style: TextButton.styleFrom(
                side: BorderSide(
                    width: 2.0,
                    color: Theme.of(context).colorScheme.primary
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)
                )
            ),
          )
      ),
    );
    return builds;
  }


  List<Widget> outputCards(BuildContext context) {
    List<Widget> builds = [];
    for (var section in sections) {
      builds.add(
          Row(
              children: [
                Expanded(
                  child: Center(
                      child: Text(
                          section.title,
                          style: TextStyle(
                              fontFamily: "Monospace",
                              fontSize: 20.0
                          )
                      )
                  ),
                ),
                TextButton(
                    onPressed: () {
                      section.markingType = (section.markingType=="Presentees")?"Absentees":"Presentees";
                      jsonizeAndWrite("dataFile");
                      Data().appUpdate();
                    },
                    child: Center(
                      child: Text(
                        section.markingType,
                        style: TextStyle(
                            color: (section.markingType=="Presentees")?Colors.green:Colors.red
                        ),
                      ),
                    )
                )
              ]
          )
      );
      builds.addAll(section.outputCards(context));
    }
    return builds;
  }

  String errRule = "";
  (int, int) errVal = (0, 0);
  String errFrom = "";
  List<String> errStatementArr = [];
  // To be used for saving to alwaysPresent, alwaysAbsent and sometimesPresent
  List<String> saveAddSubtractRules(String text, String errF) {
    errFrom = errF;
    List<String> list = [];
    String capture = "";
    int i;
    for (i=0; i<text.length; i++) {
      if (text[i]==',') {
        list.add(capture.trim());
        errVal = isInvalidRule(capture);
        errRule = capture;
        capture = "";
        continue;
      }
      if (text[i]=="\\") {
        capture += "\\";
        capture += text[i+1];
        continue;
      }
      capture += text[i];
    }
    if (capture.isNotEmpty) {
      list.add(capture.trim());
      errVal = isInvalidRule(capture);
      errRule = capture;
    }
    jsonizeAndWrite("dataFile");
    return list;
  }

  void saveOutputFormat(String text, String errF) {
    outputFormatter = text;
    errFrom = errF;
    jsonizeAndWrite("dataFile");
  }

  void deleteSection(int id) {
    for (int i=0; i<sections.length; i++) {
      if (sections[i].id==id) {
        sections.removeAt(i);
        Data().appUpdate();
      }
    }
    jsonizeAndWrite("dataFile");
  }

  Map<String, dynamic> outputValues() {
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');
    String formattedDate = '$year-$month-$day';

    Map<String, dynamic> builds = {
      "date": formattedDate,
      "workID": id,
      "outputFormat": outputFormatter,
      "sections": List.generate(sections.length, (index) {
        return {
          "id": sections[index].id,
          "markingType": sections[index].markingType,
          "cards": List.generate(sections[index].outputValues.length, (cardIdx) {
            return {
              "cardValue": sections[index].outputValues[cardIdx].$1,
              "isMarked": sections[index].outputValues[cardIdx].$2
            };
          })
        };
      })
    };
    return builds;
  }
}
