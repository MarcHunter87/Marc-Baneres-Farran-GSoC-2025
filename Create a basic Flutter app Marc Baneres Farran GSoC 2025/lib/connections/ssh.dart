import 'package:dartssh2/dartssh2.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
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
        <size x="300" y="$factor" xunits="pixels" yunits="pixels"/>
      </ScreenOverlay>
    </Folder>
  </Document>
</kml>''';

      final execResult = await _client!
          .execute('echo \'$KML\' > /var/www/html/kml/slave_$leftMostRig.kml');

      print(
          "chmod 777 /var/www/html/kml/kmls.txt; echo '$KML' > /var/www/html/kml/slave_$leftMostRig.kml");
      return execResult;
    } catch (e) {
      print('An error occurred while sending the logos: $e');
      return null;
    }
  }

  makeFile(String filename, String content) async {
    try {
      var localPath = await getApplicationDocumentsDirectory();
      File localFile = File('${localPath.path}/${filename}.kml');
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
      final v = await _client!.execute(
          "echo 'http://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt");
    } catch (e) {
      print('An error occurred while loading the KML: $e');
      await loadKML(kmlName);
    }
  }

  Future<void> flyTo(double longitude, double latitude, double altitude,
      double heading, double tilt, double range) async {
    try {
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
      print('An error occurred while executing the command: $e');
    }
  }

  Future<SSHSession?> clearLogos() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      int leftScreen = (int.parse(_numberOfRigs) / 2).floor() + 2;
      String KML = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
  </Document>
</kml>''';

      final execResult = await _client!
          .execute("echo '$KML' > /var/www/html/kml/slave_$leftScreen.kml");

      print(
          "chmod 777 /var/www/html/kml/kmls.txt; echo '$KML' > /var/www/html/kml/slave_$leftScreen.kml");
      return execResult;
    } catch (e) {
      print('An error occurred while clearing the logos: $e');
      return null;
    }
  }

  clearKML() async {
    try {
      final execResult =
          await _client!.execute("echo '' > /var/www/html/kmls.txt");
      print(
          "chmod 777 /var/www/html/kml/kmls.txt; echo '' > /var/www/html/kmls.txt");
    } catch (e) {
      print('An error occurred while clearing the KML: $e');
      await clearKML();
    }
  }
}
