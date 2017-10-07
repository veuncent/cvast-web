"""cvast_web URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.11/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import url
from django.contrib import admin
from django.conf import settings
from django.conf.urls import include

from wagtail.wagtailadmin import urls as wagtailadmin_urls
from wagtail.wagtaildocs import urls as wagtaildocs_urls
from wagtail.wagtailcore import urls as wagtail_urls

from main_website.views import about_us, load_test, main, news, projects, software

urlpatterns = [
    url(r'^django-admin/', admin.site.urls),

    url(r'^projects/$', projects.index, name='projects_index'),
    url(r'^projects/zikast/$', projects.project_index, {'project_name': 'dycast'}, name='projects_dycast'),    
    url(r'^projects/(?P<project_name>[-\w]+)/$', projects.project_index, name='projects_project_index'),    
    url(r'^projects/(?P<project_name>[-\w]+)/(?P<resource_name>[-\w]+)/$', projects.subproject, name='projects_subproject'),
    
    url(r'^about-us/(?P<about_us_name>[-\w]+)/$', about_us.about_us_subpage, name='about_us_subpage'),    
    url(r'^news/$', news.index, name='news_index'),
    url(r'^software/$', software.index, name='software_index'),
    url(r'^loaderio-cb219f4f97bd62cb751a2e5bfca5f0a3\.txt/$', load_test.load_test, name='load_test'),

    url(r'^admin/', include(wagtailadmin_urls)),
    url(r'^documents/', include(wagtaildocs_urls)),
    url(r'', include(wagtail_urls)),

]


if settings.DEBUG:
    from django.conf.urls.static import static
    from django.contrib.staticfiles.urls import staticfiles_urlpatterns

    # Serve static and media files from development server
    urlpatterns += staticfiles_urlpatterns()
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
