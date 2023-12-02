import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit(); // Initialize sqflite ffi

  final database = openDatabase(
    join(await getDatabasesPath(), 'food_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE foods(id INTEGER PRIMARY KEY, name TEXT, calories INTEGER)',
      );
    },
    version: 1,
  );

  // Wait for database initialization to complete
  await database;

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final Future<Database> database;

  MyApp({required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      home: HomePage(database: database),
    );
  }
}

class HomePage extends StatelessWidget {
  final Future<Database> database;

  HomePage({required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealPlanPage(database: database),
              ),
            );
          },
          child: Text('Go to Meal Plan'),
        ),
      ),
    );
  }
}

class MealPlanPage extends StatelessWidget {
  final Future<Database> database;

  MealPlanPage({required this.database});

  Future<List<Map<String, dynamic>>> getFoods() async {
    final Database db = await database;
    return db.query('foods');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Plan Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            List<Map<String, dynamic>> foods = await getFoods();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Food Items and Calories'),
                  content: Column(
                    children: foods.map((food) {
                      return ListTile(
                        title: Text(food['name']),
                        subtitle: Text('Calories: ${food['calories']}'),
                      );
                    }).toList(),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Get Food Items'),
        ),
      ),
    );
  }
}
