
# JetBrains IDE Installer (jetbrains-ide)

A feature to install a JetBrains IDE and plugins

## Example Usage

```json
"features": {
    "ghcr.io/Ozee-io/devcontainer-features/jetbrains-ide:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| app | Choose the JetBrains IDE you want to install. | string | IntelliJProfessional |
| version | Choose the version of the JetBrains IDE you want to install. | string | 2023.1.2 |
| plugins | List of JetBrains plugin IDs to install, separated by commas. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Ozee-io/devcontainer-features/blob/main/src/jetbrains-ide/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
