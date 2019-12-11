---
title: 'ASP.NET Core 3.0 and Gatsby'
permalink: ASP.NET-Core-3.0-and-Gatsby
disqusIdentifier: '2019-04-22 10:38:01 <!-- Remove space to have e.g. 20160405174628 -->'
coverSize: partial
tags:
  - ASP.NET Core
  - Gatsbyjs
coverCaption: 'Le Lomont, Doubs, France'
coverImage: 'https://live.staticflickr.com/65535/46976463274_aa47e1b4d3_h.jpg'
thumbnailImage: 'https://live.staticflickr.com/65535/46976463274_2a1a30979c_q.jpg'
date: 2019-04-22 11:38:01
---
I am not doing professional Web development for some time but I am still interested, watching and trying new things that keep emerging on the Web world. When I saw [Gatsby](https://www.gatsbyjs.org/), I immediately liked what I was seeing. And wanted to play with it!

As I like 💕 also [ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/?view=aspnetcore-3.0), I decided that it would be nice to combine both together and see how it would work. This post is about the minimum things you need to do to have both working together.
<!-- more -->

# About Gatsby

TODO ADD why I like it

TODO add description and that it uses react https://reactjs.org/

First, the [Quick start](https://www.gatsbyjs.org/docs/quick-start) and [Tutorial](https://www.gatsbyjs.org/tutorial/) for Gatsby are extremely well written! So, if you need to start somewhere, it is definitely the place.

# Quick start

## Gatsby

If you have node and npm installed, installing [Gatsby CLI](https://www.gatsbyjs.org/docs/gatsby-cli/) is as easy as this

{% codeblock install Gatsby CLI lang:shell  %}
    npm install -g gatsby-cli
{% endcodeblock %}

Now comes the more complex part, which is [setting up your environment for building native Node.js modules](https://www.gatsbyjs.org/docs/gatsby-on-windows/) but again the documentation is really well written.

{% alert warning %}
If you are on Windows, then use [Node.js 11.14.0](https://www.chocolatey.org/packages/nodejs.install/11.14.0) or [Node.js 12.1.0](https://nodejs.org/dist/v12.1.0/node-v12.1.0-x64.msi) and not 12.0.0 or you will get issues with [shapr](https://www.npmjs.com/package/sharp) npm package, which is a dependency of Gatsby.
{% endalert %}

## .NET Core 3.0 preview 5

As we want to create an application using Gatsby on the client and .NET Core 3.0 as a backend Web API, we need to install [.NET Core SDK 3.0](https://dotnet.microsoft.com/download/dotnet-core/3.0). At the time of writing, [Microsoft Build 2019](https://news.microsoft.com/build2019/) time, it is the .NET Core SDK 3.0 preview 5. As I am on Windows, I downloaded [Windows .NET Core Installer - SDK 3.0.100-preview5-011568](https://dotnet.microsoft.com/download/thank-you/dotnet-sdk-3.0.100-preview5-windows-x64-installer). Double clicked on it and installed it.

# Project creation

Let's create a project called GatsbyCore! As Gatsby is based on React, we will use the [.NET Core template for React](https://docs.microsoft.com/en-us/aspnet/core/client-side/spa/react?view=aspnetcore-2.2&tabs=visual-studio). But we will remove the ClientApp created by the template to use the one created by Gatsby CLI.

{% codeblock Project creation lang:shell  %}
❯ mkdir GatsbyCore
❯ cd .\GatsbyCore\

❯ dotnet --version
3.0.100-preview4-011223

❯ dotnet new react
The template "ASP.NET Core with React.js" was created successfully.

Processing post-creation actions...
Running 'dotnet restore' on C:\Users\laure\projects\Gatsby\GatsbyCore\GatsbyCore.csproj...
  Restore completed in 8.64 sec for C:\Users\laure\projects\Gatsby\GatsbyCore\GatsbyCore.csproj.

Restore succeeded.

❯ rm -r .\ClientApp\*
❯ rm .\ClientApp\
❯ gatsby new ClientApp
info Creating new site from git: https://github.com/gatsbyjs/gatsby-starter-default.git                                                                                                               
Cloning into 'ClientApp'...                                                                                                                                                   
...                        
added 1719 packages from 987 contributors and audited 25784 packages in 29.051s                                                                                                                       
found 0 vulnerabilities                                                                                                                                                                               
                                                                                                                                                                                                      
info Initialising git in ClientApp                                                                                                                                                                    
Initialized empty Git repository in C:/Users/laure/projects/Gatsby/GatsbyCore/ClientApp/.git/                                                                                                         
info Create initial git commit in ClientApp                                                                                                                                                           

❯ dotnet build
...
Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:05.03
❯ dotnet run
...
Content root path: C:\Users\laure\projects\Gatsby\GatsbyCore
Now listening on: https://localhost:5001
Now listening on: http://localhost:5000
Application started. Press Ctrl+C to shut down.

 npm run develop

info: Microsoft.AspNetCore.SpaServices[0]
      > gatsby-starter-default@0.1.0 develop C:\Users\laure\projects\Gatsby\GatsbyCore\ClientApp
 gatsby develop
...
  http://localhost:8000/

View GraphiQL, an in-browser IDE, to explore your site's data and schema

  http://localhost:8000/___graphql
{% endcodeblock %}

I have shortened a bit the output so that we can focus on the essential part of it.

As you can read on the log output, you can open your browser now on http://localhost:8000/ and you will see the Gatsby application. On http://localhost:8000/___graphql to see the [GraphiQL](https://github.com/graphql/graphiql) interface which comes with Gatsby. And also, https://localhost:5001/api/SampleData/WeatherForecasts to see the .NET Core API controller displaying some JSON.

Now that we have the basic setup we want to connect both world so that the Gatsby web application can get data from the .NET Core 3.0 Web API backend.
To achieve that we will create a [Gatsby component](https://www.gatsbyjs.org/tutorial/part-one/#building-with-components) which will be in charge to query the server and display the data returned.

# Gatsby component creation

Let's create a [Gatsby component](https://www.gatsbyjs.org/docs/building-with-components/) which will get data from our ASP.NET Core 3.0 API and display it.


In the folder *ClientApp\src\components* add a file called *weather.js*.

{% codeblock Weather Gatsby component lang:js  %}
import React, { Component } from 'react';

export class Weather extends Component {
    displayName = Weather.name

    constructor(props) {
        super(props);
        this.state = { data: {}, loading: true };
    }

    async componentDidMount() {
        const response = await fetch('api/SampleData/WeatherForecasts');
        const json = await response.json();

        this.setState({ data: json, loading: false });
    }

    static renderUpcomingWeekTable(weatherForecasts) {
        return (
            <table className='table'>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Temperature</th>
                        <th>Summary</th>
                    </tr>
                </thead>
                <tbody>
                    {weatherForecasts.map(forecast =>
                        <tr key={forecast.dateFormatted}>
                            <td>{forecast.dateFormatted}</td>
                            <td>{forecast.temperatureC}</td>
                            <td>{forecast.summary}</td>
                        </tr>
                    )}
                </tbody>
            </table>
        );
    }

    render() {
        let contents = this.state.loading
            ? <p><em>Loading...</em></p>
            : Weather.renderUpcomingWeekTable(this.state.data)

        return (
            <div>
                <h1>Weather</h1>
                {contents}
            </div>
        );
    }
}
{% endcodeblock %}

And use it on the *index.js* page

{% codeblock Weather Gatsby component lang:js  %}
    <div>
        <Weather />
    </div>
{% endcodeblock %}
