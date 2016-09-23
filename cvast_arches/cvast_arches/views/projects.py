from django.template import RequestContext
from django.shortcuts import render_to_response
from django.template import TemplateDoesNotExist
from django.http import Http404


def index(request):
    return render_to_response('projects/index.htm', {
        'main_script': 'cvast-video',
        'active_page': 'Projects',
    },
        context_instance=RequestContext(request))


def project_index(request, project_name):
    try:
        project_name = project_name.replace("-", "_")
        return render_to_response('projects/%s/index.htm' % project_name, {
            'main_script': 'cvast-video',
            'active_page': 'Projects',
        },
            context_instance=RequestContext(request))
    except TemplateDoesNotExist:
        raise Http404()


def subproject(request, project_name, resource_name):
    try:
        project_name = project_name.replace("-", "_")
        filename = resource_name.replace("-", "_")
        return render_to_response('projects/%s/%s.htm' % (project_name, filename), {
            'main_script': 'cvast-video',
            'active_page': 'Projects',
        },
            context_instance=RequestContext(request))
    except TemplateDoesNotExist:
        raise Http404()
