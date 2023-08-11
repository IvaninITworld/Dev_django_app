
from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from django.conf import settings
from django.conf.urls.static import static

# from blog.urls import urlpatterns as blog_urls
from blog.urls import router as blog_router
from forumapp.urls import router as forum_router

urlpatterns = [
    path('admin/', admin.site.urls),
    path('blog/', include(blog_router.urls)),
    path('forum/', include(forum_router.urls)),
    path('api-auth/', include('rest_framework.urls')),

    # drf-spectacular
    # api 문서를 다운 받을 수 있는 
    path('api/schema/', SpectacularAPIView.as_view(), name='api-schema'),
    # Optional UI:
    # api 문서를 읽을 수 있는
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='api-schema'), name='api-swagger-ui'),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)



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