import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
void main() => runApp(MyApp());

enum Page { CurrentPassword, PasswordHistory }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Password Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple[300],
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LongPressGestureRecognizer _longPressGestureRecognizer =
  LongPressGestureRecognizer();
  bool _showSpecialCharacters = false;
  String _password = '';
  bool _excludeNumbers = false;
  bool _shortPassword = false;
  bool _uppercaseOnly = false;
  Page _currentPage = Page.CurrentPassword;

  List<History> _passwordHistory = [];

  void _generatePassword() {
    String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_showSpecialCharacters) {
      chars += '!@#\$%^&*()';
    }
    // const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#\$%^&*()';
    const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final String numbers = '0123456789';
    final Random rand = Random();
    String newPassword = '';
    int length = 16;
    if (_shortPassword) {
      length = 8;
    }
    for (int i = 0; i < length; i++) {
      String char = chars[rand.nextInt(chars.length)];
      if (_excludeNumbers && numbers.contains(char)) {
        // If excludeNumbers is true and the character is a number, generate a new character
        while (numbers.contains(char)) {
          char = chars[rand.nextInt(chars.length)];
        }
      } else if (!_excludeNumbers && !_shortPassword) {
        // If excludeNumbers is false and shortPassword is false, include numbers in the password
        if (rand.nextBool()) {
          char = numbers[rand.nextInt(numbers.length)];
        }
      }
      if (_uppercaseOnly && !uppercaseChars.contains(char)) {
        // If uppercaseOnly is true and the character is not uppercase, generate a new character
        while (!uppercaseChars.contains(char)) {
          char = chars[rand.nextInt(chars.length)];
        }
      }
      newPassword += char;
    }
    setState(() {
      _password = newPassword;
      if (_currentPage == Page.CurrentPassword) {
        _addToHistory(new History(input: _password, output: ''));
      }
    });
  }


  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _password));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  void _copyHistoryToClipboard(String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }


  void _addToHistory(History history) {
    setState(() {
      _passwordHistory.insert(0, history);
    });
  }

  Widget _buildCurrentPasswordPage() {
    return Center(
        child: Padding(
        padding: EdgeInsets.all(16),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
    Stack(
    children: [
    Container(
    height: 50,
    width: MediaQuery.of(context).size.width,
    child: Text(
    '$_password',
    style: TextStyle(fontSize: 24),
    ),
    decoration: BoxDecoration(
    border: Border.all(
    color: Colors.black,
    width: 1,
    ),
    borderRadius: BorderRadius.circular(10),
    ),
    ),
    Positioned(
    top: 0,
    right: 0,
    child: IconButton(
    onPressed: () {
    setState(() {
    _password = '';
    });
    },
    icon: Icon(Icons.close),
    ),
    ),
    ],
    ),
    SizedBox(height: 20),
    ElevatedButton(
    child: Text('Generate my Password'),
    onPressed: _generatePassword,
    ),
    SizedBox(height: 20),
    ElevatedButton(
    child: Text('Copy to your Clipboard'),
    onPressed: _copyToClipboard,
    ),
    SizedBox(height:
    20),
      Row(
        children: [
          Checkbox(
            value: _excludeNumbers,
            onChanged: (bool? value) {
              setState(() {
                _excludeNumbers = value ?? false;
              });
            },
          ),
          Text('Exclude numbers'),
        ],
      ),
      SizedBox(height: 20),
      Row(
        children: [
          Checkbox(
            value: _shortPassword,
            onChanged: (bool? value) {
              setState(() {
                _shortPassword = value ?? false;
              });
            },
          ),
          Text('Short password'),
        ],
      ),
      SizedBox(height: 20),
      Row(
        children: [
          Checkbox(
            value: _uppercaseOnly,
            onChanged: (bool? value) {
              setState(() {
                _uppercaseOnly = value ?? false;
              });
            },
          ),
          Text('Uppercase only'),
        ],
      ),
      SizedBox(height: 20,),
      Row(
        children: [
          Checkbox(
            value: _showSpecialCharacters,
            onChanged: (bool? value) {
              setState(() {
                _showSpecialCharacters = value ?? false;
              });
            },
          ),
          Text('Show special characters'),
        ],
      ),
    ],
    ),
        ),
    );
  }

  Widget _buildPasswordHistoryPage() {
    return ListView.builder(
      itemCount: _passwordHistory.length,
      itemBuilder: (context, index) {
        final history = _passwordHistory[index];
        return GestureDetector(
          onLongPress: () { setState(() {
            _passwordHistory.removeAt(index);
          });

          },
          child: ListTile(
            title: Text('${history.input}'),
            trailing: IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                  _copyHistoryToClipboard(history.input);
              },
            ),
          ),
        );
      },
    );

  }

  Widget _buildCurrentPage() {
    if (_currentPage == Page.CurrentPassword) {
      return _buildCurrentPasswordPage();
    } else {
      return _buildPasswordHistoryPage();
    }
  }

  void _onBottomNavigationBarItemTapped(int index) {
    setState(() {
      _currentPage = index == 0 ? Page.CurrentPassword : Page.PasswordHistory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Random Password Generator')),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage == Page.CurrentPassword ? 0 : 1,
        onTap: _onBottomNavigationBarItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.vpn_key),
            label: 'Current Password',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Password History',
          ),
        ],
      ),
    );
  }
}

class History {
  final String input;
  final String output;

  History({required this.input, required this.output});
}