from pydantic import BaseModel, Field
from threading import Lock


class HealthResponse(BaseModel):
    status: str = Field(description="Estado actual del servicio", examples=["ok"])
    service: str = Field(
        description="Nombre del servicio", examples=["microservicio-echo"]
    )

    model_config = {
        "json_schema_extra": {
            "examples": [{"status": "ok", "service": "microservicio-echo"}]
        }
    }


# Contador en memoria (se reinicia si la API se reinicia)
_contador = 0
_lock = Lock()  # para evitar problemas si llegan varias peticiones al tiempo


def incrementar_contador() -> int:
    global _contador
    with _lock:
        _contador += 1
        return _contador


class Solicitud(BaseModel):
    nombre: str
    id: int


class Respuesta(BaseModel):
    nombre: str
    id: int
    consecutivo: int
