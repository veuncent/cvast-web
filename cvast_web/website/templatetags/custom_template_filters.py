import re
from django import template

register = template.Library()

@register.filter
def get_embed_url_with_parameters(url):
    if 'youtube.com' in url or 'youtu.be' in url:
        regex = r"(?:https:\/\/)?(?:www\.)?(?:youtube\.com|youtu\.be)\/(?:watch\?v=)?(.+)"  # Get video id from URL
        embed_url = re.sub(regex, r"https://www.youtube.com/embed/\1", url)                 # Append video id to desired URL
        embed_url_with_parameters = embed_url + '?rel=0'                                    # Add additional parameters
        return embed_url_with_parameters
    elif 'vimeo.com' in url:
        embed_url = url.replace('vimeo.com', 'player.vimeo.com/video')
        embed_url_with_parameters = embed_url + '?loop=0&title=0&byline=0&portrait=0'
        return embed_url_with_parameters
    else:
        return None
