
PELICAN=pelican
PELICANOPTS=None

BASEDIR=$(PWD)
INPUTDIR=$(BASEDIR)/src
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelican.conf.py

help:
	@echo 'Makefile for a pelican Web site                                            '
	@echo '                                                                           '
	@echo 'Usage:                                                                     '
	@echo '   make html                        generate site with relative urls       '
	@echo '   make html_deploy                 generate site without relative urls    '
	@echo '   make clean                       remove the generated files             '
	@echo '   deploy                           deploy to gh-pages                     '
	@echo '   serve                            local web server                       '
	@echo '   watch_serve                      auto-reload and build local web server '
	@echo '                                                                           '


html: clean $(OUTPUTDIR)/index.html
	@echo 'Done'

html_deploy:
	sed --regexp-extended 's/RELATIVE_URLS = True/RELATIVE_URLS = False/' pelican.conf.py > pelican.conf.deploy.py
	@$(MAKE) CONFFILE="pelican.conf.deploy.py" html
	rm pelican.conf.deploy.py*

$(OUTPUTDIR)/%.html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE)

clean:
	rm -fr $(OUTPUTDIR)
	mkdir $(OUTPUTDIR)

deploy: html_deploy
	ghp-import -n -p $(OUTPUTDIR)

serve: html $(OUTPUTDIR)/index.html
	(cd output && python -m SimpleHTTPServer)

watch_serve:
	nodemon --ignore ./output --ext rst,py,js,css --exec make serve

.PHONY: html html_deploy help clean deploy serve watch_serve
    
