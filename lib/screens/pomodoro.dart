import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PomoDoro extends StatefulWidget {
  const PomoDoro({Key? key}) : super(key: key);

  @override
  _PomoDoroState createState() => _PomoDoroState();
}

class _PomoDoroState extends State<PomoDoro> with TickerProviderStateMixin {
  TabController? _controller;
  int? custom = 300;
  int setuptime = 1500;
  int finaltime = 1500;
  double percent = 0;

  int h = 0, m = 0;
  SharedPreferences? sf;
  bool stop = true;
  late AnimationController? _animationcontroller;

  _start() {
    finaltime = setuptime;
    stop = false;
    setState(() {});
    _increase();
  }

  _changesetup({int? index}) {
    if (index == 0) {
      setuptime = 1500;
    } else if (index == 1) {
      setuptime = 300;
    } else {
      custom = sf!.getInt("custom");
      setuptime = custom!;
    }
  }

  _reset() {
    finaltime = setuptime;

    percent = 0;
    stop = true;
    _animationcontroller!.reverse();

    setState(() {});
  }

  _increase() async {
    if (stop == true) {
      return;
    }
    finaltime--;
    percent = ((setuptime - finaltime) / setuptime);
    if (percent == 1) {
      _reset();
      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ALERT_INCALL_LITE);
    }
    setState(() {});
    (percent < 1 && stop == false)
        ? Future.delayed(const Duration(seconds: 1), () => _increase())
        : _animationcontroller!.reverse();
  }

  initializ() async {
    sf = await SharedPreferences.getInstance();
    custom = sf!.getInt("custom");
  }

  @override
  void initState() {
    initializ();
    _controller = TabController(length: 3, vsync: this);
    _animationcontroller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double temp = finaltime / 60;
    int _min = temp.toInt();
    temp = finaltime % 60;
    int _sec = temp.toInt();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 33, 64, 1),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(30, 33, 64, 1),
        title: Text(
          "pomodoro",
          style: GoogleFonts.workSans(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBar(
                    onTap: (index) {
                      _changesetup(index: index);
                      _reset();
                    },
                    controller: _controller,
                    labelStyle: GoogleFonts.workSans(
                      textStyle: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    indicator: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(18)),
                    tabs: const [
                      Tab(
                        child: Text(
                          "pomodoro",
                        ),
                      ),
                      Tab(
                        child: Text("short break"),
                      ),
                      Tab(
                        child: Text("custom"),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          (_min < 10 ? "0" : "") +
                              _min.toString() +
                              " : " +
                              (_sec < 10 ? "0" : "") +
                              _sec.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: AnimatedContainer(
                        width: (finaltime % 2) == 1 ? 210 : 255,
                        height: (finaltime % 2) == 0 ? 210 : 255,
                        duration: const Duration(
                          seconds: 1,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 210,
                          height: 210,
                          child: Card(
                            color: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999)),
                            child: circlechart(percent),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            stop
                                ? _animationcontroller!.forward()
                                : _animationcontroller!.reverse();
                            stop ? _start() : _reset();
                          },
                          icon: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            color: Colors.white,
                            progress: _animationcontroller!,
                          ),
                        ),
                      ),
                    ),
                  ],
                ))
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: IconButton(
              onPressed: () {
                h = 0;
                m = 0;
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Custom timer : ",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 150,
                                      child: TextField(
                                        onChanged: (val) {
                                          h = int.parse(val);
                                        },
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          label: Text("Hours"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 150,
                                      child: TextField(
                                        onChanged: (val) {
                                          m = int.parse(val);
                                        },
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          label: Text("Minute"),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red[400],
                                  ),
                                  onPressed: () async {
                                    custom = ((h * 60 * 60) + m * 60);
                                    await sf!.setInt("custom", custom!);
                                    Navigator.of(context).pop();
                                    _controller!.animateTo(2,
                                        duration:
                                            const Duration(milliseconds: 500));
                                    _changesetup(index: 2);
                                    _reset();
                                  },
                                  child: const Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              },
              icon: Icon(
                Icons.settings,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget circlechart(double percent) {
    return CircularPercentIndicator(
      radius: 190.0,
      lineWidth: 10.0,
      percent: percent,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.black,
      progressColor: Colors.red[400],
      restartAnimation: false,
      animateFromLastPercent: true,
      animation: true,
      animationDuration: 1000,
    );
  }
}
