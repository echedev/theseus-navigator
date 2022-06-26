import 'dart:collection';
import 'package:flutter/widgets.dart';

import 'destination.dart';
import 'exceptions.dart';
import 'utils/utils.dart';
import 'widgets/index.dart';

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
/// the [currentDestination]/[stack] is changed, or some error was happened.
///
/// See also:
/// - [Destination]
/// - [NavigationScheme]
/// - [TheseusNavigatorError]
///
class TheseusNavigator with ChangeNotifier {
  /// Creates navigator.
  ///
  /// Add initial destination to the navigation stack and creates a [GlobalKey] for
  /// a [Navigator] widget.
  ///
  TheseusNavigator({
    required this.destinations,
    this.builder = const DefaultNavigatorBuilder(),
    this.initialDestinationIndex = 0,
    this.notifyOnError = true,
    this.tag = '',
  }) {
    _stack.add(destinations[initialDestinationIndex]);
    key = GlobalKey<NavigatorState>(debugLabel: tag);
  }

  /// List of destinations, which this navigator operate of.
  ///
  final List<Destination> destinations;

  /// An implementation of [NavigatorBuilder] that creates a wrapping widget tree
  /// around destinations.
  ///
  /// Defaults to [DefaultNavigatorBuilder] that wraps destinations to Flutter's
  /// [Navigator] widget.
  ///
  /// Also a [BottomNavigationBuilder] implementation is available, which allow
  /// to switch destination using Flutter's [BottomNavigationBar] widget.
  ///
  /// It can be used when you want, for example, to navigate destinations by
  /// [TabBar], or [BottomNavigationBar].
  ///
  /// See also:
  /// - [NavigatorBuilder]
  /// - [DefaultNavigatorBuilder]
  /// - [BottomNavigationBuilder]
  ///
  final NavigatorBuilder builder;

  /// Index of the initial destination.
  ///
  /// Initial destination will be added to the navigation [stack] on creation the
  /// navigator. If it is omitted, the first destination in the [destinations] list
  /// will be used as initial one.
  ///
  final int initialDestinationIndex;

  /// Whether to notify listeners on errors in navigation actions.
  ///
  /// Defaults to true. Basically the [NavigationScheme] handles the errors.
  /// When set to false, the exception will be thrown on errors instead of notifying listeners.
  ///
  final bool notifyOnError;

  /// An identifier of this navigator.
  ///
  /// It is used in the debug logs to identify entries related to this navigator.
  ///
  final String? tag;

  /// Provides the global key for corresponding [Navigator] widget.
  ///
  late final GlobalKey<NavigatorState> key;

  TheseusNavigatorError? _error;

  /// Error details
  ///
  TheseusNavigatorError? get error => _error;

  /// Whether an error was happened on [goTo()] or [goBack()] actions.
  ///
  bool get hasError => _error != null;

  bool _gotBack = false;

  /// Whether the back action was performed.
  ///
  /// It is 'true' if the last navigation method call was the [goBack()].
  ///
  bool get gotBack => _gotBack;

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

  String get _tag => '$runtimeType::$tag';

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

  /// Builds a widget that wraps the destination's content.
  ///
  Widget build(BuildContext context) {
    return builder.build(context, this);
  }

  /// Opens specified destination.
  ///
  /// By calling calling this method, depending on [destination.configuration],
  /// the given destination will be either added to the navigation [stack], or
  /// will replace the current destination.
  ///
  /// Also, missing upward destinations can be added to the stack, if the
  /// current stack state doesn't match, and the [destination.upwardDestinationBuilder]
  /// is defined. This mostly could happen when it is navigated as a deeplink.
  ///
  /// Throws [UnknownDestinationException] if the navigator's [destinations]
  /// doesn't contain given destination.
  ///
  Future<void> goTo(Destination destination) async {
    Log.d(_tag,
        'goTo(): destination=${destination.uri}, reset=${destination.configuration.reset}');
    _error = null;
    _gotBack = false;
    _shouldClose = false;
    if (currentDestination == destination) {
      if (!destination.configuration.reset) {
        Log.d(_tag,
            'goTo(): The destination is already on top. No action required.');
        notifyListeners();
        return;
      }
    }
    if (_isDestinationMatched(destination)) {
      _updateStack(destination);
      notifyListeners();
    } else {
      if (notifyOnError) {
        _error = TheseusNavigatorError(destination: destination);
        notifyListeners();
        return;
      } else {
        throw UnknownDestinationException(destination);
      }
    }
  }

  /// Closes the current destination.
  ///
  /// The current destination is removed from the navigation [stack].
  ///
  /// If it is the only destination in the stack, it remains in the stack and
  /// [shouldClose] flag is set to 'true'.
  ///
  void goBack() {
    _gotBack = true;
    if (_stack.length > 1) {
      _stack.removeLast();
      _shouldClose = false;
    } else {
      _shouldClose = true;
    }
    Log.d(_tag,
        'goBack(): destination=${_stack.last.uri}, shouldClose=$_shouldClose');
    notifyListeners();
  }

  bool _isDestinationMatched(Destination destination) =>
      destinations.any((element) => element.isMatch(destination.uri));

  void _updateStack(Destination destination) {
    if (destination.configuration.reset) {
      _stack.clear();
    } else {
      if (destination.configuration.action == DestinationAction.replace) {
        _stack.removeLast();
      }
    }
    final upwardStack = _buildUpwardStack(destination);
    if (upwardStack.isNotEmpty) {
      // Find first missing item of upward stack
      int startUpwardFrom = 0;
      for (int i = 0; i < upwardStack.length; i++) {
        if (_stack.isNotEmpty && _stack.last == upwardStack[i]) {
          startUpwardFrom = i + 1;
        }
      }
      // Add all missing upward destinations to the stack
      if (startUpwardFrom < upwardStack.length) {
        for (int i = startUpwardFrom; i < upwardStack.length; i++) {
          _stack.addLast(upwardStack[i]);
        }
      }
    }
    _stack.addLast(destination);
  }

  List<Destination> _buildUpwardStack(Destination destination) {
    final result = <Destination>[];
    var upwardDestination = destination.upwardDestination;
    while (upwardDestination != null) {
      result.insert(0, upwardDestination);
      upwardDestination = upwardDestination.upwardDestination;
    }
    return result;
  }
}

/// Contains navigation error details
///
class TheseusNavigatorError {
  /// Creates an error object
  TheseusNavigatorError({
    this.destination,
  });

  /// A destination related to this error
  ///
  final Destination? destination;

  @override
  String toString() => '$runtimeType={destination: $destination}';
}
