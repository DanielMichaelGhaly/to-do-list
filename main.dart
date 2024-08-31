import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 0, 0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<String> favourites = [];
  List<TodoItem> todolist = [];
  void toggleFavourites(String current) {
    if (favourites.contains(current)) {
      favourites.remove(current);
    } else {
      favourites.add(current);
    }
    notifyListeners();
  }

  void addItem(String details, DateTime date) {
    todolist
        .add(TodoItem(details: details, date: date, finalDate: DateTime.now()));
    notifyListeners();
  }

  void removeItem(TodoItem x) {
    todolist.remove(x);
    notifyListeners();
  }

  void addFinalDate(TodoItem x, DateTime y) {
    x.finalDate = y;
  }

  void removeFavourite(String quote) {
    favourites.remove(quote);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class TodoItem {
  TodoItem(
      {required this.details, required this.date, required this.finalDate});

  String details;
  DateTime date;
  DateTime finalDate;
  bool isChecked = false;
}

class MyHomePageState extends State<MyHomePage> {
  showAddTodoDialog() async {
    TextEditingController titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          var todolistProvider = context.watch<MyAppState>();
          return AlertDialog(
              title: const Text('Add a new Task'),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Task')),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        Text(
                          'Due Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    selectedDate.hour,
                                    selectedDate.minute);
                              });
                            }
                          },
                        ),
                        IconButton(
                            icon: const Icon(Icons.alarm),
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(selectedDate),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  selectedDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute);
                                });
                              }
                            }),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 120.0),
                      child: Text(
                          'Due Time ${DateFormat("h:mma").format(selectedDate)}'),
                    ),
                  ]);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      todolistProvider.addItem(
                          titleController.text, selectedDate);
                      Navigator.of(context).pop();
                    }
                  },
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    var todolistProvider = context.watch<MyAppState>();
    return Scaffold(
      body: ListView.builder(
          itemCount: todolistProvider.todolist.length,
          itemBuilder: (context, index) {
            final item = todolistProvider.todolist[index];
            if (!todolistProvider.todolist[index].isChecked) {
              return CheckboxListTile(
                value: item.isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    item.isChecked = value!;
                    todolistProvider.addFinalDate(item, DateTime.now());
                  });
                },
                title: Text(item.details),
                subtitle: Text(
                    "${DateFormat('dd-MM-yyyy').format(item.date)} ${DateFormat('h:mma').format(item.date)}"),
              );
            }
          }),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favourite'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Done',
          )
        ],
        onTap: (i) {
          if (i == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FavouritesPage()));
          }
          if (i == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (conetxt) => const FinishedTasks()));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTodoDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      // backgroundColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.orange,
      appBar: AppBar(title: Text('To-do List'), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            icon: const Icon(Icons.quora_outlined),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const QuotePage()));
            },
            tooltip: "Quote of the Day",
          ),
        ),
      ]),
    );
  }
}

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});
  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  final List<String> quotes = [
    "The best way to predict the future is to create it.",
    "You miss 100% of the shots you don't take.",
    "Success is not the key to happiness. Happiness is the key to success.",
    "The only limit to our realization of tomorrow is our doubts of today.",
    "Don't watch the clock; do what it does. Keep going.",
    "The greates glory in living lies not in never falling, but in rising every time we fall.",
  ];
  String currentQuote = "";
  void generateRandomQuote() {
    final random = Random();
    setState(() {
      currentQuote = quotes[random.nextInt(quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(title: Text('Quotes')),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    currentQuote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 30, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 500.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: generateRandomQuote,
                          child: const Text('Generate Quote'),
                        ),
                        SizedBox(width: 20.0),
                        ElevatedButton(
                            onPressed: () {
                              appState.toggleFavourites(currentQuote);
                            },
                            child: Icon(Icons.favorite)),
                      ],
                    ),
                  ),
                ])),
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favourites.isEmpty) {
      return Scaffold(
          backgroundColor: Colors.orange,
          appBar: AppBar(title: Text("Favourite Quotes")),
          body: Center(
            child: Text(
              "No favorites yet.",
              style: TextStyle(fontSize: 40.0, fontStyle: FontStyle.italic),
            ),
          ));
    }
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(title: Text("Favourite Quotes")),
      body: ListView(
        children: [
          for (String pair in appState.favourites)
            if (pair.isNotEmpty)
              ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      appState.removeFavourite(pair);
                    },
                  ),
                  title: Text(pair,
                      style: TextStyle(
                          fontSize: 30.0, fontStyle: FontStyle.italic))),
        ],
      ),
    );
  }
}

class FinishedTasks extends StatelessWidget {
  const FinishedTasks({super.key});
  @override
  Widget build(BuildContext context) {
    var todolistProvider = context.watch<MyAppState>();
    if (todolistProvider.todolist.isEmpty) {
      return Scaffold(
          backgroundColor: Colors.orange,
          appBar: AppBar(title: Text("Completed Tasks")),
          body: Center(
              child: Text(
            "No Done Tasks Yet!",
            style: TextStyle(fontSize: 40.0, fontStyle: FontStyle.italic),
          )));
    }
    int l = 0;
    String t = "";
    for (TodoItem x in todolistProvider.todolist) {
      if (x.isChecked) {
        l++;
      }
    }
    switch (l) {
      case 0:
        t = "Come On! Start with your first task:)";
        break;
      case 1:
        t = "Success always starts with the first step. Great Job!";
        break;
      default:
        t = "You have compeleted $l tasks. Keep Going!!";
        break;
    }
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(title: Text("Completed Tasks")),
      body: ListView(children: [
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              t,
              style: TextStyle(fontSize: 40.0, fontStyle: FontStyle.italic),
            )),
        for (TodoItem x in todolistProvider.todolist)
          if (x.isChecked) ...[
            ListTile(
                leading: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    todolistProvider.removeItem(x);
                  },
                ),
                title: Row(
                  children: [
                    Text(
                      "${x.details} was done at ${DateFormat('dd-MM-yyyy').format(x.finalDate)} ${DateFormat('h:mma').format(x.finalDate)}",
                      style: TextStyle(fontSize: 25.0),
                    ),
                    if (x.finalDate.isAfter(x.date))
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text("Late",
                            style: TextStyle(
                                fontSize: 25.0,
                                fontStyle: FontStyle.normal,
                                color: Colors.red)),
                      ),
                  ],
                )),
          ],
      ]),
    );
  }
}
