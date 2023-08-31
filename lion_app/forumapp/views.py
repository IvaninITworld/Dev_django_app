import uuid
import boto3

from django.shortcuts import get_object_or_404
from django.conf import settings
from django.core.files.base import File

# from django.db.models import Q
from drf_spectacular.utils import extend_schema
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.request import Request
from rest_framework.response import Response

# from rest_framework.exceptions import PermissionDenied

from .models import Topic, Post, TopicGroupUser
from .serializers import TopicSerializer, PostSerializer, PostUploadSerializer

# 코드 리팩토링... 장고에서 코드 리펙토링할 떄 중요한건 !
# Views.py 를 간결하게 하고 최대한 models 와 serializer 를 활용할 수 있게 하자


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
        if not topic.can_be_access_by(user):
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
    serializer_class = PostSerializer  # 항상 기재해야하는 트리거?

    def get_serializer_class(self):
        if self.action == "create":
            return PostUploadSerializer  # api doc 때문에 명시
        return super().get_serializer_class()

    @extend_schema(deprecated=True)
    def list(self, request, *args, **kwargs):
        return Response(status=status.HTTP_400_BAD_REQUEST, data="Deprecated API")

    def create(self, request: Request, *args, **kwargs):
        # check group and topic if user has right permission to write a post
        # return 403 forbidden
        user = request.user
        data = request.data
        topic_id = data.get("topic")
        topic = get_object_or_404(Topic, id=topic_id)

        if not topic.can_be_access_by(user):
            return Response(
                status=status.HTTP_401_UNAUTHORIZED,
                data="This user is denied to access to this Topic",
            )
            # raise PermissionDenied("Forbidden")

        # if image exists.
        # upload it to Object Storage(S3)
        # and save the url to image_url field
        if image := data.get("image"):  # ":=" 으른쪽에 있는 변수가 존재하면 image 변수에 할당
            print(type(image))
            image: File
            endpont_url = "https://kr.object.ncloudstorage.com"
            access_key = settings.NCP_ACCESS_KEY
            secret_key = settings.NCP_SECRET_KEY
            bucket_name = "post-image-mh"

            s3 = boto3.client(
                "s3",
                endpoint_url=endpont_url,
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key,
            )
            image_id = str(uuid.uuid4())  # unique id created
            ext = image.name.split(".")[-1]
            image_filename = f"{image_id}.{ext}"
            s3.upload_fileobj(
                image.file, bucket_name, image_filename
            )  # url 을 그대로 사용하면 보안상 문제가 될 수 있어어 UUID 사용
            s3.put_object_acl(
                ACL="public-read",
                Bucket=bucket_name,
                Key=image_filename,
            )
            image_url = f"{endpont_url}/{bucket_name}/{image_id}"

        serializer = PostSerializer(data=request.data)  # is_valid() 를 활성화하기 위함
        if serializer.is_valid():
            data = serializer.validated_data
            data["owner"] = user
            data["image_url"] = image_url if image else None
            res = serializer.create(data)
            return Response(
                status=status.HTTP_201_CREATED, data=PostSerializer(res).data
            )
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST, data=serializer.errors)

        # return super().create(request, *args, **kwargs)

    def retrieve(self, request: Request, *args, **kwargs):
        user = request.user
        post: Post = self.get_object()
        topic = post.topic
        # Authorization check
        if not topic.can_be_access_by(user):
            return Response(
                status=status.HTTP_401_UNAUTHORIZED,
                data="This user is not allowed to read this post",
            )

        return super().retrieve(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        post: Post = self.get_object()
        topic: Topic = post.topic
        if (
            TopicGroupUser.objects.filter(
                user=request.user,
                group=TopicGroupUser.GroupChoices.admin,
                topic=topic,
            ).exists()
            or topic.owner == request.user
            or post.owner == request.user
        ):
            return super().destroy(request, *args, **kwargs)
        else:
            return Response(
                status=status.HTTP_401_UNAUTHORIZED,
                data="This user is not allowed to delete this post",
            )
