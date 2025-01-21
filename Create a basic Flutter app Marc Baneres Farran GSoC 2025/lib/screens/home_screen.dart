import 'dart:io';
import 'package:flutter/material.dart';
import 'package:create_a_basic_flutter_app_marc_baneres_farran_gsoc_2025/components/connection_flag.dart';
import 'package:create_a_basic_flutter_app_marc_baneres_farran_gsoc_2025/connections/ssh.dart';
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
        title: const Text('LG Connection'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _connectToLG();
            },
          ),
        ],
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
                        await ssh.sendLogos();
                      },
                      cardChild: const Center(
                        child: Text(
                          'PUT LG LOGOS',
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
                        String content = await rootBundle
                            .loadString('lib/files/kml/Lleida.kml');
                        File? localFile = await ssh.makeFile('Lleida', content);
                        if (localFile != null) {
                          String fileContent = await localFile.readAsString();

                          await ssh.uploadKMLFile(localFile, 'Lleida');
                          await ssh.loadKML('Lleida');
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
                        String content = await rootBundle
                            .loadString('lib/files/kml/Tokyo.kml');
                        File? localFile = await ssh.makeFile('Tokyo', content);
                        if (localFile != null) {
                          String fileContent = await localFile.readAsString();

                          await ssh.uploadKMLFile(localFile, 'Tokyo');
                          await ssh.loadKML('Tokyo');
                        } else {
                          print('The file is null');
                        }
                      },
                      cardChild: const Center(
                        child: Text(
                          'SEND SECOND KML',
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
                        await ssh.clearLogos();
                      },
                      cardChild: const Center(
                        child: Text(
                          'CLEAR LG LOGOS',
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
                      onPress: () async {},
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
