from django.contrib import admin
from .models import Topic, Post, TopicGroupUser

# Register your models here.

admin.site.register(Topic)
admin.site.register(Post)


# admin.site.register(TopicGroupUser)
@admin.register(TopicGroupUser)
class TopicGroupUserAdmin(admin.ModelAdmin):
    list_display = ("topic", "group", "user")
