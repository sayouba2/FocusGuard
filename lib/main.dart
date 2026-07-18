import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const FocusGuardApp());
}

class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FocusGuard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F6F5B),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF081915),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF11261F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        useMaterial3: true,
      ),
      home: const FocusGuardHomePage(),
    );
  }
}

class FocusGuardHomePage extends StatefulWidget {
  const FocusGuardHomePage({super.key});

  @override
  State<FocusGuardHomePage> createState() => _FocusGuardHomePageState();
}

class _FocusGuardHomePageState extends State<FocusGuardHomePage> {
  static const List<Duration> _durations = <Duration>[
    Duration(minutes: 15),
    Duration(minutes: 25),
    Duration(minutes: 45),
    Duration(minutes: 60),
  ];

  static const List<RoadmapItem> _roadmap = <RoadmapItem>[
    RoadmapItem(
      title: 'Android shell that launches',
      detail: 'Keep the starter app tiny, stable, and easy to audit.',
      state: ItemState.done,
    ),
    RoadmapItem(
      title: 'Functional focus timer',
      detail: 'Countdown, pause, reset, and completion state.',
      state: ItemState.inProgress,
    ),
    RoadmapItem(
      title: 'Local session history',
      detail: 'Store only what is needed for user-visible analytics.',
      state: ItemState.todo,
    ),
    RoadmapItem(
      title: 'App-selection screen',
      detail: 'Explain selected apps before any restriction logic exists.',
      state: ItemState.todo,
    ),
    RoadmapItem(
      title: 'Permission onboarding',
      detail: 'Document every permission and the data it exposes.',
      state: ItemState.todo,
    ),
    RoadmapItem(
      title: 'Blocking experiment',
      detail: 'Prototype the strongest OS-supported restriction path.',
      state: ItemState.todo,
    ),
    RoadmapItem(
      title: 'Accessibility review',
      detail: 'Check emergency access, screen readers, and recovery paths.',
      state: ItemState.todo,
    ),
    RoadmapItem(
      title: 'Release checklist',
      detail: 'Add tests, screenshots, and compatibility notes.',
      state: ItemState.todo,
    ),
  ];

  Timer? _timer;
  Duration _selectedDuration = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  int _completedSessions = 0;
  bool _isRunning = false;
  String _statusLine = 'Ready to begin a focused session.';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setSelectedDuration(Duration duration) {
    setState(() {
      _selectedDuration = duration;
      if (!_isRunning) {
        _remaining = duration;
        _statusLine = 'Timer set to ${_formatDuration(duration)}.';
      }
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_remaining == Duration.zero) {
      _remaining = _selectedDuration;
    }

    setState(() {
      _isRunning = true;
      _statusLine = 'Focus session in progress.';
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remaining <= const Duration(seconds: 1)) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          _isRunning = false;
          _completedSessions++;
          _statusLine = 'Session completed locally.';
        });
        return;
      }

      setState(() {
        _remaining -= const Duration(seconds: 1);
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _statusLine = 'Session paused locally.';
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remaining = _selectedDuration;
      _statusLine = 'Timer reset.';
    });
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _selectedDuration.inSeconds == 0
        ? 0
        : 1 -
            (_remaining.inSeconds / _selectedDuration.inSeconds)
                .clamp(0.0, 1.0)
                .toDouble();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'FocusGuard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              _isRunning ? Icons.lock_clock_rounded : Icons.shield_outlined,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0B231C),
              Color(0xFF081915),
              Color(0xFF050D0B),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: <Widget>[
              _buildHeroCard(context),
              const SizedBox(height: 16),
              _buildTimerCard(context, progress),
              const SizedBox(height: 16),
              _buildDurationPicker(context),
              const SizedBox(height: 16),
              _buildBlockedAppsCard(context),
              const SizedBox(height: 16),
              _buildRoadmapCard(context),
              const SizedBox(height: 16),
              _buildStatusCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F6F5B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.visibility_off_outlined),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Android-first proof of concept',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'A transparent starter build that shows the direction, not a fake finished product.',
                        style: TextStyle(height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _StatusChip(label: 'Local-first'),
                _StatusChip(label: 'Calls preserved'),
                _StatusChip(label: 'Open source'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context, double progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Focus session',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  _isRunning ? 'Running' : 'Idle',
                  style: TextStyle(
                    color: _isRunning
                        ? const Color(0xFF70D6A2)
                        : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    _formatDuration(_remaining),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusLine,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF70D6A2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: _toggleTimer,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: const Color(0xFF70D6A2),
                      foregroundColor: const Color(0xFF04140F),
                    ),
                    child: Text(_isRunning ? 'Pause' : 'Start'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetTimer,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _MetricChip(
                  label: 'Selected',
                  value: _formatDuration(_selectedDuration),
                ),
                const SizedBox(width: 12),
                _MetricChip(
                  label: 'Completed',
                  value: '$_completedSessions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationPicker(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Quick durations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _durations
                  .map(
                    (Duration duration) => ChoiceChip(
                      label: Text(_formatDuration(duration)),
                      selected: _selectedDuration == duration,
                      onSelected: (_) => _setSelectedDuration(duration),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedAppsCard(BuildContext context) {
    const List<String> apps = <String>[
      'Instagram',
      'TikTok',
      'YouTube Shorts',
      'X',
      'Reddit',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Restricted apps sample',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: apps
                  .map(
                    (String app) => Chip(
                      label: Text(app),
                      avatar: const Icon(Icons.block_outlined, size: 18),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Roadmap issues',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ..._roadmap.map(
              (RoadmapItem item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RoadmapTile(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Current limits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'This first build proves the app shell and the countdown loop. '
              'Blocking other apps, reading installed packages, and restoring sessions '
              'are documented next steps rather than hidden claims.',
              style: TextStyle(
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

class _RoadmapTile extends StatelessWidget {
  const _RoadmapTile({required this.item});

  final RoadmapItem item;

  @override
  Widget build(BuildContext context) {
    final Color accent = switch (item.state) {
      ItemState.done => const Color(0xFF70D6A2),
      ItemState.inProgress => const Color(0xFFF4C95D),
      ItemState.todo => Colors.white54,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  item.detail,
                  style: TextStyle(
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ItemState { done, inProgress, todo }

class RoadmapItem {
  const RoadmapItem({
    required this.title,
    required this.detail,
    required this.state,
  });

  final String title;
  final String detail;
  final ItemState state;
}
