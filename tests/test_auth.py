from tests.conftest import register_user


def test_register_and_get_profile(client):
    headers = register_user(client, "alice@example.com", name="Alice")

    response = client.get("/api/users/me", headers=headers)
    assert response.status_code == 200
    body = response.json()
    assert body["email"] == "alice@example.com"
    assert body["name"] == "Alice"
    assert body["photos"] == []


def test_duplicate_email_rejected(client):
    register_user(client, "bob@example.com", name="Bob")
    response = client.post(
        "/api/auth/register",
        json={
            "email": "bob@example.com",
            "password": "anotherpass1",
            "name": "Bob Two",
            "birthdate": "1990-01-01",
            "gender": "man",
        },
    )
    assert response.status_code == 400


def test_minor_registration_rejected(client):
    response = client.post(
        "/api/auth/register",
        json={
            "email": "young@example.com",
            "password": "supersecret1",
            "name": "Young Person",
            "birthdate": "2015-01-01",
            "gender": "man",
        },
    )
    assert response.status_code == 422


def test_login_success_and_failure(client):
    register_user(client, "carol@example.com", name="Carol")

    good = client.post(
        "/api/auth/login", json={"email": "carol@example.com", "password": "supersecret1"}
    )
    assert good.status_code == 200
    assert "access_token" in good.json()

    bad = client.post(
        "/api/auth/login", json={"email": "carol@example.com", "password": "wrongpassword"}
    )
    assert bad.status_code == 401


def test_me_requires_auth(client):
    response = client.get("/api/users/me")
    assert response.status_code == 401
