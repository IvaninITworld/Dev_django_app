
from rest_framework import serializers
from .models import Topic, Post

class TopicSerializer(serializers.ModelSerializer):
    # 모델을 시리얼라이져로 가져올 때는 Meta 를 정의
    class Meta: # 어떤 모델을, 어떤 필드를 가져올지
        model = Topic
        fields = "__all__"
        
        # 유저가 수정하면 안되는 부분들을 정리
        read_only_fields =(
            "id",
            "created_at",
            "updated_at",
        )


class PostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = "__all__"

        read_only_fields =(
            "id",
            "created_at",
            "updated_at",
        )