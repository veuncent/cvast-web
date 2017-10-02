from django.shortcuts import render


def index(request):
    return render(request,
                  'software/index.htm',
                  {
                      'active_page': 'Software',
                  })
