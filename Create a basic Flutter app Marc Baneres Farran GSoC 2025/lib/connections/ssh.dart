import 'package:dartssh2/dartssh2.dart';
import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = '3';
  }

  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );
      print('IP: $_host, port: $_port');
      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  Future<SSHSession?> execute() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final execResult =
          await _client!.execute('echo "search=Spain" > /tmp/query.txt');
      print('Execution Okay');
      return execResult;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> sendLogos() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }

      int leftMostRig = (int.parse(_numberOfRigs) / 2).floor() + 2;
      double factor = 300 * (6190 / 6054);

      String KML = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <Folder>
      <name>Logos</name>
      <ScreenOverlay>
        <name>Logo</name>
        <Icon>
        <href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgXmdNgBTXup6bdWew5RzgCmC9pPb7rK487CpiscWB2S8OlhwFHmeeACHIIjx4B5-Iv-t95mNUx0JhB_oATG3-Tq1gs8Uj0-Xb9Njye6rHtKKsnJQJlzZqJxMDnj_2TXX3eA5x6VSgc8aw/s320-rw/LOGO+LIQUID+GALAXY-sq1000-+OKnoline.png</href>
        </Icon>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="300" y="${factor}" xunits="pixels" yunits="pixels"/>
      </ScreenOverlay>
    </Folder>
  </Document>
</kml>''';

      final execResult = await _client!
          .execute('echo \'$KML\' > /var/www/html/kml/slave_$leftMostRig.kml');

      await _client!
          .execute('chmod 777 /var/www/html/kml/slave_$leftMostRig.kml');

      print(
          "chmod 777 /var/www/html/kml/kmls.txt; echo '$KML' > /var/www/html/kml/slave_$leftMostRig.kml");
      return execResult;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> clearLogos() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      int leftMostRig = (int.parse(_numberOfRigs) / 2).floor() + 2;
      String KML = '';

      final execResult = await _client!
          .execute("echo '$KML' > /var/www/html/kml/slave_$leftMostRig.kml");

      print(
          "chmod 777 /var/www/html/kml/kmls.txt; echo '$KML' > /var/www/html/kml/slave_$leftMostRig.kml");
      return execResult;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }
}
