import 'dart:ui';

import 'package:eventhub/src/screens/create_event_screen.dart';
import 'package:eventhub/src/screens/home_screen.dart';
import 'package:eventhub/src/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class RouterPath extends StatefulWidget {
  const RouterPath({super.key});

  @override
  State<RouterPath> createState() => _RouterPathState();
}

class _RouterPathState extends State<RouterPath> {
  late int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> screen = [
    HomeScreen(),
    CreateEventScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: screen,
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? LiquidGlassFab(
                child: Icon(
                  Icons.add,
                  color: const Color.fromARGB(255, 194, 194, 194),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateEventScreen(),
                    ),
                  );
                },
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 244),
        selectedItemColor: const Color.fromARGB(255, 0, 169, 195),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class LiquidGlassFab extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double size;

  const LiquidGlassFab({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 64,
  });

  @override
  State<LiquidGlassFab> createState() => _LiquidGlassFabState();
}

class _LiquidGlassFabState extends State<LiquidGlassFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOut,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onTapUp(_) {
    _ctrl.reverse();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _pressed = false);
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        213,
                        181,
                        255,
                      ).withValues(alpha: _pressed ? 0.07 : 0.06),
                      blurRadius: _pressed ? 28 : 20,
                      spreadRadius: _pressed ? 2 : 0,
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(s / 2),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Container(
                    width: s - 6,
                    height: s - 6,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-0.5, -1),
                        end: Alignment(1, 1),
                        colors: [
                          const Color.fromARGB(
                            255,
                            170,
                            0,
                            255,
                          ).withValues(alpha: 0.10),
                          const Color.fromARGB(
                            255,
                            0,
                            98,
                            255,
                          ).withValues(alpha: 0.06),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromARGB(
                          255,
                          173,
                          173,
                          173,
                        ).withValues(alpha: 0.16),
                        width: 1.0,
                      ),
                    ),
                    child: widget.child,
                  ),
                ),
              ),
              if (_pressed)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _pressed ? 0.22 : 0,
                  child: Container(
                    width: s + 12,
                    height: s + 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 215, 182, 255),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
