from django.http import HttpResponse

def load_test(request):
    return HttpResponse("loaderio-cb219f4f97bd62cb751a2e5bfca5f0a3", mimetype='text/plain')
