from django.core.management import BaseCommand
from django.contrib.auth.models import User
from forumapp.models import Post, Topic, TopicGroupUser
from django_seed import Seed
from random import sample


# class Command(BaseCommand):
#     help = "This command creates random users, posts, and follows"

#     def handle(self, *args, **kwargs):
#         seeder = Seed.seeder()
#         fake = seeder.faker

#         # Seed users
#         user_data = []
#         for i in range(5):
#             username = fake.user_name()
#             email = fake.email()
#             password = "1234"
#             user = User.objects.create_user(
#                 username=username, email=email, password=password
#             )
#             user_data.append(user)

#         # Seed posts
#         for user in user_data:
#             for i in range(3):
#                 title = fake.sentence(nb_words=5)
#                 content = fake.text(max_nb_chars=20)
#                 Post.objects.create(title=title, content=content, author=user)

#         # Seed follows
#         for user in user_data:
#             followers = []
#             for other_user in user_data:
#                 if other_user != user:
#                     followers.append(other_user)

#             selected_followers = sample(followers, 2)
#             for follower in selected_followers:
#                 Follow.objects.create(follower=user, following=follower)

#         self.stdout.write(self.style.SUCCESS("Data seeded successfully"))
