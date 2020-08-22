import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../components/add_task.dart';
import '../../../components/todo_item_tile.dart';
import '../../../data/todo_list.dart';
import '../../../data/todo_fetch.dart';
import '../../../model/todo_item.dart';

class All extends StatefulWidget {
  All({Key key}) : super(key: key);

  @override
  _AllState createState() => _AllState();
}

class _AllState extends State<All> {
  VoidCallback refetchQuery;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Mutation(
          options: MutationOptions(
            documentNode: gql(TodoFetch.addTodo),
            update: (Cache cache, QueryResult result) {
              return cache;
            },
            onCompleted: (dynamic resultData) {
              refetchQuery();
            },
          ),
          builder: (RunMutation runMutation, QueryResult result) {
            return AddTask(
              onAdd: (value) {
                todoList.addTodo(value);
                runMutation({'title': value, 'isPublic': false});
              },
            );
          },
        ),
        Expanded(
          child: Query(
            options: QueryOptions(
              documentNode: gql(TodoFetch.fetchAll),
              variables: {"is_public": false},
            ),
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              refetchQuery = refetch;
              if (result.hasException) {
                return Text(result.exception.toString());
              }
              if (result.loading) {
                return Text('Loading');
              }
              final List<LazyCacheMap> todos =
                  (result.data['todos'] as List<dynamic>).cast<LazyCacheMap>();
              return Container(
                constraints: BoxConstraints(minWidth: 700, maxWidth: 700),
                child: ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    dynamic responseData = todos[index];
                    return TodoItemTile(
                      item: TodoItem.fromElements(responseData['id'],
                          responseData['title'], responseData['is_completed']),
                      deleteDocument: TodoFetch.deleteTodo,
                      deleteRunMutaion: {
                        'id': responseData['id'],
                      },
                      toggleDocument: TodoFetch.toggleTodo,
                      toggleRunMutaion: {
                        'id': responseData["id"],
                        "isCompleted": !responseData["is_completed"]
                      },
                      refetchQuery: refetchQuery,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
