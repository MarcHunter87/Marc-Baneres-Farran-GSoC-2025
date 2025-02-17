import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/connection_flag.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/connections/ssh.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../components/reusable_card.dart';

bool connectionStatus = false;

class AnimatedMilestoneCircle extends StatefulWidget {
  final int milestoneNumber;
  final bool animate;
  final bool filled;

  const AnimatedMilestoneCircle({
    Key? key,
    required this.milestoneNumber,
    required this.animate,
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fillAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    if (widget.animate) {
      _controller.forward();
    } else if (widget.filled) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMilestoneCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0);
    }
    if (widget.filled && !widget.animate) {
      _controller.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: ClipOval(
        child: AnimatedBuilder(
          animation: _fillAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: diameter * _fillAnimation.value,
                    height: diameter,
                    color: Colors.black,
                  ),
                ),
                Center(
                  child: Text(
                    '${widget.milestoneNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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

  const MilestoneProgressBar({
    Key? key,
    required this.targetProgress,
    required this.displayProgress,
    this.totalMilestones = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < totalMilestones; i++) {
      bool filled = displayProgress >= i + 1;
      bool animate = (!filled) && (targetProgress == i + 1);
      children.add(AnimatedMilestoneCircle(
        milestoneNumber: i + 1,
        animate: animate,
        filled: filled,
      ));
      if (i < totalMilestones - 1) {
        children.add(
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double fullWidth = constraints.maxWidth;
                bool segmentCompleted = targetProgress > i + 1;
                return Stack(
                  children: [
                    Container(
                      width: fullWidth,
                      height: 4,
                      color: Colors.grey,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: segmentCompleted ? fullWidth : 0,
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
    return Row(
      children: children,
    );
  }
}

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
    setState(() {
      targetProgress = nextProgress;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        displayProgress = nextProgress;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LG App'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: ConnectionFlag(
              status: connectionStatus,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ReusableCard(
                      colour: const Color(0xFF424242),
                      onPress: () async {
                        if (displayProgress != 1) return;
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
                          'SEND FIRST KML',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ReusableCard(
                      colour: const Color(0xFF424242),
                      onPress: () async {
                        if (displayProgress != 2) return;
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
                  Expanded(
                    child: ReusableCard(
                      colour: const Color(0xFF424242),
                      onPress: () async {
                        if (displayProgress != 3) return;
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MilestoneProgressBar(
              targetProgress: targetProgress,
              displayProgress: displayProgress,
              totalMilestones: 4,
            ),
          ),
        ],
      ),
    );
  }
}
