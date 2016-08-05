from django.template import RequestContext
from django.shortcuts import render_to_response


def people(request):
    return render_to_response('about_us/people.htm', {
        # 'main_script': 'index',
        'active_page': 'About_us',
    },
        context_instance=RequestContext(request))


def partners(request):
    return render_to_response('about_us/partners.htm', {
        # 'main_script': 'index',
        'active_page': 'About_us',
    },
        context_instance=RequestContext(request))


def technology(request):
    return render_to_response('about_us/technology.htm', {
        # 'main_script': 'index',
        'active_page': 'About_us',
    },
        context_instance=RequestContext(request))
