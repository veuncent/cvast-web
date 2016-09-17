from django.template import RequestContext
from django.shortcuts import render_to_response
from django.template import TemplateDoesNotExist
from django.http import Http404

def index(request):
    return render_to_response('projects/index.htm', {
        # 'main_script': 'index',
        'active_page': 'Projects',
    },
        context_instance=RequestContext(request))


def la_mancha(request):
    return render_to_response('projects/la_mancha/index.htm', {
        # 'main_script': 'index',
        'active_page': 'Projects',
    },
        context_instance=RequestContext(request))

def la_mancha_resource(request, resource_name):
    try:
        filename = resource_name.replace ("-", "_")
        return render_to_response('projects/la_mancha/%s.htm' % filename, {
            # 'main_script': 'index',
            'active_page': 'Projects',
        },
            context_instance=RequestContext(request))
    except TemplateDoesNotExist:
        raise Http404()

def paris_nhm(request):
    return render_to_response('projects/paris-nhm/index.htm', {
        # 'main_script': 'index',
        'active_page': 'Projects',
    },
        context_instance=RequestContext(request))
