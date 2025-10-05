import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';

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

void copyToClipboard() {
  String out = Data().getCurrentWorkspace().outputFormatter;
  String ret = "";
  bool inRule = false;
  String rule = "";
  for (int i=0; i<out.length; i++) {
    if (out[i]=='[') {
      inRule = true;
      continue;
    }
    if (out[i]=="]") {
      inRule = false;
      List<String> toAdd = parseOutRules(rule);
      ret += toAdd.join('\n');
      rule = "";
      continue;
    }
    if (inRule) {
      rule += out[i];
    } else {
      ret += out[i];
    }
  }
  Clipboard.setData(ClipboardData(text: ret));
  Data().getCurrentWorkspace().outputFormatter = ret;
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

(int, int) isInvalidRule(String text) {
  return (0, 0);
}

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
    return map;
  }
}

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
  void deleteCurrentWorksapce() {
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

String fillSpecialData() {
  return '''
{
  "lastOpenedWorkspace": 0,
  "data": []
}''';
}

String fillDateData() {
  return '''
{
  "dates": []
}''';
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/appData.json');
}

Future<File> get _dateFile async {
  final path = await _localPath;
  return File('$path/dateFile.json');
}

Future<File> writeData(String data, String fileType) async {
  File file;
  if (fileType=="dataFile") {
    file = await _localFile;
  } else {
    file = await _dateFile;
  }
  return file.writeAsString(data);
}

Future<bool> fileDoesNotExists(String fileType) async {
  File file;
  if (fileType=="dataFile") {
    file = await _localFile;
  } else {
    file = await _dateFile;
  }
  bool fileExists = await file.exists();
  if (!fileExists) {
    await file.create(recursive: true);
  }
  return !fileExists; // Returns true if the file does NOT exist
}

Future<String> readData(String fileType) async {
  try {
    File file;
    if (fileType=="dataFile") {
      file = await _localFile;
    } else {
      file = await _dateFile;
    }
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
    if (fileType=="dataFile") {
      return fillSpecialData(); // Return an empty string or handle as appropriate
    }
    return fillDateData();
  }
}

Future<void> readFile(String file) async {
  String jsonString;
  //await writeData(fillSpecialData(), "dataFile");
  //await writeData(fillDateData(), "dateFile");
  if (await fileDoesNotExists(file)) {
    if (file=="dataFile") {
        jsonString = fillSpecialData();
        writeData(jsonString, "dataFile");
    } else {
        jsonString = fillDateData();
        writeData(jsonString, "dateFile");
    }
  } else {
    jsonString = await readData(file);
  }
  if (file=="dataFile") {
    Map<String, dynamic> data = jsonDecode(jsonString);
    Data().fillData(data["data"], data["lastOpenedWorkspace"]);
  }
  Data().fillDateData(await readData("dateFile"));
}

void jsonizeAndWrite(String fileType, {bool delete=false}) async {
  if (fileType=="dataFile") {
    writeData(json.encode(Data().jsonize()), "dataFile");
  } else {
    if (Data().workspaces.isNotEmpty && !delete) {
      Data().dateData["dates"].add(Data().getCurrentWorkspace().outputValues());
    }
    writeData(json.encode(Data().dateData), "dateFile");
  }
}