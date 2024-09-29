<#

.SYNOPSIS
This is a Powershell script to bootstrap the blog.

.DESCRIPTION
This Powershell script will install npm dependencies if needed,
let the user create a new page and start the server.

.PARAMETER Page
The new page to create.

.LINK
https://laurentkempe.com/

#>

[CmdletBinding()]
Param(
    [string]$Page
)

${function:install} = {
    npm install hexo@7.3.0 --save
    npm install
    npm audit fix
    Set-Location .\themes\tranquilpeak\
    npm install
    npm audit fix
    npm run prod
    Set-Location ..\.. 
}

${function:newPage} = {
    param ([string]$pageTitle)
    & hexo new draft $pageTitle
}

if (!$BlogRoot) {
    $BlogRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

$NodeModules_DIR = Join-Path $BlogRoot "node_modules"

if (!(Test-Path $NodeModules_DIR)) {
    & install    
}

if ($Page) {
    hexo new draft $Page
}

code .

hexo server --open --draft 
