# Ozee Dev Container Features

Welcome to the Ozee Dev Container Features repository! This repository provides a collection of reusable components that can be added to a [Visual Studio Code dev container](https://code.visualstudio.com/docs/remote/containers) to provide additional functionality. Each feature is designed to help you set up your development environment quickly and easily.

## What are Dev Container Features?

Dev Container Features are reusable components that can be added to a dev container to provide additional functionality. Features can be used to install software, configure settings, or perform other tasks that are required for a specific development environment. Dev Container Features are distributed as Docker images and can be hosted on any container registry.

## Supported Features

### JetBrains IDE Installer

### What it does?

The jetbrains-ide feature is a Dev Container Feature that installs a JetBrains IDE and plugins.

### How it works?

To use this feature, you can add the following configuration to your devcontainer.json file:

```json
{
    "image": "mcr.microsoft.com/vscode/devcontainers/base:ubuntu-20.04",
    "features": {
        "ghcr.io/ozee-devcontainer-features/jetbrains-ide:1.0.0": {
            "app": "IntelliJCommunity",
            "version": "2021.2",
            "plugins": [
                "org.intellij.scala",
                "com.jetbrains.plugins.yaml",
                "org.jetbrains.kotlin"
            ]
        }
    }
}
```

In this example, we're using the ghcr.io/ozee-devcontainer-features/jetbrains-ide:1.0.0 image to install the IntelliJ Community Edition IDE, version 2021.2. We're also installing three plugins: the Scala plugin, the YAML plugin, and the Kotlin plugin.

Once you've added this configuration to your devcontainer.json file, you can rebuild your dev container and the JetBrains IDE and plugins will be installed automatically.

### Why you would use it?

By pre-installing the JetBrains IDE and any server-side plugins that are needed ahead of time in a Github Codespace, you increase the time to launch for new codespaces, as well as reducing variability between developers sharing codespace configs. This can help you get up and running quickly and ensure that your development environment is consistent across different machines and environments. Additionally, using Dev Container Features can help you avoid conflicts between different versions of software and ensure that your development environment is always up-to-date.

## License

The Ozee Dev Container Features repository is licensed under the MIT License.
