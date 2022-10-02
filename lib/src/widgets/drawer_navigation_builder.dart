import 'package:flutter/material.dart';

import '../navigation_controller.dart';
import 'index.dart';

/// A [NavigatorBuilder] that allows to switch between destinations using
/// [Drawer].
///
/// It builds a wrapper widget, which is a [Scaffold] with a [Scaffold.body] set
/// to the current destination's content, and [Scaffold.drawer] specified.
///
/// The [drawerItems] must correspond to the navigator's destinations.
///
/// The drawer can be customized using [parameters], which includes
/// all parameters supported by the [Drawer] widget.
///
/// See also:
/// - [NavigatorBuilder]
/// - [DrawerParameters]
/// - [NavigationController]
/// - [Drawer]
///
class DrawerNavigationBuilder implements NavigatorBuilder {
  /// Creates a [DrawerNavigationBuilder] instance.
  ///
  const DrawerNavigationBuilder({
    required this.drawerItems,
    this.header,
    this.parameters,
  });

  /// A list of [DrawerItems], that corresponds to the navigator's
  /// destination list.
  ///
  /// The list must contain the same number of drawer items,
  /// following with the same order as a destination list specified for the navigator.
  ///
  final List<DrawerItem> drawerItems;

  /// Optional header, that is shown at the top of drawer.
  ///
  final Widget? header;

  /// A set of [Drawer`] parameters.
  ///
  /// Contains all supported parameters to customize [Drawer] widget.
  /// Doesn't include 'child', which is managed by [DrawerNavigationBuilder].
  ///
  final DrawerParameters? parameters;

  @override
  Widget build(BuildContext context, NavigationController navigator) {
    final currentDestination = navigator.currentDestination;
    final content = currentDestination.build(context);
    return _DrawerWrapper(
      content: content,
      items: drawerItems,
      header: header,
      parameters: parameters,
      onSelectItem: (index) => navigator.goTo(navigator.destinations[index]),
      selectedIndex: navigator.destinations.indexOf(currentDestination),
    );
  }
}

class _DrawerWrapper extends StatefulWidget {
  const _DrawerWrapper({
    Key? key,
    required this.content,
    required this.items,
    required this.onSelectItem,
    required this.selectedIndex,
    this.header,
    this.parameters,
  }) : super(key: key);

  final Widget content;

  final List<DrawerItem> items;

  final void Function(int) onSelectItem;

  final int selectedIndex;

  final Widget? header;

  final DrawerParameters? parameters;

  @override
  _DrawerWrapperState createState() => _DrawerWrapperState();
}

class _DrawerWrapperState extends State<_DrawerWrapper> {
  late final OverlayEntry _mainOverlay;

  @override
  void initState() {
    super.initState();
    _mainOverlay = OverlayEntry(
      builder: (context) => Row(
        children: [
          Drawer(
              backgroundColor: widget.parameters?.backgroundColor,
              elevation: widget.parameters?.elevation,
              shape: widget.parameters?.shape,
              width: widget.parameters?.width,
              semanticLabel: widget.parameters?.semanticLabel,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (widget.header != null) widget.header!,
                  ...widget.items
                      .map((item) => ListTile(
                            leading: item.leading,
                            title: Text(item.title ?? ''),
                            selected: widget.selectedIndex ==
                                widget.items.indexOf(item),
                            selectedColor: widget.parameters?.selectedColor,
                            selectedTileColor:
                                widget.parameters?.selectedTileColor,
                            onTap: () =>
                                widget.onSelectItem(widget.items.indexOf(item)),
                          ))
                      .toList(),
                ],
              )),
          Expanded(
            child: Scaffold(
              body: widget.content,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(_DrawerWrapper oldWidget) {
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

/// A model of drawer item.
///
/// The data provided in the model is used to create a [ListTile] widget, which
/// represents the drawer list item.
///
class DrawerItem {
  /// Creates an instance of [DrawerItem].
  ///
  const DrawerItem({
    this.leading,
    this.title,
  });

  /// A leading widget in the drawer item.
  ///
  /// Usually it is an icon, but could be any widget.
  ///
  final Widget? leading;

  /// An item's title.
  ///
  final String? title;
}

/// Contains parameters to customize the [Drawer].
///
/// It includes all the same arguments as the [Drawer()], excepting
/// the 'child', which is managed by the [DrawerNavigationBuilder].
///
/// In addition it includes some parameters of [ListTile()] that are used to style
/// selected drawer item.
///
/// See also:
/// - [DrawerNavigationBuilder]
/// - [Drawer]
/// - [ListTile]
///
class DrawerParameters {
  /// Create a [DrawerParameters] instance.
  ///
  const DrawerParameters({
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.width,
    this.semanticLabel,
    this.selectedColor,
    this.selectedTileColor,
  });

  /// [Drawer.backgroundColor]
  ///
  final Color? backgroundColor;

  /// [Drawer.elevation]
  ///
  final double? elevation;

  /// [Drawer.shape]
  ///
  final ShapeBorder? shape;

  /// [Drawer.width]
  ///
  final double? width;

  /// [Drawer.semanticLabel]
  ///
  final String? semanticLabel;

  /// [ListTile.selectedColor]
  ///
  final Color? selectedColor;

  /// [ListTile.selectedTileColor]
  ///
  final Color? selectedTileColor;
}
