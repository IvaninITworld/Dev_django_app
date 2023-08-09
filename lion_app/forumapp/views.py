from rest_framework import viewsets

from .models import Topic, Post
from .serializers import TopicSerializer, PostSerializer

# 모델 뷰셋 사용
class TopicViewSet(viewsets.ModelViewSet):
    # 어떤 모델 오브젝트를 쓸꺼니? 
    # all() -> create ~ list ~ 전부 알아서 작성됨
    queryset = Topic.objects.all()
    # 어떤 시리얼라이저 쓸꺼니?
    serializer_class = TopicSerializer

class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer