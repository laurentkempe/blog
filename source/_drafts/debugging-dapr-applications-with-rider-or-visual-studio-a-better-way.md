---
title: 'Debugging Dapr applications with Rider or Visual Studio: A better way'
permalink: /2023/02/18/debugging-dapr-applications-with-rider-or-visual-studio-a-better-way/
date: 2/18/2023 5:26:38 PM
disqusIdentifier: 20230218052638
coverSize: partial
tags: [.NET, Dapr, Rider, VisualStudio]
coverCaption: 'Tahiti, Polynésie, France, Moʻorea island in the back'
coverImage: 'https://live.staticflickr.com/4662/25053526657_0240dbf766_h.jpg'
thumbnailImage: 'https://live.staticflickr.com/4662/25053526657_b5a7c23594_q.jpg'
---
Dapr is a great set of APIs for building distributed applications with any language and platform. It provides a set of building blocks that you can use to build microservices. Dapr is based on sidecar architecture. It means that you need to run a Dapr sidecar for each of your application. How do you debug your Dapr apps effectively? If you have been using PowerShell scripts to run and attach your debugger, you know how tedious and error-prone it can be. In this post, I will show you how to use Rider or Visual Studio to debug your Dapr apps with ease and confidence. You might read my previous post about [Dapr and .NET](https://laurentkempe.com/tags/Dapr/).
<!-- more -->

# Running Dapr application

To run the Dapr application, you need to use the Dapr cli, define some parameters like the application name and port, where are located the definition of the Dapr components and the command line to run your application. It look something like this for a .NET application.

```powershell
dapr run --app-id dapr-service --resources-path ../../dapr/components/ --app-port 5190 -- dotnet run --project .
```

How can you debug your application? It is the Dapr sidecar that is starting your application. You need to attach the debugger to your application not to the Dapr sidecar. You can do that by using the IDE `Attach to process` feature. This is not really convenient, but it works.

# Debugging Dapr application a better way

Another way is to leverage `Debugger.Launch()` and nest it in a `#if DEBUG` C# preprocessor directive. This way, the code is compiled only when you are in debug mode. Place, those three lines in your application entry point, for example in the `Program.cs` file.

```csharp
#if DEBUG
Debugger.Launch();
#endif
```

`Debugger.Launch()` as it names implies, will launch and attach a debugger to the process.

## Solution for Rider and Visual Studio

In Rider and Visual Studio, you can leverage the `launchSettings.json` and add one entry to its `profiles` to run the Dapr cli command and your application.

```json
    "dapr": {
      "commandName": "Executable",
      "workingDirectory": "$(ProjectDir)",
      "executablePath": "dapr.exe",
      "commandLineArgs": "run --app-id dapr-service --resources-path ../dapr/components/ --app-port 5190 -- dotnet run --project ."
    }
```

In there, it is nice to note that we can use MSBuild properties like `$(ProjectDir)` to define the project path as the working directory. 

The good thing of that approach is that this can be shared in a team through the source control system. You can also use the `launchSettings.json` to run your application without Dapr with another profile.

```json
    "http": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "http://localhost:5190",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
```

Now you can run your application with Dapr or without Dapr using the IDE Run/Debug configuration.

## Debugging configuration for Rider

We need to set Rider as the default debugger. We can do that by going to _Settings_ and then _Build, Execution, Deployment_ and then _Debugger_. In the dialog click on _Set Rider as the default debugger_ and follow the instructions.

![Set Rider As Default Debugger](/images/SetRiderAsDefaultDebugger.png)

Now, we can select the run/debug configuration **Service: dapr** and either Run (CTRL+F5) or Debug (F5).

![RiderRunDebugConfiguration.png](/images/RiderRunDebugConfiguration.png)

Or use Rider Run Anything by pressing two times CTRL and typing `dapr` to select the run/debug configuration.

![Rider Run Anything](/images/RiderRunAnything.png)

The Dapr side car starts and it starts your application and the Rider _Just-ln-Time Debugger_ dialog popups. Select your project and tick _Remember executable in solution_. This creates a new run configuration in the selected solution with the target executable. If there will be an opened solution with such run configuration, this solution will be chosen automatically. Meaning that from the second time you start with the Dapr profile you won't even see the Rider _Just-ln-Time Debugger_ dialog.

![Rider Just In Time Debugger](/images/RiderJITDebuggerLauncher64.png)

After that, click the Select _Button_, the debugger will be attached to the process and will break on the line `Debugger.Launch()` and you can happily debug your application 😃.

![Debugger Launch Hit](/images/DebuggerLaunchHit.png)

On the next debugging session the _Just-ln-Time Debugger_ dialog will not popup anymore and you will be able to debug your application directly.

All outputs done by the Dapr side car and your application are displayed in the Rider Debug Output window if started in Debug or into the Rider Run Console if started without Debug. That super nice because there is need to swicth between windows to see the outputs.

## Debugging configuration for Visual Studio

{% alert warning %}
At this point, if you set Rider as the default debugger, you need to reset first that settings from Rider settings dialog.
{% endalert %}

In Visual Studio, you can select the _Launch profile_ **dapr** and **must use Run (CTRL+F5)**. 

![VSRunConfiguration.png](/images/VSRunConfiguration.png)

A command window will open followed by the Visual Studio _Choose Just-ln-Time Debugger_ dialog. Select your project from the _Available Debuggers_. 

![vsjitdebugger.png](/images/vsjitdebugger.png)

You will hit then also the `Debugger.Launch()` breakpoint and you can debug your application.

![Visual Studio Debugger Launch Hit](/images/VSDebuggerLaunchHit.png)

There are two drawbacks with Visual Studio
1. The _Choose Just-ln-Time Debugger_ dialog will open everytime and you need to select the project each time.
2. A shell window will open on your desktop.

## Alternative solution for Rider

In Rider, you can create a _Shell Script_ Run/Debug configuration. 

![Rider Run/Debug Configuration Shell](/images/RiderRunDebugConfigurationShell.png)

We use _Script text_ specifying the Dapr cli command to run the application. We set the _Working directory_ to the directory where our service is located. And we define the Run/Debug _Name_ as **dapr**. Finally, we tick _Store as project file_ to share this run configuration with other developers.

![Rider Dapr ScriptText](/images/RiderDaprScriptText.png)

We can select the `dapr` Run/Debug configuration and start it and the Dapr side car will start and the application will start. Then debugger will be attached to the process and we can debug our application 😀.

# Conclusion

In this post, we have seen how to debug a Dapr application. We have seen that we can use `Debugger.Launch()` and nest it in a `#if DEBUG` C# preprocessor directive. We have seen that we can use the `launchSettings.json` to run our application with Dapr or without Dapr. We have seen how to configure Rider and Visual Studio to debug our application with Dapr.

# Code

The code for this post is available on my project [daprPlayground / EaseDaprDebugging ](https://github.com/laurentkempe/daprPlayground/tree/master/EaseDaprDebugging).

<p></p>
{% githubCard user:laurentkempe repo:daprPlayground align:left %}

# Reference

* [Dapr.io](https://dapr.io/)
* [Debugger.Launch Method](https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.debugger.launch?view=net-7.0)
* [My blog post series about Dapr](https://laurentkempe.com/tags/Dapr/)
