import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<String> _cards = ["A", "A", "B", "B", "C", "C", "D", "D", "E", "E", "F","F"];
  List<bool> _flipped = List.filled(12, false);
  final List<int> _selectedIndices = [];
  int _score = 0;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _cards.shuffle();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _flipCard(int index) {
    if (_flipped[index] || _selectedIndices.length == 2) return;
    
    setState(() {
      _flipped[index] = true;
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          if (_cards[_selectedIndices[0]] == _cards[_selectedIndices[1]]) {
            _score += 10;
          } else {
            _flipped[_selectedIndices[0]] = false;
            _flipped[_selectedIndices[1]] = false;
            _score -= 2;
          }
          _selectedIndices.clear();
          
          if (_flipped.every((flipped) => flipped)) {
            _timer?.cancel();
            _showWinDialog();
          }
        });
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("You Win!"),
        content: Text("Time: $_seconds seconds\nScore: $_score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: Text("Restart"),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _cards.shuffle();
      _flipped = List.filled(12, false);
      _selectedIndices.clear();
      _score = 0;
      _seconds = 0;
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Card Matching Game")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Score: $_score", style: TextStyle(fontSize: 20)),
                Text("Time: $_seconds s", style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _flipCard(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        _flipped[index] ? _cards[index] : "?",
                        style: TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
