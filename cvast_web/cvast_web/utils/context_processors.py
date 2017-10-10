from django.conf import settings

def media_settings(request):
    return {
        'S3_STATIC_URL': settings.S3_STATIC_URL,
        'S3_STATIC_URL_IMG': settings.S3_STATIC_URL_IMG,
        'S3_STATIC_URL_VIDEO': settings.S3_STATIC_URL_VIDEO,
        'S3_STATIC_URL_FILES': settings.S3_STATIC_URL_FILES
    }

def google_analytics(request):
    """
    Use the variables returned in this function to
    render your Google Analytics tracking code template.
    """
    ga_prop_id = getattr(settings, 'GOOGLE_ANALYTICS_PROPERTY_ID', False)
    if not settings.DEBUG and ga_prop_id:
        return {
            'GOOGLE_ANALYTICS_PROPERTY_ID': ga_prop_id
        }
    return {}