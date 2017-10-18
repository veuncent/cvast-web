# encoding=utf8
import logging

from django.conf import settings
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from wagtail.wagtailcore.models import Page, Site

from website.models import HomePage, NewsIndexPage, NewsPage, NewsTagIndexPage


logger = logging.getLogger(__name__)


class Command(BaseCommand):

    def handle(self, *args, **options):
        try:
            default_home = Page.objects.filter(title="Welcome to your new Wagtail site!")[0]
            if default_home:
                logging.info("Moving default home page slug")
                default_home.slug = "home-old"
                default_home.save_revision().publish()
                default_home.save()
        except:
            pass


        home_page = HomePage(
            title="CVAST Home",
            intro_title="Center for Virtualization and Applied Spatial Technologies",
            intro_text="The University of South Florida’s CVAST works to document, preserve, and protect the world’s cultural and natural heritage through the use of digital visualization, geospatial technologies, informatics, and 3D virtualization.",
            intro_button="Learn More",
            news_summary_title="News",
            news_summary_link="See all News items",
            slug="home",
            seo_title="home",
            search_description="home",
            show_in_menus=True,
        )

        news_index_page = NewsIndexPage(
            title="CVAST News",
            intro_text="Get the latest CVAST news.",
            slug="news"
        )

        news_page = NewsPage(
            title="Archeologists Uncover New Economic History of Ancient Rome",
            location="Agrigento, Italy",
            date="2017-08-15",
            intro="University of South Florida researchers are the first to successfully excavate the Roman villa of Durrueli at Realmonte, located off the southern coast of Sicily.",
            slug="archeologists-uncover-new-economic-history-ancient-rome"
        )


        logging.info("Add new Home page as child to site root")
        site = Page.objects.get(id=1).specific
        site.add_child(instance=home_page)


        logging.info("Adding Home")
        revision = home_page.save_revision()
        revision.publish()
        home_page.save()


        logging.info("Adding News Index")
        home_page.add_child(instance=news_index_page)
        news_index_page.save_revision().publish()
        news_index_page.save()


        logging.info("Adding News Page")
        news_index_page.add_child(instance=news_page)
        news_page.save_revision().publish()
        news_page.save()


        logging.info("Setting Home as new Site root page")
        site = Site.objects.get(id=1)
        site.root_page = home_page
        site.save()


        logging.info("Deleting default home page...")
        try:
            default_home = Page.objects.filter(title="Welcome to your new Wagtail site!")
            default_home.delete()
        except:
            pass
