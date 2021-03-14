---
title: 'Service to service invocation with Dapr .NET SDK'
permalink: /2021/03/13/service-to-service-invocation-with-dapr-dotnet-sdk/
date: 3/13/2021 8:25:53 PM
disqusIdentifier: 20210313082553
coverSize: partial
tags: ASP.NET Core, .NET, Dapr
coverCaption: 'Matamata, Hobbiton, New Zealand'
coverImage: 'https://live.staticflickr.com/4399/36332910612_10d4a7d2da_h.jpg'
thumbnailImage: 'https://live.staticflickr.com/4399/36332910612_149b9735ec_q.jpg'
---
In the previous posts
* [Getting started with Dapr for .NET Developers](https://laurentkempe.com/2021/03/09/getting-started-with-dapr-for-dotnet-developers/)
* [Using Service Invocation from Dapr .NET SDK](https://laurentkempe.com/2021/03/11/using-service-invocation-from-dapr-dotnet-sdk/)

we tackled the way to start with Dapr and how to call services.

In this one we will see how we can leverage the Dapr .NET SDK to handle service to service calls.

<!-- more -->

# Introduction

We have two services implemented in C# ASP.NET exposing REST API, one named **proxy** and the second **backend**.

**proxy** is calling **backend** using Dapr .NET SDK.

# Backend service

Nothing special here, it is the normal WeatherService from the default webapi .NET template, in the project WeatherForecastService. We just start it using Dapr and expose it under the name **backend**. In fact, that's one of the beauty of Dapr, you don't need to change your service to expose through a Dapr sidecar.

{% codeblock start.ps1 lang:powershell %}
dapr.exe run --app-id backend --app-port 5000 --dapr-http-port 3500 --app-ssl dotnet run -- --urls=https://localhost:5000/ -p WeatherForecastService/WeatherForecastService.csproj
{% endcodeblock %}

https://localhost:5000/swagger/index.html

https://localhost:5000/WeatherForecast/



# Proxy service

Here is the interesting part of this post.

project WeatherForecastProxyService

{% codeblock IWeatherForecastClient.cs lang:csharp %}
    public interface IWeatherForecastClient
    {
        Task<IEnumerable<WeatherForecast>> GetWeatherForecast(int count);
    }
{% endcodeblock %}

{% codeblock WeatherForecastClient.cs lang:csharp %}
    public class WeatherForecastClient : IWeatherForecastClient
    {
        private readonly HttpClient _httpClient;

        public WeatherForecastClient(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<IEnumerable<WeatherForecast>> GetWeatherForecast(int count)
        {
            var weatherForecasts = await _httpClient.GetFromJsonAsync<List<WeatherForecast>>("weatherforecast");

            return weatherForecasts?.Take(count);
        }
    }
{% endcodeblock %}

{% codeblock Startup.cs lang:csharp %}
        public void ConfigureServices(IServiceCollection services)
        {
            ...
            services.AddSingleton<IWeatherForecastClient, WeatherForecastClient>(
                _ => new WeatherForecastClient(DaprClient.CreateInvokeHttpClient("backend")));
        }
{% endcodeblock %}


{% codeblock WeatherForecastProxyController.cs lang:csharp %}
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastProxyController : ControllerBase
    {
        private readonly IWeatherForecastClient _weatherForecastClient;

        public WeatherForecastProxyController(IWeatherForecastClient weatherForecastClient)
        {
            _weatherForecastClient = weatherForecastClient;
        }

        [HttpGet]
        public async Task<IEnumerable<WeatherForecast>> Get(int count)
        {
            return await _weatherForecastClient.GetWeatherForecast(count);
        }
    }
{% endcodeblock %}

We start it using Dapr and expose it under the name **proxy**.

{% codeblock start.ps1 lang:powershell %}
dapr.exe run --app-id proxy --app-port 5001 --dapr-http-port 3501 --app-ssl dotnet run -- --urls=https://localhost:5001/ -p WeatherForecastProxyService/WeatherForecastProxyService.csproj
{% endcodeblock %}

https://localhost:5001/swagger/index.html

https://localhost:5001/WeatherForecastProxy?count=2

# Starting proxy and backend Dapr sidecar

You can use the `start.ps1` powershell script if you have Windows Terminal installed, and it will display side by side both outputs in a new full screen window.
On the left is the **proxy** sidecar output and on the right the **backend**.

# Calling the proxy

You can use http://localhost:3500/v1.0/invoke/proxy/method/weatherforecastproxy?count=2


Continue with text displayed on the blog page
![alt image](https://live.staticflickr.com/65535/49566323082_e1817988c2_c.jpg)
{% alert info %}
{% endalert %}
{% codeblock GreeterService.cs lang:csharp %}
{% endcodeblock %}

# Conclusion
TODO

<p></p>
{% githubCard user:laurentkempe repo:daprPlayground align:left %}
