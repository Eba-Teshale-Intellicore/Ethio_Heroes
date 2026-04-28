from flask import Blueprint, request, jsonify, session, redirect, url_for
import os
import psycopg2
from psycopg2.extras import RealDictCursor
import bcrypt
from app.extensions import oauth
import secrets

auth_bp = Blueprint("auth", __name__)

# ================= DB =================
def get_db():
    return psycopg2.connect(
        os.environ.get("DATABASE_URL"),
        sslmode="require",
        cursor_factory=RealDictCursor
    )

# ================= OAUTH =================
google = oauth.register(
    name="google",
    client_id=os.environ.get("GOOGLE_CLIENT_ID"),
    client_secret=os.environ.get("GOOGLE_CLIENT_SECRET"),
    server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
    client_kwargs={"scope": "openid email profile"}
)

github = oauth.register(
    name="github",
    client_id=os.environ.get("GITHUB_CLIENT_ID"),
    client_secret=os.environ.get("GITHUB_CLIENT_SECRET"),
    access_token_url="https://github.com/login/oauth/access_token",
    authorize_url="https://github.com/login/oauth/authorize",
    api_base_url="https://api.github.com/",
    client_kwargs={"scope": "user:email"}
)

# =========================================================
# SIGNUP
# =========================================================
@auth_bp.route("/signup", methods=["POST"])
def signup():
    data = request.get_json()

    full_name = data.get("full_name")
    email = data.get("email")
    country = data.get("country")
    phone = data.get("phone")
    password = data.get("password")
    confirm = data.get("confirm_password")

    if not all([full_name, email, password]):
        return jsonify({"message": "Missing required fields"}), 400

    if len(password) < 8:
        return jsonify({"message": "Password must be at least 8 characters"}), 400

    if password != confirm:
        return jsonify({"message": "Passwords do not match"}), 400

    hashed_password = bcrypt.hashpw(
        password.encode("utf-8"),
        bcrypt.gensalt()
    ).decode("utf-8")

    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO Users (
                    full_name,
                    email_address,
                    country,
                    phone_number,
                    password,
                    login_type
                )
                VALUES (%s,%s,%s,%s,%s,%s)
            """, (
                full_name,
                email,
                country,
                phone,
                hashed_password,
                "local"
            ))
            conn.commit()

    except psycopg2.IntegrityError:
        conn.rollback()
        return jsonify({"message": "Email already exists"}), 409

    finally:
        conn.close()

    session["email"] = email
    session["name"] = full_name

    return jsonify({
        "message": "Signup successful",
        "user": {
            "email": email,
            "name": full_name
        }
    }), 201


# =========================================================
# LOGIN
# =========================================================
@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    email = data.get("email")
    password = data.get("password")

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("""
            SELECT * FROM Users WHERE email_address=%s
        """, (email,))
        user = cur.fetchone()
    conn.close()

    if not user:
        return jsonify({"message": "Invalid email"}), 401

    stored_password = user["password"]

    if stored_password and bcrypt.checkpw(
        password.encode("utf-8"),
        stored_password.encode("utf-8")
    ):
        session["email"] = user["email_address"]
        session["name"] = user["full_name"]

        return jsonify({
            "message": "Login successful",
            "user": {
                "email": user["email_address"],
                "name": user["full_name"],
                "avatar": user["avatar"],
                "country": user["country"]
            }
        }), 200

    return jsonify({"message": "Invalid password"}), 401


# =========================================================
# GOOGLE LOGIN
# =========================================================
@auth_bp.route("/login/google")
def login_google():
    nonce = secrets.token_urlsafe(16)
    session["nonce"] = nonce

    redirect_uri = url_for("auth.google_callback", _external=True)
    return google.authorize_redirect(redirect_uri, nonce=nonce)


@auth_bp.route("/login/google/callback")
def google_callback():
    token = google.authorize_access_token()
    user_info = google.parse_id_token(token)

    email = user_info["email"]
    name = user_info["name"]
    avatar = user_info.get("picture")

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("""
            SELECT * FROM Users WHERE email_address=%s
        """, (email,))
        user = cur.fetchone()

        if not user:
            cur.execute("""
                INSERT INTO Users (
                    full_name,
                    email_address,
                    login_type,
                    avatar,
                    is_verified
                )
                VALUES (%s,%s,%s,%s,%s)
            """, (name, email, "google", avatar, True))

        else:
            cur.execute("""
                UPDATE Users
                SET full_name=%s, avatar=%s
                WHERE email_address=%s
            """, (name, avatar, email))

        conn.commit()
    conn.close()

    session["email"] = email
    session["name"] = name

    return redirect("http://localhost:3000/")


# =========================================================
# GITHUB LOGIN
# =========================================================
@auth_bp.route("/login/github")
def github_login():
    redirect_uri = url_for("auth.github_callback", _external=True)
    return github.authorize_redirect(redirect_uri)


@auth_bp.route("/login/github/callback")
def github_callback():
    token = github.authorize_access_token()
    profile = github.get("user").json()

    username = profile["login"]

    session["email"] = username
    session["name"] = username

    return redirect("http://localhost:3000/")


# =========================================================
# LOGOUT
# =========================================================
@auth_bp.route("/logout")
def logout():
    session.clear()
    return jsonify({"message": "Logged out"}), 200