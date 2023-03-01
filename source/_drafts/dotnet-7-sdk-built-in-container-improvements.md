---
title: '.NET 7 SDK built-in container improvements'
permalink: /2023/02/28/dotnet-7-sdk-built-in-container-improvements/
date: 2/28/2023 3:55:16 AM
disqusIdentifier: 20230228035516
coverSize: partial
tags: [.NET SDK, Docker]
coverCaption: 'LO Ferré, Petite Anse, Martinique, France'
coverImage: 'https://c7.staticflickr.com/9/8689/16775792438_e45283970c_h.jpg'
thumbnailImage: 'https://c7.staticflickr.com/9/8689/16775792438_8366ee5732_q.jpg'
---
Are you looking for a fast and easy way to create and run .NET applications using Docker containers without writing any Dockerfile? If so, you will be glad to know that Microsoft has introduced a new feature of the .NET SDK 7.0.200 that makes it possible to create and publish OCI container images directly from your project file. We have seen how "[.NET 7 SDK built-in container support and Ubuntu Chiseled](https://laurentkempe.com/2022/11/14/dotnet-7-sdk-built-in-container-support-and-ubuntu-chiseled/)" can be used together. It lets us **create small and secure containers** for our .NET applications easily. We went from a first docker image of 216MB to a final docker image of 48.3MB. That’s more than a **77% reduction in size**. Starting with the .NET SDK 7.0.200, some new capabilities have been added and we will explore those in this post.
<!-- more -->

# Capability now bundled into the .NET SDK 7.0.200

Previously you had to add a reference to the nuget `Microsoft.NET.Build.Containers`. With the .NET SDK 7.0.200 this is not required anymore. The new capability is now bundled into the .NET SDK.

The only thing needed is the following property in your `csproj` project file:

```xml .csproj
<EnableSdkContainerSupport>true</EnableSdkContainerSupport>
```

The feature leverages **dotnet publish** and it is a command-line tool that allows you to build and publish your .NET applications as Docker images with one command. With dotnet publish, you can:

- Create a Docker image for your .NET application without writing any Dockerfile
- Publish your Docker image to a container registry of your choice with one command
- Specify variables such as the base image, image tag, and registry name in your project file

{% alert info %}
It is interesting to realize that you don't need to have docker installed on your machine to publish to remote container registry. The .NET SDK is able to build the image and to push it to the remote registry on is own. It is interesting for CI/CD pipelines.
{% endalert %}

# Create a Docker image

To create a Docker image for your .NET application, you need to run the following command:

```powershell
❯  dotnet publish --os linux --arch x64 -p:PublishProfile=DefaultContainer -c Release
```

# Publishing your Docker image

By default, dotnet publish publishes your Docker image to the local Docker daemon.

To publish your Docker image to a container registry, you need again to add a new MSBuild property to your `.csproj` file:

```xml
<ContainerRegistry>myregistry.azurecr.io</ContainerRegistry>
```

A tend to prefer another approach which let you use the same command line to publish to a local Docker daemon or to a container registry. For that, I use publish profiles which are files found in the _<project_folder>/Properties/PublishProfiles_ folder. In which you can set publish-related properties like `ContainerRegistry` by referring to a .pubxml file in that folder. Then specify the name of the file in the `-p:PublishProfile` parameter of the `dotnet publish` command.

```powershell
❯  dotnet publish --os linux --arch x64 -p:PublishProfile=GitHub -c Release
```

With this approach, you can define **multiple publish profiles** and use them to publish to different container registries. You might want a publish profile for GitHub Package registry for your feature branch builds and push to Azure Container Registry only the released images.

The following registries have been explicitly tested: Azure Container Registry, GitLab Container Registry, Google Cloud Artifact Registry, Quay.io, AWS Elastic Container Registry, GitHub Package Registry, and Docker Hub.

{% alert warning %}
Currently, the .NET SDK 7.0.200 has an issue to upload the image to GitHub Container registry. The issue is tracked on [GitHub issue #292](https://github.com/dotnet/sdk-container-builds/issues/292)
{% endalert %}

For sure you would need to authenticate to the container registry before publishing. Docker has established a pattern with this via the docker login command, which is a way of interacting with a Docker config file that contains rules for authenticating with specific registries. This should ensure that this package works seamlessly with any registry you can `docker pull` from and `docker push`.

You can read more about this part in the [Authenticating to container registries documentation](https://github.com/dotnet/sdk-container-builds/blob/main/docs/RegistryAuthentication.md#authenticating-to-container-registries).

# Specifying a base image

By default, the SDK will infer the best base image to use. It can use values of properties of your project like `TargetFramework`, or verify if it self contained or an ASP.NET Core application. You can read about this [here](https://github.com/dotnet/sdk-container-builds/blob/main/docs/ContainerCustomization.md#containerbaseimage).

Nevertheless, you can override the default base image by adding the following property to your `.csproj` or `.pubxml` file:

```xml .csproj or .pubxml
<PropertyGroup>
    <ContainerBaseImage>mcr.microsoft.com/dotnet/runtime:7.0</ContainerBaseImage>
</PropertyGroup>
```

# Define the image name

You can achieve this by adding the following property to your `.csproj` or `.pubxml` file:

```xml .csproj or .pubxml
<PropertyGroup>
    <ContainerImageName>laurentkempe/my-super-awesome-app</ContainerImageName>
</PropertyGroup>
```

# Tagging your image

You can achieve this by adding the following property to your `.csproj` or `.pubxml` file:

```xml .csproj or .pubxml
<PropertyGroup>
    <ContainerImageTag>1.2.3-alpha2</ContainerImageTag>
</PropertyGroup>
```

This property also can be used to push multiple tags - simply use a semicolon-delimited set of tags, e.g. `1.2.3-alpha2;latest`.

This part can be automated by using 

Another interesting nuget to add is reproducible build

# Labels

TODO See
https://github.com/dotnet/sdk-container-builds/blob/main/docs/ContainerCustomization.md#default-container-labels


TODO Should we show how to build an image with Nuke, or in another post?

---

The dotnet publish tool uses the official .NET Docker images¹ that are created and optimized by Microsoft. These images contain the .NET SDK¹, which includes the .NET CLI, the .NET runtime, and ASP.NET Core¹. The images are designed for different scenarios, such as development, testing, and production.

To use dotnet publish, you need to have:

- The latest version of the .NET SDK 7.0.200 installed on your machine
- Docker Desktop installed on your machine

To get started with dotnet publish, follow these steps:

1. Create a new console application using `dotnet new console -o MyApp`
2. Navigate to the application folder using `cd MyApp`
3. Open the project file (MyApp.csproj) in your editor and add these lines inside the `<PropertyGroup>` element:

```xml
<ContainerRegistry>myregistry.azurecr.io</ContainerRegistry>
<BaseImage>mcr.microsoft.com/dotnet/sdk:7-alpine</BaseImage>
<ImageTag>myapp:latest</ImageTag>
```

4. Save and close the project file
5. Build and publish your application as a Docker image using `dotnet publish /t:PublishContainer`
6. Run your application using `docker run -it --rm myregistry.azurecr.io/myapp:latest`

# Versioning your Docker images

When you publish your application as a Docker image, you can specify the version of the image using the `<ImageTag>` property. The version can be a simple string or a combination of variables. For example, you can use the following syntax to specify the version of your image:

That's it! You have just created and published your first .NET application as a Docker image without writing any Dockerfile.

Continue with text displayed on the blog page
![alt image](https://live.staticflickr.com/65535/49566323082_e1817988c2_c.jpg)
{% alert info %}
{% endalert %}
{% codeblock GreeterService.cs lang:csharp %}
{% endcodeblock %}

# Conclusion


TODO words on the news announced related to .NET 8

I hope you enjoyed this post and learned something new that you want to try out. If you have any questions or comments, please leave them below. Thanks for reading!

# Code
<p></p>
{% githubCard user:laurentkempe repo:dotfiles align:left %}

# References

* [dotnet publish](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-publish)
* [.NET SDK Container Building Tools](https://github.com/dotnet/sdk-container-builds)
* [OCI container](https://opencontainers.org/)
* [Publish Profiles](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/visual-studio-publish-profiles?view=aspnetcore-6.0#publish-profiles) 

