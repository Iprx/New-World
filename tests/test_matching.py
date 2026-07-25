from tests.conftest import register_user


def _user_id(client, headers):
    return client.get("/api/users/me", headers=headers).json()["id"]


def test_discover_excludes_self_and_already_swiped(client):
    alice_headers = register_user(client, "alice2@example.com", name="Alice", gender="woman", interested_in="man")
    bob_headers = register_user(client, "bob2@example.com", name="Bob", gender="man", interested_in="woman")
    carol_headers = register_user(client, "carol2@example.com", name="Carol", gender="woman", interested_in="man")

    bob_id = _user_id(client, bob_headers)

    discover = client.get("/api/discover", headers=alice_headers).json()
    names = {p["name"] for p in discover}
    assert "Alice" not in names
    assert "Bob" in names
    # Carol is excluded because Alice is only interested in men.
    assert "Carol" not in names

    client.post("/api/swipes", json={"swiped_id": bob_id, "liked": False}, headers=alice_headers)

    discover_after = client.get("/api/discover", headers=alice_headers).json()
    names_after = {p["name"] for p in discover_after}
    assert "Bob" not in names_after


def test_mutual_like_creates_match_and_chat_works(client):
    alice_headers = register_user(client, "alice3@example.com", name="Alice")
    bob_headers = register_user(client, "bob3@example.com", name="Bob")

    alice_id = _user_id(client, alice_headers)
    bob_id = _user_id(client, bob_headers)

    first = client.post(
        "/api/swipes", json={"swiped_id": bob_id, "liked": True}, headers=alice_headers
    )
    assert first.status_code == 201
    assert first.json() == {"matched": False, "match_id": None}

    second = client.post(
        "/api/swipes", json={"swiped_id": alice_id, "liked": True}, headers=bob_headers
    )
    assert second.status_code == 201
    assert second.json()["matched"] is True
    match_id = second.json()["match_id"]
    assert match_id is not None

    alice_matches = client.get("/api/matches", headers=alice_headers).json()
    assert len(alice_matches) == 1
    assert alice_matches[0]["other_user"]["name"] == "Bob"

    send = client.post(
        f"/api/matches/{match_id}/messages",
        json={"content": "Hey Bob!"},
        headers=alice_headers,
    )
    assert send.status_code == 201

    messages = client.get(f"/api/matches/{match_id}/messages", headers=bob_headers).json()
    assert len(messages) == 1
    assert messages[0]["content"] == "Hey Bob!"
    assert messages[0]["sender_id"] == alice_id


def test_one_sided_like_does_not_match(client):
    alice_headers = register_user(client, "alice4@example.com", name="Alice")
    bob_headers = register_user(client, "bob4@example.com", name="Bob")
    bob_id = _user_id(client, bob_headers)

    result = client.post(
        "/api/swipes", json={"swiped_id": bob_id, "liked": True}, headers=alice_headers
    )
    assert result.json()["matched"] is False
    assert client.get("/api/matches", headers=alice_headers).json() == []


def test_cannot_access_others_match_messages(client):
    alice_headers = register_user(client, "alice5@example.com", name="Alice")
    bob_headers = register_user(client, "bob5@example.com", name="Bob")
    eve_headers = register_user(client, "eve5@example.com", name="Eve")

    alice_id = _user_id(client, alice_headers)
    bob_id = _user_id(client, bob_headers)

    client.post("/api/swipes", json={"swiped_id": bob_id, "liked": True}, headers=alice_headers)
    result = client.post(
        "/api/swipes", json={"swiped_id": alice_id, "liked": True}, headers=bob_headers
    )
    match_id = result.json()["match_id"]

    response = client.get(f"/api/matches/{match_id}/messages", headers=eve_headers)
    assert response.status_code == 404
