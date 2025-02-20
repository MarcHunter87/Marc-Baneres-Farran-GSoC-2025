import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/connection_flag.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/connections/ssh.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/reusable_card.dart';
import 'package:flutter/services.dart' show rootBundle;

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
        const SizedBox(height: 8),
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
          flex: 2,
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              milestoneTexts[i],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
      if (i < totalMilestones - 1) {
        children.add(
          const Expanded(
            flex: 3,
            child: SizedBox(),
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

class AnimatedMilestoneCircle extends StatelessWidget {
  final int milestoneNumber;
  final bool filled;

  const AnimatedMilestoneCircle({
    Key? key,
    required this.milestoneNumber,
    required this.filled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.black : Colors.grey,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Center(
        child: Text(
          '$milestoneNumber',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
