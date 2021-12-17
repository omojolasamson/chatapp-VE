import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: InMemoryCache(),
    link: WebSocketLink(url: 'http://10.0.2.2:3000'),
    //link: HttpLink(uri: 'http://10.0.2.2:3000'),
  ),
);

const String getMessages = """
  subscription {
    messages {
      id
      content
      user
    }
  }
""";

const String createMessageMutation = """
  mutation(\$user: String!, \$content: String!) {
    postMessage(user: \$user, content: \$content)
  }
""";
