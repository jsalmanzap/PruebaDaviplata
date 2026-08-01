from pydantic import BaseModel, Field
from pydantic import BaseModel
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
contador = 0
lock = Lock()  # para evitar problemas si llegan varias peticiones al tiempo
 
 
class Solicitud(BaseModel):
    nombre: str
    id: int
 
 
class Respuesta(BaseModel):
    nombre: str
    id: int
    consecutivo: int