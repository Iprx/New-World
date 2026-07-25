import io

from tests.conftest import register_user


def test_update_profile(client):
    headers = register_user(client, "dana@example.com", name="Dana")

    response = client.put(
        "/api/users/me", json={"bio": "Loves hiking"}, headers=headers
    )
    assert response.status_code == 200
    assert response.json()["bio"] == "Loves hiking"
    assert response.json()["name"] == "Dana"


def test_photo_upload_and_delete(client):
    headers = register_user(client, "erin@example.com", name="Erin")

    fake_image = io.BytesIO(b"fake-image-bytes")
    response = client.post(
        "/api/users/me/photos",
        files={"file": ("selfie.jpg", fake_image, "image/jpeg")},
        headers=headers,
    )
    assert response.status_code == 201, response.text
    photo = response.json()
    assert photo["position"] == 0
    assert photo["url"].startswith("/static/uploads/")

    me = client.get("/api/users/me", headers=headers).json()
    assert len(me["photos"]) == 1

    delete_response = client.delete(f"/api/users/me/photos/{photo['id']}", headers=headers)
    assert delete_response.status_code == 204

    me_after = client.get("/api/users/me", headers=headers).json()
    assert me_after["photos"] == []


def test_photo_upload_rejects_bad_content_type(client):
    headers = register_user(client, "finn@example.com", name="Finn")
    fake_file = io.BytesIO(b"not-an-image")
    response = client.post(
        "/api/users/me/photos",
        files={"file": ("notes.txt", fake_file, "text/plain")},
        headers=headers,
    )
    assert response.status_code == 400
