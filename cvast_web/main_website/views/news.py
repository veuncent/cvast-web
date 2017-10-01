from django.shortcuts import render


def index(request):
    return render(request, 'news/index.htm',
                  {
                      'main_script': 'cvast-main',
                      'active_page': 'News',
                  })
