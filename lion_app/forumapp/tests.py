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
            name="private topuc",
            is_private=True,
            owner=cls.superuser,
        )
        cls.authorized_user = User.objects.create_user("authorized")
        cls.unauthorized_user = User.objects.create_user("unauthorized")
        TopicGroupUser.objects.create(
            topic=cls.private_topic,
            group=TopicGroupUser.GroupChoices.common,
            user=cls.authorized_user,
        )

    def test_write_permission_on_private_topic(self):
        # unauthorzied tries to write a post on Topic -> fail, 401
        self.client.force_login(self.unauthorized_user)
        data = {
            "title": "test",
            "content": "test",
            "topic": self.private_topic.pk,
        }
        # res = self.client.post("http://localhost:8000/forum/post/", data=data) 리버스 사용전
        res = self.client.post(reverse("post-list"), data=data)
        # data["owner"] = self.unauthorized_user.pk  # onwer 추가
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # authorized user tries to write a post on Topic -> success, 201
        self.client.force_login(self.authorized_user)
        # data["owner"] = self.authorized_user.pk  # onwer 만 변경
        # res = self.client.post("http://localhost:8000/forum/post/", data=data) 리버스 사용전
        res: HttpResponse = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        data = json.loads(res.content)
        Post.objects.get(pk=data["id"])
