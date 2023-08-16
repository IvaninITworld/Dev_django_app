from rest_framework import viewsets
from drf_spectacular.utils import extend_schema

from .models import Topic, Post
from .serializers import TopicSerializer, PostSerializer


# 모델 뷰셋 사용
@extend_schema(tags=["Topic"])
class TopicViewSet(viewsets.ModelViewSet):
    # 어떤 모델 오브젝트를 쓸꺼니?
    # all() -> create ~ list ~ 전부 알아서 작성됨
    queryset = Topic.objects.all()
    # 어떤 시리얼라이저 쓸꺼니?
    serializer_class = TopicSerializer

    @extend_schema(summary="Create new topic")
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


@extend_schema(tags=["Post"])
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
