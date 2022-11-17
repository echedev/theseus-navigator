import 'package:flutter/widgets.dart';

import 'destination_parser.dart';
import 'navigation_controller.dart';
import 'redirection.dart';

/// A class that contains all required information about navigation target.
///
/// The destination is identified by its [path]. Optionally, [parameters] can be provided.
/// Either content [builder] or nested [navigator] must be provided for the destination.
///
/// The navigator uses a destination's [configuration] to apply a certain logic of
/// updating the navigation stack and transition animations.
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
/// - [DestinationConfiguration]
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
    DestinationConfiguration? configuration,
    this.isHome = false,
    this.navigator,
    this.parameters,
    this.parser = const DefaultDestinationParser(),
    this.redirections = const <Redirection>[],
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
    this.configuration = configuration ?? DestinationConfiguration.material();
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
        configuration = DestinationConfiguration.material(),
        parameters = null,
        parser = const DefaultDestinationParser(),
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

  /// Defines a way of how this destination will appear.
  ///
  late final DestinationConfiguration configuration;

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

  /// Optional parameters, that are used to build content.
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
  final Destination? Function(Destination<T> destination)?
      upwardDestinationBuilder;

  late final Widget Function(BuildContext context, T? parameters, Widget child)?
      _transitBuilder;

  /// Indicates if the [upwardDestinationBuilder] is provided.
  ///
  bool get hasUpwardDestinationBuilder => upwardDestinationBuilder != null;

  /// Whether this destination is final, i.e. it builds a content
  ///
  /// Final destinations must have a [builder] function provided.
  /// Non-final destinations must have a [navigator], that manages its own destinations.
  ///
  bool get isFinalDestination => navigator == null;

  /// Return a destination that should be displayed on reverse navigation.
  ///
  Destination? get upwardDestination => upwardDestinationBuilder?.call(this);

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

  /// Returns a copy of this destination with a different configuration.
  ///
  Destination<T> withConfiguration(DestinationConfiguration configuration) =>
      copyWith(
        configuration: configuration,
      );

  /// Returns a copy of this destination with different parameters.
  ///
  /// For typed parameters ensures that raw parameter values in [DestinationParameters.map] are valid.
  ///
  Destination<T> withParameters(T parameters) {
    final rawParameters = parser.toMap(parameters);
    return copyWith(
      parameters: parameters
        ..map.clear()
        ..map.addAll(rawParameters),
    );
  }

  /// Creates a copy of this destination with the given fields replaced
  /// with the new values.
  ///
  Destination<T> copyWith({
    DestinationConfiguration? configuration,
    T? parameters,
  }) =>
      Destination<T>(
        path: path,
        builder: builder,
        navigator: navigator,
        configuration: configuration ?? this.configuration,
        parameters: parameters ?? this.parameters,
        parser: parser,
        redirections: redirections,
        tag: tag,
        upwardDestinationBuilder: upwardDestinationBuilder,
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

/// Encapsulates the configuration attributes which are used for navigating to
/// the destination.
///
/// There are convenient factory constructors of commonly used configurations.
/// [material] - pushes the destination to the navigation stack with standard material animations.
/// [quiet] - replace the previous destination with the current one without animations.
///
/// See also:
/// - [DestinationAction]
/// - [DestinationTransition]
///
class DestinationConfiguration {
  /// Creates configuration of a destination.
  ///
  const DestinationConfiguration({
    required this.action,
    required this.transition,
    this.redirectedFrom,
    this.reset = false,
    this.transitionBuilder,
  }) : assert(
            (transition == DestinationTransition.custom &&
                    transitionBuilder != null) ||
                (transition != DestinationTransition.custom),
            'You have to provide "transitionBuilder" for "custom" transition.');

  /// Creates a configuration that pushes a destination to the top of navigation
  /// stack with a standard Material animations.
  ///
  const factory DestinationConfiguration.material() =
      _DefaultDestinationConfiguration;

  /// Creates a configuration that displays a destination as a modal dialog.
  ///
  const factory DestinationConfiguration.dialog() =
      _DialogDestinationConfiguration;

  /// Creates a configuration that replaces the current destination with a new one
  /// with no animations.
  ///
  const factory DestinationConfiguration.quiet() =
      _QuietDestinationConfiguration;

  /// How the destination will update the navigation stack.
  ///
  /// See also:
  ///  - [DestinationAction]
  ///
  final DestinationAction action;

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

  /// Creates a copy of this configuration with the given fields replaced
  /// with the new values.
  ///
  DestinationConfiguration copyWith({
    // TODO: Add other properties
    Destination? redirectedFrom,
    bool? reset,
  }) =>
      DestinationConfiguration(
        action: action,
        transition: transition,
        redirectedFrom: redirectedFrom ?? this.redirectedFrom,
        reset: reset ?? this.reset,
        transitionBuilder: transitionBuilder,
      );
}

class _DefaultDestinationConfiguration extends DestinationConfiguration {
  const _DefaultDestinationConfiguration()
      : super(
          action: DestinationAction.push,
          transition: DestinationTransition.material,
        );
}

class _DialogDestinationConfiguration extends DestinationConfiguration {
  const _DialogDestinationConfiguration()
      : super(
          action: DestinationAction.push,
          transition: DestinationTransition.materialDialog,
        );
}

class _QuietDestinationConfiguration extends DestinationConfiguration {
  const _QuietDestinationConfiguration()
      : super(
          action: DestinationAction.replace,
          transition: DestinationTransition.none,
        );
}

/// An action that is used to update the navigation stack with the destination.
///
enum DestinationAction {
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
/// Extend this abstract class to define your custom parameters class.
/// Use [Destination<YourCustomDestinationParameters>()] to make a destination
/// aware of your custom parameters.
///
/// For custom parameters you also must implement [YouCustomDestinationParser<YourCustomDestinationParameters>]
/// with [toDestinationParameters()] ans [toMap()] methods, like this:
/// ```
/// class YourCustomDestinationParser
///     extends DestinationParser<YourCustomDestinationParameters> {
///   const YourCustomDestinationParser() : super();
///
///   @override
///   YourCustomDestinationParameters toDestinationParameters(
///       Map<String, String> map) {
///       ...
///   }
///
///   @override
///   Map<String, String> toMap(YourCustomDestinationParameters parameters) {
///       ...
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

  /// Contains parameter values parsed from the destination's URI.
  ///
  /// The parameter name is a [MapEntry.key], and the value is [MapEntry.value].
  ///
  late final Map<String, String> map;
}
