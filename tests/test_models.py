from app.models import HealthResponse, Solicitud, Respuesta, incrementar_contador


def test_health_response_model():
    resp = HealthResponse(status="ok", service="microservicio-echo")
    assert resp.status == "ok"
    assert resp.service == "microservicio-echo"


def test_solicitud_and_respuesta_models():
    solicitud = Solicitud(nombre="Ana", id=1)
    respuesta = Respuesta(nombre=solicitud.nombre, id=solicitud.id, consecutivo=1)
    assert respuesta.consecutivo == 1


def test_incrementar_contador_is_monotonic():
    first = incrementar_contador()
    second = incrementar_contador()
    assert second == first + 1
