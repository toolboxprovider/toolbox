# Toolbox

The package exposes two library products:

- `ToolboxCore`: Foundation utilities, identifiers, decoding defaults, version and build configuration values, Redux protocols, and UserDefaults persistence. No external dependencies.
- `Toolbox`: the full library, including reactive state, settings, networking, and UI integrations. It depends on and re-exports ToolboxCore, so existing clients can keep `import Toolbox`.

Use `import ToolboxCore` for model and reducer code that does not need the runtime integrations. `ReduxAction.dispatch(into:)` and the store remain in Toolbox. The shared declarations and implementations have moved into Core without changing their behavior; consumers must rebuild after updating.

1) .gitignore
2) Add project folder structure
3) Add xcode adhoc environment (adhoc env variable)
4) get UDIDs of testers + register devices + download signing certs/provisioning
5) add fastlane for release distribution
6) add signing key from AppStore conenct
7) link this repo, 
8) add R.swift (move source/buildTools folder + add run script phase, untick incremental builds + add source/resources/rswift/R.generated file)
9) firebase crashlytics
10) slack notification
11) Add app environemnts and shakeToChange ENV
12) Add network API domains for envs, add netowrk auth, add network Response mappers, network error mappers. Add network Logger
13) Add app error
14) Add SettingsStore for Environment
15) Add AppState + store
