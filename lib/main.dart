import 'package:flutter/material.dart';
import 'package:attender/create_ui.dart';
import 'package:attender/app_data.dart';
import 'package:attender/helpers.dart';
import 'package:attender/api_representation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await readFile("dataFile");
  await readFile("dateFile");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attender',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Attender'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Data data = Data();

  void updateCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    data.setAppUpdate(updateCallback);

    return Scaffold(
      drawer: ShowDrawer(),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            height: 120.0,
            child:  Column(
              children: [
                SizedBox(height: 20,),
                Row(
                  children: [
                    if (data.workspaces.isNotEmpty)
                      Builder(
                        builder: (context) {
                          return IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          );
                        }
                      ),
                    IconButton(
                      icon: const Icon(Icons.dark_mode),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Attender",
                          style: TextStyle(
                            fontFamily: "Monsospace",
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        )
                      )
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        data.addNewWorkspace();
                      },  
                    )
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(data.workspaces.length, (index) {
                      Workspace work = data.workspaces[index];
                      bool isSelected = work.id == data.currentWorkID;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: (isSelected)?(Theme.of(context).colorScheme.secondary):(Colors.transparent),
                              width: 3.0
                            )
                          )
                        ),
                        child: TextButton(
                          onPressed: () {
                            data.changeWorkspace(work.id);
                          },
                          child: Text(work.title)
                        )
                      );
                    })
                  )
                )
              ]
            )
          ),
          if (data.currentWorkID>=0)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(15.0),
                  child: ShowCards()
                )
              )
            ),
          if (data.workspaces.isNotEmpty)
            ShowActionButtons(),
          SizedBox(height: 40,)
        ]
      ),
    );
  }
}
