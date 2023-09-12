from django.http import JsonResponse
from django.conf import settings
from django.http import HttpResponseServerError


class HealthcheckMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if settings.VERSION == "unhealthy":
            return JsonResponse({"status": "unhealthy"}, status=500)

        if request.path == "/health/":
            return JsonResponse({"status": "ok"})

        return self.get_response(request)  # 그 다음 미들웨어로 보낸다...
