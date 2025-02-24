import 'package:dartssh2/dartssh2.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

class SSH {
  static final SSH _instance = SSH._internal();
  factory SSH() => _instance;
  SSH._internal();

  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  static final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  static Stream<bool> get connectionStatus =>
      _connectionStatusController.stream;

  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  Future<bool?> connectToLG() async {
    await disconnect();

    await initConnectionDetails();

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );
      print('IP: $_host, port: $_port');
      _connectionStatusController.add(true);
      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      _connectionStatusController.add(false);
      return false;
    }
  }

  makeFile(String filename, String content) async {
    try {
      var localPath = await getApplicationDocumentsDirectory();
      File localFile = File('${localPath.path}/$filename.kml');
      await localFile.writeAsString(content);
      return localFile;
    } catch (e) {
      print('An error occurred while creating the file: $e');
      return null;
    }
  }

  uploadKMLFile(File inputFile, String kmlName) async {
    try {
      bool uploading = true;
      final sftp = await _client!.sftp();
      final file = await sftp.open('/var/www/html/$kmlName.kml',
          mode: SftpFileOpenMode.create |
              SftpFileOpenMode.truncate |
              SftpFileOpenMode.write);
      var fileSize = await inputFile.length();
      file.write(inputFile.openRead().cast(), onProgress: (progress) async {
        if (fileSize == progress) {
          uploading = false;
        }
      });
    } catch (e) {
      print('An error occurred while uploading the file: $e');
    }
  }

  loadKML(String kmlName) async {
    try {
      await _client!.execute(
          "echo 'http://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt");
    } catch (e) {
      print('An error occurred while loading the KML: $e');
    }
  }

  Future<void> flyTo(String kmlContent) async {
    try {
      final document = xml.XmlDocument.parse(kmlContent);
      final lookAt = document.findAllElements('LookAt').first;

      final longitude =
          double.parse(lookAt.findElements('longitude').first.innerText);
      final latitude =
          double.parse(lookAt.findElements('latitude').first.innerText);
      final altitude =
          double.parse(lookAt.findElements('altitude').first.innerText);
      final heading =
          double.parse(lookAt.findElements('heading').first.innerText);
      final tilt = double.parse(lookAt.findElements('tilt').first.innerText);
      final range = double.parse(lookAt.findElements('range').first.innerText);

      final command =
          'echo "flytoview=<gx:duration>3</gx:duration><gx:flyToMode>smooth</gx:flyToMode>'
          '<LookAt>'
          '<longitude>$longitude</longitude>'
          '<latitude>$latitude</latitude>'
          '<altitude>$altitude</altitude>'
          '<heading>$heading</heading>'
          '<tilt>$tilt</tilt>'
          '<range>$range</range>'
          '</LookAt>" > /tmp/query.txt';

      await _client!.execute(command);
    } catch (e) {
      print('Error en flyTo: $e');
    }
  }

  clearKML() async {
    try {
      await _client!.execute("echo '' > /var/www/html/kmls.txt");
      print(
          "chmod 777 /var/www/html/kml/kmls.txt; echo '' > /var/www/html/kmls.txt");
    } catch (e) {
      print('An error occurred while clearing the KML: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      if (_client != null) {
        _client!.close();
        _client = null;
        _connectionStatusController.add(false);
      }
    } catch (e) {
      print('Error al desconectar: $e');
    }
  }
}
