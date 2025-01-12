import 'package:flutter/material.dart';
import 'package:create_a_basic_flutter_app_marc_baneres_farran_gsoc_2025/components/connection_flag.dart';
import 'package:create_a_basic_flutter_app_marc_baneres_farran_gsoc_2025/connections/ssh.dart';
import 'package:dartssh2/dartssh2.dart';

import '../components/reusable_card.dart';

bool connectionStatus = false;
// TODO 17: Initialize const String searchPlace

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
                        // TODO 14: Implement relaunchLG() as async task
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
                        // TODO 15: Implement shutdownLG() as async task
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
                        // TODO 16: Implement clearKML() as async task and test
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
                        // TODO 21: Implement rebootLG() as async task and test
                      },
                      cardChild: const Center(
                        child: Text(
                          'CLEAN LG LOGOS',
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
                        SSHSession? result = await ssh.cleanKML();
                        print('KMLs cleaned successfully');
                                            },
                      cardChild: const Center(
                        child: Text(
                          'CLEAN KMLS',
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
