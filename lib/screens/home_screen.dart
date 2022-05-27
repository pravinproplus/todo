import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do/models/todo_model.dart';
import 'package:to_do/screens/todo_screen.dart';
import 'package:geocoding/geocoding.dart' as geo;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SharedPreferences? prefs;
  List<ToDoModel> todos = [];
  List<ToDoModel> currentData = [];
  Position? position;
  String? currentLocation;
  LocationPermission? permission;

  @override
  void initState() {
    super.initState();

    // setupTodo();
    initial();
  }

  // initial setup
  setupTodo() async {
    prefs = await SharedPreferences.getInstance();
    var stringTodo = prefs!.getString('todo');

    List todoList = jsonDecode(stringTodo!);
    print('hiiiii');
    todos.clear();
    currentData.clear();
    for (var todo in todoList) {
      todos.add(ToDoModel().fromJson(todo));
    }

    for (var i = 0; i < todos.length; i++) {
      print(todos[i].location);
      // print(currentLocation);
      if (currentLocation != null) {
        if (todos[i].location == currentLocation) {
          currentData.add(todos[i]);
        }
      } else {
        print('gggggggg');
      }
    }
    setState(() {});
  }

  void initial() async {
    await checkPermission()
        .then((value) => getLocation().then((value) => setupTodo()));
  }

  Future checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg:
            "Location permissions are permanently denied, we cannot request permissions.",
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // return await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
  }

  Future getLocation() async {
    try {
      print('llllllllll');
      print('jjjjjjjjjjjjj');
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      } else {
        var position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        // position = await getPosition();

        print("location:" + position.latitude.toString());
        var coordinates = Coordinates(position.latitude, position.longitude);
        var addresses = await geo.placemarkFromCoordinates(
            position.latitude, position.longitude);
        // placemarkFromCoordinates(
        //     position.latitude, position.longitude);
        // List addresses =
        //     await Geocoder.local.findAddressesFromCoordinates(coordinates);

        currentLocation = addresses.first.subLocality;
        print(currentLocation! + 'jjjjjjj');

        setState(() {});
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
  // save todo

  void saveTodo() {
    List items = todos.map((e) => e.toJson()).toList();

    prefs!.setString('todo', jsonEncode(items));

    // .then((value) => setupTodo());
  }

  // delete popup

  delete(ToDoModel todo) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Alert"),
              content: const Text("Are you sure to delete"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text("No")),
                TextButton(
                    onPressed: () {
                      for (var i = 0; i < todos.length; i++) {
                        if (todo.id == todos[i].id) {
                          todos.remove(todo);
                          currentData.remove(todo);
                        } else {
                          currentData.remove(todo);
                        }
                      }
                      saveTodo();
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    child: const Text("Yes"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Todo"),
        backgroundColor: const Color.fromARGB(226, 64, 145, 238),
        actions: [
          IconButton(
              onPressed: () async {
                await getLocation();
              },
              icon: Icon(Icons.location_on))
        ],
      ),
      body: currentLocation == null
          ? const Center(
              child: Text('waiting for your location...'),
            )
          : todos.isEmpty && currentData.isEmpty
              ? const Center(
                  child: Text('Please Add Your TODO'),
                )
              : SingleChildScrollView(
                  // physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      currentData.isEmpty
                          ? SizedBox()
                          : Row(
                              children: [
                                Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      currentLocation.toString() + ' TODO',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ],
                            ),
                      currentData.isEmpty
                          ? const SizedBox()
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: currentData.length,
                              itemBuilder: (BuildContext context, int index) {
                                var data = currentData[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(226, 64, 145, 238),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20.0, vertical: 10.0),
                                      leading: Container(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    width: 1.0,
                                                    color: Color.fromARGB(
                                                        60, 255, 255, 255)))),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {});
                                            data.status!
                                                ? data.status = false
                                                : data.status = true;
                                          },
                                          icon: data.status!
                                              ? const Icon(
                                                  Icons.check_box,
                                                  color: Colors.white,
                                                )
                                              : const Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: Colors.white,
                                                ),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          data.status!
                                              ? Text(
                                                  data.title!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                )
                                              : Text(
                                                  data.title!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      subtitle: Wrap(
                                        children: <Widget>[
                                          Text(data.description!,
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  color: Colors.white))
                                        ],
                                      ),
                                      trailing: InkWell(
                                        onTap: () {
                                          delete(data);
                                        },
                                        child: const Icon(Icons.delete,
                                            color: Colors.white, size: 30.0),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: const Text(
                                'Your TODO',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                      Container(
                        child: todos.isEmpty
                            ? const Center(
                                child: Text('Please Add Your  TODO'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: todos.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var data = todos[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color:
                                            Color.fromARGB(226, 64, 145, 238),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 10.0),
                                        leading: Container(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  right: BorderSide(
                                                      width: 1.0,
                                                      color: Color.fromARGB(
                                                          60, 255, 255, 255)))),
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {});
                                              data.status!
                                                  ? data.status = false
                                                  : data.status = true;
                                            },
                                            icon: data.status!
                                                ? const Icon(
                                                    Icons.check_box,
                                                    color: Colors.white,
                                                  )
                                                : const Icon(
                                                    Icons
                                                        .check_box_outline_blank,
                                                    color: Colors.white,
                                                  ),
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            data.status!
                                                ? Text(
                                                    data.title!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    ),
                                                  )
                                                : Text(
                                                    data.title!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                        subtitle: Wrap(
                                          children: <Widget>[
                                            Text(data.description!,
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    color: Colors.white))
                                          ],
                                        ),
                                        trailing: InkWell(
                                          onTap: () {
                                            delete(data);
                                          },
                                          child: const Icon(Icons.delete,
                                              color: Colors.white, size: 30.0),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(226, 64, 145, 238),
        onPressed: () async {
          // toDoController.addTodo(context);
          int id = Random().nextInt(30);
          ToDoModel todo = ToDoModel(
              id: id,
              title: '',
              description: '',
              status: false,
              location: currentLocation);
          var data = await Get.to(() => TodoView(todo: todo));
          if (data != null) {
            setState(() {});
            todos.add(data);
            saveTodo();
            setupTodo();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
