# main.py
from flask import Blueprint, session, redirect, url_for, render_template, request
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import pycountry

main_bp = Blueprint('main', __name__)

# ----- Database connection for Neon/PostgreSQL -----
def get_db():
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        dbname=os.getenv("DB_NAME", "ethio_heroes"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASS", "password"),
        cursor_factory=RealDictCursor
    )
    return conn

# ------------------- Home Page -------------------
@main_bp.route("/")
def home():
    page = int(request.args.get("page", 1))
    per_page = 9
    offset = (page - 1) * per_page

    conn = get_db()
    with conn.cursor() as cur:
        # total heroes
        cur.execute("SELECT COUNT(*) AS total FROM Heroes")
        total_heroes = cur.fetchone()["total"]
        total_pages = (total_heroes + per_page - 1) // per_page

        cur.execute("""
            SELECT DISTINCT
                h.id,
                h.name,
                h.hero_image,
                h.short_description,
                e.name AS era_name,
                c.name AS category_name
            FROM Heroes h
            LEFT JOIN Eras e ON h.era_id = e.id
            LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
            LEFT JOIN Categories c ON hc.category_id = c.id
            ORDER BY h.id DESC
            LIMIT %s OFFSET %s
        """, (per_page, offset))
        heroes = cur.fetchall()

        cur.execute("SELECT * FROM Categories")
        categories = cur.fetchall()

        cur.execute("SELECT * FROM Eras")
        eras = cur.fetchall()

    conn.close()

    return render_template(
        "home.html",
        heroes=heroes,
        categories=categories,
        eras=eras,
        query="",
        selected_category="",
        selected_era="",
        page=page,
        total_pages=total_pages
    )

# ------------------- Profile -------------------
@main_bp.route("/profile")
def profile():
    if "email_address" not in session:
        return redirect(url_for("auth.login"))

    email = session["email_address"]
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
        user = cur.fetchone()

    conn.close()
    if not user:
        return redirect(url_for("auth.login"))

    try:
        country_name = pycountry.countries.get(alpha_2=user["country"].upper()).name
    except:
        country_name = user["country"]

    return render_template("profile.html", user=user, country_name=country_name)

@main_bp.route("/edit-profile", methods=["GET","POST"])
def edit_profile():
    if "email_address" not in session:
        return redirect(url_for("auth.login"))

    email = session["email_address"]
    conn = get_db()
    with conn.cursor() as cur:
        if request.method == "POST":
            cur.execute("""
                UPDATE Users
                SET full_name=%s, phone_number=%s, country=%s, bio=%s
                WHERE email_address=%s
            """, (
                request.form.get("full_name"),
                request.form.get("phone_number"),
                request.form.get("country"),
                request.form.get("bio"),
                email
            ))
            conn.commit()
            return redirect(url_for("main.profile"))

        cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
        user = cur.fetchone()

    conn.close()
    return render_template("profile.html", user=user)

# ------------------- Hero Detail -------------------
@main_bp.route("/hero/<int:hero_id>")
def hero_detail(hero_id):
    if "email_address" not in session:
        return redirect(url_for("auth.login"))

    email = session["email_address"]
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
        user = cur.fetchone()
        if not user:
            return redirect(url_for("auth.login"))

        cur.execute("""
            SELECT h.*, e.name AS era_name
            FROM Heroes h
            LEFT JOIN Eras e ON h.era_id = e.id
            WHERE h.id=%s
        """, (hero_id,))
        hero = cur.fetchone()
        if not hero:
            return "Hero not found", 404

        cur.execute("""
            SELECT c.name
            FROM Categories c
            JOIN HeroCategories hc ON c.id = hc.category_id
            WHERE hc.hero_id=%s
        """, (hero_id,))
        categories = [c["name"] for c in cur.fetchall()]

        cur.execute("SELECT * FROM HeroImages WHERE hero_id=%s", (hero_id,))
        images = cur.fetchall()

        cur.execute("SELECT * FROM Achievements WHERE hero_id=%s", (hero_id,))
        achievements = cur.fetchall()

        cur.execute("SELECT * FROM Sources WHERE hero_id=%s", (hero_id,))
        sources = cur.fetchall()

        cur.execute("""
            SELECT c.comment, u.full_name, u.avatar, c.created_at
            FROM Comments c
            JOIN Users u ON c.user_id = u.id
            WHERE c.hero_id=%s
            ORDER BY c.created_at DESC
        """, (hero_id,))
        comments = cur.fetchall()

        cur.execute("SELECT * FROM Favorites WHERE hero_id=%s AND user_id=%s", (hero_id, user["id"]))
        favorite = cur.fetchone()

    conn.close()

    return render_template(
        "detail.html",
        hero=hero,
        categories=categories,
        images=images,
        achievements=achievements,
        sources=sources,
        comments=comments,
        favorite=favorite,
        user=user
    )

# ------------------- Favorites -------------------
@main_bp.route("/hero/<int:hero_id>/add_favorite", methods=["POST"])
def add_favorite(hero_id):
    email = session.get("email_address")
    if not email:
        return redirect(url_for("auth.login"))

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
        user = cur.fetchone()
        cur.execute("INSERT INTO Favorites (user_id, hero_id) VALUES (%s, %s) ON CONFLICT DO NOTHING", (user["id"], hero_id))
        conn.commit()
    conn.close()
    return redirect(url_for("main.hero_detail", hero_id=hero_id))

@main_bp.route("/hero/<int:hero_id>/remove_favorite", methods=["POST"])
def remove_favorite(hero_id):
    email = session.get("email_address")
    if not email:
        return redirect(url_for("auth.login"))

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
        user = cur.fetchone()
        cur.execute("DELETE FROM Favorites WHERE user_id=%s AND hero_id=%s", (user["id"], hero_id))
        conn.commit()
    conn.close()
    return redirect(url_for("main.hero_detail", hero_id=hero_id))

# ------------------- Comments -------------------
@main_bp.route("/hero/<int:hero_id>/add_comment", methods=["POST"])
def add_comment(hero_id):
    email = session.get("email_address")
    if not email:
        return redirect(url_for("auth.login"))

    comment_text = request.form.get("comment")
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
        user = cur.fetchone()
        cur.execute("INSERT INTO Comments (user_id, hero_id, comment) VALUES (%s, %s, %s)", (user["id"], hero_id, comment_text))
        conn.commit()
    conn.close()
    return redirect(url_for("main.hero_detail", hero_id=hero_id))

# ------------------- Search -------------------
@main_bp.route("/search")
def search():
    query = request.args.get("q", "")
    category = request.args.get("category", "")
    era = request.args.get("era", "")
    page = int(request.args.get("page", 1))
    per_page = 9
    offset = (page - 1) * per_page

    conn = get_db()
    with conn.cursor() as cur:
        # Count total filtered heroes
        count_sql = """
            SELECT COUNT(DISTINCT h.id) AS total
            FROM Heroes h
            LEFT JOIN Eras e ON h.era_id = e.id
            LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
            LEFT JOIN Categories c ON hc.category_id = c.id
            WHERE 1=1
        """
        count_params = []

        if query:
            count_sql += " AND (h.name ILIKE %s OR h.short_description ILIKE %s OR h.full_biography ILIKE %s)"
            term = f"%{query}%"
            count_params += [term, term, term]

        if category:
            count_sql += " AND c.name = %s"
            count_params.append(category)

        if era:
            count_sql += " AND e.name = %s"
            count_params.append(era)

        cur.execute(count_sql, count_params)
        total_heroes = cur.fetchone()["total"]
        total_pages = (total_heroes + per_page - 1) // per_page

        # Fetch filtered heroes
        sql = """
            SELECT DISTINCT h.id, h.name, h.hero_image, h.short_description, e.name AS era_name, c.name AS category_name
            FROM Heroes h
            LEFT JOIN Eras e ON h.era_id = e.id
            LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
            LEFT JOIN Categories c ON hc.category_id = c.id
            WHERE 1=1
        """
        params = []

        if query:
            sql += " AND (h.name ILIKE %s OR h.short_description ILIKE %s OR h.full_biography ILIKE %s)"
            params += [term, term, term]

        if category:
            sql += " AND c.name = %s"
            params.append(category)

        if era:
            sql += " AND e.name = %s"
            params.append(era)

        sql += " ORDER BY h.id DESC LIMIT %s OFFSET %s"
        params += [per_page, offset]

        cur.execute(sql, params)
        heroes = cur.fetchall()

        cur.execute("SELECT * FROM Categories")
        categories = cur.fetchall()
        cur.execute("SELECT * FROM Eras")
        eras = cur.fetchall()

    conn.close()
    return render_template(
        "home.html",
        heroes=heroes,
        categories=categories,
        eras=eras,
        query=query,
        selected_category=category,
        selected_era=era,
        page=page,
        total_pages=total_pages
    )