from django.db import connection
from django.http import JsonResponse


def health(request):
    """GET /api/v1/health: is the API up, and can it reach MongoDB?"""
    try:
        connection.ensure_connection()
        connection.database.command("ping")
    except Exception as exc:  # report, don't crash: this is the thing we're checking
        return JsonResponse({"status": "error", "database": str(exc)}, status=503)
    return JsonResponse({"status": "ok", "database": connection.settings_dict["NAME"]})
