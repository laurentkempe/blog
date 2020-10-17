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
    .\start.ps1 "Title of a new page"

## How to update Hexo

Update packages.json

    npm i -g npm-check-updates
    ncu -u
    npm install
