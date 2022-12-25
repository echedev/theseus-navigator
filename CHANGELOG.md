### 0.5.0
2022-12-24

- **BREAKING**: `DestinationConfiguration` renamed to `DestinationSettings`. The `configuration` field of `Destination` is renamed to `settings`.
- Fix: custom waiting view was not applied

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
