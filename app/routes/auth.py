# auth.py
from flask import Blueprint, request, render_template, flash, redirect, url_for, session
import os
import psycopg2
from psycopg2.extras import RealDictCursor
import bcrypt
from app.extensions import oauth
import secrets

auth_bp = Blueprint('auth', __name__)

# ----- Database connection -----
def get_db():
    conn = psycopg2.connect(
        os.environ.get("DATABASE_URL"),
        sslmode="require",
        cursor_factory=RealDictCursor
    )
    return conn

# ----- OAuth registration -----
google = oauth.register(
    name='google',
    client_id=os.environ.get("GOOGLE_CLIENT_ID"),
    client_secret=os.environ.get("GOOGLE_CLIENT_SECRET"),
    server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email profile'}
)

github = oauth.register(
    name='github',
    client_id=os.environ.get("GITHUB_CLIENT_ID"),
    client_secret=os.environ.get("GITHUB_CLIENT_SECRET"),
    access_token_url='https://github.com/login/oauth/access_token',
    authorize_url='https://github.com/login/oauth/authorize',
    api_base_url='https://api.github.com/',
    client_kwargs={'scope': 'user:email'}
)

# ----- SIGNUP -----
@auth_bp.route('/signup', methods=["GET", "POST"])
def signup():
    if request.method == "GET":
        return render_template("signup.html")

    # POST
    full_name = request.form.get("full_name")
    email_address = request.form.get("email_address")
    country = request.form.get("country")
    phone_number = request.form.get("phone_number")
    password = request.form.get("password")
    confirm_password = request.form.get("confirm_password")

    if len(password) < 8:
        flash("Password must be at least 8 characters", "error")
        return redirect(url_for('auth.signup'))

    if password != confirm_password:
        flash("Passwords do not match", "error")
        return redirect(url_for('auth.signup'))

    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """INSERT INTO Users(full_name, email_address, country, phone_number, password, login_type)
                   VALUES (%s,%s,%s,%s,%s,%s)""",
                (full_name, email_address, country, phone_number, hashed_password, 'local')
            )
            conn.commit()
    except psycopg2.IntegrityError:
        conn.rollback()
        flash("Email already exists", "error")
        return redirect(url_for('auth.signup'))
    finally:
        conn.close()

    session["email_address"] = email_address
    session["full_name"] = full_name
    flash("Registered Successfully!", "success")
    return redirect(url_for('main.home'))

# ----- LOGIN -----
@auth_bp.route('/login', methods=["GET","POST"])
def login():
    if request.method == "GET":
        return render_template('login.html')

    email = request.form.get("email_address")
    password = request.form.get("password")

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
        user = cur.fetchone()
    conn.close()

    if not user:
        flash("Invalid email", "error")
        return redirect(url_for('auth.login'))

    if user["password"] and bcrypt.checkpw(password.encode('utf-8'), bytes(user["password"])):
        session["email_address"] = email
        session["full_name"] = user["full_name"]
        flash("Logged in successfully!", "success")
        return redirect(url_for('main.home'))
    else:
        flash("Invalid password", "error")
        return redirect(url_for('auth.login'))

# ----- GOOGLE LOGIN -----
@auth_bp.route("/login/google")
def login_google():
    nonce = secrets.token_urlsafe(16)
    session["google_nonce"] = nonce
    redirect_uri = url_for("auth.google_authorize", _external=True)
    return google.authorize_redirect(redirect_uri, nonce=nonce)

@auth_bp.route("/login/google/authorize")
def google_authorize():
    token = google.authorize_access_token()
    nonce = session.get("google_nonce")
    user_info = google.parse_id_token(token, nonce=nonce)

    email = user_info["email"]
    name = user_info["name"]
    avatar = user_info.get("picture")
    email_verified = user_info.get("email_verified", False)
    country = user_info.get("locale", "et")

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
        user_db = cur.fetchone()

        if not user_db:
            cur.execute(
                """INSERT INTO Users
                (full_name,email_address,country,phone_number,password,login_type,is_verified,avatar)
                VALUES(%s,%s,%s,%s,%s,%s,%s,%s)""",
                (name, email, country, "00000000", None, "google", email_verified, avatar)
            )
        else:
            cur.execute(
                "UPDATE Users SET full_name=%s, avatar=%s, is_verified=%s, country=%s WHERE email_address=%s",
                (name, avatar, email_verified, country, email)
            )
        conn.commit()
    conn.close()

    session.update({
        "email_address": email,
        "full_name": name,
        "avatar": avatar,
        "country": country
    })

    flash("Logged in with Google!", "success")
    return redirect(url_for('main.home'))

# ----- GITHUB LOGIN -----
@auth_bp.route('/login/github')
def github_login():
    redirect_uri = url_for('auth.github_authorize', _external=True)
    return github.authorize_redirect(redirect_uri)

@auth_bp.route('/login/github/authorize')
def github_authorize():
    token = github.authorize_access_token()
    resp = github.get('user')
    profile = resp.json()

    username = profile["login"]
    session["email_address"] = username
    session["full_name"] = username
    flash("Logged in with GitHub!", "success")
    return redirect(url_for('main.home'))

# ----- LOGOUT -----
@auth_bp.route("/logout")
def logout():
    session.clear()
    flash("Successfully logged out", "success")
    return redirect(url_for("main.home"))