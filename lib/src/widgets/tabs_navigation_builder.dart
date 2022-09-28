import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../navigator.dart';
import 'index.dart';

/// A [NavigatorBuilder] that allows to switch between destinations using
/// [TabBar].
///
/// It builds a wrapper widget, which is a [Scaffold] with a [Scaffold.appbar] set
/// to the [TabBar] with provided [tabs], and a [Scaffold.body] set to the [TabBarView],
/// which display a content of corresponding destination.
///
/// The [tabs] must correspond to the navigator's destinations.
///
/// The tab bar can be customized using [parameters], which includes all parameters
/// supported by the [TabBar] widget.
///
/// See also:
/// - [NavigatorBuilder]
/// - [TabBarParameters]
/// - [TheseusNavigator]
/// - [TabBar]
///
class TabsNavigationBuilder implements NavigatorBuilder {
  /// Creates a [TabsNavigationBuilder] instance.
  ///
  const TabsNavigationBuilder({
    required this.tabs,
    this.parameters = const TabBarParameters(),
    this.wrapInScaffold = false,
  });

  /// Typically a list of [Tab] widgets, that corresponds to the navigator's
  /// destination list.
  ///
  /// The list must contain the same number of widgets, following with the same order
  /// as a destination list specified for the navigator.
  ///
  final List<Widget> tabs;

  /// A set of [TabBar] parameters.
  ///
  /// Contains all supported parameters to customize [TabBar] widget.
  /// Doesn't include 'tabs', 'onTap' and 'controller', which are managed by
  /// [TabsNavigationBuilder].
  ///
  final TabBarParameters parameters;

  /// Controls if the [Scaffold] widget should be used around the tab bar and tab's content.
  ///
  /// This might be needed if you are using tabs as a top level navigation in your app.
  ///
  final bool wrapInScaffold;

  @override
  Widget build(BuildContext context, TheseusNavigator navigator) {
    final currentDestination = navigator.currentDestination;
    return _TabsNavigationWrapper(
      tabs: tabs,
      // TODO: This implementation doesn't respect the possible parameters of destinations (excluding current destination).
      // How this could be resolved?
      tabContentBuilder: (tabIndex) =>
          navigator.destinations[tabIndex].build(context),
      parameters: parameters,
      onTabSelected: (index) => navigator.goTo(navigator.destinations[index]),
      selectedIndex: navigator.destinations.indexOf(currentDestination),
      wrapInScaffold: wrapInScaffold,
    );
  }
}

class _TabsNavigationWrapper extends StatefulWidget {
  const _TabsNavigationWrapper({
    Key? key,
    required this.tabs,
    required this.tabContentBuilder,
    required this.onTabSelected,
    required this.selectedIndex,
    required this.parameters,
    this.wrapInScaffold = false,
  }) : super(key: key);

  final List<Widget> tabs;

  final Widget Function(int tabIndex) tabContentBuilder;

  final void Function(int index) onTabSelected;

  final int selectedIndex;

  final TabBarParameters parameters;

  final bool wrapInScaffold;

  @override
  _TabsNavigationWrapperState createState() => _TabsNavigationWrapperState();
}

class _TabsNavigationWrapperState extends State<_TabsNavigationWrapper>
    with TickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: widget.tabs.length, vsync: this);
    _controller.animateTo(widget.selectedIndex);
  }

  @override
  void didUpdateWidget(_TabsNavigationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _controller.animateTo(widget.selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      controller: _controller,
      tabs: widget.tabs,
      onTap: (value) => widget.onTabSelected(value),
      isScrollable: widget.parameters.isScrollable,
      padding: widget.parameters.padding,
      indicatorColor: widget.parameters.indicatorColor,
      automaticIndicatorColorAdjustment:
          widget.parameters.automaticIndicatorColorAdjustment,
      indicatorWeight: widget.parameters.indicatorWeight,
      indicatorPadding: widget.parameters.indicatorPadding,
      indicator: widget.parameters.indicator,
      indicatorSize: widget.parameters.indicatorSize,
      labelColor: widget.parameters.labelColor,
      labelStyle: widget.parameters.labelStyle,
      labelPadding: widget.parameters.labelPadding,
      unselectedLabelColor: widget.parameters.unselectedLabelColor,
      unselectedLabelStyle: widget.parameters.unselectedLabelStyle,
      dragStartBehavior: widget.parameters.dragStartBehavior,
      overlayColor: widget.parameters.overlayColor,
      mouseCursor: widget.parameters.mouseCursor,
      enableFeedback: widget.parameters.enableFeedback,
      physics: widget.parameters.physics,
      splashFactory: widget.parameters.splashFactory,
      splashBorderRadius: widget.parameters.splashBorderRadius,
    );
    final tabBarView = TabBarView(
      controller: _controller,
      children: List<Widget>.generate(
          widget.tabs.length, (index) => widget.tabContentBuilder(index)),
    );
    Widget result = Column(
      children: [
        tabBar,
        Expanded(
          child: tabBarView,
        ),
      ],
    );
    if (widget.wrapInScaffold) {
      result = Scaffold(
        body: result,
      );
    }
    return result;
  }
}

/// Contains parameters to customize the [TabBar].
///
/// It includes all the same arguments as the [TabBar()], excepting
/// the 'tabs', 'onTap' and 'controller', which are managed by the [TabsNavigationBuilder].
///
/// See also:
/// - [TabsNavigationBuilder]
/// - [TabBar]
///
class TabBarParameters {
  /// Create a [TabBarParameters] instance.
  ///
  const TabBarParameters({
    this.isScrollable = false,
    this.padding,
    this.indicatorColor,
    this.automaticIndicatorColorAdjustment = true,
    this.indicatorWeight = 2.0,
    this.indicatorPadding = EdgeInsets.zero,
    this.indicator,
    this.indicatorSize,
    this.labelColor,
    this.labelStyle,
    this.labelPadding,
    this.unselectedLabelColor,
    this.unselectedLabelStyle,
    this.dragStartBehavior = DragStartBehavior.start,
    this.overlayColor,
    this.mouseCursor,
    this.enableFeedback,
    this.physics,
    this.splashFactory,
    this.splashBorderRadius,
  });

  /// [TabBar.isScrollable]
  ///
  final bool isScrollable;

  /// [TabBar.padding]
  ///
  final EdgeInsetsGeometry? padding;

  /// [TabBar.indicatorColor]
  ///
  final Color? indicatorColor;

  /// [TabBar.automaticIndicatorColorAdjustment]
  ///
  final bool automaticIndicatorColorAdjustment;

  /// [TabBar.indicatorWeight]
  ///
  final double indicatorWeight;

  /// [TabBar.indicatorPadding]
  ///
  final EdgeInsetsGeometry indicatorPadding;

  /// [TabBar.indicator]
  ///
  final Decoration? indicator;

  /// [TabBar.indicatorSize]
  ///
  final TabBarIndicatorSize? indicatorSize;

  /// [TabBar.labelColor]
  ///
  final Color? labelColor;

  /// [TabBar.labelStyle]
  ///
  final TextStyle? labelStyle;

  /// [TabBar.labelPadding]
  ///
  final EdgeInsetsGeometry? labelPadding;

  /// [TabBar.unselectedLabelColor]
  ///
  final Color? unselectedLabelColor;

  /// [TabBar.unselectedLabelStyle]
  ///
  final TextStyle? unselectedLabelStyle;

  /// [TabBar.dragStartBehavior]
  ///
  final DragStartBehavior dragStartBehavior;

  /// [TabBar.overlayColor]
  ///
  final MaterialStateProperty<Color?>? overlayColor;

  /// [TabBar.mouseCursor]
  ///
  final MouseCursor? mouseCursor;

  /// [TabBar.enableFeedback]
  ///
  final bool? enableFeedback;

  /// [TabBar.physics]
  ///
  final ScrollPhysics? physics;

  /// [TabBar.splashFactory]
  ///
  final InteractiveInkFeatureFactory? splashFactory;

  /// [TabBar.splashBorderRadius]
  ///
  final BorderRadius? splashBorderRadius;
}
