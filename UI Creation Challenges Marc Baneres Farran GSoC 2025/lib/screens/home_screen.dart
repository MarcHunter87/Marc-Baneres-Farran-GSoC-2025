import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/connection_flag.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/reusable_card.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/milestone_progress_bar.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/connections/ssh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SSH ssh;
  int targetProgress = 0;
  int displayProgress = 0;
  bool connectionStatus = false;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
    SSH.connectionStatus.listen((status) {
      setState(() {
        connectionStatus = status;
      });
    });
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    if (result != null && result) {
      setState(() {
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
            _buildKMLCard(),
            _build3DKMLCard(),
            _buildClearKMLCard(),
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

  Widget _buildKMLCard() {
    return SizedBox(
      height: 100,
      child: ReusableCard(
        colour: const Color(0xFF424242),
        onPress: () async {
          String content = await rootBundle.loadString(
              'lib/files/kml/Night light in India during Diwali.kml');
          File? localFile =
              await ssh.makeFile('Night light in India during Diwali', content);
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _build3DKMLCard() {
    return SizedBox(
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
    );
  }

  Widget _buildClearKMLCard() {
    return SizedBox(
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
    );
  }

  @override
  void dispose() {
    ssh.disconnect();
    super.dispose();
  }
}
