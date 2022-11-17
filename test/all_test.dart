import 'destination_test.dart' as destination;
import 'destination_parser_test.dart' as destination_parser;
import 'navigation_scheme_test.dart' as navigation_scheme;
import 'navigation_controller_test.dart' as navigation_controller;
import 'redirection_test.dart' as redirection;
import 'route_parser_test.dart' as route_parser;
import 'router_delegate_test.dart' as router_delegate;
import 'widgets/router_delegate_widget_test.dart' as router_delegate_widgets;

void main() {
  destination.main();
  destination_parser.main();
  navigation_scheme.main();
  navigation_controller.main();
  redirection.main();
  router_delegate.main();
  route_parser.main();

  destination_widget.main();
  router_delegate_widget.main();
}
