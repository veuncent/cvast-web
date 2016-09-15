from django.template import RequestContext
from django.shortcuts import render_to_response


def index(request):
    return render_to_response('projects/index.htm', {
        # 'main_script': 'index',
        'active_page': 'Projects',
    },
        context_instance=RequestContext(request))


def la_mancha(request):
    return render_to_response('projects/la-mancha.htm', {
        # 'main_script': 'index',
        'active_page': 'Projects',
    },
        context_instance=RequestContext(request))

def la_motilla_del_azuer(request):
    return render_to_response('projects/la-motilla-del-azuer.htm', {
        # 'main_script': 'index',
        'active_page': 'Projects',
    },
        context_instance=RequestContext(request))

def paris_nhm(request):
    return render_to_response('projects/paris-nhm.htm', {
        # 'main_script': 'index',
        'active_page': 'Projects',
    },
        context_instance=RequestContext(request))



