from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_liveness():
    assert client.get("/health/live").json() == {"status": "alive"}

def test_readiness():
    assert client.get("/health/ready").status_code == 200

def test_root():
    assert client.get("/").json()["no_phi"] is True

def test_metrics():
    assert client.get("/metrics").status_code == 200
