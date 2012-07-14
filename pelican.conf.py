#!/usr/bin/env python
# -*- coding: utf-8 -*- #

AUTHOR = u"walkermatt"
SITENAME = u"longwayaround.org.uk"
SITESUBTITLE = u"taking the scenic route and enjoying the journey"
SITEURL = ''

TIMEZONE = 'Europe/London'

DEFAULT_LANG='en'

# Blogroll
LINKS =  ()

# Social widget
SOCIAL = (
        ('linkedin', 'http://uk.linkedin.com/in/walkermatt'),
        ('delicious', 'http://delicious.com/walkermatt'),
        ('github', 'http://github.com/organizations/AstunTechnology'),
        ('github', 'http://github.com/walkermatt'),
        ('twitter', 'http://twitter.com/_walkermatt')
)

DEFAULT_PAGINATION = False

DISPLAY_PAGES_ON_MENU = True

THEME = 'longwayaround.org.uk_theme'

DISQUS_SITENAME = 'longwayaroundorguk'

ARTICLE_URL = 'notes/{slug}/'
ARTICLE_SAVE_AS = 'notes/{slug}/index.html'

PAGE_URL = 'pages/{slug}/'
PAGE_SAVE_AS = 'pages/{slug}/index.html'

CATEGORY_URL = '{name}/'
CATEGORY_SAVE_AS = '{name}/index.html'

FEED_RSS = 'feeds/all.rss.xml'
