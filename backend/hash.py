import hashlib
import os


def hash_password(password: str) -> str:
    salt = os.urandom(16).hex()
    password_hash = hashlib.sha256((salt + password).encode("utf-8")).hexdigest()
    return f"{salt}${password_hash}"


def verify_password(password: str, stored_password: str) -> bool:
    try:
        salt, expected_hash = stored_password.split("$")
        candidate_hash = hashlib.sha256((salt + password).encode("utf-8")).hexdigest()
        return candidate_hash == expected_hash
    except ValueError:
        return False