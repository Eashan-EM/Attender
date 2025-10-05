import 'package:flutter/material.dart';
import 'package:attender/app_data.dart';
import 'package:attender/action_buttons.dart';

class ShowCards extends StatefulWidget {
  const ShowCards({super.key});

  @override
  State<ShowCards> createState() => _ShowCards();
}

class _ShowCards extends State<ShowCards> {
  final Data data = Data();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        spacing: 10.0,
        children: data.getCurrentWorkspace().outputCards(context),
      ),
    );
  }
}

class ShowActionButtons extends StatefulWidget {
  const ShowActionButtons({super.key});

  @override
  State<ShowActionButtons> createState() => _ShowActionButtons();
}

class _ShowActionButtons extends State<ShowActionButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5.0,
      children: [
        Expanded(
          child: ElevatedButton.icon(
          icon: const Icon(Icons.menu_open),
          label: Text("Open"),
          onPressed: () {
            showActionSheet(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(5.0)
            )
          ),
         ),
        ),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text("Save"),
            onPressed: () {
              jsonizeAndWrite("dateFile");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(5.0)
              )
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: Text("Copy"),
            onPressed: () {
              copyToClipboard();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(5.0)
              )
            ),
           ),
        ),
      ],
    );
  }
}

class ShowDrawer extends StatefulWidget {
  const ShowDrawer({super.key});

  @override
  State<ShowDrawer> createState() => _ShowDrawer();
}

class _ShowDrawer extends State<ShowDrawer> {
  final TextStyle textStyle = TextStyle(
    fontFamily: "Monospace",
  );
  final Data data = Data();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _alwaysPresentController = TextEditingController();
  final TextEditingController _sometimesPresentController = TextEditingController();
  final TextEditingController _alwaysAbsentController = TextEditingController();
  final TextEditingController _outputFormatter = TextEditingController();

  @override
  void initState() {
    super.initState();
    Data().setDrawerUpdate(drawerUpdate);
  }

  void drawerUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _textController.text = data.getCurrentWorkspace().title;
    _alwaysPresentController.text = data.getCurrentWorkspace().alwaysPresent.join(', ');
    _sometimesPresentController.text = data.getCurrentWorkspace().sometimesPresent.join();
    _alwaysAbsentController.text = data.getCurrentWorkspace().alwaysAbsent.join();
    _outputFormatter.text = data.getCurrentWorkspace().outputFormatter;

    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      child: Container(
        width: screenWidth*0.80,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(padding: EdgeInsetsGeometry.all(10.0),
          child: ListView(
            children: [
              Text(
                "Workspace Title",
                style: textStyle,
              ),
              TextField(
                controller: _textController,
                onSubmitted: (value) {
                  data.getCurrentWorkspace().title = value;
                  data.appUpdate();
                },
              ),
              SizedBox(height: 10,),
              Text(
                "Always Present",
                style: textStyle
              ),
              TextField(
                controller: _alwaysPresentController,
                onSubmitted: (value) {
                  setState(() {
                    data.getCurrentWorkspace().alwaysPresent = data.getCurrentWorkspace().saveAddSubtractRules(value, "aP");
                  });
                },
              ),
              if (data.getCurrentWorkspace().errFrom=="aP" && data.getCurrentWorkspace().errVal.$1>0)
                Text(
                  "Error in Always Present,\nColumn ${data.getCurrentWorkspace().errVal.$1} in Rule '${data.getCurrentWorkspace().errRule}': ${data.getCurrentWorkspace().errStatementArr[data.getCurrentWorkspace().errVal.$2]}",
                  style: TextStyle(
                    color: Colors.red
                  ),
                ),
              Text(
                "Sometimes Present",
                style: textStyle
              ),
              TextField(
                controller: _sometimesPresentController,
                onSubmitted: (value) {
                  setState(() {
                    data.getCurrentWorkspace().sometimesPresent = data.getCurrentWorkspace().saveAddSubtractRules(value, "sP");
                  });
                },
              ),
              if (data.getCurrentWorkspace().errFrom=="sP" && data.getCurrentWorkspace().errVal.$1>0)
                Text(
                  "Error in Always Present,\nColumn ${data.getCurrentWorkspace().errVal.$1} in Rule '${data.getCurrentWorkspace().errRule}': ${data.getCurrentWorkspace().errStatementArr[data.getCurrentWorkspace().errVal.$2]}",
                  style: TextStyle(
                    color: Colors.red
                  ),
                ),
              Text(
                "Always Absent",
                style: textStyle
              ),
              TextField(
                controller: _alwaysAbsentController,
                onSubmitted: (value) {
                  setState(() {
                    data.getCurrentWorkspace().alwaysAbsent = data.getCurrentWorkspace().saveAddSubtractRules(value, "aA");
                  });
                },
              ),
              if (data.getCurrentWorkspace().errFrom=="aA" && data.getCurrentWorkspace().errVal.$1>0)
                Text(
                  "Error in Always Present,\nColumn ${data.getCurrentWorkspace().errVal.$1} in Rule '${data.getCurrentWorkspace().errRule}': ${data.getCurrentWorkspace().errStatementArr[data.getCurrentWorkspace().errVal.$2]}",
                  style: TextStyle(
                    color: Colors.red
                  ),
                ),
              Text(
                "Rules Formatter",
                style: textStyle,
              ),
              RulesFormatter(),
 
             Text(
                "Ouptut Formatter",
                style: textStyle
              ),
              TextField(
                controller: _outputFormatter,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onSubmitted: (value) {
                  data.getCurrentWorkspace().title = value;
                  data.appUpdate();
                },
              ),
              if (data.getCurrentWorkspace().errFrom=="oF" && data.getCurrentWorkspace().errVal.$1>0)
                Text(
                  "Error in Output Format,\nColumn ${data.getCurrentWorkspace().errVal.$1} in Rule '${data.getCurrentWorkspace().errRule}': ${data.getCurrentWorkspace().errStatementArr[data.getCurrentWorkspace().errVal.$2]}"
                ),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    data.getCurrentWorkspace().saveOutputFormat(_outputFormatter.text, "oF");
                  },
                  label: Text("Verify and Add Format"),
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
             SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (ctx) {
                    return TextButton.icon(
                      onPressed: () {
                        data.deleteCurrentWorksapce();
                        if (data.isDeleted) {
                          data.appUpdate();
                          Scaffold.of(context).closeDrawer();
                        }
                      },
                      label: Text("Tap 3 times to Delete Workspace"),
                      icon: const Icon(Icons.delete),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(
                          width: 2.0,
                          color: Colors.red
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        )
                      ),
                    );
                  }
                )
              ),
              SizedBox(
                height: 500,
              )
            ]
          ),
        ),
      )
    );
  }
}

class RulesFormatter extends StatefulWidget {
  const RulesFormatter({super.key});

  @override
  State<RulesFormatter> createState() => _RulesFormatter();
}

class _RulesFormatter extends State<RulesFormatter> {
  @override
  Widget build(BuildContext context) {
    final Data data = Data();
    return Column(
      mainAxisSize: MainAxisSize.min,
        children: data.getCurrentWorkspace().buildRulesUI(context)
    );
  }
}

