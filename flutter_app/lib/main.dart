import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const StarShooterApp());
}

class StarShooterApp extends StatelessWidget {
  const StarShooterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Shooter',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int _maxColors = 6;
  static const Duration _minimumSpawnInterval = Duration(seconds: 2);
  static const Duration _starLifetime = Duration(seconds: 8);

  final Random _rng = Random();
  final List<_Star> _stars = <_Star>[];
  final List<Color> _basePalette = <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  Timer? _spawnTimer;
  Duration _spawnInterval = const Duration(seconds: 10);
  int _level = 1;
  int _score = 0;
  int _starsClearedThisLevel = 0;
  int _starsRequiredThisLevel = 3;
  Color? _selectedColor;
  bool _showingAd = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = _availableColors.first;
    _startSpawningStars();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    for (final _Star star in _stars) {
      star.dispose();
    }
    super.dispose();
  }

  void _startSpawningStars() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(_spawnInterval, (_) {
      _addStar();
    });
  }

  void _addStar() {
    if (!mounted) {
      return;
    }
    final Color color = _availableColors[_rng.nextInt(_availableColors.length)];
    final _Star star = _Star(
      id: DateTime.now().millisecondsSinceEpoch,
      color: color,
      position: Offset(_rng.nextDouble(), _rng.nextDouble()),
      onExpire: _handleExpiredStar,
    );

    star.startLifetimeTimer(_starLifetime);

    setState(() {
      _stars.add(star);
    });
  }

  void _handleExpiredStar(_Star star) {
    if (!mounted) {
      return;
    }
    setState(() {
      _stars.removeWhere((_) => _.id == star.id);
    });
  }

  List<Color> get _availableColors {
    final int colorCount = min(_maxColors, 2 + _level - 1);
    return _basePalette.take(colorCount).toList();
  }

  void _handleStarTap(_Star star) {
    if (_selectedColor == null || _selectedColor != star.color) {
      return;
    }

    setState(() {
      _stars.removeWhere((_) => _.id == star.id);
      _score += 10;
      _starsClearedThisLevel++;
    });

    if (_starsClearedThisLevel >= _starsRequiredThisLevel) {
      _progressToNextLevel();
    }
  }

  Future<void> _progressToNextLevel() async {
    _spawnTimer?.cancel();
    setState(() {
      _level++;
      _starsClearedThisLevel = 0;
      _starsRequiredThisLevel = min(8, 3 + _level);
      final int milliseconds = max(
        _minimumSpawnInterval.inMilliseconds,
        (_spawnInterval.inMilliseconds * 0.8).round(),
      );
      _spawnInterval = Duration(milliseconds: milliseconds);
    });

    await _showInterstitialAd();
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedColor = _availableColors.first;
    });

    _startSpawningStars();
  }

  Future<void> _showInterstitialAd() async {
    if (!mounted || _showingAd) {
      return;
    }

    setState(() {
      _showingAd = true;
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sponsored break'),
          content: const Text(
            'This is a placeholder for an interstitial ad. Use this moment to share revenue with players.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _showingAd = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Star Shooter'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[Colors.black, Colors.indigo],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              ..._stars.map((_) => _StarWidget(
                    star: _,
                    size: constraints.biggest,
                    onTap: () => _handleStarTap(_),
                  )),
              _buildHud(),
              Align(
                alignment: Alignment.bottomCenter,
                child: _ColorPalette(
                  colors: _availableColors,
                  selectedColor: _selectedColor,
                  onColorSelected: (Color color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHud() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _HudChip(label: 'Level', value: '$_level'),
          _HudChip(label: 'Score', value: '$_score'),
          _HudChip(
            label: 'Stars',
            value: '${_starsClearedThisLevel.toString().padLeft(2, '0')}/${_starsRequiredThisLevel}',
          ),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Colors.white.withOpacity(0.2),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      color: Colors.black.withOpacity(0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors
            .map(
              (Color color) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => onColorSelected(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: selectedColor == color ? 56 : 48,
                    height: selectedColor == color ? 56 : 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Star {
  _Star({
    required this.id,
    required this.color,
    required this.position,
    required this.onExpire,
  });

  final int id;
  final Color color;
  final Offset position; // Relative (0.0 - 1.0)
  final void Function(_Star star) onExpire;

  Timer? _lifetimeTimer;

  void startLifetimeTimer(Duration lifetime) {
    _lifetimeTimer?.cancel();
    _lifetimeTimer = Timer(lifetime, () => onExpire(this));
  }

  void dispose() {
    _lifetimeTimer?.cancel();
  }
}

class _StarWidget extends StatelessWidget {
  const _StarWidget({
    required this.star,
    required this.size,
    required this.onTap,
  });

  final _Star star;
  final Size size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double x = star.position.dx.clamp(0.1, 0.9) * size.width;
    final double y = star.position.dy.clamp(0.1, 0.8) * size.height;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          Icons.star,
          color: star.color,
          size: 48,
        ),
      ),
    );
  }
}
