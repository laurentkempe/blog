---
title: '.NET Aspire and Dev Container'
permalink: /2025/03/05/dotnet-aspire-and-dev-container/
date: 3/5/2025 1:36:19 PM
disqusIdentifier: 20250305013619
coverSize: partial
tags: [.NET Aspire, Dev Container, Docker]
coverCaption: 'LO Ferré, Petite Anse, Martinique, France'
coverImage: 'https://c7.staticflickr.com/9/8689/16775792438_e45283970c_h.jpg'
thumbnailImage: 'https://c7.staticflickr.com/9/8689/16775792438_8366ee5732_q.jpg'
---
.NET Aspire 9.1 was just released on February 25th, 2025. It comes with great new dashboard features, and there is more! One feature, I am particularly interested in is the ability to use Dev Containers.

In this post, I will show you how to use the new .NET Aspire 9.1 with a Dev Container.
<!-- more -->

# Introduction

First, what are Dev Containers? Dev Containers are a way to **define a fully functional development environment in a container**. This allows you to have a **consistent development environment across your team**. It also allows you to have a development environment that is **isolated from your host machine**. It also means that you can host your development environment somewhere else, like in the cloud, and access it from anywhere.

# Prerequisites

To follow this post, you need to have the following installed on your machine:

* [Docker Desktop](https://www.docker.com/products/docker-desktop)

Then you can one of the following IDEs:

* [Visual Studio Code](https://code.visualstudio.com/)
* [Rider](https://www.jetbrains.com/rider/) or [Gateway](https://www.jetbrains.com/remote-development/gateway/)

Note that you don't need to have .NET or .NET Aspire 9.1 installed on your machine as this will be provided by the Dev Container 🤯

{% alert info %}
Rider Is Now Free for Non-Commercial Use! See the References section for more information.
{% endalert %}

# Getting Started

Dev containers are defined using a `devcontainer.json` file. This file defines the development container and is placed in a `.devcontainer` folder in your project. The `devcontainer.json` file can define the following:

```json .devcontainer/devcontainer.json
{
    "name": ".NET Aspire",
    // 👇🏼 Use .NET 9 Debian image
    "image": "mcr.microsoft.com/devcontainers/dotnet:9.0-bookworm",
    "features": {
        "ghcr.io/devcontainers/features/docker-in-docker:2": {},
        "ghcr.io/devcontainers/features/powershell:1": {},
    },

    "hostRequirements": {
        "cpus": 8,
        "memory": "32gb",
        "storage": "64gb"
    },

    // 👇🏼 Install .NET Aspire project templates, run inside the container 
    // immediately after it has started for the first time
	"onCreateCommand": "dotnet new install Aspire.ProjectTemplates::9.1.0 --force",
    // 👇🏼 Restore nugets, when the container is created
	"postCreateCommand": "dotnet restore",
    // 👇🏼 Trusting the development certificates, run each time the
    // container is successfully started
    "postStartCommand": "dotnet dev-certs https --trust",
    "customizations": {
    "vscode": {
            "extensions": [
                "ms-dotnettools.csdevkit",
                "GitHub.copilot-chat",
                "GitHub.copilot"
            ]
        }
    }
}
```

The `features` section defines the features that are installed in the container. In this case, we are installing Docker in Docker and PowerShell.

The `hostRequirements` section defines the requirements for the host machine. 

The `onCreateCommand` section defines the command that is run inside the container immediately after it has started for the first time. In this case, we are installing the .NET Aspire project templates.

The `postCreateCommand` section defines the command that is run once when the container is created. It executes in the container after `onCreateCommand`. In this case, we are running `dotnet restore`.

The `postStartCommand` section defines the command that is run each time the container starts. In this case, we are trusting the development certificates. 

Finally, the `customizations` section defines the customizations that are applied to the container. In this case, we are installing the C# extension for Visual Studio Code, and the GitHub Copilot extensions.

# Using the Dev Container in Rider or Gateway

Start Rider or JetBrains Gateway, select Remote Development / Dev Containers, then click on **New Dev Container** and open your project. 

![JetBrains Rider New Dev Container](/images/2025/dotnet-aspire_jetbrains-rider-new-devcontainer.png)

Select **From Local Project** then **Rider** and the path of your devcontainer.json file and click on the **Build Container and Continue** button.

![JetBrains Gateway New Dev Container from local project](/images/2025/dotnet-aspire_jetbrains-rider-dev-containers.png)

Your container will be built

![JetBrains Gateway Dev Container building](/images/2025/dotnet-aspire_jetbrains-rider-building-container.png)

and you will be connected to it. You can now start developing in your container.

![JetBrains Gateway Dev Container connected](/images/2025/dotnet-aspire_jetbrains-rider-connected-container.png)

{% alert warning %}
We used the **From Local Project** option to create the Dev Container. We are using it for testing. When you are all set, you will prefer from **VCS Project** for performance reasons. In that case the source code would be cloned in the container and not mounted from the host.
{% endalert %}

# Using the Dev Container in Visual Studio Code

To use the Dev Container, you need to open your project in Visual Studio Code or Rider. Then you need to open the Command Palette and run the `Remote-Containers: Reopen in Container` command. This will open your project in the Dev Container.

Continue with text displayed on the blog page
![alt image](https://live.staticflickr.com/65535/49566323082_e1817988c2_c.jpg)
{% alert info %}
{% endalert %}
{% codeblock GreeterService.cs lang:csharp %}
{% endcodeblock %}

# Conclusion

In this post, I showed you how to use the new .NET Aspire 9.1 with a Dev Container. This allows you to have a consistent development environment across your team and have a development environment that is isolated from your host machine. It also means that you can host your development environment somewhere else, like in the cloud, and access it from anywhere.

# References

* [Development Containers](https://containers.dev/)
* [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers)
* [Dev Container overview](https://www.jetbrains.com/help/rider/Connect_to_DevContainer.html)
* [Big News for .NET and Game Devs: Rider Is Now Free for Non-Commercial Use](https://blog.jetbrains.com/dotnet/2024/10/16/rider-reveal-livestream-big-news-for-dotnet-and-game-devs/)
* [dotnet/aspire-devcontainer](https://github.com/dotnet/aspire-devcontainer)
* [Available Dev Container Features](https://containers.dev/features)
* [Dev Container Lifecycle scripts](https://containers.dev/implementors/json_reference/#lifecycle-scripts)
* [.NET Development Container Images](https://mcr.microsoft.com/en-us/artifact/mar/devcontainers/dotnet/about)

<p></p>
{% githubCard user:laurentkempe repo:aspirePlayground align:left %}
