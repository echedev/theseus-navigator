import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  MainScreen({
    Key? key,
    required this.content,
    required this.onSelectBottomTab,
    required this.selectedIndex,
  }) : super(key: key);

  final Widget content;

  final void Function(int) onSelectBottomTab;

  final int selectedIndex;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final OverlayEntry _mainOverlay;

  @override
  void initState() {
    super.initState();
    _mainOverlay = OverlayEntry(
      builder: (context) => Scaffold(
        body: widget.content,
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.list_rounded),
              label: 'Catalog',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_rounded),
              label: 'Settings',
            ),
          ],
          // selectedItemColor: Constants.colorAccent,
          // unselectedItemColor: Constants.colorUnselected,
          currentIndex: widget.selectedIndex,
          onTap: widget.onSelectBottomTab,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _mainOverlay.markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        _mainOverlay,
      ],
    );
  }
}
