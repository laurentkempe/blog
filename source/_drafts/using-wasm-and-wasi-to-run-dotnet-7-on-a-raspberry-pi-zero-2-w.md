---
title: 'Using WASM and WASI to run .NET 7 on a Raspberry PI Zero 2 W'
permalink: /2022/10/21/using-wasm-and-wasi-to-run-dotnet-7-on-a-raspberry-pi-zero-2-w/
date: 10/21/2022 5:26:38 AM
disqusIdentifier: 20221021052638
coverSize: partial
tags: [Wasm, Wasi, ASP.NET Core, Raspberry Pi]
coverCaption: 'Lomont, Haute-Saône, Franche-Comté, France'
coverImage: 'https://live.staticflickr.com/65535/46849237405_c2d528b3a9_h.jpg'
thumbnailImage: 'https://live.staticflickr.com/65535/46849237405_9522c01139_q.jpg'
---
WebAssembly (WASM) and WebAssembly System Interface (WASI) are opening new opportunities for developers. .NET developers became familiar with WASM when Blazor WebAssembly was released. Blazor WebAssembly run client-side in the browser on a WebAssembly-based .NET runtime. WASI is bringing WASM out of the browser world by providing a system interface to run WebAssembly outside the web. It is a standard for how WASM modules can interact with the host environment. In this post, I will show you how to run .NET 7 on a Raspberry PI Zero 2 W using WASM and WASI.  
<!-- more -->

## What is WASM?

WebAssembly (WASM) is a **binary instruction format** for a stack-based **virtual machine**. WASM is designed as a **portable compilation target** for programming languages. It is a low-level assembly-like language with a compact binary format that runs with **near-native performance** and provides languages such as C#, C/C++, Rust... with a compilation target that can run in browsers and other environments.

## What is WASI?

WebAssembly System Interface (WASI) is a **standard** for how WASM modules can **interact with the host environment**. WASI is a specification for a system interface for WebAssembly. It is a set of APIs that a WebAssembly module can call to access the host environment.
As WASI is about running securely WASM outside the browser, it cannot leverage the runtime embedded in our modern web browsers. It needs another runtime. This is why runtimes like [Wasmtime](https://wasmtime.dev/) or [Wasmer](https://wasmer.io/) exists. Wasmtime is a standalone JIT-style runtime for WebAssembly. It is designed to be run as a standalone command-line utility, embedded into other applications, or used to run WebAssembly modules within larger runtimes.

## .NET 7 WASI SDK

[Steve Sanderson](https://twitter.com/stevensanderson) is known as the creator of ASP.NET Core Blazor WebAssembly and opened the GitHub repository [SteveSandersonMS / dotnet-wasi-sdk](https://github.com/SteveSandersonMS/dotnet-wasi-sdk) some months ago. The "Experimental WASI SDK for .NET Core" was born. A couple of weeks ago the experiment was moved to [dotnet / dotnet-wasi-sdk](https://github.com/dotnet/dotnet-wasi-sdk) which might give us an hint that the experiment is ready to get to the next step. I am convinced that we will hear about this during the [.NET Conf 2022](https://www.dotnetconf.net/).

## Creating a .NET WASI project

The goal is to build a .NET 7 Web Api using WASI SDK for .NET and to run it on a Raspberry PI Zero 2 W using Wasmtime. I won't repeat the instructions about creating such a project as you can find them on [How to use: ASP.NET Core applications](https://github.com/dotnet/dotnet-wasi-sdk#how-to-use-aspnet-core-applications). The only difference is that I am using ASP.NET Core Web API project template and not web.

```powershell
dotnet new webapi -o WasiWebApi
```

## Uploading the project to the Raspberry PI Zero 2 W

Today, Windows supports ssh and scp out of the box. It super easy to copy our application from our PC to the Raspberry PI Zero 2 W.

## Installing Wasmtime on the Raspberry PI Zero 2 W


## Running the .NET WASI project

The project is ready to be run. 

The following command will run the project using Wasmtime.

```powershell
```

Continue with text displayed on the blog page
![alt image](https://live.staticflickr.com/65535/49566323082_e1817988c2_c.jpg)
{% alert info %}
{% endalert %}
{% codeblock GreeterService.cs lang:csharp %}
{% endcodeblock %}
# Conclusion
TODO
<p></p>
{% githubCard user:laurentkempe repo:dotfiles align:left %}

# References

* [WASM](https://webassembly.org/)
* [Blazor WebAssembly](https://learn.microsoft.com/en-us/aspnet/core/blazor/hosting-models?view=aspnetcore-6.0#blazor-webassembly)
* [WASI](https://wasi.dev/)
* [Standardizing WASI: A system interface to run WebAssembly outside the web](https://hacks.mozilla.org/2019/03/standardizing-wasi-a-webassembly-system-interface/)
* [Wasmtime](https://wasmtime.dev/)
* [Wasmer](https://wasmer.io/)
* [Raspberry PI Zero 2 W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/)
