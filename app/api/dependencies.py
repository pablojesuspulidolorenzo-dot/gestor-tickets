from __future__ import annotations

from fastapi import HTTPException, Request, status


def require_api_session(request: Request) -> dict:
    user = request.session.get("user")
    if not isinstance(user, dict) or not user.get("user_id"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Sesión requerida para este endpoint interno.",
        )
    return user
