import 'package:todo_app/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Config {
  static String _token;

  static final HttpLink httpLink = HttpLink(
    uri: 'https://hasura.io/learn/graphql',
    // uri: 'https://promoted-muskox-80.hasura.app/v1/graphql',
  );

  static final AuthLink authLink = AuthLink(getToken: () => _token);

  static final WebSocketLink websocketLink = WebSocketLink(
    url: 'wss://hasura.io/learn/graphql',
    // url: 'wss://promoted-muskox-80.hasura.app/v1/graphql',
    config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
      initPayload: () => {
        'headers': {'Authorization': _token},
      },
    ),
  );

  static final Link link = authLink.concat(httpLink).concat(websocketLink);

  static ValueNotifier<GraphQLClient> initializeClient(String token) {
    print(token);
    _token = token;
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
        link: link,
      ),
    );
    return client;
  }
}
