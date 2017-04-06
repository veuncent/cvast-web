from django.template import RequestContext
from django.shortcuts import render_to_response
from django.template import TemplateDoesNotExist
from django.http import Http404

def about_us_subpage(request, about_us_name):
    try:
        about_us_name = about_us_name.replace("-", "_")
        return render_to_response('about_us/%s.htm' % about_us_name, {
            'active_page': 'About_us',
        },
            context_instance=RequestContext(request))
    except TemplateDoesNotExist:
        raise Http404()