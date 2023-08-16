from django.urls import path
from rest_framework.routers import DefaultRouter
from . import views

# urlpatterns= [
#     path('', views.create_blog, name='blog-create'),
# ]

router = DefaultRouter()
router.register("", views.BlogViewSet, basename="blog")
