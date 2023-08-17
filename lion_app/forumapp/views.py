from django.shortcuts import get_object_or_404

# from django.db.models import Q
from drf_spectacular.utils import extend_schema
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.request import Request
from rest_framework.response import Response

# from rest_framework.exceptions import PermissionDenied

from .models import Topic, Post, TopicGroupUser
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

    # "Topic-posts" 를 사용하기 위한 셋업
    @action(detail=True, methods=["get"], url_name="posts")
    def posts(self, request: Request, *args, **kwargs):
        # need to update here
        topic: Topic = self.get_object()  # Topic 가져오기
        user = request.user
        # Authorization check
        # If user without permission, return 401

        qs = TopicGroupUser.objects.filter(
            # Q(group=0) | Q(group=1),
            group__lte=TopicGroupUser.GroupChoices.common,
            topic=topic,
            user=user,
        )
        if topic.is_private and not qs.exists():
            return Response(
                status=status.HTTP_401_UNAUTHORIZED,
                data="This user is denied to access to this Topic",
            )

        # else, return posts
        posts = Post.objects.filter(topic=topic)  # Post 가져오기
        # posts = topic.posts # 이렇게도 가능
        serializer = PostSerializer(posts, many=True)
        return Response(data=serializer.data)


@extend_schema(tags=["Post"])
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer

    def create(self, request: Request, *args, **kwargs):
        # check group and topic if user has right permission to write a post
        # return 403 forbidden
        user = request.user
        data = request.data
        topic_id = data.get("topic")
        topic = get_object_or_404(Topic, id=topic_id)

        qs = TopicGroupUser.objects.filter(
            # Q(group=0) | Q(group=1),
            group__lte=TopicGroupUser.GroupChoices.common,
            topic=topic,
            user=user,
        )
        if topic.is_private and not qs.exists():
            return Response(
                status=status.HTTP_401_UNAUTHORIZED,
                data="This user is denied to access to this Topic",
            )
            # raise PermissionDenied("Forbidden")

        serializer = PostSerializer(data=request.data)

        if serializer.is_valid():
            data = serializer.validated_data
            data["owner"] = user
            res = serializer.create(data)
            return Response(
                status=status.HTTP_201_CREATED, data=PostSerializer(res).data
            )
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST, data=serializer.errors)

        # return super().create(request, *args, **kwargs)
