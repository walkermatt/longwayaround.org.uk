
PELICAN=pelican
PELICANOPTS=None

BASEDIR=$(PWD)
INPUTDIR=$(BASEDIR)/src
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelican.conf.py

FTP_HOST=longwayaround.org.uk
FTP_USER=longwaya
FTP_TARGET_DIR=/public_html

help:
	@echo 'Makefile for a pelican Web site                                       '
	@echo '                                                                      '
	@echo 'Usage:                                                                '
	@echo '   make html                        (re)generate the web site         '
	@echo '   make clean                       remove the generated files        '
	@echo '   ftp_upload                       upload the web site using FTP     '
	@echo '   ssh_upload                       upload the web site using SSH     '
	@echo '   dropbox_upload                   upload the web site using Dropbox '
	@echo '                                                                      '


html: clean $(OUTPUTDIR)/index.html
	@echo 'Done'

$(OUTPUTDIR)/%.html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE)

clean:
	rm -fr $(OUTPUTDIR)
	mkdir $(OUTPUTDIR)

dropbox_upload: $(OUTPUTDIR)/index.html
	cp -r $(OUTPUTDIR)/* $(DROPBOX_DIR)

ssh_upload: $(OUTPUTDIR)/index.html
	scp -r $(OUTPUTDIR)/* $(SSH_USER)@$(SSH_HOST):$(SSH_TARGET_DIR)

ftp_upload: $(OUTPUTDIR)/index.html
	lftp -e "set ftp:ssl-allow off ; mirror --reverse --no-perms $(OUTPUTDIR) $(FTP_TARGET_DIR) ; quit" ftp://$(FTP_USER)@$(FTP_HOST)

github: $(OUTPUTDIR)/index.html
	ghp-import $(OUTPUTDIR)
	git push origin gh-pages

serve: html $(OUTPUTDIR)/index.html
	(cd output && python -m SimpleHTTPServer)

devserver:
	nodemon --ignore ./output --ext rst,py,js,css --exec make serve

.PHONY: html help clean ftp_upload ssh_upload dropbox_upload github
    
