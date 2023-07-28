import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    readData();
  }

  //TODO Scrolling Bool
  bool isScrolled = true;

  //TODO Controller
  TextEditingController titleController = TextEditingController();
  TextEditingController taskController = TextEditingController();

  List<Map<String, dynamic>> taskList = [];

  //TODO Container Name
  var taskBox = Hive.box("taskBox");

  //TODO Create data
  createData(Map<String, dynamic> data) async {
    await taskBox.add(data);
    readData();
  }

  //TODO Read data
  readData() async {
    var data = taskBox.keys.map((key) {
      final item = taskBox.get(key);
      return {'key': key, 'title': item['title'], 'task': item['task']};
    }).toList();
    setState(() {
      taskList = data.reversed.toList();
    });
  }

  //TODO Update Data
  updateData(int? key, Map<String, dynamic> data) async {
    await taskBox.put(key, data);
    readData();
  }

  //TODO Delete Data
  deleteData(int? key) async {
    await taskBox.delete(key);
    readData();
  }

  //TODO BottomSheet
  showFormModel(context, int? key) async {
    titleController.clear();
    taskController.clear();

    if (key != null) {
      final item = taskList.firstWhere((element) => element['key'] == key);
      titleController.text = item['title'];
      taskController.text = item['task'];
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Enter Title"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: taskController,
              decoration: const InputDecoration(hintText: "Enter Task"),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent.shade100,
              ),
              onPressed: () {
                var data = {
                  'title': titleController.text.trim(),
                  'task': taskController.text.trim(),
                };
                if (key == null) {
                  createData(data);
                } else {
                  updateData(key, data);
                }

                Navigator.pop(context);
              },
              child: Text(key == null ? "Add Data" : "Update Data"),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff80C4E7),
          )),
      home: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showFormModel(context, null);
          },
          isExtended: isScrolled,
          icon: const Icon(Icons.add),
          label: const Text("Add Data"),
        ),
        appBar: AppBar(
          title: const Text("Hive Data"),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => readData(),
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.forward) {
                  setState(() {
                    isScrolled = true;
                  });
                }else if(notification.direction == ScrollDirection.reverse){
                  setState(() {
                    isScrolled = false;
                  });
                }
                return true;
              },
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  var currentItem = taskList[index];
                  return Card(
                    color: Colors.orangeAccent.shade200,
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        currentItem['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        currentItem['task'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              showFormModel(context, currentItem['key']);
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              deleteData(currentItem['key']);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
