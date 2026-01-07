import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:attender/app_data.dart';
import 'dart:convert';

String fillSpecialData() {
  return '''
{
  "lastOpenedWorkspace": 0,
  "data": []
}''';
}

String fillDateData() {'package:attender/app_data.dart';
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