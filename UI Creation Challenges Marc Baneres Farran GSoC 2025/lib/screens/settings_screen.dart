import 'package:flutter/material.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/components/connection_flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_creation_challenges_marc_baneres_farran_gsoc_2025/connections/ssh.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SSH ssh = SSH();
  bool connectionStatus = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    SSH.connectionStatus.listen((status) {
      setState(() {
        connectionStatus = status;
      });
    });
  }

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _sshPortController.dispose();
    _rigsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _sshPortController.text = prefs.getString('sshPort') ?? '';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_ipController.text.isNotEmpty) {
      await prefs.setString('ipAddress', _ipController.text);
    }
    if (_usernameController.text.isNotEmpty) {
      await prefs.setString('username', _usernameController.text);
    }
    if (_passwordController.text.isNotEmpty) {
      await prefs.setString('password', _passwordController.text);
    }
    if (_sshPortController.text.isNotEmpty) {
      await prefs.setString('sshPort', _sshPortController.text);
    }
    if (_rigsController.text.isNotEmpty) {
      await prefs.setString('numberOfRigs', _rigsController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Connection Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ConnectionFlag(
                  status: connectionStatus,
                )),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.computer),
                labelText: 'IP address',
                hintText: 'Enter Master IP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: 'LG Username',
                hintText: 'Enter your username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: 'LG Password',
                hintText: 'Enter your password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sshPortController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.settings_ethernet),
                labelText: 'SSH Port',
                hintText: '22',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _rigsController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.memory),
                labelText: 'No. of LG rigs',
                hintText: 'Enter the number of rigs',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xFF424242)),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                ),
              ),
              onPressed: () async {
                await _saveSettings();
                await ssh.disconnect();
                bool? result = await ssh.connectToLG();
                setState(() {
                  connectionStatus = result ?? false;
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cast,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'CONNECT TO LG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
