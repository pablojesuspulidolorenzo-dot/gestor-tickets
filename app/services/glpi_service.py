from __future__ import annotations

from dataclasses import dataclass
from typing import Any
from urllib.parse import urljoin

import httpx

from app.core.config import settings


@dataclass(frozen=True)
class GlpiProfile:
    id: int | None
    name: str
    raw: dict[str, Any]


@dataclass(frozen=True)
class GlpiValidationResult:
    ok: bool
    login: str
    required_profile: str
    has_required_profile: bool
    profiles: list[GlpiProfile]
    glpi_user_id: int | None = None
    glpi_user_name: str | None = None
    message: str = ""
    raw_session: dict[str, Any] | None = None


class GlpiService:
    """
    Cliente mínimo para validar cuentas principales contra GLPI.

    Importante:
    Algunas instalaciones de GLPI aceptan el App Token como cabecera App-Token,
    pero otras lo exigen como parámetro app_token. Para evitar incompatibilidades,
    se envía de ambas formas cuando GLPI_APP_TOKEN está configurado.
    """

    def __init__(
        self,
        *,
        base_url: str | None = None,
        app_token: str | None = None,
        required_profile: str | None = None,
        timeout_seconds: int | None = None,
    ) -> None:
        self.base_url = (base_url or settings.GLPI_BASE_URL).rstrip("/") + "/"
        self.app_token = app_token if app_token is not None else settings.GLPI_APP_TOKEN
        self.required_profile = required_profile or settings.GLPI_REQUIRED_PROFILE
        self.timeout_seconds = timeout_seconds or settings.GLPI_TIMEOUT_SECONDS

    def _api_url(self, path: str) -> str:
        return urljoin(self.base_url, f"apirest.php/{path.lstrip('/')}")

    def _headers(self, session_token: str | None = None) -> dict[str, str]:
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
        }

        if self.app_token:
            headers["App-Token"] = self.app_token

        if session_token:
            headers["Session-Token"] = session_token

        return headers

    def _params(self) -> dict[str, str]:
        if not self.app_token:
            return {}
        return {"app_token": self.app_token}

    async def init_session_with_basic_auth(self, login: str, password: str) -> str:
        async with httpx.AsyncClient(timeout=self.timeout_seconds) as client:
            response = await client.get(
                self._api_url("initSession"),
                headers=self._headers(),
                params=self._params(),
                auth=httpx.BasicAuth(login, password),
            )

        if response.status_code != 200:
            raise ValueError(
                f"GLPI rechazó las credenciales o la API no está disponible "
                f"(HTTP {response.status_code}): {response.text[:500]}"
            )

        data = response.json()
        token = data.get("session_token")
        if not token:
            raise ValueError(f"GLPI no devolvió session_token en initSession. Respuesta: {data}")

        return token

    async def kill_session(self, session_token: str) -> None:
        try:
            async with httpx.AsyncClient(timeout=self.timeout_seconds) as client:
                await client.get(
                    self._api_url("killSession"),
                    headers=self._headers(session_token),
                    params=self._params(),
                )
        except Exception:
            pass

    async def get_my_profiles(self, session_token: str) -> list[GlpiProfile]:
        async with httpx.AsyncClient(timeout=self.timeout_seconds) as client:
            response = await client.get(
                self._api_url("getMyProfiles"),
                headers=self._headers(session_token),
                params=self._params(),
            )

        if response.status_code != 200:
            raise ValueError(
                f"No se pudieron consultar perfiles GLPI "
                f"(HTTP {response.status_code}): {response.text[:500]}"
            )

        data = response.json()
        profiles_raw = data if isinstance(data, list) else data.get("myprofiles", [])

        profiles: list[GlpiProfile] = []
        for item in profiles_raw or []:
            if not isinstance(item, dict):
                continue

            profile_id = item.get("id") or item.get("profiles_id")
            try:
                profile_id = int(profile_id) if profile_id is not None else None
            except (TypeError, ValueError):
                profile_id = None

            name = str(item.get("name") or item.get("completename") or "").strip()
            if name:
                profiles.append(GlpiProfile(id=profile_id, name=name, raw=item))

        return profiles

    async def get_full_session(self, session_token: str) -> dict[str, Any]:
        async with httpx.AsyncClient(timeout=self.timeout_seconds) as client:
            response = await client.get(
                self._api_url("getFullSession"),
                headers=self._headers(session_token),
                params=self._params(),
            )

        if response.status_code != 200:
            return {}

        data = response.json()
        if isinstance(data, dict):
            return data.get("session", data)
        return {}

    async def validate_account_manager_login(
        self,
        *,
        login: str,
        password: str,
    ) -> GlpiValidationResult:
        clean_login = (login or "").strip()
        if not clean_login:
            return GlpiValidationResult(
                ok=False,
                login=clean_login,
                required_profile=self.required_profile,
                has_required_profile=False,
                profiles=[],
                message="El login GLPI no puede estar vacío.",
            )

        session_token: str | None = None

        try:
            session_token = await self.init_session_with_basic_auth(clean_login, password)
            profiles = await self.get_my_profiles(session_token)
            raw_session = await self.get_full_session(session_token)

            required_lower = self.required_profile.casefold()
            has_required = any(p.name.casefold() == required_lower for p in profiles)

            glpi_user_id = (
                raw_session.get("glpiID")
                or raw_session.get("glpiid")
                or raw_session.get("id")
            )
            try:
                glpi_user_id = int(glpi_user_id) if glpi_user_id is not None else None
            except (TypeError, ValueError):
                glpi_user_id = None

            glpi_user_name = (
                raw_session.get("glpiname")
                or raw_session.get("glpiName")
                or raw_session.get("glpiUserName")
                or raw_session.get("name")
                or clean_login
            )

            if not has_required:
                profile_names = ", ".join(p.name for p in profiles) or "sin perfiles"
                return GlpiValidationResult(
                    ok=False,
                    login=clean_login,
                    required_profile=self.required_profile,
                    has_required_profile=False,
                    profiles=profiles,
                    glpi_user_id=glpi_user_id,
                    glpi_user_name=str(glpi_user_name) if glpi_user_name else None,
                    raw_session=raw_session,
                    message=(
                        f"El usuario existe en GLPI, pero no tiene el perfil requerido "
                        f"'{self.required_profile}'. Perfiles detectados: {profile_names}."
                    ),
                )

            return GlpiValidationResult(
                ok=True,
                login=clean_login,
                required_profile=self.required_profile,
                has_required_profile=True,
                profiles=profiles,
                glpi_user_id=glpi_user_id,
                glpi_user_name=str(glpi_user_name) if glpi_user_name else None,
                raw_session=raw_session,
                message="Login GLPI válido y perfil requerido presente.",
            )

        except Exception as exc:
            return GlpiValidationResult(
                ok=False,
                login=clean_login,
                required_profile=self.required_profile,
                has_required_profile=False,
                profiles=[],
                message=str(exc),
            )

        finally:
            if session_token:
                await self.kill_session(session_token)


glpi_service = GlpiService()
