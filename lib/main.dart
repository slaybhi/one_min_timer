import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:wear/wear.dart';
import 'package:flutter_beep/flutter_beep.dart';

void main() => runApp(MyApp());

enum TimerState { running, paused, finish, start }

class MyApp extends StatelessWidget {
  final CountDownController _controller = CountDownController();
  int totalTime = 60;
  TimerState timerState = TimerState.start;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: WatchShape(
            builder: (BuildContext context, WearShape shape, Widget? child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Shape: ${shape == WearShape.round ? 'round' : 'square'}',
                  ),
                  child!,
                ],
              );
            },
            child: AmbientMode(
              builder: (BuildContext context, WearMode mode, Widget? child) {
                return GestureDetector(
                  onDoubleTap: () {
                    _controller.start();
                  },
                  onTap: () {
                    if (timerState == TimerState.paused) {
                      _controller.resume();
                      timerState = TimerState.running;
                    } else if (timerState == TimerState.running) {
                      _controller.pause();
                      timerState = TimerState.paused;
                    } else if (timerState == TimerState.start ||
                        timerState == TimerState.finish) {
                      _controller.start();
                      timerState = TimerState.running;
                    }
                  },
                  child: Container(
                    height: 200,
                    child: CircularCountDownTimer(
                      duration: totalTime,
                      initialDuration: 0,
                      controller: _controller,
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2,
                      ringColor: Color(0xFF706565FF),
                      ringGradient: null,
                      fillColor: Colors.white,
                      fillGradient: null,
                      backgroundColor: Colors.black,
                      backgroundGradient: null,
                      strokeWidth: 20.0,
                      strokeCap: StrokeCap.round,
                      textStyle: TextStyle(
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
                        _controller.start();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
