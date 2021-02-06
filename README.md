# My blog

[Laurent Kempé - One of the Tech Head Brothers](https://laurentkempe.com/)

## Prerequisite

nodejs 12.13.1 installed

## How to create a draft on Github

* Navigate to Github action [Create new draft](https://github.com/laurentkempe/blog/actions?query=workflow%3A%22Create+new+draft%22)
* Click Run worflow, specify draft title, click Run workflow

## How to write locally

    git clone https://github.com/laurentkempe/blog.git
    cd blog
    .\start.ps1

### Start local server

    dotnet run server 

### Start local server with draft

    dotnet run server -d

### Create draft

    dotnet run new 'title' 

### See drafts

    dotnet run drafts

### Publish draft

    dotnet run publish <filename>

## How to update Hexo

Update packages.json

    npm i -g npm-check-updates
    ncu -u
    npm install
