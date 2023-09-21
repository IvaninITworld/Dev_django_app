import requests
from faker import Faker

# r = requests.get("http://localhost:8000/health/")
# print(r.json())


class APIHandler:
    urls = {
        "topic": "/forum/topics/",
        "post": "/forum/posts/",
    }

    def __init__(self, model: str, host: str = "http://localhost:8000"):
        self.model = model
        self.host = host
        self.access, self.fresh = self._login()

    def _get_url(self, detail=False, pk: int = None) -> str:
        root_url = f"{self.host}{self.urls.get(self.model)}"
        if detail:
            return f"{root_url}{pk}"
        return root_url

    def _generate_data(self, fk: int = None) -> dict:
        fake = Faker()
        if self.model == "post":
            data = {
                "topic": fk,
                "title": fake.text(max_nb_chars=20),
                "content": fake.text(max_nb_chars=100),
            }
        elif self.model == "topic":
            data = {
                "name": fake.text(max_nb_chars=10),
                "is_private": False,
            }
        else:
            raise Exception
        return data

    def _get_pk(self, model: str = None) -> int:
        lst = self.list(model)
        return lst[0].pk

    def _login(self):
        url = f"{self.host}/api/token/"
        data = {
            "username": "admin",
            "password": "admin",
        }
        res = requests.post(url, data=data)
        res_data = res.json()
        return res_data.get("access"), res_data.get("refresh")

    def _api_call(self, method: str, url: str, data: dict = None):
        request = {
            "url": url,
            "data": data,
            "headers": {"Authorization": f"Bearer {self.access}"},
        }
        # if method == "post":
        #     requests.post(**request)
        # elif method == "get":
        #     requests.get(**request)
        # elif method == "put":
        #     requests.put(**request)
        # elif method == "delete":
        #     requests.delete(**request)
        # else:
        #     raise Exception
        getattr(requests, method)(**request)

    def create(self):
        if self.model == "topic":
            self._api_call("post", url=self._get_url(), data=self._generate_data())
        elif self.model == "post":
            fk = self._get_pk("topic")
            self._api_call("post", url=self._get_url(), data=self._generate_data(fk))

    def list(self, model: str = None):
        target_model = model or self.model
        if target_model == "topic":
            res = requests.get(self._get_url())
        elif target_model == "post":
            res = requests.get(
                f"{self.host}/forum/topics/{self._get_pk('topic')}/posts"
            )
        else:
            raise Exception
        return res

    def update(self):
        pk = self._get_pk()
        if self.model == "topic":
            fk = self._get_pk("user")
        elif self.model == "post":
            fk = self._get_pk("topic")
        requests.put(self._get_url(pk=pk), data=self._generate_data(fk))

    def detail(self):
        pk = self._get_pk()
        requests.delete(self._get_url(detail=True, pk=pk))

    def destroy(self):
        pk = self._get_pk()
        requests.get(self._get_url(detail=True, pk=pk))


if __name__ == "__main__":
    topic_handler = APIHandler("topic")
    post_handler = APIHandler("post")

    topic_handler.create()
    topic_list_res = topic_handler.list()
    print("Topic List: ", topic_list_res.json())

    post_handler.create()
    post_list_res = post_handler.list()
    print("Post List: ", post_list_res.json())
