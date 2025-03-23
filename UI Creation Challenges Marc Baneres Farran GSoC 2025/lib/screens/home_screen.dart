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
  final SSH ssh = SSH();
  int targetProgress = 0;
  int displayProgress = 0;
  bool connectionStatus = false;

  @override
  void initState() {
    super.initState();
    _connectToLG();
    SSH.connectionStatus.listen((status) {
      setState(() {
        connectionStatus = status;
        if (status) {
          targetProgress = 1;
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              displayProgress = 1;
            });
          });
        } else {
          targetProgress = 0;
          displayProgress = 0;
        }
      });
    });
  }

  Future<void> _connectToLG() async {
    await ssh.connectToLG();
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

  Future<void> _retreatProgress(int previousProgress) async {
    setState(() {
      targetProgress = previousProgress;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        displayProgress = previousProgress;
      });
    });
  }

  Future<void> _tryAdvanceWithConnection(int step) async {
    if (connectionStatus && step == displayProgress + 1) {
      _advanceProgress(step);
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
                    _tryAdvanceWithConnection(2);
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
            ),
            SizedBox(
              height: 100,
              child: ReusableCard(
                colour: const Color(0xFF424242),
                onPress: () async {
                  String daeContent =
                      await rootBundle.loadString('lib/files/dae/pyramid.dae');
                  File? daeFile = await ssh.makeDAEFile('pyramid', daeContent);
                  if (daeFile != null) {
                    await ssh.uploadDAEFile(daeFile, 'pyramid');

                    ByteData textureData =
                        await rootBundle.load('lib/files/dae/pyramid.jpg');
                    List<int> textureBytes = textureData.buffer.asUint8List();
                    File? textureFile =
                        await ssh.makeDAETexture('pyramid.jpg', textureBytes);
                    if (textureFile != null) {
                      await ssh.uploadDAETexture(textureFile, 'pyramid.jpg');

                      String content = await rootBundle
                          .loadString('lib/files/kml/pyramid.kml');
                      File? localFile = await ssh.makeFile('pyramid', content);
                      if (localFile != null) {
                        await ssh.uploadKMLFile(localFile, 'pyramid');
                        await ssh.loadKML('pyramid');
                        await ssh.flyTo(content);
                        _tryAdvanceWithConnection(3);
                      } else {
                        print('The KML file is null');
                      }
                    } else {
                      print('The texture file is null');
                    }
                  } else {
                    print('The DAE file is null');
                  }
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
                  _tryAdvanceWithConnection(4);
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
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: ReusableCard(
                      colour: const Color(0xFF424242),
                      onPress: () {
                        _retreatProgress(displayProgress - 1);
                      },
                      cardChild: const Center(
                        child: Text(
                          'PB Previous',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ReusableCard(
                      colour: const Color(0xFF424242),
                      onPress: () {
                        _advanceProgress(displayProgress + 1);
                      },
                      cardChild: const Center(
                        child: Text(
                          'PB Next',
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

  @override
  void dispose() {
    super.dispose();
  }
}
