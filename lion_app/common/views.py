from django.http import JsonResponse, HttpResponseServerError
from django.conf import settings

request_count = 0


def healthcheck(request):
    return JsonResponse({"status:": "ok"})


# class SimpleCounters:
#     count = 0

#     @classmethod
#     def increment(cls):
#         cls.count += 1
#         return cls.count


# def get_version(request):
#     currenct_count = SimpleCounters.increment()
#     respnse_data = {"version": settings.VERSION, "request_count": currenct_count}
#     return JsonResponse(respnse_data)


# def get_version(request):
#     global request_count
#     request_count += 1

#     response_data = {"version": settings.VERSION, "request_count:": request_count}

#     return JsonResponse(response_data)


def get_version(request):
    global request_count
    response_data = {"version": settings.VERSION}
    return JsonResponse(response_data)
