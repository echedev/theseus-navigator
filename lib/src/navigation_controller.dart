import 'dart:collection';
import 'package:flutter/widgets.dart';

import 'destination.dart';
import 'exceptions.dart';
import 'utils/utils.dart';
import 'widgets/index.dart';

/// A [NavigationController] manages the navigation state.
///
/// Using the given [destinations] list, it maintains the navigation [stack].
///
/// The navigation stack is updated when a user navigates to specified destination
/// by calling [goTo] method, or returns back with [goBack] method.
///
/// The navigation controller (navigator) provides an access to a [currentDestination],
/// which is one on the top of the stack.
///
/// Initially, the navigation stack contains a destination at [initialDestinationIndex]
/// in the provided list of destinations.
///
/// [NavigationController] implements [ChangeNotifier] and notifies its listener when
/// the [currentDestination]/[stack] is changed, or some error was happened.
///
/// See also:
/// - [Destination]
/// - [NavigationScheme]
/// - [NavigationControllerError]
///
class NavigationController with ChangeNotifier {
  /// Creates navigation controller instance.
  ///
  /// Add initial destination to the navigation stack and creates a [GlobalKey] for
  /// a [Navigator] widget.
  ///
  NavigationController({
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

  /// An implementation of [NavigatorBuilder] which creates a navigation UI.
  ///
  /// Defaults to [DefaultNavigatorBuilder] which uses Flutter's [Navigator] widget
  /// to represent the stack of destinations.
  ///
  /// Also the following implementations are available:
  /// - [BottomNavigationBuilder] allows to switch destination using Flutter's
  /// [BottomNavigationBar] widget.
  /// - [DrawerNavigationBuilder] uses drawer menu to navigate top-level destinations.
  /// - [TabsNavigationBuilder] uses [TabBar] with [TabBarView] widgets to switch destinations.
  ///
  /// You can implement your custom wrapper by extending the [NavigatorBuilder] class.
  ///
  /// See also:
  /// - [NavigatorBuilder]
  /// - [DefaultNavigatorBuilder]
  /// - [BottomNavigationBuilder]
  /// - [DrawerNavigationBuilder]
  /// - [TabsNavigationBuilder]
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

  Destination? _backFrom;

  /// The destination from [goBack] action is performed.
  ///
  /// It is set to current destination right before [goBack] action is processed.
  /// Otherwise it is set to null.
  ///
  Destination? get backFrom => _backFrom;

  NavigationControllerError? _error;

  /// Error details
  ///
  NavigationControllerError? get error => _error;

  /// Whether an error was happened on last [goTo] or [goBack] action.
  ///
  bool get hasError => _error != null;

  bool _shouldClose = false;

  /// Whether the navigator should close.
  ///
  /// It is set to 'true' when user call [goBack] method when the only destination
  /// is in the stack.
  ///
  /// If this is the root navigator in the [NavigationScheme], setting [shouldClose]
  /// to true will cause closing the app.
  ///
  bool get shouldClose => _shouldClose;

  final _stack = Queue<Destination>();

  String get _tag => '$runtimeType::$tag';

  /// The current destination of the navigator.
  ///
  /// It is the topmost destination in the navigation [stack].
  ///
  Destination get currentDestination => _stack.last;

  /// The navigation [stack].
  ///
  /// When [goTo] method is called, the destination is placed on the top of the stack,
  /// and when [goBack] method is called, the topmost destination is removed from
  /// the stack.
  ///
  List<Destination> get stack => _stack.toList();

  /// Builds a widget that wraps destinations of the navigator.
  ///
  Widget build(BuildContext context) {
    return builder.build(context, this);
  }

  /// Opens specified destination.
  ///
  /// By calling calling this method, depending on [destination.settings],
  /// the given destination will be either added to the top of the navigation [stack],
  /// or will replace the topmost destination in the stack.
  ///
  /// Also, missing upward destinations can be added to the stack, if the
  /// current stack state doesn't match, and the [destination.upwardDestinationBuilder]
  /// is defined.
  ///
  /// Throws [UnknownDestinationException] if the navigator's [destinations]
  /// doesn't contain given destination.
  ///
  Future<void> goTo(Destination destination) async {
    Log.d(_tag,
        'goTo(): destination=$destination, reset=${destination.settings.reset}');
    _backFrom = null;
    _error = null;
    _shouldClose = false;
    if (currentDestination == destination) {
      if (!destination.settings.reset) {
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
        _error = NavigationControllerError(destination: destination);
        notifyListeners();
        return;
      } else {
        throw UnknownDestinationException(destination);
      }
    }
  }

  /// Closes the current destination.
  ///
  /// The topmost destination is removed from the navigation [stack].
  ///
  /// If it is the only destination in the stack, it remains in the stack and
  /// [shouldClose] flag is set to 'true'.
  ///
  void goBack() {
    _backFrom = currentDestination;
    if (_stack.length > 1) {
      _stack.removeLast();
      _shouldClose = false;
    } else {
      _shouldClose = true;
    }
    Log.d(_tag,
        'goBack(): destination=${_stack.last}, shouldClose=$_shouldClose');
    notifyListeners();
  }

  bool _isDestinationMatched(Destination destination) =>
      destinations.any((element) => element.isMatch(destination.uri));

  void _updateStack(Destination destination) {
    if (destination.settings.reset) {
      _stack.clear();
    } else {
      if (destination.settings.action == DestinationAction.replace) {
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
class NavigationControllerError {
  /// Creates an error object
  NavigationControllerError({
    this.destination,
  });

  /// A destination related to this error
  ///
  final Destination? destination;

  @override
  String toString() => '$runtimeType={destination: $destination}';
}
