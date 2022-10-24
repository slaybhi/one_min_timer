import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:one_min_timer/infoPage.dart';
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

  final int totalTime = 60;

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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InfoPage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.info,
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

  stopTimer() {
    _controller.pause();
    Wakelock.disable();
  }
}
