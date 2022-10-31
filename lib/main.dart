import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const MyApp());
}

enum TimerState { running, paused, finish, start }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CountDownController _controller = CountDownController();

  int totalTime = 60;
  Duration currentDuration = const Duration(minutes: 1);
  final Duration minDuration = const Duration(seconds: 1);
  final Duration maxDuration = const Duration(minutes: 15);

  TimerState timerState = TimerState.start;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: WatchShape(
            builder: (BuildContext context, WearShape shape, Widget? child) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: InkWell(
                      onTap: () {
                        showSettings(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.settings,
                          size: 26,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Center(
                      child: GestureDetector(
                    onDoubleTap: () {
                      timerStart();
                    },
                    onTap: () {
                      if (timerState == TimerState.paused) {
                        Wakelock.enable();
                        _controller.resume();
                        timerState = TimerState.running;
                      } else if (timerState == TimerState.running) {
                        stopTimer();
                        timerState = TimerState.paused;
                      } else if (timerState == TimerState.start ||
                          timerState == TimerState.finish) {
                        timerStart();
                        timerState = TimerState.running;
                      }
                    },
                    child: SizedBox(
                      height: 200,
                      child: CircularCountDownTimer(
                        duration: totalTime,
                        initialDuration: 0,
                        controller: _controller,
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 2,
                        ringColor: const Color(0xFF706565),
                        ringGradient: null,
                        fillColor: Colors.white,
                        fillGradient: null,
                        backgroundColor: Colors.black,
                        backgroundGradient: null,
                        strokeWidth: 20.0,
                        strokeCap: StrokeCap.round,
                        textStyle: const TextStyle(
                            fontSize: 33.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textFormat: CountdownTextFormat.S,
                        isReverse: true,
                        isReverseAnimation: false,
                        isTimerTextShown: true,
                        autoStart: false,
                        onStart: () {
                          timerState = TimerState.running;
                        },
                        onComplete: () async {
                          timerState = TimerState.finish;
                          if (await Vibration.hasVibrator() ?? false) {
                            Vibration.vibrate();
                          } else {
                            FlutterBeep.beep();
                          }
                          timerStart();
                        },
                      ),
                    ),
                  )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        showInfo(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.info,
                          size: 26,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  timerStart() {
    Wakelock.enable();
    _controller.start();
  }

  showInfo(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: WatchShape(
                builder:
                    (BuildContext context2, WearShape shape, Widget? child) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back_ios_outlined,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 20, 10, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/next.png",
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Tap for start/pause",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/next.png",
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "double tap for restart",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  showSettings(BuildContext context) {
    int value = totalTime;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: WatchShape(
                builder:
                    (BuildContext context2, WearShape shape, Widget? child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: InkWell(
                            onTap: () async {
                              await setDuration(value);
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back_ios_outlined,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Set Duration",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.60,
                        child: SleekCircularSlider(
                          min: minDuration.inSeconds.toDouble(),
                          max: maxDuration.inSeconds.toDouble(),
                          initialValue: currentDuration.inMinutes.toDouble(),
                          appearance: CircularSliderAppearance(
                            infoProperties: InfoProperties(
                                mainLabelStyle: TextStyle(color: Colors.white),
                                modifier: (val) {
                                  Duration duration =
                                      Duration(seconds: val.toInt());
                                  String str = "";
                                  if (duration.inSeconds < 60) {
                                    str =
                                        "${duration.inSeconds.toString()} sec";
                                  } else {
                                    str =
                                        "${duration.inMinutes.floor()}min : ${duration.inSeconds % 60}sec";
                                  }
                                  return str;
                                }),
                            customWidths:
                                CustomSliderWidths(progressBarWidth: 10),
                            customColors: CustomSliderColors(
                                trackColor: Colors.grey,
                                progressBarColor: Colors.white),
                          ),
                          onChange: (val) {
                            value = val.toInt();
                          },
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

  stopTimer() {
    _controller.pause();
    Wakelock.disable();
  }

  setDuration(int value) {
    totalTime = value;
    _controller.restart(duration: value);
  }
}
