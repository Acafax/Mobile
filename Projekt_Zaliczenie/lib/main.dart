import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


//koko
//koko
//koko
//koko
//koko

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikacja z zadaniami',
      home: MyTableWidget(),
    );
  }
}


class MyTableWidget extends StatefulWidget {
  const MyTableWidget({Key? key}) : super(key: key);

  @override
  _MyTableWidgetState createState() => _MyTableWidgetState();
}

class _MyTableWidgetState extends State<MyTableWidget> {
  @override // Wyświetlenie zadań
  void initState() {
    super.initState();
    _initializeData();
  }

  List<String> tasks = [];
  String selectedPriority = 'A';
  final TextEditingController taskController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zadania do wykonania'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedPriority,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPriority = newValue!;
                    });
                  },
                  items: ['A', 'B', 'C', 'D', 'E']
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                      .toList(),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      labelText: 'Wprowadź zadanie',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: addTask,
                  child: Text('Dodaj Zadanie'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => removeTask(index),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void addTask() {
    final newTask = '$selectedPriority: ${taskController.text}';
    if (taskController.text.isNotEmpty) {
      setState(() {
        tasks.add(newTask);
        addElementToSharedPreferences(newTask);
        taskController.clear();
      });
    }
  }

  void removeTask(int index) async {
    setState(() {
      tasks.removeAt(index);
    });
    await saveTasksToSharedPreferences();
  }

  Future<void> saveTasksToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('klucz_tasks', tasks);
    print('Zaktualizowana lista zapisana do SharedPreferences.');
  }

  Future<void> addElementToSharedPreferences(String newElement) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Pobierz istniejącą listę z SharedPreferences za pomocą klucza
    List<String> existingList = prefs.getStringList('klucz_tasks') ?? [];

    // dodawanie nowego elementu do listy
    existingList.add(newElement);

    // Zapisanie aktualną listę z ponownie do SharedPreferences
    prefs.setStringList('klucz_tasks', existingList);

    print('Nowy element dodany do SharedPreferences.');
  }

  Future<void> StartAddElementFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    tasks = prefs.getStringList('klucz_tasks') ?? [];
    print("wczytanie elementów z listy $tasks");
  }
  Future<void> _initializeData() async {
    await StartAddElementFromSharedPreferences();
  }


}
