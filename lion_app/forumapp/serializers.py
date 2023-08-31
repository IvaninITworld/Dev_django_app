from rest_framework import serializers
from .models import Topic, Post


class PostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = "__all__"

        read_only_fields = (  # 변경요청시 denied
            "id",
            "owner",
            "created_at",
            "updated_at",
        )


class PostUploadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = (
            "id",
            "topic",
            "title",
            "content",
            "image",
            "owner",
            "created_at",
            "updated_at",
            "content",
            "image",
        )

        read_only_fields = (
            "id",
            "owner",
            "created_at",
            "updated_at",
        )

    image = serializers.ImageField(required=False)


class TopicSerializer(serializers.ModelSerializer):
    # 모델을 시리얼라이져로 가져올 때는 Meta 를 정의
    class Meta:  # 어떤 모델을, 어떤 필드를 가져올지
        model = Topic
        fields = (
            "id",
            "name",
            "is_private",
            "owner",
            "created_at",
            "updated_at",
            "posts",
        )

        # 유저가 수정하면 안되는 부분들을 정리
        read_only_fields = (
            "id",
            "created_at",
            "updated_at",
        )

    # 함수를 지정해주는 작업
    posts = serializers.SerializerMethodField()

    # related_name 으로 posts 를 지정했기 때문에 posts 로 특정 Topic 과 관련된
    # 모든 Post 를 post 로 가져올 수 있다.
    def get_posts(self, obj: Topic):
        posts = obj.posts.all()
        return PostSerializer(posts, many=True).data
