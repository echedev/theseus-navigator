import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:utils/utils.dart';

import 'destination.dart';
import 'exceptions.dart';

/// The [TheseusNavigator] manages the navigation state.
///
/// Using the given [destinations] list, it maintains the navigation [stack].
///
/// The navigation stack is updated when a user navigates to specified destination
/// by calling [goTo] method, or returns back with [goBack] method.
///
/// The navigator provides an access to a [currentDestination], which is one on the
/// top of the stack.
///
/// Initially, the navigation stack contains a destination at [initialDestinationIndex]
/// in the provided list of destinations.
///
/// [TheseusNavigator] implements [ChangeNotifier] and notifies its listener when
/// the [currentDestination]/[stack] is changed.
///
/// See also:
/// - [Destination]
/// - [NavigationScheme]
///
class TheseusNavigator with ChangeNotifier {
  TheseusNavigator({
    required this.destinations,
    this.initialDestinationIndex = 0,
    this.wrapperBuilder,
    this.debugLabel = '',
  }) {
    _stack.add(destinations[initialDestinationIndex]);
    key = GlobalKey<NavigatorState>(debugLabel: this.debugLabel);
  }

  /// List of destinations, which this navigator operate of.
  ///
  final List<Destination> destinations;

  /// Index of the initial destination.
  ///
  /// Initial destination will be added to the navigation [stack] on creation the
  /// navigator. If it is omitted, the first destination in the [destinations] list
  /// will be used as initial one.
  ///
  final int initialDestinationIndex;

  /// The debug label.
  ///
  final String? debugLabel;

  /// A function to create custom wrapping widget tree around destinations.
  ///
  /// It can be used when you want, for example, to navigate destinations by
  /// [TabBar], or [BottomNavigationBar].
  ///
  /// See also:
  /// - [NavigationWrapperBuilder]
  ///
  final NavigatorWrapperBuilder? wrapperBuilder;

  /// Provides the global key for corresponding [Navigator] widget.
  ///
  late final GlobalKey<NavigatorState> key;

  bool _shouldClose = false;
  /// Whether the navigator should close.
  ///
  /// It is set to 'true' when user call [onBack] method when the only destination
  /// is in the stack.
  /// If this is the root navigator in the [NavigationScheme], setting [shouldClose]
  /// to true will cause closing the app.
  ///
  bool get shouldClose => _shouldClose;

  final _stack = Queue<Destination>();

  String get _tag => '$runtimeType::$debugLabel';

  /// The current destination of the navigator.
  ///
  /// It is the top destination in the navigation [stack].
  ///
  Destination get currentDestination => _stack.last;

  /// The navigation [stack].
  ///
  /// When [goTo] method is called, the destination is added to the stack,
  /// and when [goBack] method is called, the [currentDestination] is removed from
  /// the stack.
  ///
  List<Destination> get stack => _stack.toList();

  @override
  void dispose() {
    super.dispose();
  }

  /// Opens specified destination.
  ///
  /// By calling calling this method, depending on [destination.configuration],
  /// the given destination will be either added to the navigation [stack], or
  /// will replace the current destination.
  ///
  /// Also, missing backward destinations can be added to the stack, if the
  /// current stack state doesn't match, and the [destination.backwardDestination]
  /// is defined. This mostly could happen when it is navigated as a deeplink.
  ///
  /// Throws [UnknownDestinationException] if the navigator's [destinations]
  /// doesn't contain given destination.
  ///
  Future<void> goTo(Destination destination) async {
    Log.d(_tag, 'goTo(): destination=${destination.uri}');
    if (_isValidDestination(destination)) {
      _updateStack(destination);
      _shouldClose = false;
      notifyListeners();
    } else {
      throw UnknownDestinationException(destination);
    }
  }

  /// Closes the current destination.
  ///
  /// The current destination is removed from the navigation [stack].
  ///
  /// If it was the only destination in the stack, it remains in the stack and
  /// [shouldClose] flag is set to 'true'.
  ///
  Future<void> goBack() async {
    Log.d(_tag, 'goBack(): localStack=${_stack.length}');
    if (_stack.length > 1) {
      _stack.removeLast();
      _shouldClose = false;
    } else {
      _shouldClose = true;
    }
    notifyListeners();
  }

  bool _isValidDestination(Destination destination) =>
      destinations.any((element) => element.isMatch(destination.uri));

  void _updateStack(Destination destination) {
    if (destination.configuration.action == DestinationAction.replace) {
      _stack.removeLast();
    }
    final backwardStack = _buildBackwardStack(destination);
    if (backwardStack.isNotEmpty) {
      // Find first missing item of backward stack
      int startBackwardFrom = 0;
      for (int i = 0; i < backwardStack.length; i++) {
        if (_stack.last == backwardStack[i]) {
          startBackwardFrom = i + 1;
        }
      }
      // Add all missing backward destinations to the stack
      if (startBackwardFrom < backwardStack.length) {
        for (int i = startBackwardFrom; i < backwardStack.length; i++) {
          _stack.addLast(backwardStack[i]);
        }
      }
    }
    _stack.addLast(destination);
  }

  List<Destination> _buildBackwardStack(Destination destination) {
    final result = <Destination>[];
    var backwardDestination = destination.backwardDestination
        ?.call(destination, destination.parameters);
    while (backwardDestination != null) {
      result.insert(0, backwardDestination);
      backwardDestination = backwardDestination.backwardDestination
          ?.call(backwardDestination, backwardDestination.parameters);
    }
    return result;
  }
}

/// The signature of function that builds the navigator's wrapper widget tree.
///
/// The [nestedNavigatorBuilder] function should be called to build a wrapper for
/// nested navigators.
///
typedef NavigatorWrapperBuilder = Widget Function(
  BuildContext context,
  TheseusNavigator navigator,
  Widget Function(BuildContext context, TheseusNavigator nestedNavigator)
      nestedNavigatorBuilder,
);