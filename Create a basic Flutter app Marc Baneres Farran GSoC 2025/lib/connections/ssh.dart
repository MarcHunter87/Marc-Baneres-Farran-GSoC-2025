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

  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = '3';
  }

  // Connect to the Liquid Galaxy system
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

  Future<SSHSession?> cleanKML() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }

      final execResult = await _client!.execute('''
        echo "" > /tmp/query.txt
        echo "" > /var/www/html/kmls.txt
      ''');

      print('KML cleaned successfully');
      return execResult;
    } catch (e) {
      print('Error cleaning KML: $e');
      return null;
    }
  }
}
