# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

from wagtail.wagtailcore.models import Page
from wagtail.wagtailcore.fields import RichTextField
from wagtail.wagtailadmin.edit_handlers import FieldPanel

from wagtail.wagtailsearch import index


class HomePage(Page):
    template = 'home/home_index.htm'

    intro_title = models.CharField(max_length=100, default="Center for Virtualization and Applied Spatial Technologies")
    intro_text = RichTextField(blank=True)
    intro_button = models.CharField(max_length=40, default="Learn More")

    news_summary_title = models.CharField(max_length=120, default="News")
    news_summary_link = models.CharField(max_length=50, default="See all News items")

    content_panels = Page.content_panels + [
        FieldPanel('intro_title', classname="full"),
        FieldPanel('intro_text', classname="full"),
        FieldPanel('intro_button', classname="full"),
        FieldPanel('news_summary_title', classname="full"),
        FieldPanel('news_summary_link', classname="full"),
    ]


    def get_context(self, request):
        context = super(HomePage, self).get_context(request)
        context['main_script'] = 'index'
        context['active_page'] = 'Home'
        context['news_articles'] = NewsPage.objects.live().order_by('-date')[:1]
        context['news_index'] = NewsIndexPage.objects.first()
        return context


class NewsIndexPage(Page):
    template = 'news/news_index.htm'

    intro_title = models.CharField(max_length=100, default="News", blank=True)
    intro_text = RichTextField(blank=True)

    content_panels = Page.content_panels + [
        FieldPanel('intro_title', classname="full"),
        FieldPanel('intro_text', classname="full"),
    ]

    def get_context(self, request):
        context = super(NewsIndexPage, self).get_context(request)
        context['main_script'] = 'cvast-main'
        context['active_page'] = 'News'
        context['news_articles'] = NewsPage.objects.live().order_by('-date').specific
        return context


class NewsPage(Page):
    template = 'news/news_page.htm'

    subtitle = models.CharField(max_length=40, blank=True)
    location = models.CharField(max_length=40, blank=True)
    date = models.DateField("Post date")
    intro = RichTextField(max_length=1000)
    body = RichTextField()

    search_fields = Page.search_fields + [
        index.SearchField('title'),
        index.SearchField('subtitle'),
        index.SearchField('location'),
        index.SearchField('intro'),
        index.SearchField('body'),
    ]

    content_panels = Page.content_panels + [
        FieldPanel('location'),
        FieldPanel('date'),
        FieldPanel('intro'),
        FieldPanel('subtitle'),
        FieldPanel('body', classname="full"),
    ]

    def get_context(self, request):
        context = super(NewsPage, self).get_context(request)
        context['main_script'] = 'cvast-main'
        context['active_page'] = 'News'
        return context

