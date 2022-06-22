#!/usr/bin/env python
# -*- coding: utf-8 -*- #

# Set to false before publishing
RELATIVE_URLS = True

AUTHOR = u"walkermatt"
SITENAME = u"longwayaround.org.uk"
SITESUBTITLE = u"taking the scenic route and enjoying the journey"
SITEURL = u"https://longwayaround.org.uk"

DIRECT_TEMPLATES = ('index', 'archives')

TIMEZONE = 'Europe/London'

DEFAULT_LANG = 'en'

# Social widget
SOCIAL = (
    ('linkedin', 'https://uk.linkedin.com/in/walkermatt'),
    ('github', 'https://github.com/organizations/AstunTechnology'),
    ('github', 'https://github.com/walkermatt'),
    ('twitter', 'https://twitter.com/_walkermatt')
)

PLUGINS = [
    'pelican_gist'
]

DEFAULT_PAGINATION = False

DISPLAY_PAGES_ON_MENU = True

THEME = './theme'

AUTHORS_SAVE_AS = None
TAGS_SAVE_AS = None

DISQUS_SITENAME = 'longwayaroundorguk'

ARTICLE_URL = 'notes/{slug}/'
ARTICLE_SAVE_AS = 'notes/{slug}/index.html'

PAGE_URL = 'pages/{slug}/'
PAGE_SAVE_AS = 'pages/{slug}/index.html'

CATEGORY_URL = '{name}/'
CATEGORY_SAVE_AS = '{name}/index.html'

FEED_RSS = 'feeds/all.rss.xml'

STATIC_PATHS = ['files', '.htaccess', 'CNAME']

EXTRA_PATH_METADATA = {
    'files': {'path': 'files/'},
    '.htaccess': {'path': '.htaccess'}
}
