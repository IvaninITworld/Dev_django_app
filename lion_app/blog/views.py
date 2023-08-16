# 내장 라이브러리

# Third party 라이브러리
from pymongo import MongoClient
from django.http import JsonResponse
from rest_framework.viewsets import ViewSet
from rest_framework.response import Response
from rest_framework import status

# my 라이브러리
from .serializers import BlogSerializer

client = MongoClient(host="mongo")
db = client.likelion


class BlogViewSet(ViewSet):
    # Define serializer
    serializer_class = BlogSerializer

    def list(self, request):
        return Response(status=status.HTTP_200_OK)

    def create(self, request):
        """
        request.data = {
            "title" : "My first blog",
            "content" : "This is my first blog",
            "author" : "lion",
        }
        """
        serializer = BlogSerializer(data=request.data)
        if serializer.is_valid():
            serializer.create(serializer.validated_data)
            # serializer.save()
            return Response(status=status.HTTP_201_CREATED, data=serializer.data)
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST, data=serializer.errors)

    def update(self, request):
        pass

    def retrieve(self, request):
        pass

    def destroy(self, request):
        pass


def create_blog(rquest) -> bool:
    blog = {
        "title": "My first blog",
        "content": "This is my first blog",
        "author": "lion",
    }
    try:
        db.blogs.insert_one(blog)
        return True
    except Exception as e:
        print(e)
        return False


def update_blog():
    pass


def delete_blog():
    pass


def read_blog():
    pass
