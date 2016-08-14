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

uuid_regex = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

urlpatterns = patterns('',
    url(r'^mission.htm', 'cvast_arches.views.about_us.mission', name='mission'),
    url(r'^people.htm', 'cvast_arches.views.about_us.people', name='people'),
    url(r'^technology.htm', 'cvast_arches.views.about_us.technology', name='technology'),
    url(r'^partners.htm', 'cvast_arches.views.about_us.partners', name='partners'),
    url(r'^loaderio-cb219f4f97bd62cb751a2e5bfca5f0a3\.txt', 'cvast_arches.views.load_test.load_test', name='load_test'),
    url(r'', include(arches_hip_urls))
)
