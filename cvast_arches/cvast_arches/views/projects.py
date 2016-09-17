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
    return render_to_response('projects/la-mancha/index.htm', {
        # 'main_script': 'index',
        'active_page': 'Projects',
    },
        context_instance=RequestContext(request))

def la_mancha_resource(request, resource_name="calatrava-la-nueva"):
    try:
        return render_to_response('projects/la-mancha/%s.htm' % resource_name, {
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
