import 'package:flutter/widgets.dart';

import 'destination_parser.dart';
import 'navigation_controller.dart';
import 'redirection.dart';

/// A class that contains all required information about navigation target.
///
/// The destination is identified by its [path]. Optionally, [parameters] can be provided.
/// Either content [builder] or nested [navigator] must be provided for the destination.
///
/// The navigator uses a destination's [settings] to determine a way of changing
/// the navigation stack, apply transition animations and other aspects of updating
/// the navigation state.
///
/// The [parser] is used to parse destination from the URI and generate a URI string
/// for the destination.
///
/// Optional [upwardDestinationBuilder] builder function can be used to implement custom
/// logic of upward navigation from the current destination.
///
/// If [redirections] are specified, they will be applied on navigation to this destination.
///
/// See also:
/// - [DestinationSettings]
/// - [DestinationParameters]
/// - [DestinationParser]
/// - [Redirection]
///
class Destination<T extends DestinationParameters> {
  /// Creates a destination.
  ///
  Destination({
    required this.path,
    this.builder,
    this.isHome = false,
    this.navigator,
    this.parameters,
    this.parser = const DefaultDestinationParser(),
    this.redirections = const <Redirection>[],
    DestinationSettings? settings,
    this.tag,
    this.upwardDestinationBuilder,
  })  : assert(navigator != null || builder != null,
            'Either "builder" or "navigator" must be specified.'),
        assert(
            (navigator != null && builder == null) ||
                (builder != null && navigator == null),
            'If the "navigator" is provided, the "builder" must be null, or vice versa.'),
        assert(
            ((T == DestinationParameters) &&
                    (parser is DefaultDestinationParser)) ||
                ((T != DestinationParameters) &&
                    parser is! DefaultDestinationParser),
            'Custom "parser" must be provided when using the parameters of type $T, but ${parser.runtimeType} was provided.') {
    this.settings = settings ?? DestinationSettings.material();
    _transitBuilder = null;
  }

  /// Creates a destination that provides a navigator with nested destinations.
  ///
  /// An optional [builder] parameter is basically the same like normal [Destination.builder],
  /// but has additional [child] parameter, which contains the nested content that built by [navigator].
  /// The implementation of [builder] function must include this child widget sub-tree
  /// in the result for correct displaying the nested content.
  ///
  Destination.transit({
    required this.path,
    required this.navigator,
    Widget Function(BuildContext context, T? parameters, Widget child)? builder,
    this.isHome = false,
    this.redirections = const <Redirection>[],
    this.tag,
  })  : builder = null,
        parameters = null,
        parser = const DefaultDestinationParser(),
        settings = DestinationSettings.material(),
        upwardDestinationBuilder = null,
        _transitBuilder = builder;

  /// Path identifies the destination.
  ///
  /// Usually it follows the common url pattern with optional parameters.
  /// Example: `/catalog/{id}`
  ///
  final String path;

  /// A content builder.
  ///
  /// Returns a widget (basically a screen) that should be rendered for this destination.
  ///
  final Widget Function(BuildContext context, T? parameters)? builder;

  /// Whether the destination is the home destination.
  ///
  /// The home destination matches the '/' or empty path, beside of its specific [path].
  ///
  final bool isHome;

  /// A child navigator.
  ///
  /// Allows to implement nested navigation. When specified, the parent navigator
  /// uses this child navigator to build content for this destination.
  ///
  final NavigationController? navigator;

  /// Parameters of the destination.
  ///
  /// If the type *T* is not specified for the destination, then default [DestinationParameters]
  /// type is used.
  ///
  final T? parameters;

  /// A destination parser.
  ///
  /// Used to parse the certain destination object from the URI string, based on
  /// the current destination, and to generate a URI string from the current destination.
  ///
  final DestinationParser parser;

  /// Destinations and conditions to redirect.
  ///
  /// When it is not empty, the navigator will check for each [Redirection] in the list,
  /// if this destination is allowed to navigate to.
  ///
  final List<Redirection> redirections;

  /// Defines a way of how this destination will appear.
  ///
  late final DestinationSettings settings;

  /// An optional label to identify a destination.
  ///
  /// It will be the same for all destinations of the kind, regardless actual
  /// values of destination parameters.
  ///
  final String? tag;

  /// Function that returns an underlay destination.
  ///
  /// A [NavigationController] uses this method to create the underlay destination for the
  /// current one, using its parameters.
  ///
  final Future<Destination?> Function(Destination<T> destination)?
      upwardDestinationBuilder;

  late final Widget Function(BuildContext context, T? parameters, Widget child)?
      _transitBuilder;

  /// Whether this destination is final, i.e. it builds a content
  ///
  /// Final destinations must have a [builder] function provided.
  /// Non-final destinations must have a [navigator], that manages its own destinations.
  ///
  bool get isFinalDestination => navigator == null;

  /// Return a destination that should be displayed on reverse navigation.
  ///
  Future<Destination?> get upwardDestination async =>
      upwardDestinationBuilder?.call(this);

  /// A full URI of the destination, with parameters placeholders replaced with
  /// actual parameter values.
  ///
  String get uri => parser.uri(this);

  /// Return a widget that display destination's content.
  ///
  /// If the destination is final, then [builder] is called to build the content.
  ///
  /// Otherwise [navigator.build] is called to build nested navigator's content.
  /// In case the destination was created by [Destination.transit] constructor,
  /// and [builder] parameter was specified, the nested content is also wrapped in
  /// the widget sub-tree returned by that builder.
  ///
  Widget build(BuildContext context) {
    if (isFinalDestination) {
      return builder!(context, parameters);
    } else {
      final nestedContent = navigator!.build(context);
      if (_transitBuilder != null) {
        return _transitBuilder!(context, parameters, nestedContent);
      } else {
        return nestedContent;
      }
    }
  }

  /// Check if the destination matches the provided URI string
  ///
  bool isMatch(String uri) => parser.isMatch(uri, this);

  /// Parses the destination from the provided URI string.
  ///
  /// Returns a copy of the current destination with updated parameters, parsed
  /// from the URI.
  /// If the URI doesn't match this destination, throws an [DestinationNotMatchException].
  ///
  Future<Destination<T>> parse(String uri) =>
      parser.parseParameters(uri, this) as Future<Destination<T>>;

  /// Returns a copy of this destination with a different settings.
  ///
  Destination<T> withSettings(DestinationSettings settings) => copyWith(
        settings: settings,
      );

  /// Returns a copy of this destination with different parameters.
  ///
  /// For typed parameters ensures that raw parameter values in [DestinationParameters.map]
  /// are updated as well.
  ///
  Destination<T> withParameters(T parameters) {
    final rawParameters = parser.parametersToMap(parameters);
    return copyWith(
      parameters: parameters..map.addAll(rawParameters),
    );
  }

  /// Creates a copy of this destination with the given fields replaced
  /// with the new values.
  ///
  Destination<T> copyWith({
    T? parameters,
    DestinationSettings? settings,
    Future<Destination?> Function(Destination<T> destination)?
        upwardDestinationBuilder,
  }) =>
      Destination<T>(
        path: path,
        builder: builder,
        navigator: navigator,
        parameters: parameters ?? this.parameters,
        parser: parser,
        redirections: redirections,
        settings: settings ?? this.settings,
        tag: tag,
        upwardDestinationBuilder:
            upwardDestinationBuilder ?? this.upwardDestinationBuilder,
      );

  /// Destinations are equal when their URI string are equal.
  ///
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Destination &&
          runtimeType == other.runtimeType &&
          uri == other.uri;

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() => uri;
}

/// Encapsulates the settings attributes which are applied when the navigation state
/// is updated with the the destination.
///
/// There are convenient factory constructors for commonly used settings.
/// [material] - pushes the destination to the navigation stack with standard material animations.
/// [dialog] - display the destination like a dialog
/// [quiet] - replace the previous destination with the current one without animations.
///
/// See also:
/// - [TransitionMethod]
/// - [DestinationTransition]
///
class DestinationSettings {
  /// Creates an instance of [DestinationSettings].
  ///
  const DestinationSettings({
    required this.transitionMethod,
    required this.transition,
    this.redirectedFrom,
    this.reset = false,
    this.transitionBuilder,
    this.updateHistory = true,
  }) : assert(
            (transition == DestinationTransition.custom &&
                    transitionBuilder != null) ||
                (transition != DestinationTransition.custom),
            'You have to provide "transitionBuilder" for "custom" transition.');

  /// Creates a settings to push a destination to the top of navigation
  /// stack with a standard Material animations.
  ///
  const factory DestinationSettings.material() = _DefaultDestinationSettings;

  /// Creates a settings to displays a destination as a modal dialog.
  ///
  const factory DestinationSettings.dialog() = _DialogDestinationSettings;

  /// Creates a settings to replaces the current destination with a new one
  /// with no animations.
  ///
  const factory DestinationSettings.quiet() = _QuietDestinationSettings;

  /// How the destination will update the navigation stack.
  ///
  /// See also:
  ///  - [TransitionMethod]
  ///
  final TransitionMethod transitionMethod;

  /// Visual effects that would be applied on updating the stack with the destination.
  ///
  /// See also:
  /// - [DestinationTransition]
  ///
  final DestinationTransition transition;

  /// In case of redirection, contains a destination from which the redirection
  /// was performed.
  ///
  final Destination? redirectedFrom;

  /// Whether the stack would be cleared before adding the destination.
  ///
  final bool reset;

  /// Function that build custom destination transitions.
  ///
  /// It is required when the [transition] value is [DestinationTransition.custom].
  ///
  /// See also
  /// - [RouteTransitionBuilder]
  ///
  final RouteTransitionsBuilder? transitionBuilder;

  /// Controls if the destination will be added to the navigation history.
  ///
  /// Currently it only affects to web applications. When set to *true*, which is
  /// default, the url in the web browser address field will be updated with the [Destination.uri].
  ///
  final bool updateHistory;

  /// Creates a copy of this settings with the given fields replaced
  /// with the new values.
  ///
  DestinationSettings copyWith({
    // TODO: Add other properties
    TransitionMethod? transitionMethod,
    Destination? redirectedFrom,
    bool? reset,
    bool? updateHistory,
  }) =>
      DestinationSettings(
        transitionMethod: transitionMethod ?? this.transitionMethod,
        transition: transition,
        redirectedFrom: redirectedFrom ?? this.redirectedFrom,
        reset: reset ?? this.reset,
        transitionBuilder: transitionBuilder,
        updateHistory: updateHistory ?? this.updateHistory,
      );
}

class _DefaultDestinationSettings extends DestinationSettings {
  const _DefaultDestinationSettings()
      : super(
          transitionMethod: TransitionMethod.push,
          transition: DestinationTransition.material,
        );
}

class _DialogDestinationSettings extends DestinationSettings {
  const _DialogDestinationSettings()
      : super(
          transitionMethod: TransitionMethod.push,
          transition: DestinationTransition.materialDialog,
        );
}

class _QuietDestinationSettings extends DestinationSettings {
  const _QuietDestinationSettings()
      : super(
          transitionMethod: TransitionMethod.replace,
          transition: DestinationTransition.none,
        );
}

/// A way of transition to the destination.
///
enum TransitionMethod {
  /// The destination will be added to the navigation stack.
  /// On navigation back, the destination will be removed from the stack
  /// and previous destination will be restored.
  ///
  push,

  /// The previous destination will be removed from the navigation stack,
  /// and the current destination will be added.
  /// This means that user will not be able to return to previous destination
  /// by back navigation.
  ///
  replace,
}

/// Defines transition animations from the previous destination to the current one.
///
enum DestinationTransition {
  /// Standard Material animations.
  ///
  material,

  /// Destination appears as a dialog with Material transitions and modal barrier.
  ///
  materialDialog,

  /// Custom animations.
  ///
  custom,

  /// No animations.
  ///
  none,
}

/// Base destination parameters.
///
/// Extend this class to define your custom parameters class.
/// Use [Destination<YourCustomDestinationParameters>()] to make a destination
/// aware of your custom parameters.
///
/// For custom parameters you also must implement [YouCustomDestinationParser<YourCustomDestinationParameters>]
/// with [toDestinationParameters()] ans [toMap()] methods, like this:
/// ``` dart
/// class YourCustomDestinationParser
///     extends DestinationParser<YourCustomDestinationParameters> {
///   const YourCustomDestinationParser() : super();
///
///   @override
///   YourCustomDestinationParameters toDestinationParameters(
///       Map<String, String> map) {
///       //...
///   }
///
///   @override
///   Map<String, String> toMap(YourCustomDestinationParameters parameters) {
///       //...
///   }
/// }
/// ```
///
/// See also:
/// - [DestinationParser]
///
class DestinationParameters {
  /// Creates a [DestinationParameters] instance.
  ///
  DestinationParameters([Map<String, String>? map])
      : map = map ?? <String, String>{};

  /// Reserved query parameter name.
  ///
  /// It is used for automatic persisting of navigation state.
  /// Do not use this name for your custom parameters.
  ///
  static const String stateParameterName = 'state';

  static const _reservedParameterNames = <String>{
    stateParameterName,
  };

  /// Contains parameter values parsed from the destination's URI.
  ///
  /// The parameter name is a [MapEntry.key], and the value is [MapEntry.value].
  ///
  late final Map<String, String> map;

  /// Check if a provided parameter name is reserved
  ///
  /// This function is used by [DestinationParser] to synchronize internal raw parameter
  /// values with parsed parameter object properties and build destination URI.
  ///
  static bool isReservedParameter(String parameterName) =>
      _reservedParameterNames.contains(parameterName);
}
