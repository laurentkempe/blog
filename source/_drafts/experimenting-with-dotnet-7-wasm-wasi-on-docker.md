---
title: 'Experimenting with .NET 7, WASM and WASI on Docker'
permalink: /2022/10/29/experimenting-with-dotnet-7-wasm-wasi-on-docker/
date: 10/29/2022 11:44:46 AM
disqusIdentifier: 20221029114446
coverSize: partial
tags: [WASM, WASI, Docker, .NET]
coverCaption: 'LO Ferré, Petite Anse, Martinique, France'
coverImage: 'https://c7.staticflickr.com/9/8689/16775792438_e45283970c_h.jpg'
thumbnailImage: 'https://c7.staticflickr.com/9/8689/16775792438_8366ee5732_q.jpg'
---
On October 24th, Docker announced the support of WASM and WASI in a new technical preview release. I wanted to try it out and see how it works with .NET 7. If you want to know more about WASM and WASI you can read the introduction from my previous post, "[Using WASM and WASI to run .NET 7 on a Raspberry PI Zero 2 W](https://laurentkempe.com/2022/10/29/using-wasm-and-wasi-to-run-dotnet-7-on-a-raspberry-pi-zero-2-w/)".
<!-- more -->

A couple of weeks ago my friend [Julien Chable](https://twitter.com/JChable) asked me about the interest of WASM/WASI and Wasmtime. As he is a .NET developer, I explained that Wasmtime is the equivalent of the .NET CLR except that it is a sandbox environment therefore secure, which starts in a few milliseconds therefore faster than containers, which allows you to write code with many languages and to deploy this code on many platforms without recompiling and above all to write modules in one language and use them from another.

I also told him that you often read that WASI will replace containers. It might be true for some situations but not for all. I think that they will complement each other. Containers are great for running applications, but to run code something better could be built. For example, if you want to run a function that calculates the sum of two numbers, you will have to create a container with an application that will call this function. With WASM/WASI, you can create a module that will contain this function and call it from any language.

# Why Docker announcing WASM/WASI support is interesting?

Docker makes developers life easy to bundle and run their applications. 

Their approach toward WASM/WASI support is to leverage containerd providing the ability to use OCI-compatible artifacts and **containerd shims**. In our case, the interesting part is the conteinerd shim created in collaboration with WasmEdge. 

> This shim extracts the Wasm module from the OCI artifact and runs it using the WasmEdge runtime. We added support to declare the Wasm runtime, which will enable the use of this new shim.

![Docker support for WASM and WASI](/images/docker-containerd-wasm-diagram.png.webp)

So, as a developer you can use the **same Dockerfile to build** your WASM module. You can also use the **same Docker commands** to run your WASM module. But there is more as we will see later.

You can read more about it on their blog post "[Introducing the Docker+Wasm Technical Preview](https://www.docker.com/blog/docker-wasm-technical-preview/)".

# Docker technical preview

To run this experiment you will need to install a Docker technical preview release. You can find the instructions on the [Docker+Wasm (Beta)](https://docs.docker.com/desktop/wasm/).

# Building a .NET 7 Console WASM module

Beware, this is a technical preview and things might change in the future. It is also very early for all the different parts used, and mostly a hack to try the different parts together.

I started to experiment with a .NET 7 Web API, but I failed to make it work, so I switched to a .NET 7 Console application.

```powershell
dotnet new console -o ConsoleWasmDocker
cd ConsoleWasmDocker
dotnet add package Wasi.Sdk --prerelease
dotnet build
```

We end up with `ConsoleWasmDocker.wasm` in the folder `\bin\Debug\net7.0\`. We can run it with Wasmtime.

```powershell
wasmtime .\bin\Debug\net7.0\ConsoleWasmDocker.wasm
```

# Bundling our .NET 7 Console WASM module with Docker

At first, I tried to use the multi-stage build approach with the Docker image `mcr.microsoft.com/dotnet/sdk:7.0` to build the WASM module. But it failed with a weird error.

So, we will use a workaround to publish the WASM module from Windows and then just copying the ConsoleWasmDocker.wasm in the Docker image

```powershell
dotnet publish -c Release 
```

We define the Dockerfile.

```dockerfile
FROM scratch
COPY ./bin/Release/net7.0/ConsoleWasmDocker.wasm /ConsoleWasmDocker.wasm
ENTRYPOINT [ "ConsoleWasmDocker.wasm" ]
```

Here we see another advantage. We can use the `scratch` image as a base image. This is a special image that is empty. It is used to create a minimal Docker image. It is also used to create a container that will run a single process. In our case, we will run our WASM module.

We build the Docker image.

```powershell
docker buildx build --platform wasi/wasm32 -t consolewasmdocker .
```

Now the good surprise is the size of the docker image **3.63MB**.

```powershell
docker image list
REPOSITORY          TAG       IMAGE ID       CREATED         SIZE
consolewasmdocker   latest    a1d9e476ae28   7 seconds ago   3.63MB
```

# Running our .NET 7 Console WASM module with Docker

We can run our WASM module with Docker, with an extended command.

```powershell
docker run --rm --name=consolewasmdocker --runtime=io.containerd.wasmedge.v1 --platform=wasi/wasm32 consolewasmdocker
```

and the output

![Docker run output](/images/ConsoleWasmDocker.png)

# Conclusion

This is still very early and rough on the edges. Nevertheless, it is a good start and let us envision the great potential that those technologies will bring. I am looking forward to see how this evolves.

The annoucement of Docker+Wasm Technical Preview was done on October 24th, 2022. Exactly the same day, Fermyon announced "[Fermyon Cloud](https://www.fermyon.com/blog/introducing-fermyon-cloud)". Almost a year before,  Microsoft announced "[Public preview: AKS support for WebAssembly System Interface (WASI) workloads](https://azure.microsoft.com/en-us/updates/public-preview-aks-support-for-webassembly-system-interface-wasi-workloads/?WT.mc_id=DT-MVP-7749)".

This field is very active and I hope to see more announcements related to WASM/WASI in the .NET ecosystem during the [.NET Conf 2022](https://www.dotnetconf.net/).

# Code
<p></p>
{% githubCard user:laurentkempe repo:ConsoleWasmDocker align:left %}

# Presentation

Build, Share, Run WebAssembly Apps Using the Docker Toolchain - Chris Crone & Michael Yuan

> WebAssembly has emerged as a secure, portable, lightweight, and high performance runtime sandbox for certain types of workloads that make up cloud native apps. Chris and Michael will show how familiar Docker commands can be used to develop and share Wasm applications. Today, developers need to learn new & complicated tooling for Wasm apps. By having Docker manage the Wasm runtime, existing container tooling that Cloud Native developers are familiar with can be used, and the dev ex is fast & efficient. Docker can use WasmEdge as a security sandbox, side by side with Linux containers on the same dev machine or in a deployment cluster. They will cover how to **create WebAssembly OCI images using buildx**, how to publish the annotated image to Docker Hub, and how the enhanced Docker engine can distinguish the image and **automatically run it with WasmEdge**. They will demonstrate a complete demo of creating and running a Wasm-based microservice application using these Docker tools. We see this as a first step towards making Wasm as easy a target for developers as their existing platforms.

<p></p>
{% youtube 3j915xoDovs %}

# References

* [Introducing the Docker+Wasm Technical Preview](https://www.docker.com/blog/docker-wasm-technical-preview/)
* [Docker+Wasm (Beta)](https://docs.docker.com/desktop/wasm/)
* [Build, Share, Run WebAssembly Apps Using the Docker Toolchain - Chris Crone & Michael Yuan](https://www.youtube.com/watch?v=3j915xoDovs&ab_channel=CNCF%5BCloudNativeComputingFoundation%5D)
* [WasmEdge](https://wasmedge.org/)
* [Introducing Fermyon Cloud](https://www.fermyon.com/blog/introducing-fermyon-cloud)
* [Create WebAssembly System Interface (WASI) node pools in Azure Kubernetes Service (AKS) to run your WebAssembly (WASM) workload (preview)](https://learn.microsoft.com/en-us/azure/aks/use-wasi-node-pools?WT.mc_id=DT-MVP-7749)
