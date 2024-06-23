import pytest
from starlette.testclient import TestClient

from web_app.main import app


@pytest.fixture
def client():
    return TestClient(app)


def test_health_check(client: TestClient):
    """
    GIVEN FastAPI application
    WHEN health check endpoint is called with GET method
    THEN it should return 200 status code and response should be {"status": "ok"}
    """
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
