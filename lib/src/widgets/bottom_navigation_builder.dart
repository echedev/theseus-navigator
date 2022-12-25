import 'package:flutter/material.dart';

import '../destination.dart';
import '../navigation_controller.dart';
import 'index.dart';

/// A [NavigatorBuilder] that allows to switch between destinations using
/// [BottomNavigationBar].
///
/// It builds a wrapper widget, which is a [Scaffold] with a [Scaffold.body] set
/// to the current destination's content, and [Scaffold.bottomNavigationBar]
/// specified.
///
/// The [bottomNavigationItems] must correspond to the navigator's destinations.
///
/// The bottom navigation bar can be customized using [parameters], which includes
/// all parameters supported by the [BottomNavigationBar] widget.
///
/// See also:
/// - [NavigatorBuilder]
/// - [BottomNavigationBarParameters]
/// - [NavigationController]
/// - [BottomNavigationBar]
///
class BottomNavigationBuilder implements NavigatorBuilder {
  /// Creates a [BottomNavigationBuilder] instance.
  ///
  const BottomNavigationBuilder({
    this.bottomNavigationItems = const <BottomNavigationBarItem>[],
    this.parameters = const BottomNavigationBarParameters(),
    this.navigationBarItems = const <NavigationDestination>[],
    this.navigationBarParameters = const NavigationBarParameters(),
    bool? material3,
  }) : _material3 = material3 ?? false;

  /// Creates a [BottomNavigationBuilder] instance that uses Material 3 [NavigationBar]
  /// widget.
  ///
  factory BottomNavigationBuilder.navigationBar({
    required List<NavigationDestination> navigationBarItems,
    NavigationBarParameters? navigationBarParameters,
  }) =>
      BottomNavigationBuilder(
        navigationBarItems: navigationBarItems,
        navigationBarParameters:
            navigationBarParameters ?? const NavigationBarParameters(),
        material3: true,
      );

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
  /// Doesn't include 'items', 'onTap' and 'currentIndex', which are managed by
  /// [BottomNavigationBuilder].
  ///
  final BottomNavigationBarParameters parameters;

  /// A list of [NavigationDestination] widgets, that corresponds to the navigator's
  /// destination list.
  ///
  /// The list must contain the same number of items, following with the same order
  /// as a destination list specified in the navigator.
  ///
  final List<NavigationDestination> navigationBarItems;

  /// A set of [NavigationBar] parameters.
  ///
  /// Contains all supported parameters to customize [NavigationBar] widget.
  /// Doesn't include 'items', 'onTap' and 'currentIndex', which are managed by
  /// [BottomNavigationBuilder].
  ///
  final NavigationBarParameters navigationBarParameters;

  final bool _material3;

  @override
  Widget build(BuildContext context, NavigationController navigator) {
    final currentDestination = navigator.currentDestination;
    return _BottomNavigationWrapper(
      destination: currentDestination,
      onSelectBottomTab: (index) =>
          navigator.goTo(navigator.destinations[index]),
      selectedIndex: navigator.destinations.indexOf(currentDestination),
      items: bottomNavigationItems,
      parameters: parameters,
      navigationBarItems: navigationBarItems,
      navigationBarParameters: navigationBarParameters,
      material3: _material3,
    );
  }
}

class _BottomNavigationWrapper extends StatefulWidget {
  const _BottomNavigationWrapper({
    Key? key,
    required this.destination,
    required this.onSelectBottomTab,
    required this.selectedIndex,
    this.items = const <BottomNavigationBarItem>[],
    this.parameters = const BottomNavigationBarParameters(),
    this.navigationBarItems = const <NavigationDestination>[],
    this.navigationBarParameters = const NavigationBarParameters(),
    this.material3 = false,
  }) : super(key: key);

  final Destination destination;

  final List<BottomNavigationBarItem> items;

  final void Function(int) onSelectBottomTab;

  final int selectedIndex;

  final BottomNavigationBarParameters parameters;

  final List<NavigationDestination> navigationBarItems;

  final NavigationBarParameters navigationBarParameters;

  final bool material3;

  @override
  _BottomNavigationWrapperState createState() =>
      _BottomNavigationWrapperState();
}

class _BottomNavigationWrapperState extends State<_BottomNavigationWrapper> {
  final _content = <Destination, Widget>{};

  final _indexes = <Destination, int>{};

  late final OverlayEntry _mainOverlay;

  @override
  void initState() {
    super.initState();
    _content[widget.destination] = widget.destination.build(context);
    _indexes[widget.destination] = widget.selectedIndex;
    _mainOverlay = OverlayEntry(
      builder: (context) => Scaffold(
        body: Stack(
          children: [
            ..._content.entries
                .map((entry) => Offstage(
                      offstage: _indexes[entry.key] != widget.selectedIndex,
                      child: entry.value,
                    ))
                .toList(),
          ],
        ),
        bottomNavigationBar: widget.material3
            ? NavigationBar(
                animationDuration:
                    widget.navigationBarParameters.animationDuration,
                selectedIndex: widget.selectedIndex,
                destinations: widget.navigationBarItems,
                onDestinationSelected: widget.onSelectBottomTab,
                backgroundColor: widget.navigationBarParameters.backgroundColor,
                elevation: widget.navigationBarParameters.elevation,
                height: widget.navigationBarParameters.height,
                labelBehavior: widget.navigationBarParameters.labelBehavior,
              )
            : BottomNavigationBar(
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
    bool needsRebuild = false;
    if (widget.material3 != oldWidget.material3) {
      needsRebuild = true;
    }
    if (!widget.destination.isFinalDestination) {
      needsRebuild = true;
      _content[widget.destination] = widget.destination.build(context);
      _indexes[widget.destination] = widget.selectedIndex;
    } else if (oldWidget.selectedIndex != widget.selectedIndex &&
        !_content.containsKey(widget.destination)) {
      needsRebuild = true;
      _content[widget.destination] = widget.destination.build(context);
      _indexes[widget.destination] = widget.selectedIndex;
    }
    if (needsRebuild) {
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
/// It includes all the same arguments as the [BottomNavigationBar()], excepting
/// the 'items', 'onTap' and 'currentIndex', which are managed by the [BottomNavigationBuilder].
///
/// See also:
/// - [BottomNavigationBuilder]
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

/// Contains parameters to customize the [NavigationBar].
///
/// It includes all the same arguments as the [NavigationBar()], excepting
/// the 'items', 'onTap' and 'currentIndex', which are managed by the [BottomNavigationBuilder].
///
/// See also:
/// - [BottomNavigationBuilder]
/// - [NavigationBar]
///
class NavigationBarParameters {
  /// Create a [NavigationBarParameters] instance.
  ///
  const NavigationBarParameters({
    this.animationDuration,
    this.backgroundColor,
    this.elevation,
    this.height,
    this.labelBehavior,
  });

  /// [NavigationBar.animationDuration]
  ///
  final Duration? animationDuration;

  /// [NavigationBar.backgroundColor]
  ///
  final Color? backgroundColor;

  /// [NavigationBar.elevation]
  ///
  final double? elevation;

  /// [NavigationBar.height]
  ///
  final double? height;

  /// [NavigationBar.labelBehavior]
  ///
  final NavigationDestinationLabelBehavior? labelBehavior;
}
