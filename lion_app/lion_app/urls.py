
from django.contrib import admin
from django.urls import path, include


# from blog.urls import urlpatterns as blog_urls
from blog.urls import router as blog_router
from forumapp.urls import router as forum_router

urlpatterns = [
    path('admin/', admin.site.urls),
    path('blog/', include(blog_router.urls)),
    path('forum/', include(forum_router.urls)),
    path('api-auth/', include('rest_framework.urls')),
]



# Quickstart for DRF
# from django.urls import include, path
# from rest_framework import routers
# from quickstart import views


# router = routers.DefaultRouter()
# router.register(r'users', views.UserViewSet)
# router.register(r'groups', views.GroupViewSet)

# urlpatterns = [
#     path('', include(router.urls)),
#     path('api-auth/', include('rest_framework.urls', namespace='rest_framework'))
# ]