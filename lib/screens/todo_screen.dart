import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:to_do/models/todo_model.dart';

// ignore: must_be_immutable
class TodoView extends StatefulWidget {
  ToDoModel? todo;
  TodoView({Key? key, this.todo}) : super(key: key);

  @override
  _TodoViewState createState() => _TodoViewState(todo: this.todo);
}

class _TodoViewState extends State<TodoView> {
  ToDoModel? todo;
  _TodoViewState({this.todo});
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (todo != null) {
      titleController.text = todo!.title!;
      descriptionController.text = todo!.description!;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        backgroundColor: const Color.fromARGB(226, 64, 145, 238),
        title: const Text("Add Todo"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                  child: TextField(
                onChanged: (data) {
                  todo!.title = data;
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: Colors.black),
                  labelText: "Title",
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  //fillColor: Colors.green
                ),
                controller: titleController,
              )),
              const SizedBox(
                height: 25,
              ),
              TextField(
                maxLines: 5,
                onChanged: (data) {
                  todo!.description = data;
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: Colors.black),
                  labelText: "Description",
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  //fillColor: Colors.green
                ),
                controller: descriptionController,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 55.0,
        child: BottomAppBar(
          color: const Color.fromARGB(226, 64, 145, 238),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                  onTap: () {
                    // showDialog(
                    //     context: context,
                    //     builder: (ctx) => AlertDialog(
                    //           title: Text("Alert"),
                    //           content: Text(
                    //               "Mark this todo as ${todo!.status! ? 'not done' : 'done'}  "),
                    //           actions: <Widget>[
                    //             TextButton(
                    //               onPressed: () {
                    //                 Navigator.of(ctx).pop();
                    //               },
                    //               child: Text("No"),
                    //             ),
                    //             TextButton(
                    //               onPressed: () {
                    //                 setState(() {
                    //                   todo!.status = !todo!.status!;
                    //                 });
                    //                 Navigator.of(ctx).pop();
                    //               },
                    //               child: Text("Yes"),
                    //             )
                    //           ],
                    //         ));

                    titleController.clear();
                    descriptionController.clear();
                  },
                  child: const Text(
                    "Clear",
                    style: TextStyle(color: Colors.white),
                  )),
              const VerticalDivider(
                color: Colors.black,
              ),
              IconButton(
                icon: const Icon(Icons.done, color: Colors.white),
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    Get.back(result: todo);
                  } else {
                    Fluttertoast.showToast(msg: 'Please Fill Title');
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
