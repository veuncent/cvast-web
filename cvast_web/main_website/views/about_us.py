from django.shortcuts import render
from django.template import TemplateDoesNotExist
from django.http import Http404


def about_us_subpage(request, about_us_name):
    try:
        about_us_name = about_us_name.replace("-", "_")
        return render(request,
                      'about_us/%s.htm' % about_us_name,
                      {'active_page': 'About_us', }
                      )
    except TemplateDoesNotExist:
        raise Http404()
