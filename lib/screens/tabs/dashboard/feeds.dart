import '../../../components/custom_button.dart';
import '../../../components/feed_tile.dart';
import '../../../data/feed_list.dart';
import 'package:flutter/material.dart';

class Feeds extends StatefulWidget {
  const Feeds({Key key}) : super(key: key);

  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
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
                    feedList.addFeed("", "You", _controller.text);
                    _controller.clear();
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  text: "Post",
                ),
              )
            ],
          ),
        ),
        CustomButton(
          onTap: () {
            print("loading");
          },
          height: 50,
          text: "New Notification",
          width: MediaQuery.of(context).size.width / 2,
        ),
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
            print("load more");
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
