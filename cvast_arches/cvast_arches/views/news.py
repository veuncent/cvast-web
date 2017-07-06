from django.template import RequestContext
from django.shortcuts import render_to_response
from django.template import TemplateDoesNotExist
from django.http import Http404


def index(request):
    return render_to_response('news/index.htm', {
        'main_script': 'cvast-main',
        'active_page': 'News',
    },
        context_instance=RequestContext(request))