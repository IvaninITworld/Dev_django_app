from django.shortcuts import get_object_or_404
from django.db.models import Q
from rest_framework import viewsets, status
from drf_spectacular.utils import extend_schema
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.exceptions import PermissionDenied

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


@extend_schema(tags=["Post"])
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer

    def create(self, request: Request, *args, **kwargs):
        # check group and topic if user has right permission to write a post
        # return 403 forbidden
        data = request.data
        topic_id = data.get("topic")
        topic = get_object_or_404(Topic, id=topic_id)

        if topic.is_private:
            qs = TopicGroupUser.objects.filter(
                # Q(group=0) | Q(group=1),
                group_lte=TopicGroupUser.groupChoices.common,
                topic=topic,
                user=user,
            )

            if not qs.exists():
                return Response(
                    status=status.HTTP_401_UNAUTHORIZED,
                    data="This user is not allowed to write a post on this Topic",
                )
                # raise PermissionDenied("Forbidden")

            # user A, user B
            # user A = success, user B = Unauthorized

        return super().create(request, *args, **kwargs)
