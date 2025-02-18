import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/connection_flag.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/connections/ssh.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../components/reusable_card.dart';

bool connectionStatus = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SSH ssh;
  int targetProgress = 0;
  int displayProgress = 0;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    if (result != null && result) {
      setState(() {
        connectionStatus = true;
        targetProgress = 1;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          displayProgress = 1;
        });
      });
    }
  }

  Future<void> _advanceProgress(int nextProgress) async {
    if (nextProgress == displayProgress + 1) {
      setState(() {
        targetProgress = nextProgress;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          displayProgress = nextProgress;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('LG App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: ConnectionFlag(
                status: connectionStatus,
              ),
            ),
            SizedBox(
              height: 100,
              child: ReusableCard(
                colour: const Color(0xFF424242),
                onPress: () async {
                  String content = await rootBundle.loadString(
                      'lib/files/kml/Night light in India during Diwali.kml');
                  File? localFile = await ssh.makeFile(
                      'Night light in India during Diwali', content);
                  if (localFile != null) {
                    await ssh.uploadKMLFile(
                        localFile, 'Night light in India during Diwali');
                    await ssh.loadKML('Night light in India during Diwali');
                    await ssh.flyTo(content);
                    _advanceProgress(2);
                  } else {
                    print('The file is null');
                  }
                },
                cardChild: const Center(
                  child: Text(
                    'SEND KML',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ReusableCard(
                colour: const Color(0xFF424242),
                onPress: () async {
                  _advanceProgress(3);
                },
                cardChild: const Center(
                  child: Text(
                    'SEND 3D KML',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ReusableCard(
                colour: const Color(0xFF424242),
                onPress: () async {
                  await ssh.clearKML();
                  _advanceProgress(4);
                },
                cardChild: const Center(
                  child: Text(
                    'CLEAR KMLS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            MilestoneProgressBar(
              targetProgress: targetProgress,
              displayProgress: displayProgress,
              totalMilestones: 4,
              milestoneTexts: const [
                'Connect',
                'Send KML',
                'Send 3D KML',
                'Clear KML'
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedMilestoneCircle extends StatefulWidget {
  final int milestoneNumber;
  final bool filled;

  const AnimatedMilestoneCircle({
    Key? key,
    required this.milestoneNumber,
    required this.filled,
  }) : super(key: key);

  @override
  _AnimatedMilestoneCircleState createState() => _AnimatedMilestoneCircleState();
}

class _AnimatedMilestoneCircleState extends State<AnimatedMilestoneCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  static const double diameter = 30;
  bool _prevFilled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fillAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _prevFilled = widget.filled;
    if (widget.filled) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMilestoneCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filled != oldWidget.filled) {
      if (widget.filled) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: AnimatedBuilder(
        animation: _fillAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: diameter,
                height: diameter,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
              ClipOval(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: diameter * _fillAnimation.value,
                    height: diameter * _fillAnimation.value,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Text(
                '${widget.milestoneNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MilestoneProgressBar extends StatelessWidget {
  final int targetProgress;
  final int displayProgress;
  final int totalMilestones;
  final List<String> milestoneTexts;

  const MilestoneProgressBar({
    Key? key,
    required this.targetProgress,
    required this.displayProgress,
    this.totalMilestones = 4,
    required this.milestoneTexts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgressRow(),
        _buildTextsRow(),
      ],
    );
  }

  Widget _buildProgressRow() {
    List<Widget> children = [];
    for (int i = 0; i < totalMilestones; i++) {
      children.add(
        Expanded(
          flex: 2,
          child: AnimatedMilestoneCircle(
            milestoneNumber: i + 1,
            filled: displayProgress >= i + 1,
          ),
        ),
      );

      if (i < totalMilestones - 1) {
        children.add(
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool segmentCompleted = targetProgress > i + 1;
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      height: 4,
                      color: Colors.grey,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: segmentCompleted ? constraints.maxWidth : 0,
                      height: 4,
                      color: Colors.black,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    }
    return Row(children: children);
  }

  Widget _buildTextsRow() {
    List<Widget> children = [];
    for (int i = 0; i < totalMilestones; i++) {
      children.add(
        Expanded(
          flex: 4,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Transform.translate(
                offset: const Offset(1, 0),
                child: Text(
                  milestoneTexts[i],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      if (i < totalMilestones - 1) {
        children.add(
          Expanded(
            flex: 4,
            child: Container(),
          ),
        );
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

}