from django.shortcuts import render
from django.template import TemplateDoesNotExist
from django.http import Http404


def index(request):
    return render(request,
                  'projects/index.htm',
                  {
                      'main_script': 'cvast-main',
                      'active_page': 'Projects',
                  })


def project_index(request, project_name):
    try:
        project_name = project_name.replace("-", "_")
        return render(request,
                      'projects/%s/index.htm' % project_name,
                      {
                          'main_script': 'cvast-main',
                          'active_page': 'Projects',
                      })
    except TemplateDoesNotExist:
        raise Http404()


def subproject(request, project_name, resource_name):
    try:
        project_name = project_name.replace("-", "_")
        filename = resource_name.replace("-", "_")
        return render(request,
                      'projects/%s/%s.htm' % (project_name, filename),
                      {
                          'main_script': 'cvast-main',
                          'active_page': 'Projects',
                      })
    except TemplateDoesNotExist:
        raise Http404()
