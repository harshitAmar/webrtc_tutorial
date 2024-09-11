import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_tutorial/category_page.dart';
import 'package:webrtc_tutorial/firebase_options.dart';
import 'package:webrtc_tutorial/signaling.dart';

import 'add_product.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestPAge(),
    );
  }
}

class TestPAge extends StatelessWidget {
  const TestPAge({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
              child: Text("category"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CategoryPage()));
              }),
          FloatingActionButton(
              child: Text("product"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddProduct()));
              }),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  List<Map<String, dynamic>> output = [];

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Flutter Explained - WebRTC"),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Wrap(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  signaling.openUserMedia(
                      _localRenderer, _remoteRenderer, false);
                  roomId = await signaling.createRoom(_remoteRenderer, false);
                  textEditingController.text = roomId!;
                  setState(() {});
                },
                child: Text("Audio Call"),
              ),
              ElevatedButton(
                onPressed: () async {
                  signaling.openUserMedia(
                      _localRenderer, _remoteRenderer, true);
                  roomId = await signaling.createRoom(_remoteRenderer, true);
                  textEditingController.text = roomId!;
                  setState(() {});
                },
                child: Text("Video Call"),
              ),
              SizedBox(
                width: 8,
              ),
              // ElevatedButton(
              //   onPressed: () async {

              //   },
              //   child: Text("Create room"),
              // ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  // Add roomId
                  signaling.joinRoom(textEditingController.text.trim(),
                      _remoteRenderer, false);
                },
                child: Text("Join audio room"),
              ),

              ElevatedButton(
                onPressed: () {
                  // Add roomId
                  signaling.joinRoom(
                      textEditingController.text.trim(), _remoteRenderer, true);
                },
                child: Text("Join video room"),
              ),
              SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  signaling.hangUp(_localRenderer);
                },
                child: Text("Hangup"),
              ),
              ElevatedButton(
                onPressed: () {
                  signaling.muteAudio();
                },
                child: Text("Mute Audio"),
              ),
              ElevatedButton(
                onPressed: () {
                  // signaling.muteVideo();

                  var input = [
                    {
                      "name": "Width",
                      "unit": "inch",
                      "values": [32, 24, 36]
                    },
                    {
                      "name": "thickness",
                      "unit": "inch",
                      "values": [2, 4, 6]
                    },
                    {
                      "name": "Fabric",
                      "unit": "typr",
                      "values": ["Cotton", "Nylon", "White"]
                    },
                    {
                      "name": "Color",
                      "unit": "type",
                      "values": ["Red", "Blue", "Green", "White"]
                    }
                  ];

                  output = signaling.generateVariations(input);

                  log("${output}");
                },
                child: Text("Mute Video"),
              )
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
