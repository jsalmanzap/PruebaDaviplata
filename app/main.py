from fastapi import FastAPI

from app.models import Respuesta, Solicitud, HealthResponse, lock

app = FastAPI(
    title="Microservicio E1",
    version="1.0.0",
    contact={"name": "Johan Almanza", "email": "jsalmanzap1941@gmail.com"},
    license_info={"name": "MIT"},
    openapi_tags=[
        {"name": "Health", "description": "Estado del servicio"},
        {"name": "consecutivo", "description": "Contador en memoria"},
    ],
)

@app.get("/health", tags=["Health"], summary="Healthcheck")
def healthcheck() -> HealthResponse:
    return HealthResponse(status="ok", service="Microservicio_E1")

@app.post("/consecutivo", response_model=Respuesta)
def generar_consecutivo(solicitud: Solicitud):
    global contador
    with lock:
        contador += 1
        valor_actual = contador
 
    return Respuesta(
        nombre=solicitud.nombre,
        id=solicitud.id,
        consecutivo=valor_actual,
    )
