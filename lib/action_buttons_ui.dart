import 'package:attender/app_data.dart';
import 'package:flutter/material.dart';
import 'package:attender/action_buttons.dart';
import 'package:attender/helpers.dart';

void showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      
      builder: (BuildContext context) {
        Data data = Data();
        TextEditingController textController = TextEditingController(text: data.dateData["outputFormat"]);
        return ListView(
          children: List.generate(data.dateData["dates"].length, (index) {
            return Padding(
              padding: EdgeInsetsGeometry.all(10),
            child: Column(
              children: [
                SizedBox(width: double.infinity,),
                Text(
                  data.dateData["dates"][index]["date"],
                  style: TextStyle(
                    fontFamily: "Monospace",
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  ),
                ),
                TextField(
                  controller: textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textInputAction: TextInputAction.none,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Expanded(
                    flex: 0,
                    child: TextButton.icon(
                      onPressed: () {
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
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        data.dateData["dates"].removeAt(index);
                        jsonizeAndWrite("dateFile", delete: true);
                        data.appUpdate();
                      },
                      label: Text("Delete"),
                      icon: const Icon(Icons.delete),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(
                          width: 2.0,
                          color: Colors.red,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        )
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(child: TextButton.icon(
                      onPressed: () {
                        copyToClipboard();
                      },
                      label: Text("Copy"),
                      icon: const Icon(Icons.copy),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(
                          width: 2.0,
                          color: Colors.green,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        )
                      ),
                    ))
                    ],
                )
              ],
            ));
          })
        );
      },
    );
  }