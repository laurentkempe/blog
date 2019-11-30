# My blog

[Laurent Kempé - One of the Tech Head Brothers](https://laurentkempe.com/)

## How to write locally

With nodejs 12.13.1!

	git clone https://github.com/laurentkempe/blog.git
	cd blog 
	npm install hexo --save
	npm install hexo-cli -g
	npm install
	npm audit fix
	cd .\themes\tranquilpeak\
	npm install
	npm audit fix
	npm run prod
	cd ..\..
	Hexo server --open --draft 
