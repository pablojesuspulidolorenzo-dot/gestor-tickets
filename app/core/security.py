import base64
import hashlib
import hmac
import os
from dataclasses import dataclass

from cryptography.fernet import Fernet, InvalidToken

from app.core.config import settings


def _derive_fernet_key(secret: str) -> bytes:
    """
    Deriva una clave Fernet válida a partir de APP_ENCRYPTION_SECRET.

    Así no obligamos a que el .env contenga una clave Fernet exacta;
    puede contener un secreto largo normal.
    """
    digest = hashlib.sha256(secret.encode("utf-8")).digest()
    return base64.urlsafe_b64encode(digest)


def get_fernet() -> Fernet:
    return Fernet(_derive_fernet_key(settings.APP_ENCRYPTION_SECRET))


def encrypt_text(plain_text: str) -> str:
    if plain_text is None:
        raise ValueError("No se puede cifrar un valor None")
    return get_fernet().encrypt(plain_text.encode("utf-8")).decode("utf-8")


def decrypt_text(encrypted_text: str) -> str:
    if not encrypted_text:
        raise ValueError("No se puede descifrar un valor vacío")
    try:
        return get_fernet().decrypt(encrypted_text.encode("utf-8")).decode("utf-8")
    except InvalidToken as exc:
        raise ValueError("No se pudo descifrar el valor: secreto incorrecto o dato corrupto") from exc


@dataclass(frozen=True)
class PasswordHash:
    algorithm: str
    iterations: int
    salt: str
    digest: str

    def serialize(self) -> str:
        return f"{self.algorithm}${self.iterations}${self.salt}${self.digest}"


def hash_password(password: str, iterations: int = 390_000) -> str:
    """
    Hash PBKDF2-SHA256 para contraseñas locales de colaboradores.

    No se guardan contraseñas en claro.
    """
    if not password:
        raise ValueError("La contraseña no puede estar vacía")

    salt_bytes = os.urandom(16)
    salt = base64.urlsafe_b64encode(salt_bytes).decode("ascii")
    digest = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt_bytes,
        iterations,
    )
    digest_b64 = base64.urlsafe_b64encode(digest).decode("ascii")

    return PasswordHash(
        algorithm="pbkdf2_sha256",
        iterations=iterations,
        salt=salt,
        digest=digest_b64,
    ).serialize()


def verify_password(password: str, stored_hash: str) -> bool:
    try:
        algorithm, iterations_raw, salt, digest = stored_hash.split("$", 3)
        if algorithm != "pbkdf2_sha256":
            return False

        iterations = int(iterations_raw)
        salt_bytes = base64.urlsafe_b64decode(salt.encode("ascii"))
        expected_digest = base64.urlsafe_b64decode(digest.encode("ascii"))

        candidate = hashlib.pbkdf2_hmac(
            "sha256",
            password.encode("utf-8"),
            salt_bytes,
            iterations,
        )

        return hmac.compare_digest(candidate, expected_digest)
    except Exception:
        return False
