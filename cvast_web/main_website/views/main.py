from django.shortcuts import render


def index(request):
    return render(request, 'index.htm', {
        'main_script': 'index',
        'active_page': 'Home',
    })
