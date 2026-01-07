import 'package:flutter/services.dart';
import 'package:attender/app_data.dart';
import 'package:attender/dsl_parser.dart';

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
  // Data().getCurrentWorkspace().outputFormatter = ret;
}