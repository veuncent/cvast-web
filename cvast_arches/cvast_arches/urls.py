'''
ARCHES - a program developed to inventory and manage immovable cultural heritage.
Copyright (C) 2013 J. Paul Getty Trust and World Monuments Fund

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
'''

from arches_hip import urls as arches_hip_urls
from django.conf.urls import patterns, url, include

urlpatterns = patterns('',
    url(r'', include(arches_hip_urls)),
    url(r'^$', 'arches.app.views.main.index', name='home'),

    url(r'^projects/$', 'cvast_arches.views.projects.index', name='projects_index'),
    url(r'^projects/zikast/$', 'cvast_arches.views.projects.project_index', {'project_name': 'dycast'}, name='projects_dycast'),    
    url(r'^projects/(?P<project_name>[-\w]+)/$', 'cvast_arches.views.projects.project_index', name='projects_project_index'),    
    url(r'^projects/(?P<project_name>[-\w]+)/(?P<resource_name>[-\w]+)/$', 'cvast_arches.views.projects.subproject', name='projects_subproject'),
    
    url(r'^about-us/(?P<about_us_name>[-\w]+)/$', 'cvast_arches.views.about_us.about_us_subpage', name='about_us_subpage'),    
    url(r'^news/$', 'cvast_arches.views.news.index', name='news_index'),
    url(r'^software/$', 'cvast_arches.views.software.index', name='software_index'),
    url(r'^loaderio-cb219f4f97bd62cb751a2e5bfca5f0a3\.txt/$', 'cvast_arches.views.load_test.load_test', name='load_test')
)
