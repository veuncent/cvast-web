from django.template import RequestContext
from django.shortcuts import render_to_response

def about_us(request):
    return render_to_response('about_us/about-us.htm', {
            # 'main_script': 'index',
            'active_page': 'about_us',
        },
        context_instance=RequestContext(request))