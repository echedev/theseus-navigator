### 0.8.0
2023-06-20
- Added ability to dynamically identify a destination for redirection.
- Fixed: a context passed to nested navigator builder

### 0.7.1
2023-04-11
- Support of navigation back from redirection destination in case when it was reached by 'replace' method.

**BREAKING**:
- The `DestinationAction` is renamed to `TransitionMethod` and the `action` field of `Destination` is renamed to `transitionMethod`.

### 0.6.5
2023-03-24
- Fixed redirection from home destination.

### 0.6.3
2023-03-09
- Added `config` getter in the navigation scheme, which allows to setup a `MaterialApp` with `routerConfig` parameter.

### 0.6.1
2023-03-03
- Added support of persisting of navigation state in destination parameters. This allows to restore the navigation state from a deeplink.

**BREAKING**:
- The `upwardDestinationBuidler` function changed to be asynchronous.
- In `DestinationParser` methods `toDestinationParameters` and `toMap` are renamed to `parametersFromMap` and `parametersToMap`.

### 0.5.2
2023-01-06

- Added `updateHistory` property in `DestinationSettings` that allows to control if the destination will appear in the web browser history.
- Demo app updated to better support web.

### 0.5.1
2022-12-25

- **BREAKING**: `DestinationConfiguration` renamed to `DestinationSettings`. The `configuration` field of `Destination` is renamed to `settings`.
- Add support of Material 3 `NavigationBar` in `BottomNavigationBuilder`.
- Fix: preserve destination states in `BottomNavigationBuilder` and `TabsNavigationBuilder`.

### 0.4.1
2022-11-27

- Fix: custom waiting view was not applied

### 0.4.0
2022-11-17

- **BREAKING**: `TheseusRouterDelegate` and `TheseusRouteInformationParser` are not available directly anymore. Use `NavigationScheme.routerDelegate` and `NavigationScheme.routeParser` getters.
- The `Destination.transit()` constructor is introduced.

### 0.3.5
2022-11-07

- Support of displaying destination as a dialog.

### 0.3.4
2022-10-29

- Fixes an issue when new route is requested by OS during resolving the current destination.
- Added `redirectedFrom` property in `DestinationSettings`
- The `gotBack` property in `NavigationController` is changed to `backFrom`, which contains the previous destination when `goBack` action is performed.

### 0.3.2
2022-10-22

- Support asynchronous `validator` in `Redirection`
- Added `waitingOverlayBuilder` property in `NavigationScheme`
- Better test coverage

### 0.2.0
2022-10-02

- **BREAKING**: `TheseusNavigator` class renamed to `NavigationController`
- **BREAKING**: `DestinationLight` and `DefaultDestinationParameters` were removed
- Adds `tag` property to `Destination` which is another optional way to identify destinations.
- `TabsNavigationBuilder` is updated to support 'AppBar'

### 0.1.3
2022-09-28

- Added `DrawerNavigationBuilder` and `TabsNavigationBuilder`
- Bug fixes

### 0.1.1
2022-06-26

- **BREAKING**: Renamed some methods of `Destination` class
- Update handling of deep-links
- Improve docs
- Bug fixes

### 0.0.14
2022-03-06

- Fix Dart Analyzer issues

### 0.0.13
2021-12-30

- Add `BottomNavigationBuilder`

### 0.0.12
2021-12-27

- Update back navigation logic
- Fix package layout

### 0.0.9
2021-12-04

- Add web support in the example project
- Fix a bug when navigating history in the web browser

### 0.0.8
2021-10-29

- Handle navigation errors
- Add more tests

### 0.0.7
2021-10-24

- Update redirection logic
- Support various navigation cases in the demo app

### 0.0.6
2021-10-17

- Support redirections
- Update docs

### 0.0.4
2021-10-10

- Minor fixes

### 0.0.1
2021-10-10

- Initial implementation
