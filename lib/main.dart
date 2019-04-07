import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/services.dart';
import 'package:fireworks/fireworks.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lights Out',
      theme: ThemeData(brightness: Brightness.dark),
      home: LightsOutPage(),
    );
  }
}

class LightsOutPage extends StatefulWidget {
  @override
  _LightsOutPageState createState() => _LightsOutPageState();
}

class _LightsOutPageState extends State<LightsOutPage> {
  final AudioCache audioPlayer = new AudioCache();

  int n = 7;
  List<List<bool>> data;
  int onLights;
  bool isWinner = false;
  Size size;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    int i = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Lights Out'),
        actions: <Widget>[
          Center(child: Text('$onLights')),
          SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.apps),
            onPressed: resize,
            tooltip: 'Resize',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: data.map((row) => buildRow(row, i++)).toList(),
          ),
          isWinner
              ? Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/49.png',
                        width: size.width / 1.5,
                        height: size.height / 1.5,
                      ),
                      Text(
                        'Congratulations!\n\nYou\'ve just enlightened our GALAXY!',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Fireworks(numberOfExplosions: 6, delay: 1),
                    ],
                  ))
              : Container(),
        ],
      ),
    );
  }

  Widget buildRow(List row, int i) {
    int j = 0;
    return Row(
      children: row.map((isOn) => buildSquare(i, j++, isOn)).toList(),
    );
  }

  Widget buildSquare(int i, int j, bool isOn) {
    return GestureDetector(
      onTap: () {
        audioPlayer.play('blop.wav');
        flip(i, j);
        flip(i + 1, j);
        flip(i - 1, j);
        flip(i, j + 1);
        flip(i, j - 1);
        checkScore();
      },
      child: Container(
        width: size.width / n,
        height: size.width / n,
        child: AnimatedContainer(
          margin: EdgeInsets.all(2),
          curve: Curves.bounceInOut,
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: !isOn ? Colors.black45 : Colors.greenAccent,
            boxShadow: isOn
                ? [
                    BoxShadow(
                      color: Colors.greenAccent,
                      blurRadius: 5.0,
                      offset: Offset(0.0, 0.0),
                    )
                  ]
                : [],
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: isOn
                ? Image.asset(
                    'assets/${i * n + j}.png',
                  )
                : Container(),
          ),
        ),
      ),
    );
  }

  List<List<bool>> generateData() {
    return List<List<bool>>.generate(
        n, (i) => List<bool>.generate(n, (i) => false));
  }

  void flip(int i, int j) {
    if (i >= 0 && i < data.length && j >= 0 && j < data[0].length) {
      data[i][j] = !data[i][j];
      data[i][j] ? onLights++ : onLights--;
    }
    setState(() {});
  }

  void checkScore() {
    if (onLights == n * n) {
      isWinner = true;
      audioPlayer.play('tada.wav');
    }
    setState(() {});
  }

  void refresh() {
    data = generateData();
    data[Random().nextInt(n)][Random().nextInt(n)] = true;
    onLights = 1;
    isWinner = false;
    setState(() {});
  }

  void resize() {
    n++;
    if (n == 8) n = 5;
    refresh();
  }
}
