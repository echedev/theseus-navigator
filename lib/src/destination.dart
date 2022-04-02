import 'package:flutter/widgets.dart';

import 'destination_parser.dart';
import 'navigator.dart';
import 'redirection.dart';

/// A class that contains all required information about navigation target.
///
/// The destination is identified by its [path]. Optionally, [parameters] can be provided.
/// Either content [builder] or child [navigator] must be provided for the destination.
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
    this.upwardDestinationBuilder,
  })  : assert(navigator != null || builder != null,
            'Either "builder" or "navigator" must be specified.'),
        assert(
            (navigator != null && builder == null) ||
                (builder != null && navigator == null),
            'If the "navigator" is provided, the "builder" must be null, or vice versa.'),
        assert(
            ((T == DefaultDestinationParameters) &&
                    (parser is DefaultDestinationParser)) ||
                ((T != DefaultDestinationParameters) &&
                    parser is! DefaultDestinationParser),
            'Custom "parser" must be provided when using the parameters of type $T, but ${parser.runtimeType} was provided.') {
    this.configuration =
        configuration ?? DestinationConfiguration.defaultMaterial();
  }

  /// Creates a destination that provides a navigator with nested destinations.
  ///
  Destination.intermediate({
    required this.path,
    this.isHome = false,
    this.navigator,
    this.redirections = const <Redirection>[],
  }) : builder = null,
        configuration = DestinationConfiguration.defaultMaterial(),
        parameters = null,
        parser = const DefaultDestinationParser(),
        upwardDestinationBuilder = null;

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
  /// use this child navigator to build content for this destination.
  ///
  final TheseusNavigator? navigator;

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

  /// Function that returns an underlay destination.
  ///
  /// The TheseusNavigator use this method to create the underlay destination for the
  /// current one, using its parameters.
  ///
  final Destination? Function(Destination<T> destination)?
      upwardDestinationBuilder;

  /// Whether this destination is final, i.e. it builds a content
  ///
  /// Final destinations must have a [builder] function provided.
  /// Non-final destinations must have a [navigator], that manages its own destinations.
  ///
  bool get isFinalDestination => navigator == null;

  /// A full URI of the destination, with parameters placeholders replaced with
  /// actual parameter values.
  ///
  String get uri => parser.uri(this);

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

  /// TODO: Add description
  Widget build(BuildContext context) => isFinalDestination
      ? builder!(context, parameters)
      : navigator!.build(context);

  /// TODO: Add description
  Destination? get upwardDestination => upwardDestinationBuilder?.call(this);

  /// Returns a copy of this destination with a different configuration.
  ///
  Destination<T> copyWithConfiguration(
          DestinationConfiguration configuration) =>
      copyWith(
        configuration: configuration,
      );

  /// Returns a copy of this destination with different parameters.
  ///
  Destination<T> copyWithParameters(T parameters) => copyWith(
        parameters: parameters,
      );

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
}

/// Encapsulates the configuration attributes which are used for navigating to
/// the destination.
///
/// There are convenient factory constructors of commonly used configurations.
/// [defaultMaterial] - pushes the destination to the navigation stack with standard material animations.
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
  const factory DestinationConfiguration.defaultMaterial() =
      _DefaultDestinationConfiguration;

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
    bool? reset,
  }) =>
      DestinationConfiguration(
        action: action,
        transition: transition,
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

  /// Custom animations.
  ///
  custom,

  /// No animations.
  ///
  none,
}

/// An interface for destination parameters.
///
/// Extend this abstract class to define your custom parameters class.
/// Use [Destination<YourCustomDestinationParameters>()] to make a destination
/// aware of your custom parameters.
///
/// For custom parameters you also have to implement [toDestinationParameters()]
/// ans [toMap()] methods in the [YouCustomDestinationParser<YourCustomDestinationParameters>]
/// like this:
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
abstract class DestinationParameters {
  /// Creates destination parameters.
  ///
  const DestinationParameters();
}

/// Default destination parameters implementation.
///
/// Uses Map<String, String> to store parameter values.
///
class DefaultDestinationParameters extends DestinationParameters {
  /// Creates default destination parameters.
  ///
  DefaultDestinationParameters([this.map = const <String, String>{}]);

  /// Contains parameter values.
  ///
  /// The parameter name is a [MapEntry.key], and the value is [MapEntry.value].
  ///
  final Map<String, String> map;
}

/// A shorten for destination without custom type parameters.
///
typedef DestinationLight = Destination<DefaultDestinationParameters>;
