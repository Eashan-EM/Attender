import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:attender/app_data.dart';
import 'dart:convert';

// Default Data to be filled when "dataFile" is not created, i.e. app is launched for first time
String fillSpecialData() {
  return '''
{
  "lastOpenedWorkspace": 0,
  "data": []
}''';
}

// Default Data to be filled when "dateFile" is not created, i.e. app is launched for first time, or attendence has never been saved
String fillDateData() {'package:attender/app_data.dart';
  return '''
{
  "dates": []
}''';
}

// Gets directory to store files in
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

// Gets the data file
Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/appData.json');
}

// Gets the "dateFile"
Future<File> get _dateFile async {
  final path = await _localPath;
  return File('$path/dateFile.json');
}

// Write data to either data file or date file depending on parameter
Future<File> writeData(String data, String fileType) async {
  // filetype can be "dataFile" or "dateFile"
  File file;
  if (fileType=="dataFile") {
    file = await _localFile;
  } else {
    file = await _dateFile;
  }
  return file.writeAsString(data);
}

// Checks if data file or date file exists
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

// Read data from either data file or date file
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

// Either reads file successfully or returns default data
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

// Convert internal data to JSON and save it to file
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