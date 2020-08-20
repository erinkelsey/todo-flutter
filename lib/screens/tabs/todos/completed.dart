import '../../../components/add_task.dart';
import '../../../components/todo_item_tile.dart';
import '../../../data/todo_list.dart';
import 'package:flutter/material.dart';

class Completed extends StatefulWidget {
  const Completed({Key key}) : super(key: key);

  @override
  _CompletedState createState() => _CompletedState();
}

class _CompletedState extends State<Completed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AddTask(
            onAdd: (value) {
              todoList.addTodo(value);
            },
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minWidth: 700, maxWidth: 700),
              child: ListView.builder(
                itemCount: todoList.completeList.length,
                itemBuilder: (context, index) {
                  return TodoItemTile(
                    item: todoList.completeList[index],
                    delete: () {
                      setState(() {
                        todoList.removeTodo(todoList.completeList[index].id);
                      });
                    },
                    toggleIsCompleted: () {
                      setState(() {
                        todoList.toggleList(todoList.completeList[index].id);
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
