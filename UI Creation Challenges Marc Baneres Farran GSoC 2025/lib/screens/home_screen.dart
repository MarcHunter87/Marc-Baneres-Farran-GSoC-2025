import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/connection_flag.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/connections/ssh.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;

import '../components/reusable_card.dart';

bool connectionStatus = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SSH ssh;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
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
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
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
                          await ssh
                              .loadKML('Night light in India during Diwali');

                          // Añadir flyTo con los parámetros del KML
                          await ssh.flyTo(
                              87.71119568547307, // longitude
                              20.9773758875981, // latitude
                              0, // altitude
                              -3.872240540561028, // heading
                              5.756690886091893, // tilt
                              7270018.156032546 // range
                              );
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
                      onPress: () async {},
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
                        await ssh.clearKML();
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
        ],
      ),
    );
  }
}
