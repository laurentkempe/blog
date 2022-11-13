---
title: '.NET 7 SDK built-in container support and Ubuntu Chiseled'
permalink: /2022/11/09/dotnet-7-sdk-built-in-container-support-and-ubuntu-chiseled/
date: 11/9/2022 9:41:12 PM
disqusIdentifier: 20221109094112
coverSize: partial
tags: [ASP.NET Core, Docker, Ubuntu, .NET SDK]
coverCaption: 'Moʻorea, Polynésie, France'
coverImage: 'https://live.staticflickr.com/4401/36848984906_a51b695ef2_h.jpg'
thumbnailImage: 'https://live.staticflickr.com/4401/36848984906_f7a10e1aca_q.jpg'
---
End of this summer 2022 the .NET team at Microsoft announced two things related to containers: .NET in Chiseled Ubuntu containers and then a week later built-in container support in the .NET 7 SDK. I have talked about both topics on two episodes of the French podcast [devdevdev.net](https://devdevdev.net/) of my friend [Richard Clark](https://twitter.com/c2iClark). In this post I will explain what these two things are and how they can be combined to help you.
<!-- more -->

# .NET in Chiseled Ubuntu containers

.NET in Chiseled Ubuntu containers are new **small** and **secure containers** offering from Canonical which is **100MB smaller** then the Ubuntu image.

Why does it improve the security? Because small reduce the attack surface. It is based on images with only the packages required to run the container; no package manager, no shell and non-root user.   

The idea originate from distroless concept introduced in 2017 by Google. On top of that it brings the following features: polished tools and trusted packages from platform providers, choice of free or paid support, choice of fast-moving releases or LTS, possibility to customise the images.

![Standard vs Chiseled .NET Images](/images/standardvsChiseledDotNETimages.png)

To take advantage of those new images, in .NET 6 and 7 for Arm64 and x64, you need to use one of the three layers of Chiseled Ubuntu container images 

* mcr.microsoft.com/dotnet/nightly/runtime-deps:6.0-jammy-chiseled 
* mcr.microsoft.com/dotnet/nightly/runtime:6.0-jammy-chiseled 
* mcr.microsoft.com/dotnet/nightly/aspnet:6.0-jammy-chiseled

{% alert info %}
Today, this is still in preview, this is why images are served from the nightly repository. The final images will be available before end of this year.
{% endalert %}

# Built-in container support in the .NET 7 SDK

For long time, you could use Dockerfile to bundle your .NET application in a container. You had to create a Dockerfile, install the .NET SDK, restore the packages, build the application, copy the output in the container. It implied quite some steps and it was not easy to do it right.

Today, .NET 7 SDK supports **container images** as a new output type through a simple **dotnet publish**. This was already the case on other platform Ko for Go, Jib for Java, and even in .NET with projects like konet.

This requires only to add on nuget package reference to the project file:

```xml
<PackageReference Include="Microsoft.NET.Build.Containers" Version="0.2.7"/>
```

{% alert info %}
In the future, you will not even need to add this nuget package reference, as it will be part of the SDK.
{% endalert %}

{% alert info %}
Currently, only Linux containers are supported.
{% endalert %}

Then you can run the following command:

```powershell
 ❯  dotnet publish --os linux --arch x64 -p:PublishProfile=DefaultContainer -c Release
MSBuild version 17.4.0+18d5aef85 for .NET
  Determining projects to restore...
  All projects are up-to-date for restore.
  WebApp -> C:\Users\laure\projects\dotnet\7rtm\ParsableStatic\WebApp\bin\Release\net7.0\linux-x64\WebApp.dll
  WebApp -> C:\Users\laure\projects\dotnet\7rtm\ParsableStatic\WebApp\bin\Release\net7.0\linux-x64\publish\
  'WebApp' was not a valid container image name, it was normalized to webapp
  Building image 'webapp' with tags 1.0.0 on top of base image mcr.microsoft.com/dotnet/aspnet:7.0
  Pushed container 'webapp:1.0.0' to Docker daemon
```

The image created is **216MB**

```powershell
 ❯  docker image list
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
webapp       1.0.0     e2d2de6a8878   4 seconds ago   216MB
 ```

You can control many of the properties of the image that is created like the image name and tags through MSBuild properties. See, [Configure container image](https://learn.microsoft.com/en-us/dotnet/core/docker/publish-as-container#configure-container-image).

```xml
    <PropertyGroup>
        <ContainerImageName>dotnet-webapp-image</ContainerImageName>
        <ContainerImageTag>1.1.0</ContainerImageTag>
    </PropertyGroup>
```

After dotnet publish, the image with the new name and version is created

```powershell
 ❯  docker image list
REPOSITORY            TAG       IMAGE ID       CREATED          SIZE
dotnet-webapp-image   1.1.0     d63f313397aa   2 seconds ago    216MB
webapp                1.0.0     e2d2de6a8878   50 seconds ago   216MB
```

# Can we combine the two?

Sure, we can combine the two and create a .NET application in a Chiseled Ubuntu container using the .NET SDK. This is a great way to create a small and secure container for your .NET application.

We need to add MSBuild property **ContainerBaseImage** to our csproj file to specify the Chiseled Ubuntu base image to use, in this case **aspnet:7.0-jammy-chiseled**.

```xml
    <PropertyGroup>
        <ContainerImageName>dotnet-webapp-chiseled</ContainerImageName>
        <ContainerImageTag>1.1.0</ContainerImageTag>
        <ContainerBaseImage>mcr.microsoft.com/dotnet/nightly/aspnet:7.0-jammy-chiseled</ContainerBaseImage>
    </PropertyGroup>

    <ItemGroup>
        <PackageReference Include="Microsoft.NET.Build.Containers" Version="0.2.7"/>
    </ItemGroup>
```

This time the image is **112MB** compared to the 216MB, we **won 104MB** and all other advantages coming from the Chiseled Ubuntu container.

```powershell
 ❯  dotnet publish --os linux --arch x64 -p:PublishProfile=DefaultContainer -c Release
 ...
 ❯  docker image list
REPOSITORY               TAG       IMAGE ID       CREATED              SIZE
dotnet-webapp-chiseled   1.1.0     a0456f5d4b27   4 seconds ago        112MB
dotnet-webapp-image      1.1.0     d63f313397aa   About a minute ago   216MB
webapp                   1.0.0     e2d2de6a8878   2 minutes ago        216MB
```

# Can we do better?

Yes, we can 😉 mixing chiseling and trimming. 

We can use the base image **runtime-deps:6.0-jammy-chiseled** which is 13MB and publish our ASP.NET application as a self-contained and trimmed application.

```xml
    <PropertyGroup>
        <ContainerImageName>dotnet-webapp-chiseled-trimmed</ContainerImageName>
        <ContainerImageTag>1.1.0</ContainerImageTag>
        <ContainerBaseImage>mcr.microsoft.com/dotnet/nightly/runtime-deps:6.0-jammy-chiseled</ContainerBaseImage>
        <PublishTrimmed>true</PublishTrimmed>
    </PropertyGroup>

    <ItemGroup>
        <PackageReference Include="Microsoft.NET.Build.Containers" Version="0.2.7"/>
    </ItemGroup>
```

We need to add **--self-contained** to the dotnet publish command. Now, the image is **56.5MB** compared to the 112MB, we won 55.5MB.

```powershell
 ❯  dotnet publish --os linux --arch x64 -p:PublishProfile=DefaultContainer -c Release --self-contained
 ...
   Optimizing assemblies for size. This process might take a while.
 ...
 ❯  docker image list
REPOSITORY                       TAG       IMAGE ID       CREATED          SIZE
dotnet-webapp-chiseled-trimmed   1.1.0     f1ba30048ef8   11 seconds ago   56.5MB
dotnet-webapp-chiseled           1.1.0     a0456f5d4b27   2 minutes ago    112MB
dotnet-webapp-image              1.1.0     d63f313397aa   4 minutes ago    216MB
webapp                           1.0.0     e2d2de6a8878   5 minutes ago    216MB
```

# Can we do even better?

Yes, we can by publishing to a single file

```xml
    <PropertyGroup>
        <ContainerImageName>dotnet-webapp-chiseled-trimmed-singlefile</ContainerImageName>
        <ContainerImageTag>1.1.0</ContainerImageTag>
        <ContainerBaseImage>mcr.microsoft.com/dotnet/nightly/runtime-deps:6.0-jammy-chiseled</ContainerBaseImage>
        <PublishTrimmed>true</PublishTrimmed>
    </PropertyGroup>
```

We need to add **-p:PublishSingleFile=true** to the dotnet publish command. Now, the image is **48.4MB** compared to the 56.5MB, we won 8.1MB.

```powershell
 ❯  dotnet publish --os linux --arch x64 -p:PublishProfile=DefaultContainer -c Release --self-contained true -p:PublishSingleFile=true
...
 ❯  docker image list
REPOSITORY                                  TAG       IMAGE ID       CREATED          SIZE
dotnet-webapp-chiseled-trimmed-singlefile   1.1.0     2643c10fa1d9   56 seconds ago   48.4MB
dotnet-webapp-chiseled-trimmed              1.1.0     f1ba30048ef8   11 seconds ago   56.5MB
dotnet-webapp-chiseled                      1.1.0     a369967b535a   15 minutes ago   112MB
dotnet-webapp-image                         1.1.0     d63f313397aa   31 minutes ago   216MB
webapp                                      1.0.0     e2d2de6a8878   32 minutes ago   216MB
```

# A tiny bit better?

If you don't need globalization in your application, you can turn the [globalization invariant mode on](https://github.com/dotnet/runtime/blob/main/docs/design/features/globalization-invariant-mode.md
).

```xml
    <PropertyGroup>
        <ContainerImageName>dotnet-webapp-chiseled-trimmed-singlefile-invariant</ContainerImageName>
        <ContainerImageTag>1.1.0</ContainerImageTag>
        <ContainerBaseImage>mcr.microsoft.com/dotnet/nightly/runtime-deps:6.0-jammy-chiseled</ContainerBaseImage>
        <InvariantGlobalization>true</InvariantGlobalization>
        <PublishTrimmed>true</PublishTrimmed>
    </PropertyGroup>
```

Finally, the image is **48.3MB** compared to the 48.4MB, we won 0.1MB.

```powershell
 ❯  dotnet publish --os linux --arch x64 -p:PublishProfile=DefaultContainer -c Release --self-contained true -p:PublishSingleFile=true
 ...
 ❯  docker image list
REPOSITORY                                            TAG       IMAGE ID       CREATED          SIZE
dotnet-webapp-chiseled-trimmed-singlefile-invariant   1.1.0     fd7c4aca6501   19 seconds ago   48.3MB
dotnet-webapp-chiseled-trimmed-singlefile             1.1.0     2643c10fa1d9   8 minutes ago    48.4MB
dotnet-webapp-chiseled-trimmed                        1.1.0     df989eda0f7f   13 minutes ago   48.4MB
dotnet-webapp-chiseled                                1.1.0     a369967b535a   22 minutes ago   112MB
dotnet-webapp-image                                   1.1.0     d63f313397aa   38 minutes ago   216MB
webapp                                                1.0.0     e2d2de6a8878   39 minutes ago   216MB
```

I expected better results with this last step. I guess is the best we can do, because the ICU package is still part of runtime-deps:6.0-jammy-chiseled, or? Till maybe Microsoft and Canonical publish a new base image with the ICU package removed.

# Run

```powershell
 ❯  docker run --rm -it -p 8080:80  dotnet-webapp-chiseled-trimmed-singlefile-invariant:1.1.0
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: /app
```

Then you can browse to http://localhost:8080/weatherforecast to see 

![dotnet-webapp-chiseled-trimmed-singlefile-invariant running](/images/dotnet-webapp-chiseled-trimmed-singlefile-invariant.png)

# Conclusion

Now that .NET 7 RTM shipped we can leverage those new capabilities. It let us create small and secure containers for our .NET applications super easily. We went from a first docker image of **216MB** to a final docker image of **48.3MB**. That's a **77.8% reduction in size**. I hope you enjoyed this post and learned something new that you will try out. If you have any questions or comments, please leave them below. Thanks for reading! 

# Code

<p></p>
{% githubCard user:laurentkempe repo:ChiseledDocker align:left %}

# Presentation

TODO ADD dotnet conf video

<p></p>
{% youtube 3j915xoDovs %}

# References

* [.NET in Chiseled Ubuntu Containers](https://devblogs.microsoft.com/dotnet/dotnet-6-is-now-in-ubuntu-2204/#net-in-chiseled-ubuntu-containers)
* [Announcing built-in container support for the .NET SDK](https://devblogs.microsoft.com/dotnet/announcing-builtin-container-support-for-the-dotnet-sdk/)
* [Publish to a container](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-7#publish-to-a-container)
* [dotnet / sdk-container-builds](https://github.com/dotnet/sdk-container-builds)
* [.NET Core Globalization Invariant Mode](https://github.com/dotnet/runtime/blob/main/docs/design/features/globalization-invariant-mode.md)
* [devdevdev.net](https://devdevdev.net/)