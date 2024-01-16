import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> tasks = [];
  String selectedPriority = 'A';
  final TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

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
                  onPressed: () => addTask(),
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
        addElementToSharedPreferences(newTask, false);
        taskController.clear();
      });
    }
  }
  Future<void> addElementToSharedPreferences(String taskKey, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Pobierz istniejącą mapę z SharedPreferences za pomocą klucza
    Map<String, bool> existingMap = Map.fromEntries(
      (prefs.getStringList('klucz_tasks') ?? []).map(
            (entry) {
          // Rozdziel klucz i wartość
          List<String> parts = entry.split(':');
          String key = parts[0].trim(); // Klucz
          bool value = parts[1].trim() == 'true'; // Wartość
          return MapEntry(key, value);
        },
      ),
    );

    // Sprawdź, czy zadanie o danym kluczu już istnieje
    if (existingMap.containsKey(taskKey)) {
      print('Zadanie o kluczu $taskKey już istnieje.');
    } else {
      // Dodaj nowy element do mapy
      existingMap[taskKey] = value;

      // Przekształć mapę na listę stringów przed zapisaniem do SharedPreferences
      List<String> updatedList = existingMap.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .toList();

      // Zapisz aktualną listę ponownie do SharedPreferences
      prefs.setStringList('klucz_tasks', updatedList);

      print('Nowy element dodany do SharedPreferences.');
    }
  }


  void removeTask(int index) async {
    setState(() {
      if (index >= 0 && index < tasks.length) {
        String zadanie = tasks[index];
        tasks.removeAt(index);
        removeTaskFromSharedPreferences(zadanie.trim());
      }
    });
  }

  Future<void> removeTaskFromSharedPreferences(String task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String zadanie = " " + task;

    prefs.remove(zadanie.trim());

    print('Zadanie o kluczu $zadanie zostało usunięte z SharedPreferences.');
  }

  Future<void> StartAddElementFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> existingList = prefs.getStringList('klucz_tasks') ?? [];

    tasks.addAll(existingList);

    print("Wczytanie elementów z listy $tasks");
  }

  Future<void> _initializeData() async {
    await StartAddElementFromSharedPreferences();
    await displayAllSharedPreferences();
  }

  Future<void> displayAllSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> allPrefsKeys = prefs.getKeys();

    allPrefsKeys.forEach((key) {
      print('Klucz: $key, Wartość: ${prefs.get(key)}');
    });
  }
}
