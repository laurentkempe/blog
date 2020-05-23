# My blog

[Laurent Kempé - One of the Tech Head Brothers](https://laurentkempe.com/)

## How to write locally

After a fresh clone, with nodejs 12.13.1 installed, use **install.ps1** to install all dependencies.

Then to start the server use **start.ps1** or

    hexo server --open --draft 

To update packages.json

    npm i -g npm-check-updates
    ncu -u
    npm install
