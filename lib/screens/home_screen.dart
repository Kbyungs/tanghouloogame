import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tanghoolo/screens/game_screen.dart';

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScreen(),
    );
  }
}

class homePage extends StatelessWidget {
  const homePage({super.key});

  Widget _safe() {
    return Container(
      color: const Color(0xFFF8D7A3),
      child: const SizedBox(
        width: 500,
        height: 60,
      ),
    );
  }

  FloatingActionButton extendButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        runApp(const MyApp2());
      },
      label: const Text("Start"),
      backgroundColor: const Color.fromARGB(255, 60, 244, 54),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: SizedBox(
          height: 70,
          width: 120,
          child: extendButton(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        /*FloatingActionButton(
          

          
          onPressed: (){
            runApp( const MyApp2());
          },
          backgroundColor: Colors.red,
          child: Text('start'),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        */

        backgroundColor: const Color(0xFFF8D7A3),
        body: GestureDetector(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              child: _safe(),
            ),
            const SizedBox(
              child: Text(
                'Make \nTangHuoLoo',
                style: TextStyle(
                  fontSize: 60,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
