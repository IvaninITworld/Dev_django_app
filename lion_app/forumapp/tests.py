# from django.test import TestCase
import json
from django.http import HttpResponse
from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status

from .models import Topic, Post, TopicGroupUser


class PostTest(APITestCase):
    # setup
    # Topic - if private
    # user A, user B
    # user A = success, user B = Unauthorized
    @classmethod
    def setUpTestData(cls):
        cls.superuser = User.objects.create_superuser(
            username="superuser",
            email=None,
            password=None,
        )
        cls.private_topic = Topic.objects.create(
            name="private topic",
            is_private=True,
            owner=cls.superuser,
        )
        cls.public_topic = Topic.objects.create(
            name="pubilc topic", is_private=False, owner=cls.superuser
        )
        # Posts on private topic
        for i in range(5):
            Post.objects.create(
                topic=cls.private_topic,
                title=f"private {i+1}",
                content=f"private {i+1}",
                owner=cls.superuser,
            )

        # Posts on public topic
        for i in range(5):
            Post.objects.create(
                topic=cls.public_topic,
                title=f"public {i+1}",
                content=f"public {i+1}",
                owner=cls.superuser,
            )

        cls.authorized_user = User.objects.create_user("authorized")
        cls.unauthorized_user = User.objects.create_user("unauthorized")
        cls.admin = User.objects.create_user("admin")

        TopicGroupUser.objects.create(
            topic=cls.private_topic,
            group=TopicGroupUser.GroupChoices.common,
            user=cls.authorized_user,
        )

    def test_write_permission_on_private_topic(self):
        # setup : given data
        data = {
            "title": "test",
            "content": "test",
            "topic": self.private_topic.pk,
        }

        # unauthorzied tries to write a post on Topic -> fail, 401
        self.client.force_login(self.unauthorized_user)
        # res = self.client.post("http://localhost:8000/forum/post/", data=data) # 리버스 사용전
        res = self.client.post(reverse("post-list"), data=data)
        # data["owner"] = self.unauthorized_user.pk  # onwer 추가 # views 에서 정의
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # authorized user tries to write a post on Topic -> success, 201
        self.client.force_login(self.authorized_user)
        # res = self.client.post("http://localhost:8000/forum/post/", data=data) # 리버스 사용전
        # data["owner"] = self.authorized_user.pk  # onwer 만 변경 # views 에서 정의
        res: HttpResponse = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        res_data = json.loads(res.content)
        Post.objects.get(pk=res_data["id"])

        # Owner
        self.client.force_login(self.superuser)
        res: HttpResponse = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        res_data = json.loads(res.content)
        Post.objects.get(pk=res_data["id"])

        # Admin
        # self.client.force_login(self.admin)
        # res: HttpResponse = self.client.post(reverse("post-list"), data=data)
        # self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        # res_data = json.loads(res.content)
        # Post.objects.get(pk=res_data["id"])

    def test_read_permission_on_topics(self):
        # read public topic
        # unauthorized user requests -> 200. public topic's posts
        self.client.force_login(self.unauthorized_user)
        res = self.client.get(reverse("topic-posts", args=[self.public_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.public_topic).count()
        self.assertEqual(len(data), posts_n)

        # read private topic
        # unauthorized user requests -> 401.
        self.client.force_login(self.unauthorized_user)
        res = self.client.get(reverse("topic-posts", args=[self.private_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # authorized user requests -> 200. private topic's posts
        self.client.force_login(self.authorized_user)
        res = self.client.get(reverse("topic-posts", args=[self.private_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.private_topic).count()
        self.assertEqual(len(data), posts_n)
