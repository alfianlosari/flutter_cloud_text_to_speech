import 'package:flutter/material.dart';
import 'package:flutter_wavenet/TextToSpeechAPI.dart';
import 'dart:io';
import 'package:audioplayer/audioplayer.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_wavenet/voice.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'DeepMind WaveNet Text To Speech',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new MyHomePage(title: 'DeepMind WaveNet Text To Speech'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  List<Voice> _voices = [];
  Voice _selectedVoice;
  AudioPlayer audioPlugin = AudioPlayer();
  final TextEditingController _searchQuery = TextEditingController();


  initState() {
    super.initState();
    getVoices();
  }


  void synthesizeText(String text, String name) async {
      if (audioPlugin.state == AudioPlayerState.PLAYING) {
        await audioPlugin.stop();
      }
      final String audioContent = await TextToSpeechAPI().synthesizeText(text, _selectedVoice.name, _selectedVoice.languageCodes.first);
      if (audioContent == null) return;
      final bytes = Base64Decoder().convert(audioContent, 0, audioContent.length);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/wavenet.mp3');
      await file.writeAsBytes(bytes);
      await audioPlugin.play(file.path, isLocal: true);
  }
  
  void getVoices() async {
    final voices = await TextToSpeechAPI().getVoices();
    if (voices == null) return;
    setState(() {
      _selectedVoice = voices.firstWhere((e) => e.name == 'en-US-Wavenet-F' && e.languageCodes.first == 'en-US', orElse: () => Voice('en-US-Wavenet-F', 'FEMALE', ['en-US']));
      _voices = voices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: SingleChildScrollView(child:
        Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: DropdownButton<Voice>(
              value: _selectedVoice,
              hint: Text('Select Voice'),
              items: _voices.map((f) => DropdownMenuItem(
                value: f,
                child: Text('${f.name} - ${f.languageCodes.first} - ${f.gender}'),
              )).toList(),
              onChanged: (voice) {
                setState(() {
                  _selectedVoice = voice;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: TextField(
              autofocus: true,
              controller: _searchQuery,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                  hintText: 'Please enter text to convert to WaveNet Speech'
              ),
            ),
          )
        ])
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4.0,
        child: Icon(Icons.audiotrack),
        onPressed: () {
          final text = _searchQuery.text;
          if (text.length == 0 || _selectedVoice == null) return;
          synthesizeText(text, '');
        },
      ),
    );
  }

}
