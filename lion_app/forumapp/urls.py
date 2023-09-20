from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register("topics", views.TopicViewSet, basename="topic")
router.register("posts", views.PostViewSet, basename="post")
