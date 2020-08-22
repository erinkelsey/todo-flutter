import 'package:todo_app/data/feed_fetch.dart';

import '../../../components/custom_button.dart';
import '../../../components/feed_tile.dart';
import '../../../data/feed_list.dart';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Feeds extends StatefulWidget {
  const Feeds({Key key}) : super(key: key);

  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  static int _lastLatestFeedId;
  static int _oldestFeedId;
  static int _newTodoCount = 0;
  static int _previousId = 0;
  static int _newId = 0;
  GraphQLClient _client;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _client = GraphQLProvider.of(context).value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Mutation(
            options:
                MutationOptions(documentNode: gql(FeedFetch.addPublicTodo)),
            builder: (RunMutation runMutation, QueryResult result) {
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(minWidth: 500, maxWidth: 500),
                      child: TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: "Say something ...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomButton(
                        width: 90,
                        height: 50,
                        onTap: () {
                          runMutation({"title": _controller.text});
                          _controller.clear();
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        text: "Post",
                      ),
                    )
                  ],
                ),
              );
            }),
        Subscription("fetchNewNotification", FeedFetch.fetchNewNotification,
            builder: ({bool loading, dynamic payload, dynamic error}) {
          if (error != null) print('Error ----> $error');

          if (payload != null) {
            _newId = payload['todos'][0]['id'];

            if (_previousId != 0) {
              _newTodoCount = _newTodoCount + (_newId - _previousId);
            } else {
              _lastLatestFeedId = _newId;
              _client
                  .query(
                QueryOptions(
                  documentNode: gql(FeedFetch.loadMoreTodos),
                  variables: {"oldestTodoId": _newId + 1},
                ),
              )
                  .then((onValue) {
                for (var todo in onValue.data.data['todos']) {
                  feedList.addFeed(todo['id'].toString(), todo['title'],
                      todo['user']['name']);
                }
                setState(() {});
                // feedList.addFeed(username, feed)
              }).catchError((onError) {
                print(onError);
              });
            }

            _previousId = payload['todos'][0]['id'];

            if (_newTodoCount != 0) {
              return CustomButton(
                onTap: () {
                  // scrollController.animateTo(0.0,
                  //     curve: Curves.easeIn,
                  //     duration: Duration(milliseconds: 300));
                  _client
                      .query(
                    QueryOptions(
                      documentNode: gql(FeedFetch.newTodos),
                      variables: {"latestVisibleId": _lastLatestFeedId},
                    ),
                  )
                      .then((onValue) {
                    for (var todo in onValue.data.data['todos'].reversed) {
                      feedList.addfirstFeed(todo['id'].toString(),
                          todo['title'], todo['user']['name']);
                    }
                    _lastLatestFeedId = int.parse(feedList.list.first.id);
                    _newTodoCount = 0;
                    setState(() {});
                  }).catchError((onError) {
                    print(onError);
                  });
                },
                height: 50,
                text: "$_newTodoCount New Notification",
                width: MediaQuery.of(context).size.width / 2,
              );
            } else
              return SizedBox();
          } else
            return SizedBox();
        }),
        SizedBox(height: 20),
        Expanded(
          child: Container(
            constraints: BoxConstraints(minWidth: 700, maxWidth: 700),
            child: ListView.builder(
              itemCount: feedList.list.length,
              itemBuilder: (context, index) {
                return FeedTile(
                    username: feedList
                        .list[feedList.list.length - index - 1].username,
                    feed: feedList.list[feedList.list.length - index - 1].feed);
              },
            ),
          ),
        ),
        CustomButton(
          onTap: () {
            _oldestFeedId = int.parse(feedList.list.last.id);
            _client
                .query(
              QueryOptions(
                documentNode: gql(FeedFetch.loadMoreTodos),
                variables: {"oldestTodoId": _oldestFeedId},
              ),
            )
                .then((onValue) {
              for (var todo in onValue.data.data['todos']) {
                feedList.addFeed(
                    todo['id'].toString(), todo['title'], todo['user']['name']);
              }
              setState(() {});
            }).catchError((onError) {
              print(onError);
            });
          },
          height: 50,
          text: "Load More",
          width: MediaQuery.of(context).size.width / 3,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
