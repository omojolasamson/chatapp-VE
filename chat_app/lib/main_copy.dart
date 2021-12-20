import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:chat_app/api.dart';

void main() {
  /*WebSocketLink link = WebSocketLink(
    url: 'http://10.0.2.2:3000',
    config: const SocketClientConfig(
      autoReconnect: true,
    ),
  );

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    ),
  );*/
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: client,
        child: MaterialApp(
          title: 'CHat',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'CHat Page'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final String firstName;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    createAlertDialog(context).then((onValue) {
      setState(() {
        firstName = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Subscription(getMessages, "", builder: ({
      required bool loading,
      dynamic payload,
      dynamic error,
    }) {
      return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: const Text("Chats"),
          ),
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(children: [
                error
                    ? Text(error)
                    : loading
                        ? const CircularProgressIndicator()
                        : payload['messages'].map((message) {
                            return Row(
                                mainAxisAlignment: firstName == message.user
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: <Widget>[
                                  firstName == message.user
                                      ? Container()
                                      : Expanded(
                                          flex: 1,
                                          child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 0, 15, 0),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
                                              width: 50.0,
                                              height: 50.0,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  border: Border.all(
                                                      width: 3,
                                                      color: Colors.black)),
                                              child: Text(
                                                firstName
                                                    .substring(0, 2)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ))),
                                  Expanded(
                                      flex: 6,
                                      child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          color: firstName == message.user
                                              ? Colors.green[200]
                                              : Colors.grey[500],
                                          child: Text(
                                            message.content,
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: firstName == message.user
                                                    ? Colors.white
                                                    : Colors.black),
                                          )))
                                ]);
                          }),
                Mutation(
                  options:
                      MutationOptions(documentNode: gql(createMessageMutation)),
                  builder: (runMutation, result) {
                    return Expanded(
                      child: Container(
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, -3),
                              blurRadius: 6.0,
                              color: Colors.black12,
                            ),
                          ],
                        ),
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _buildMessageInput(context),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Container(
                                  height: 45.0,
                                  width: 45.0,
                                  child: RawMaterialButton(
                                      fillColor: Colors.green[200],
                                      shape: const CircleBorder(),
                                      elevation: 5.0,
                                      child: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        if (_textEditingController.text
                                            .trim()
                                            .isEmpty) return;
                                        runMutation({
                                          'user': firstName,
                                          'content':
                                              _textEditingController.text,
                                        });
                                        _textEditingController.clear();
                                      }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              ])));
    });
  }

  Future createAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Your First Name?"),
            content: TextField(
              controller: _textEditingController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: const Text('Submit'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(_textEditingController.text.toString());
                },
              )
            ],
          );
        });
  }

  _buildMessageInput(BuildContext context) {
    final _border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(90.0)),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    );

    return Focus(
      onFocusChange: (focus) {},
      child: TextFormField(
        controller: _textEditingController,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: Theme.of(context).textTheme.caption,
        cursorColor: Colors.green[200],
        onChanged: (val) {},
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          enabledBorder: _border,
          filled: true,
          fillColor: Colors.green[200],
          focusedBorder: _border,
        ),
      ),
    );
  }

  /*_sendMessage() {
    if (_textEditingController.text.trim().isEmpty) return;

    /*final message = Message(
        timestamp: DateTime.now(),
        contents: _textEditingController.text);*/

    _textEditingController.clear();
  }*/
}
