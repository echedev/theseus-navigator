import 'package:flutter/widgets.dart';

import 'destination_parser.dart';
import 'navigator.dart';

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
/// Optional [backwardDestination] builder function can be used to implement custom
/// logic of backward navigation from the current destination.
///
/// See also:
/// - [DestinationConfiguration]
/// - [DestinationParameters]
/// - [DestinationParser]
///
class Destination<T extends DestinationParameters> {
  Destination({
    required this.path,
    this.backwardDestination,
    this.builder,
    this.isHome = false,
    this.navigator,
    DestinationConfiguration? configuration,
    this.parameters,
    this.parser = const DefaultDestinationParser(),
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
                    !(parser is DefaultDestinationParser)),
            'Custom "parser" must be provided when using the parameters of type $T, but ${parser.runtimeType} was provided.') {
    this.configuration = configuration == null
        ? DestinationConfiguration.defaultMaterial()
        : configuration;
  }

  /// Path identifies the destination.
  ///
  /// Usually it follows the common url pattern with optional parameters.
  /// Example: `/categories/{id}`
  ///
  final String path;

  /// Returns an underlay destination.
  ///
  /// Navigator will use this method to create the underlay destination for the
  /// current one, using its parameters.
  ///
  final Destination? Function(Destination destination, T? parameters)?
      backwardDestination;

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
  /// use this child navigator to build content for this destination.
  ///
  final TheseusNavigator? navigator;

  /// Defines a way of how this destination will appear.
  ///
  late final DestinationConfiguration configuration;

  /// Optional parameters, that are used to build content.
  ///
  final T? parameters;

  /// A destination parser.
  ///
  /// Used to parse the certain destination object from the URI string, based on
  /// the current destination, and to generate a URI string from the current destination.
  ///
  final DestinationParser parser;

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

  Widget build(BuildContext context) => isFinalDestination
      ? builder!(context, parameters)
      : navigator!.build(context);

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

  Destination<T> copyWith({
    DestinationConfiguration? configuration,
    T? parameters,
    DestinationTransition? transitionType,
  }) =>
      Destination<T>(
        path: this.path,
        builder: this.builder,
        navigator: this.navigator,
        configuration: this.configuration,
        parameters: parameters ?? this.parameters,
        parser: this.parser,
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
  const DestinationConfiguration({
    required this.action,
    required this.transition,
    this.transitionBuilder,
  }) : assert(
            (transition == DestinationTransition.custom &&
                    transitionBuilder != null) ||
                (transition != DestinationTransition.custom),
            'You have to provide "transitionBuilder" for "custom" transition.');

  const factory DestinationConfiguration.defaultMaterial() =
      _DefaultDestinationConfiguration;

  const factory DestinationConfiguration.quiet() =
      _QuietDestinationConfiguration;

  final DestinationAction action;

  final DestinationTransition transition;

  final RouteTransitionsBuilder? transitionBuilder;
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
/// [push] - The destination will be added to the navigation stack. On back action,
/// the destination will be removed from the stack and previous destination will be returned.
/// [replace] - The previous destination will be removed from the navigation stack,
/// and the current destination will be added. This means that user will not be
/// able to return to previous destination by back action.
///
enum DestinationAction { push, replace }

/// Defines transition animations from the previous destination to the current one.
///
enum DestinationTransition { material, custom, none }

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
  const DestinationParameters();
}

/// Default destination parameters implementation.
///
/// Uses Map<String, String> to store parameter values.
///
class DefaultDestinationParameters extends DestinationParameters {
  DefaultDestinationParameters([this.map = const <String, String>{}]);

  final Map<String, String> map;
}

typedef DestinationLight = Destination<DefaultDestinationParameters>;
