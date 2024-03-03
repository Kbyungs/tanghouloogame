import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tanghoolo/screens/home_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<RelativeRect>> _animations;
  late List<GlobalKey> _containerKey;
  late List<Offset> _ballX;
  late List<Color> _ballColors; // 공의 색상을 저장할 리스트

  var stickPosition = -500.0;
  bool stickStop = false;
  static const maxTime = 15;
  bool isRunning = true;
  int score = 0;
  int playTime = maxTime;
  late Timer timer;
  bool _isInitDone = false; // 초기화가 완료되었는지 확인하기 위한 플래그

  @override
  void initState() {
    super.initState();
    _animations = [];
    _controllers = [];
    _ballColors = [];
    _containerKey = [];
    for (int i = 0; i < 5; i++) {
      _containerKey.add(GlobalKey());
    }
    _ballX = [];
    // initBalls(); 이 부분을 didChangeDependencies로 이동
    timerStart();
  }

  void onTick(Timer timer) {
    setState(() {
      if (isRunning) playTime -= 1;
      if (playTime == 0) {
        pauseBalls();
        endGame();
        playTime = maxTime;
        timer.cancel();
      }
    });
  }

  void timerStart() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );
  }

  void timeStop() {
    isRunning = false;
  }

  void timeResume() {
    isRunning = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitDone) {
      // 초기화가 아직 안된 경우에만 실행
      // final screenWidth = MediaQuery.of(context).size.width;

      initBalls();

      _isInitDone = true; // 초기화 완료 플래그 설정
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    timer.cancel(); // 타이머 취소 추가
    super.dispose();
  }

  void pauseBalls() {
    for (var controller in _controllers) {
      controller.stop(); // 모든 공의 움직임을 멈춥니다.
    }
  }

  void resumeBalls() {
    for (var controller in _controllers) {
      controller.repeat(); // 모든 공의 움직임을 멈춥니다.
    }
  }

  Offset _getOffset(index) {
    final RenderBox renderBox =
        _containerKey[index].currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    return offset;
  }

  void pauseAndResumeBalls() {
    for (var controller in _controllers) {
      controller.stop(); // 모든 공의 움직임을 멈춥니다.
    }
    stickStop = true;
    _ballX.clear();
    if (stickStop) {
      timeStop();
    }
    for (int i = 0; i < 5; i++) {
      setState(() {
        _ballX.add(_getOffset(i));
      });
    }
    for (int i = 0; i < 4; i++) {
      if (_ballX[4].dx - _ballX[i].dx - 25 < 55 &&
          _ballX[4].dx - _ballX[i].dx - 25 > -55) {
        score += 1;
      }
    }
    Future.delayed(const Duration(seconds: 1), () {
      if (stickStop) {
        for (var controller in _controllers) {
          controller.repeat(); // 1초 후에 공들의 움직임을 다시 시작합니다.
          timeResume();
          setState(
            () {
              stickPosition = -500;
            },
          );
        }
      }
    });
  }

  void endGame() {
    timeStop();
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: const Column(
              children: <Widget>[
                Text(
                  "게임 종료",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "최종 점수: $score",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('홈으로'),
                onPressed: () {
                  runApp(const homePage());
                },
              ),
              TextButton(
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    score = 0;
                    initBalls();
                    timeResume();
                    timerStart();
                  });
                },
              ),
            ],
          );
        });
  }

  // 공과 관련된 초기 설정을 수행하는 메서드
  void initBalls() {
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = [Colors.red, Colors.orange, Colors.green, Colors.purple];
    final random = Random();
    _animations.clear();
    _controllers.clear();
    _ballColors.clear();

    for (int index = 0; index < 4; index++) {
      final randomTime = random.nextInt(501) + 500;
      final ballController = AnimationController(
        duration: Duration(milliseconds: randomTime),
        vsync: this,
      );
      _controllers.add(ballController);
      ballController.repeat();

      final color = colors[random.nextInt(colors.length)];
      _ballColors.add(color); // 공의 색상 결정

      final animation = RelativeRectTween(
        begin: RelativeRect.fromLTRB(-80, 0, screenWidth, 0),
        end: RelativeRect.fromLTRB(screenWidth, 0, -80, 0),
      ).animate(CurvedAnimation(parent: ballController, curve: Curves.linear));

      _animations.add(animation);
    }
  }

  Widget _createMovingBall(int index) {
    return SizedBox(
      height: 90,
      child: Stack(
        children: [
          PositionedTransition(
            rect: _animations[index],
            child: Stack(
              children: [
                Container(
                  key: _containerKey[index],
                  decoration: BoxDecoration(
                    color: _ballColors[index], // 공의 색상 사용
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        offset: const Offset(10, 10),
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFA).withOpacity(0.2), // 반투명하게 설정
                    shape: BoxShape.circle,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stick() {
    return Container(
      key: _containerKey[4],
      color: Colors.yellow,
      child: const SizedBox(
        width: 30,
        height: 725,
      ),
    );
  }

  Widget _lowerStick() {
    return Container(
      color: Colors.yellow,
      child: const SizedBox(
        width: 30,
        height: 100,
      ),
    );
  }

  Widget _safe() {
    return Container(
      color: const Color(0xFFF8D7A3),
      child: const SizedBox(
        width: 500,
        height: 60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8D7A3),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          setState(() {
            stickPosition = -700;
          });
        },
        onTapUp: (details) {
          setState(
            () {
              stickPosition = -100;
              pauseAndResumeBalls();
            },
          );
        },
        child: Column(
          children: [
            Container(
              child: _safe(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                ),
                const SizedBox(
                  height: 50,
                  width: 100,
                  child: Text(
                    'time: ',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 80,
                  child: Text(
                    '$playTime',
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 50,
                  width: 100,
                  child: Text(
                    'score: ',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 80,
                  child: Text(
                    '$score',
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                Positioned(
                  bottom: stickPosition, // 아래쪽에 위치
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter, // 가운데 아래 정렬
                    child: _stick(),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: 200,
                    ),
                    Column(
                      children: _animations.asMap().entries.map((entry) {
                        int index = entry.key;
                        Animation<RelativeRect> animation = entry.value;
                        return _createMovingBall(index); // 인덱스를 전달
                      }).toList(), // 각 애니메이션에 대한 공 생성
                    ),
                    _lowerStick()
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
