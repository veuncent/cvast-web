from django.template import RequestContext
from django.shortcuts import render_to_response

def index(request):
    return render_to_response('software/index.htm', {
        'active_page': 'Software',
    },
        context_instance=RequestContext(request))