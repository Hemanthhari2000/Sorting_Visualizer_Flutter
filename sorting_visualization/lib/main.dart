import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1E6BFA),
    ));

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: Colors.grey[200],
      ),
      home: SortHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SortHomePage extends StatefulWidget {
  const SortHomePage({Key key}) : super(key: key);
  @override
  _SortHomePageState createState() => _SortHomePageState();
}

class _SortHomePageState extends State<SortHomePage> {
  String _currentSortAlgo = "bubble";
  bool isSorted = false;
  bool isSorting = false;
  List<int> _numbers = [];
  int _sampleSize = 25;
  int arrayRange = 500;
  int speed = 0;

  List<int> _barsCount = [25, 50, 100, 150, 200, 250, 300];

  StreamController _streamController = StreamController();

  static int duration = 2000;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Duration _getDuration() {
    return Duration(microseconds: duration);
  }

  String capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }

  _initializeArray() {
    _numbers = [];
    for (int i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(arrayRange));
    }
    _streamController.add(_numbers);
  }

  _reset() {
    isSorted = false;
    _numbers = [];
    for (int i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(arrayRange));
    }
    _streamController.add(_numbers);
  }

  _setSortAlgo(String type) {
    setState(() {
      _currentSortAlgo = type;
    });
  }

  _changeSpeed() {
    if (speed >= 4) {
      speed = 0;
      duration = 2000;
    } else {
      speed++;
      duration = duration ~/ 2;
    }

    print(speed.toString() + " " + duration.toString());
    setState(() {});
  }

  _checkAndResetIfSorted() async {
    if (isSorted) {
      _reset();
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  _bubbleSort() async {
    for (int i = 0; i < _numbers.length; ++i) {
      for (int j = 0; j < _numbers.length - i - 1; ++j) {
        if (_numbers[j] > _numbers[j + 1]) {
          int temp = _numbers[j];
          _numbers[j] = _numbers[j + 1];
          _numbers[j + 1] = temp;
        }

        await Future.delayed(_getDuration(), () {});

        _streamController.add(_numbers);
      }
    }
  }

  _selectionSort() async {
    for (int i = 0; i < _numbers.length; i++) {
      for (int j = i + 1; j < _numbers.length; j++) {
        if (_numbers[i] > _numbers[j]) {
          int temp = _numbers[j];
          _numbers[j] = _numbers[i];
          _numbers[i] = temp;
        }

        await Future.delayed(_getDuration(), () {});

        _streamController.add(_numbers);
      }
    }
  }

  _sort() async {
    setState(() {
      isSorting = true;
    });

    await _checkAndResetIfSorted();

    Stopwatch stopwatch = new Stopwatch()..start();

    switch (_currentSortAlgo) {
      case "bubble":
        await _bubbleSort();
        break;

      case "selection":
        await _selectionSort();
        break;
    }

    stopwatch.stop();

    // ======================== Show Snackbar when algo is complete ========================

    // _scaffoldKey.currentState.removeCurrentSnackBar();
    // _scaffoldKey.currentState.showSnackBar(
    //   SnackBar(
    //     content: Text(
    //         "Completed in ${(stopwatch.elapsed.inMilliseconds * .001).toStringAsFixed(2)}s"),
    //   ),
    // );

    // ======================== Show BottomModalSheet when algo is complete ========================
    _scaffoldKey.currentState.showBottomSheet((context) => Container(
          height: 300,
          color: Colors.blue,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    text: "Took about ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                    children: [
                      TextSpan(
                        text:
                            "${(stopwatch.elapsed.inMilliseconds * .001).toStringAsFixed(2)}s",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));

    setState(() {
      isSorting = false;
      isSorted = true;
    });
  }

  @override
  void initState() {
    _initializeArray();
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("${capitalize(_currentSortAlgo)} Sorting"),
        backgroundColor: Color(0xFF1E6BFA),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.black38,
            ),
            child: DropdownButton(
              value: _sampleSize,
              onChanged: (int newValue) {
                setState(() {
                  _sampleSize = newValue;
                  _initializeArray();
                });
              },
              underline: SizedBox(),
              icon: Padding(
                padding: EdgeInsets.only(
                  top: 5.0,
                ),
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.white,
                ),
              ),
              items: _barsCount.map((bar) {
                return DropdownMenuItem(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 5.0,
                    ),
                    child: Text(
                      bar.toString(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  value: bar,
                );
              }).toList(),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Theme(
            data: Theme.of(context).copyWith(
              cardColor: Colors.black38,
            ),
            child: PopupMenuButton(
              initialValue: _currentSortAlgo,
              icon: Icon(
                Icons.menu_rounded,
                color: Colors.white,
              ),
              itemBuilder: (ctx) {
                return [
                  PopupMenuItem(
                    child: Text(
                      "Bubble Sort",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    value: 'bubble',
                  ),
                  PopupMenuItem(
                    child: Text(
                      "Selection Sort",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    value: 'selection',
                  ),
                ];
              },
              onSelected: (String value) {
                _reset();
                _setSortAlgo(value);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 0.0),
          child: StreamBuilder(
              initialData: _numbers,
              stream: _streamController.stream,
              builder: (context, snapshot) {
                List<int> numbers = snapshot.data;
                int counter = 0;

                return Row(
                  children: numbers.map((int num) {
                    counter++;
                    return Container(
                      child: CustomPaint(
                        painter: BarPainter(
                          range: arrayRange,
                          index: counter,
                          value: num,
                          width:
                              MediaQuery.of(context).size.width / _sampleSize,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            SizedBox(
              width: 4,
            ),
            Expanded(
              child: FlatButton(
                child: Text(
                  "Reset",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: isSorting
                    ? null
                    : () {
                        _reset();
                        _setSortAlgo(_currentSortAlgo);
                      },
                color: Colors.red,
              ),
            ),
            SizedBox(
              width: 4,
            ),
            Expanded(
              child: FlatButton(
                child: Text(
                  "Sort",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: isSorting ? null : _sort,
                color: Colors.green,
              ),
            ),
            SizedBox(
              width: 4,
            ),
            Expanded(
              child: OutlineButton(
                child: Text("${speed + 1}x", style: TextStyle(fontSize: 20)),
                onPressed: isSorting ? null : _changeSpeed,
              ),
            ),
            SizedBox(
              width: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class BarPainter extends CustomPainter {
  final double width;
  final int value;
  final int index;
  final int range;

  BarPainter({this.range, this.width, this.value, this.index});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    if (this.value < range * .20) {
      paint.color = Color(0xFF07C8F9);
    } else if (this.value < range * .40) {
      paint.color = Color(0xFF09A6F3);
    } else if (this.value < range * .60) {
      paint.color = Color(0xFF0A85ED);
    } else if (this.value < range * .80) {
      paint.color = Color(0xFF0C63E7);
    } else {
      paint.color = Color(0xFF0D41E1);
    }
    paint.strokeWidth = width;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(index * this.width, 0),
        Offset(index * this.width, this.value.ceilToDouble()), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
