import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Capy Study',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: green),
      useMaterial3: true,
    ),
    home: const LoginScreen(),
  ),
);

const green = Color(0xFF62956B);
const yellow = Color(0xFFFFF95C);
const cream = Color(0xFFFFFCE9);

// Fake "database": email -> {name, password}
final Map<String, Map<String, String>> users = {};

// ───────────────────────── LOGIN ─────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  bool _hide = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);

    final email = _email.text.trim().toLowerCase();
    final pass = _password.text;
    String name;

    if (_isSignUp) {
      if (users.containsKey(email)) {
        _msg('Email already registered.');
        return;
      }
      name = _name.text.trim();
      users[email] = {'name': name, 'password': pass};
    } else {
      final user = users[email];
      if (user == null || user['password'] != pass) {
        _msg('Incorrect email or password.');
        return;
      }
      name = user['name']!;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeShell(name: name)),
    );
  }

  InputDecoration _deco(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      if (_isSignUp) ...[
        TextFormField(
          controller: _name,
          decoration: _deco('Your name'),
          validator: (v) =>
              (v == null || v.trim().length < 2) ? 'Enter your name' : null,
        ),
        const SizedBox(height: 14),
      ],
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: _deco('E-mail'),
        validator: (v) =>
            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
            ? null
            : 'Enter a valid email',
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _password,
        obscureText: _hide,
        decoration: _deco(
          'Password',
          suffix: IconButton(
            icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _hide = !_hide),
          ),
        ),
        validator: (v) =>
            (v == null || v.length < 6) ? 'At least 6 characters' : null,
      ),
    ];

    return Scaffold(
      backgroundColor: green,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('🦫', style: TextStyle(fontSize: 72)),
                    Text(
                      _isSignUp ? 'Sign Up' : 'Log In',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _isSignUp
                          ? 'Welcome! Let’s get started'
                          : 'Welcome back!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ...fields,
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                _isSignUp ? 'Sign Up' : 'Log In',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp
                            ? 'I’m already registered'
                            : 'Create an account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── HOME (tabs) ─────────────────────────

class HomeShell extends StatefulWidget {
  final String name;
  const HomeShell({super.key, required this.name});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: Text(
          'Hi, ${widget.name}! 🦫',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [TasksTab(), TimerTab(), ChatTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        indicatorColor: yellow,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Capy',
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── TASKS ─────────────────────────

class Task {
  String title;
  String category;
  bool done;
  Task(this.title, this.category, [this.done = false]);
}

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final List<Task> _tasks = [
    Task('Review plasmid vector design', 'Science', true),
    Task('Prepare Cambridge biology slides', 'Study'),
    Task('Water quality test with papaya seeds', 'Research'),
  ];

  void _showAddDialog() {
    final controller = TextEditingController();
    String category = 'General';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Add New Task',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: category,
                    isExpanded: true,
                    items:
                        ['General', 'Science', 'Study', 'Research', 'Personal']
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (v) =>
                        setDialogState(() => category = v ?? category),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final title = controller.text.trim();
                    if (title.isEmpty) return;
                    setState(() => _tasks.add(Task(title, category)));
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _taskTile(Task task) {
    return Dismissible(
      key: ObjectKey(task),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => setState(() => _tasks.remove(task)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: CheckboxListTile(
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: task.done ? TextDecoration.lineThrough : null,
              color: task.done ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Text(
            task.category,
            style: const TextStyle(fontSize: 12, color: green),
          ),
          value: task.done,
          activeColor: green,
          onChanged: (v) => setState(() => task.done = v ?? false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = _tasks.where((t) => t.done).length;

    return Scaffold(
      backgroundColor: green,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: yellow,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: _showAddDialog,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$doneCount/${_tasks.length} Done',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks yet. Add one below!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
                      children: _tasks.map(_taskTile).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── CAPY CHAT ─────────────────────────

class ChatMessage {
  final String text;
  final bool fromCapy;
  const ChatMessage(this.text, {this.fromCapy = true});
}

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [
    const ChatMessage('Hey, study buddy! What are we working on today?'),
  ];

  static const _quickReplies = [
    'I’m ready to study!',
    'I feel stuck',
    'I finished a task!',
  ];

  // Edit these keywords and replies to change what Capy says.
  static const Map<String, String> _rules = {
    'stuck|overwhelmed|distracted':
        'Let’s make the task smaller. What could you do in five minutes?',
    'finished|done|completed':
        'You did it! What helped you get through that task?',
    'tired|break|rest':
        'A short break sounds good. Stretch a little and get some water.',
    'ready|start|study': 'Let’s go! Pick one task and give it ten minutes.',
  };

  String _reply(String message) {
    final text = message.toLowerCase();
    for (final rule in _rules.entries) {
      if (RegExp('\\b(${rule.key})\\b').hasMatch(text)) return rule.value;
    }
    return 'I’m here with you. How’s studying going today?';
  }

  void _send(String message) {
    final text = message.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text, fromCapy: false));
      _messages.add(ChatMessage(_reply(text)));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendTyped() {
    _send(_input.text);
    _input.clear();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _bubble(ChatMessage m) {
    return Align(
      alignment: m.fromCapy ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: m.fromCapy ? const Color(0xFFF7E9BC) : const Color(0xFFC1DAA9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              m.fromCapy ? 'Capy' : 'You',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(m.text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  children: _messages.map(_bubble).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _quickReplies
                      .map(
                        (r) => ActionChip(
                          label: Text(r),
                          onPressed: () => _send(r),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendTyped(),
                        decoration: const InputDecoration(
                          hintText: 'Say something to Capy…',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Send message',
                      icon: const Icon(Icons.send),
                      onPressed: _sendTyped,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── TIMER ─────────────────────────

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  static const int _focusMinutes = 25;
  static const int _breakMinutes = 5;

  int _secondsLeft = _focusMinutes * 60;
  bool _isRunning = false;
  bool _isBreak = false;

  Timer? _timer;

  void _startTimer() {
    if (_isRunning || _secondsLeft == 0) return;

    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();

        setState(() {
          _secondsLeft = 0;
          _isRunning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBreak
                  ? 'Break finished! Ready to study? 🦫'
                  : 'Great work! Your focus session is complete. ☕',
            ),
          ),
        );
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _secondsLeft = (_isBreak ? _breakMinutes : _focusMinutes) * 60;
    });
  }

  void _selectMode(bool isBreak) {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isBreak = isBreak;
      _secondsLeft = (isBreak ? _breakMinutes : _focusMinutes) * 60;
    });
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cream,
      width: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🦫', style: TextStyle(fontSize: 65)),
              const SizedBox(height: 12),
              const Text(
                'Study Timer',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isBreak ? 'Take a little breather!' : 'Time to focus!',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Focus · 25 min'),
                    selected: !_isBreak,
                    selectedColor: yellow,
                    onSelected: (_) => _selectMode(false),
                  ),
                  ChoiceChip(
                    label: const Text('Break · 5 min'),
                    selected: _isBreak,
                    selectedColor: yellow,
                    onSelected: (_) => _selectMode(true),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: green, width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: green.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _formattedTime,
                    style: const TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.w900,
                      color: green,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 15,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRunning
                        ? _pauseTimer
                        : (_secondsLeft == 0 ? null : _startTimer),
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? 'Pause' : 'Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Text(
                _isRunning
                    ? 'You got this! Keep going 💚'
                    : _secondsLeft == 0
                    ? 'Session complete! Choose a mode to start again.'
                    : 'Ready when you are!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
