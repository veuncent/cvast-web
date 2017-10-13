# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

from wagtail.wagtailcore.models import Page
from wagtail.wagtailcore.fields import RichTextField
from wagtail.wagtailadmin.edit_handlers import FieldPanel, MultiFieldPanel

from wagtail.wagtailsearch import index

from modelcluster.fields import ParentalKey
from modelcluster.contrib.taggit import ClusterTaggableManager
from taggit.models import Tag, TaggedItemBase


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


class NewsPageTag(TaggedItemBase):
    content_object = ParentalKey('NewsPage', related_name='tagged_items')


class NewsPage(Page):
    template = 'news/news_page.htm'

    subtitle = models.CharField(max_length=40, blank=True)
    location = models.CharField(max_length=40, blank=True)
    date = models.DateField("Post date")
    intro = RichTextField(max_length=1000)
    body = RichTextField()
    tags = ClusterTaggableManager(through=NewsPageTag, blank=True)

    search_fields = Page.search_fields + [
        index.SearchField('title'),
        index.SearchField('subtitle'),
        index.SearchField('location'),
        index.SearchField('intro'),
        index.SearchField('body'),
    ]

    content_panels = Page.content_panels + [
        MultiFieldPanel([
            FieldPanel('location'),
            FieldPanel('date'),
            FieldPanel('tags'),
        ], heading="News article metadata"),
        FieldPanel('intro'),
        FieldPanel('subtitle'),
        FieldPanel('body', classname="full"),
    ]

    def get_context(self, request):
        context = super(NewsPage, self).get_context(request)
        context['main_script'] = 'cvast-main'
        context['active_page'] = 'News'
        return context


class NewsTagIndexPage(Page):
    template = 'news/news_tag_index.htm'

    def get_context(self, request):

        # Filter by tag
        tag = request.GET.get('tag')
        news_articles = NewsPage.objects.filter(tags__name=tag)

        # Update template context
        context = super(NewsTagIndexPage, self).get_context(request)
        context['news_articles'] = news_articles

        context['all_tags'] = Tag.objects.all()

        return context




