# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

from wagtail.wagtailcore.models import Page
from wagtail.wagtailcore.fields import RichTextField, StreamField
from wagtail.wagtailcore.blocks import CharBlock, StructBlock, RichTextBlock
from wagtail.wagtailimages.blocks import ImageChooserBlock
from wagtail.wagtailadmin.edit_handlers import FieldPanel, MultiFieldPanel, StreamFieldPanel

from wagtail.wagtailsearch import index

from modelcluster.fields import ParentalKey
from modelcluster.contrib.taggit import ClusterTaggableManager
from taggit.models import Tag, TaggedItemBase


class ParagraphBlock(StructBlock):
    title = CharBlock(max_length=100)
    body = RichTextBlock()

    class Meta:
        template = "blocks/paragraph_block.htm"

class ImageBlockHeaderLeft(StructBlock):
    title = CharBlock(max_length=300)
    image = ImageChooserBlock(required=True)

    class Meta:
        template = "blocks/image_block_header_left.htm"



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

    back_button = models.CharField(max_length=40, default="Back to News Overview")

    content_panels = Page.content_panels + [
        FieldPanel('intro_title', classname="full"),
        FieldPanel('intro_text', classname="full"),
        FieldPanel('back_button'),
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

    location = models.CharField(max_length=40, blank=True)
    date = models.DateField("Post date")
    intro = RichTextField(max_length=1000)
    body = StreamField([
        ('paragraph', ParagraphBlock()),
        ('image_header_left', ImageBlockHeaderLeft())
    ])
    tags = ClusterTaggableManager(through=NewsPageTag, blank=True)

    search_fields = Page.search_fields + [
        index.SearchField('title'),
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
        MultiFieldPanel([
            StreamFieldPanel('body'),
        ]),
    ]

    def get_context(self, request):
        context = super(NewsPage, self).get_context(request)
        context['main_script'] = 'cvast-main'
        context['active_page'] = 'News'
        return context


class NewsTagIndexPage(Page):
    template = 'tags/news_tag_index.htm'

    available_tags = models.CharField(max_length=40, default="Available Tags:")
    no_available_tags = models.CharField(max_length=40, default="No tags recorded yet.")
    tag_not_found = models.CharField(max_length=40, default="No pages found with tag ")
    tag_found = models.CharField(max_length=40, default="Showing pages tagged ")

    content_panels = Page.content_panels + [
        FieldPanel('available_tags'),
        FieldPanel('no_available_tags'),
        FieldPanel('tag_not_found'),
        FieldPanel('tag_found'),
    ]

    def get_context(self, request):
        context = super(NewsTagIndexPage, self).get_context(request)

        # Filter by tag
        tag = request.GET.get('tag')
        news_articles = NewsPage.objects.filter(tags__name=tag)
        context['news_articles'] = news_articles

        context['all_tags'] = Tag.objects.all()

        return context




