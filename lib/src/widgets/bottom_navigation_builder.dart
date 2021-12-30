import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../navigator.dart';
import 'index.dart';

/// A [NavigatorBuilder] that allows to switch between destinations using
/// [BottomNavigationBar].
///
/// It builds a wrapper widget, which is a [Scaffold] with a body set to the current
/// destination's content, and a Flutter's [BottomNavigationBar] widget specified.
///
/// The [bottomNavigationItems] must correspond to the navigator's destinations.
///
/// The bottom navigation bar can be customized using [parameters], which includes
/// all parameters supported by the [BottomNavigationBar] widget.
///
/// See also:
/// - [NavigatorBuilder]
/// - [BottomNavigationBarParameters]
/// - [TheseusNavigator]
/// - [BottomNavigationBar]
///
class BottomNavigationBuilder implements NavigatorBuilder {
  /// Creates a [BottomNavigationBuilder] instance.
  ///
  BottomNavigationBuilder({
    required this.bottomNavigationItems,
    this.parameters = const BottomNavigationBarParameters(),
  });

  /// A list of [BottomNavigationBarItems], that corresponds to the navigator's
  /// destination list.
  ///
  /// The list must contain the same number of bottom navigation bar items,
  /// following with the same order as a destination list specified for the navigator.
  ///
  final List<BottomNavigationBarItem> bottomNavigationItems;

  /// A set of [BottomNavigationBar] parameters.
  ///
  /// Contains all supported parameters to customize [BottomNavigationBar] widget.
  /// Doesn't include 'items', 'onTap' and 'currentIndex', which are manages by
  /// [BottomNavigationBuilder].
  ///
  final BottomNavigationBarParameters parameters;

  @override
  Widget build(BuildContext context, TheseusNavigator navigator) {
    final currentDestination = navigator.currentDestination;
    final content = currentDestination.build(context);
    return _BottomNavigationWrapper(
      content: content,
      items: bottomNavigationItems,
      parameters: parameters,
      onSelectBottomTab: (index) =>
          navigator.goTo(navigator.destinations[index]),
      selectedIndex: navigator.destinations.indexOf(currentDestination),
    );
  }
}

class _BottomNavigationWrapper extends StatefulWidget {
  const _BottomNavigationWrapper({
    Key? key,
    required this.content,
    required this.items,
    required this.onSelectBottomTab,
    required this.selectedIndex,
    required this.parameters,
  }) : super(key: key);

  final Widget content;

  final List<BottomNavigationBarItem> items;

  final void Function(int) onSelectBottomTab;

  final int selectedIndex;

  final BottomNavigationBarParameters parameters;

  @override
  _BottomNavigationWrapperState createState() =>
      _BottomNavigationWrapperState();
}

class _BottomNavigationWrapperState extends State<_BottomNavigationWrapper> {
  late final OverlayEntry _mainOverlay;

  @override
  void initState() {
    super.initState();
    _mainOverlay = OverlayEntry(
      builder: (context) => Scaffold(
        body: widget.content,
        bottomNavigationBar: BottomNavigationBar(
          items: widget.items,
          currentIndex: widget.selectedIndex,
          onTap: widget.onSelectBottomTab,
          elevation: widget.parameters.elevation,
          type: widget.parameters.type,
          fixedColor: widget.parameters.fixedColor,
          backgroundColor: widget.parameters.backgroundColor,
          iconSize: widget.parameters.iconSize,
          selectedItemColor: widget.parameters.selectedItemColor,
          unselectedItemColor: widget.parameters.unselectedItemColor,
          selectedIconTheme: widget.parameters.selectedIconTheme,
          unselectedIconTheme: widget.parameters.unselectedIconTheme,
          selectedFontSize: widget.parameters.selectedFontSize,
          unselectedFontSize: widget.parameters.unselectedFontSize,
          selectedLabelStyle: widget.parameters.selectedLabelStyle,
          unselectedLabelStyle: widget.parameters.unselectedLabelStyle,
          showSelectedLabels: widget.parameters.showSelectedLabels,
          showUnselectedLabels: widget.parameters.showUnselectedLabels,
          mouseCursor: widget.parameters.mouseCursor,
          enableFeedback: widget.parameters.enableFeedback,
          landscapeLayout: widget.parameters.landscapeLayout,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(_BottomNavigationWrapper oldWidget) {
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

/// Contains parameters to customize the [BottomNavigationBar].
///
/// See also:
/// - [BottomNavigationBar]
///
class BottomNavigationBarParameters {
  /// Create a [BottomNavigationBarParameters] instance.
  ///
  const BottomNavigationBarParameters({
    this.elevation,
    this.type,
    this.fixedColor,
    this.backgroundColor,
    this.iconSize = 24.0,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedIconTheme,
    this.unselectedIconTheme,
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.showSelectedLabels,
    this.showUnselectedLabels,
    this.mouseCursor,
    this.enableFeedback,
    this.landscapeLayout,
  });

  /// [BottomNavigationBar.elevation]
  ///
  final double? elevation;

  /// [BottomNavigationBar.type]
  ///
  final BottomNavigationBarType? type;

  /// [BottomNavigationBar.fixedColor]
  ///
  final Color? fixedColor;

  /// [BottomNavigationBar.backgroundColor]
  ///
  final Color? backgroundColor;

  /// [BottomNavigationBar.iconSize]
  ///
  final double iconSize;

  /// [BottomNavigationBar.selectedItemColor]
  ///
  final Color? selectedItemColor;

  /// [BottomNavigationBar.unselectedItemColor]
  ///
  final Color? unselectedItemColor;

  /// [BottomNavigationBar.selectedIconTheme]
  ///
  final IconThemeData? selectedIconTheme;

  /// [BottomNavigationBar.unselectedIconTheme]
  ///
  final IconThemeData? unselectedIconTheme;

  /// [BottomNavigationBar.selectedLabelStyle]
  ///
  final TextStyle? selectedLabelStyle;

  /// [BottomNavigationBar.unselectedLabelStyle]
  ///
  final TextStyle? unselectedLabelStyle;

  /// [BottomNavigationBar.selectedFontSize]
  ///
  final double selectedFontSize;

  /// [BottomNavigationBar.unselectedFontSize]
  ///
  final double unselectedFontSize;

  /// [BottomNavigationBar.showUnselectedLabels]
  ///
  final bool? showUnselectedLabels;

  /// [BottomNavigationBar.showSelectedLabels]
  ///
  final bool? showSelectedLabels;

  /// [BottomNavigationBar.mouseCursor]
  ///
  final MouseCursor? mouseCursor;

  /// [BottomNavigationBar.enableFeedback]
  ///
  final bool? enableFeedback;

  /// [BottomNavigationBar.landscapeLayout]
  ///
  final BottomNavigationBarLandscapeLayout? landscapeLayout;
}
