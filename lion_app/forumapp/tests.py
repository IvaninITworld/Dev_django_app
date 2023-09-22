# from django.test import TestCase
import json
import tempfile
from unittest.mock import patch, MagicMock

from django.http import HttpResponse
from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework.test import APITestCase, APIClient
from rest_framework import status

from .models import Topic, Post, TopicGroupUser


class PostTest(APITestCase):
    # setup
    # Topic - if private
    # user A, user B
    # user A = success, user B = Unauthorized
    def __init__(self, methodName: str = "runTest") -> None:
        super().__init__(methodName)
        self.client = APIClient()

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

        # authorized & unauthorized
        cls.authorized_user = User.objects.create_user("authorized")
        cls.unauthorized_user = User.objects.create_user("unauthorized")

        TopicGroupUser.objects.create(
            topic=cls.private_topic,
            group=TopicGroupUser.GroupChoices.common,
            user=cls.authorized_user,
        )

        # admin user
        cls.admin = User.objects.create_user("admin")
        TopicGroupUser.objects.create(
            topic=cls.private_topic,
            group=TopicGroupUser.GroupChoices.admin,
            user=cls.admin,
        )

    def test_write_permission_on_private_topic(self):
        # setup : given data
        data = {
            "title": "test",
            "content": "test",
            "topic": self.private_topic.pk,
        }

        # unauthorzied tries to write a post on Topic -> fail, 401
        self.client.force_authenticate(self.unauthorized_user)
        # res = self.client.post("http://localhost:8000/forum/post/", data=data) # 리버스 사용전
        res = self.client.post(reverse("post-list"), data=data)
        # data["owner"] = self.unauthorized_user.pk  # onwer 추가 # views 에서 정의
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # authorized user tries to write a post on Topic -> success, 201
        self.client.force_authenticate(self.authorized_user)
        # res = self.client.post("http://localhost:8000/forum/post/", data=data) # 리버스 사용전
        res: HttpResponse = self.client.post(reverse("post-list"), data=data)
        # data["owner"] = self.authorized_user.pk  # onwer 만 변경 # views 에서 정의
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        res_data = json.loads(res.content)
        Post.objects.get(pk=res_data["id"])

        # Owner
        self.client.force_authenticate(self.superuser)
        res: HttpResponse = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        res_data = json.loads(res.content)
        Post.objects.get(pk=res_data["id"])

        # Admin
        self.client.force_authenticate(self.admin)
        res: HttpResponse = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        res_data = json.loads(res.content)
        Post.objects.get(pk=res_data["id"])

    def test_read_permission_on_topics(self):
        # read public topic
        # unauthorized user requests -> 200. public topic's posts
        self.client.force_authenticate(self.unauthorized_user)
        res = self.client.get(reverse("topic-posts", args=[self.public_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.public_topic).count()
        self.assertEqual(len(data), posts_n)

        # read private topic
        # unauthorized user requests -> 401.
        self.client.force_authenticate(self.unauthorized_user)
        res = self.client.get(reverse("topic-posts", args=[self.private_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # authorized user requests -> 200. private topic's posts
        self.client.force_authenticate(self.authorized_user)
        res = self.client.get(reverse("topic-posts", args=[self.private_topic.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.private_topic).count()
        self.assertEqual(len(data), posts_n)

    def test_read_permission_on_posts(self):
        # read public topic posts
        # unathorized user request => 200
        self.client.force_authenticate(self.unauthorized_user)
        public_post = Post.objects.filter(topic=self.public_topic).first()
        res = self.client.get(reverse("post-detail", args=[public_post.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)

        # read private topic posts
        # unathorized user request => 401
        self.client.force_authenticate(self.unauthorized_user)
        private_post = Post.objects.filter(topic=self.private_topic).first()
        res = self.client.get(reverse("post-detail", args=[private_post.pk]))
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # read private topic posts
        # authorized user request => 200
        self.client.force_authenticate(self.authorized_user)
        private_post = Post.objects.filter(topic=self.private_topic).first()
        res = self.client.get(reverse("post-detail", args=[private_post.pk]))
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    @patch("forumapp.views.boto3.client")
    def test_post_with_or_without_image(self, s3_client: MagicMock):
        # mock s3
        s3 = MagicMock()
        s3_client.return_value = s3
        s3.upload_fileobj.return_value = None
        s3.put_object_acl.return_value = None

        # without image
        data = {
            "title": "test",
            "content": "test",
            "topic": self.private_topic.pk,
        }
        self.client.force_authenticate(self.authorized_user)
        res = self.client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

        # with image
        with tempfile.NamedTemporaryFile(suffix=".jpg") as tmpfile:
            data["image"] = tmpfile
            res = self.client.post(reverse("post-list"), data=data)
            self.assertEqual(res.status_code, status.HTTP_201_CREATED)
            res_data = json.loads(res.content)
            self.assertTrue(res_data["image_url"].startswith("https://"))
            print(res_data["image_url"])

        s3.upload_fileobj.assert_called_once()
        s3.put_object_acl.assert_called_once()

    def test_delete_permission(self):
        # owner can delete any post
        common_user = User.objects.create_user("common1")
        admin_user = User.objects.create_user("admin1")
        post1 = Post.objects.create(
            topic=self.private_topic,
            title="private",
            content="private",
            owner=common_user,
        )
        post2 = Post.objects.create(
            topic=self.private_topic,
            title="post2",
            content="private",
            owner=common_user,
        )
        post3 = Post.objects.create(
            topic=self.private_topic,
            title="post3",
            content="private",
            owner=common_user,
        )
        TopicGroupUser.objects.create(
            topic=self.private_topic,
            group=TopicGroupUser.GroupChoices.common,
            user=common_user,
        )
        TopicGroupUser.objects.create(
            topic=self.private_topic,
            group=TopicGroupUser.GroupChoices.admin,
            user=admin_user,
        )
        topic_owner = self.superuser
        self.client.force_authenticate(topic_owner)
        res = self.client.delete(reverse("post-detail", args=[post1.pk]))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        self.client.force_authenticate(admin_user)
        res = self.client.delete(reverse("post-detail", args=[post2.pk]))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        # admin can delete any post
        # common can delete only their posts
        # unauthorized user can not delete any post
        self.client.force_authenticate(common_user)
        res = self.client.delete(reverse("post-detail", args=[post3.pk]))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        ## another post created by another common user -> fail
        another_common_user = User.objects.create_user("another")
        another_post = Post.objects.create(
            topic=self.private_topic,
            title="another",
            content="another",
            owner=another_common_user,
        )
        self.client.force_authenticate(common_user)
        res = self.client.delete(reverse("post-detail", args=[another_post.pk]))
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)
        # unauthorized user can't delete any post
        ## another post created by another common user -> fail
        self.client.force_authenticate(self.unauthorized_user)
        res = self.client.delete(reverse("post-detail", args=[another_post.pk]))
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)
