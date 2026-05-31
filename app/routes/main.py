# # # main.py
# # from flask import Blueprint, session, redirect, url_for, render_template, request
# # import psycopg2
# # from psycopg2.extras import RealDictCursor
# # import os
# # import pycountry
# # from flask import jsonify

# # main_bp = Blueprint('main', __name__)

# # # # ----- Database connection for Neon/PostgreSQL -----

# # def get_db():
# #     """
# #     Opens a new PostgreSQL connection.
# #     Reads DATABASE_URL from environment variables.
 
# #     Set it before running:
# #         export DATABASE_URL="postgresql://user:password@host:5432/dbname"
# #     """
# #     conn = psycopg2.connect(
# #         os.environ.get("DATABASE_URL"),
# #         sslmode="require",
# #         cursor_factory=RealDictCursor
# #     )
# #     return conn
# # # ------------------- Home Page -------------------
# # @main_bp.route("/api/heroes")
# # def get_heroes():
# #     page = int(request.args.get("page", 1))
# #     per_page = 5
# #     offset = (page - 1) * per_page

# #     conn = get_db()
# #     with conn.cursor() as cur:
# #         cur.execute("""
# #             SELECT DISTINCT
# #                 h.id,
# #                 h.name,
# #                 h.hero_image,
# #                 h.short_description,
# #                 e.name AS era_name,
# #                 c.name AS category_name
# #             FROM Heroes h
# #             LEFT JOIN Eras e ON h.era_id = e.id
# #             LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
# #             LEFT JOIN Categories c ON hc.category_id = c.id
# #             ORDER BY h.id DESC
# #             LIMIT %s OFFSET %s
# #         """, (per_page, offset))

# #         heroes = cur.fetchall()

# #     conn.close()
# #     return jsonify(heroes)

# #     # ------------------- Director Page -------------------
# # @main_bp.route("/api/director")
# # def director_heroes():

# #     conn = get_db()
# #     with conn.cursor() as cur:
# #         cur.execute("""
# #             SELECT
# #                 h.id,
# #                 h.name,
# #                 h.hero_image,
# #                 h.short_description,
# #                 e.name AS era_name,
# #                 STRING_AGG(c.name, ', ') AS categories
# #             FROM Heroes h
# #             LEFT JOIN Eras e ON h.era_id = e.id
# #             LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
# #             LEFT JOIN Categories c ON hc.category_id = c.id
# #             GROUP BY h.id, e.name
# #             ORDER BY h.id DESC 
# #                     """, ())

# #         heroes = cur.fetchall()

# #     conn.close()
# #     return jsonify(heroes)



# # # ------------------- Search -------------------
# # @main_bp.route("/api/search")
# # def search():
# #     query    = request.args.get("q", "")
# #     category = request.args.get("category", "")
# #     era      = request.args.get("era", "")
# #     page     = int(request.args.get("page", 1))
# #     per_page = 35
# #     offset   = (page - 1) * per_page

# #     conn = get_db()

# #     try:
# #         with conn.cursor(cursor_factory=RealDictCursor) as cur:

# #             # ── Count total filtered heroes ──────────────────────────
# #             count_sql = """
# #                 SELECT COUNT(DISTINCT h.id) AS total
# #                 FROM Heroes h
# #                 LEFT JOIN Eras           e  ON h.era_id       = e.id
# #                 LEFT JOIN HeroCategories hc ON h.id           = hc.hero_id
# #                 LEFT JOIN Categories     c  ON hc.category_id = c.id
# #                 WHERE 1=1
# #             """
# #             count_params = []

# #             if query:
# #                 count_sql += " AND (h.name ILIKE %s OR h.short_description ILIKE %s OR h.full_biography ILIKE %s)"
# #                 term = f"%{query}%"
# #                 count_params += [term, term, term]

# #             if category:
# #                 count_sql += " AND c.name = %s"
# #                 count_params.append(category)

# #             if era:
# #                 count_sql += " AND e.name = %s"
# #                 count_params.append(era)

# #             cur.execute(count_sql, count_params)
# #             total_heroes = cur.fetchone()["total"]
# #             total_pages  = (total_heroes + per_page - 1) // per_page


# #             # ── Fetch filtered heroes ────────────────────────────────
# #             sql = """
# #                 SELECT
# #                     h.id,
# #                     h.slug,                        -- ✅ FIX: was missing, caused /hero/undefined
# #                     h.name,
# #                     h.hero_image,
# #                     h.short_description,
# #                     e.name AS era_name,
# #                     STRING_AGG(c.name, ', ') AS categories
# #                 FROM Heroes h
# #                 LEFT JOIN Eras           e  ON h.era_id       = e.id
# #                 LEFT JOIN HeroCategories hc ON h.id           = hc.hero_id
# #                 LEFT JOIN Categories     c  ON hc.category_id = c.id
# #                 WHERE 1=1
# #             """
# #             params = []
# #             term   = f"%{query}%"

# #             if query:
# #                 sql += " AND (h.name ILIKE %s OR h.short_description ILIKE %s OR h.full_biography ILIKE %s)"
# #                 params += [term, term, term]

# #             if category:
# #                 sql += " AND c.name = %s"
# #                 params.append(category)

# #             if era:
# #                 sql += " AND e.name = %s"
# #                 params.append(era)

# #             # ✅ FIX: h.slug added to GROUP BY (required when selected)
# #             sql += " GROUP BY h.id, h.slug, h.name, h.hero_image, h.short_description, e.name"
# #             sql += " ORDER BY h.id DESC LIMIT %s OFFSET %s"
# #             params += [per_page, offset]

# #             cur.execute(sql, params)
# #             heroes = [dict(row) for row in cur.fetchall()]

# #             # ── Filters ─────────────────────────────────────────────
# #             cur.execute("SELECT * FROM Categories ORDER BY name")
# #             categories = [dict(row) for row in cur.fetchall()]

# #             cur.execute("SELECT * FROM Eras ORDER BY name")
# #             eras = [dict(row) for row in cur.fetchall()]

# #         return jsonify({
# #             "heroes":      heroes,
# #             "categories":  categories,
# #             "eras":        eras,
# #             "total_pages": total_pages,
# #         })

# #     except Exception as e:
# #         print(f"[Search API Error] q={query!r} | error={e}")
# #         return jsonify({"error": "Internal server error"}), 500

# #     finally:
# #         conn.close()

# # # ─────────────────────────────────────────────
# # # HERO DETAIL ENDPOINT
# # # ─────────────────────────────────────────────
# # @main_bp.route("/api/hero/<slug>")
# # def hero_detail(slug):
# #     """
# #     GET /api/hero/<slug>
 
# #     Returns full hero data:
# #     - Hero info + era
# #     - Categories
# #     - Related heroes (same era or category)
# #     - Images
# #     - Achievements
# #     - Sources
# #     - Comments
# #     """
 
# #     conn = get_db()
 
# #     try:
# #         with conn.cursor(cursor_factory=RealDictCursor) as cur:
 
# #             # ───────── 1. HERO ─────────
# #             cur.execute("""
# #                 SELECT h.*, e.name AS era_name
# #                 FROM Heroes h
# #                 LEFT JOIN Eras e ON h.era_id = e.id
# #                 WHERE h.slug = %s
# #             """, (slug,))
 
# #             hero = cur.fetchone()
 
# #             if not hero:
# #                 return jsonify({"error": "Hero not found"}), 404
 
# #             hero_id  = hero["id"]
# #             era_id   = hero["era_id"]
 
 
# #             # ───────── 2. CATEGORIES ─────────
# #             # Must be fetched BEFORE related heroes so we can pass them in
# #             cur.execute("""
# #                 SELECT c.name
# #                 FROM Categories c
# #                 JOIN HeroCategories hc ON c.id = hc.category_id
# #                 WHERE hc.hero_id = %s
# #             """, (hero_id,))
 
# #             categories = [row["name"] for row in cur.fetchall()]
 
# #             # FIX: empty list crashes PostgreSQL ANY() — use a dummy sentinel
# #             category_filter = categories if categories else ["__none__"]
 
 
# #             # ───────── 3. RELATED HEROES ─────────
# #             # Finds up to 5 random heroes sharing the same era OR same category
# #             cur.execute("""
# #                 SELECT DISTINCT
# #                     h.id,
# #                     h.name,
# #                     h.slug,
# #                     h.hero_image,
# #                     h.short_description,
# #                     e.name AS era_name
# #                 FROM Heroes h
# #                 LEFT JOIN Eras e        ON h.era_id = e.id
# #                 LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
# #                 LEFT JOIN Categories c  ON hc.category_id = c.id
# #                 WHERE h.id != %s
# #                 AND (
# #                     h.era_id = %s
# #                     OR c.name = ANY(%s::text[])
# #                 )
# #                 ORDER BY RANDOM()
# #                 LIMIT 5
# #             """, (hero_id, era_id, category_filter))
 
# #             related_heroes = cur.fetchall()
 
 
# #             # ───────── 4. IMAGES ─────────
# #             cur.execute("""
# #                 SELECT *
# #                 FROM HeroImages
# #                 WHERE hero_id = %s
# #             """, (hero_id,))
 
# #             images = cur.fetchall()
 
 
# #             # ───────── 5. ACHIEVEMENTS ─────────
# #             cur.execute("""
# #                 SELECT *
# #                 FROM Achievements
# #                 WHERE hero_id = %s
# #                 ORDER BY year ASC
# #             """, (hero_id,))
 
# #             achievements = cur.fetchall()
 
 
# #             # ───────── 6. SOURCES ─────────
# #             cur.execute("""
# #                 SELECT *
# #                 FROM Sources
# #                 WHERE hero_id = %s
# #             """, (hero_id,))
 
# #             sources = cur.fetchall()
 
 
# #             # ───────── 7. COMMENTS ─────────
# #             cur.execute("""
# #                 SELECT
# #                     c.comment,
# #                     u.full_name,
# #                     u.avatar,
# #                     c.created_at
# #                 FROM Comments c
# #                 JOIN Users u ON c.user_id = u.id
# #                 WHERE c.hero_id = %s
# #                 ORDER BY c.created_at DESC
# #             """, (hero_id,))
 
# #             comments = cur.fetchall()
 
 
# #         # ───────── RESPONSE ─────────
# #         return jsonify({
# #             "hero":           dict(hero),
# #             "categories":     categories,
# #             "related_heroes": [dict(r) for r in related_heroes],
# #             "images":         [dict(i) for i in images],
# #             "achievements":   [dict(a) for a in achievements],
# #             "sources":        [dict(s) for s in sources],
# #             "comments":       [dict(c) for c in comments],
# #         })
 
# #     except Exception as e:
# #         print(f"[Hero API Error] slug={slug!r} | error={e}")
# #         return jsonify({"error": "Internal server error"}), 500
 
# #     finally:
# #         conn.close()   # Always closes — even if an error occurred


# #     # return render_template(
# #     #     "home.html",
# #     #     heroes=heroes,
# #     #     categories=categories,
# #     #     eras=eras,
# #     #     query=query,
# #     #     selected_category=category,
# #     #     selected_era=era,
# #     #     page=page,
# #     #     total_pages=total_pages
# #     # )


















# # # # ------------------- Profile -------------------
# # # @main_bp.route("/profile")
# # # def profile():
# # #     if "email_address" not in session:
# # #         return redirect(url_for("auth.login"))

# # #     email = session["email_address"]
# # #     conn = get_db()
# # #     with conn.cursor() as cur:
# # #         cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
# # #         user = cur.fetchone()

# # #     conn.close()
# # #     if not user:
# # #         return redirect(url_for("auth.login"))

# # #     try:
# # #         country_name = pycountry.countries.get(alpha_2=user["country"].upper()).name
# # #     except:
# # #         country_name = user["country"]

# # #     return render_template("profile.html", user=user, country_name=country_name)

# # # @main_bp.route("/edit-profile", methods=["GET","POST"])
# # # def edit_profile():
# # #     if "email_address" not in session:
# # #         return redirect(url_for("auth.login"))

# # #     email = session["email_address"]
# # #     conn = get_db()
# # #     with conn.cursor() as cur:
# # #         if request.method == "POST":
# # #             cur.execute("""
# # #                 UPDATE Users
# # #                 SET full_name=%s, phone_number=%s, country=%s, bio=%s
# # #                 WHERE email_address=%s
# # #             """, (
# # #                 request.form.get("full_name"),
# # #                 request.form.get("phone_number"),
# # #                 request.form.get("country"),
# # #                 request.form.get("bio"),
# # #                 email
# # #             ))
# # #             conn.commit()
# # #             return redirect(url_for("main.profile"))

# # #         cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
# # #         user = cur.fetchone()

# # #     conn.close()
# # #     return render_template("profile.html", user=user)



# #     # if "email_address" not in session:
# #     #     return redirect(url_for("auth.login"))

# #     # email = session["email_address"]

# # # # ------------------- Hero Detail -------------------
# # # @main_bp.route("/api/hero/<slug>")
# # # def hero_detail(slug):
# # #     conn = get_db()

# # #     with conn.cursor(cursor_factory=RealDictCursor) as cur:

# # #         # HERO
# # #         cur.execute("""
# # #             SELECT h.*, e.name AS era_name
# # #             FROM Heroes h
# # #             LEFT JOIN Eras e ON h.era_id = e.id
# # #             WHERE h.slug = %s
# # #         """, (slug,))

# # #         hero = cur.fetchone()

# # #         if not hero:
# # #             return jsonify({"error": "Hero not found"}), 404

# # #         hero_id = hero["id"]
# # #         # ------------------- RELATED HEROES -------------------
# # #         cur.execute("""
# # #             SELECT DISTINCT
# # #                 h.id,
# # #                 h.name,
# # #                 h.slug,
# # #                 h.hero_image,
# # #                 h.short_description,
# # #                 e.name AS era_name
# # #             FROM Heroes h
# # #             LEFT JOIN Eras e ON h.era_id = e.id
# # #             LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
# # #             LEFT JOIN Categories c ON hc.category_id = c.id
# # #             WHERE h.id != %s
# # #             AND (
# # #                 h.era_id = %s
# # #                 OR c.id IN (
# # #                     SELECT category_id
# # #                     FROM HeroCategories
# # #                     WHERE hero_id = %s
# # #                 )
# # #             )
# # #             ORDER BY RANDOM()
# # #             LIMIT 6
# # #         """, (hero_id, hero["era_id"], hero_id))

# # #         related_heroes = cur.fetchall()

# # #         # CATEGORIES
# # #         cur.execute("""
# # #             SELECT c.name
# # #             FROM Categories c
# # #             JOIN HeroCategories hc ON c.id = hc.category_id
# # #             WHERE hc.hero_id = %s
# # #         """, (hero_id,))

# # #         categories = [c["name"] for c in cur.fetchall()]

# # #         # IMAGES
# # #         cur.execute("""
# # #             SELECT *
# # #             FROM HeroImages
# # #             WHERE hero_id = %s
# # #         """, (hero_id,))
# # #         images = cur.fetchall()

# # #         # ACHIEVEMENTS
# # #         cur.execute("""
# # #             SELECT *
# # #             FROM Achievements
# # #             WHERE hero_id = %s
# # #             ORDER BY year ASC
# # #         """, (hero_id,))
# # #         achievements = cur.fetchall()

# # #         # SOURCES
# # #         cur.execute("""
# # #             SELECT *
# # #             FROM Sources
# # #             WHERE hero_id = %s
# # #         """, (hero_id,))
# # #         sources = cur.fetchall()

# # #         # COMMENTS
# # #         cur.execute("""
# # #             SELECT
# # #                 c.comment,
# # #                 u.full_name,
# # #                 u.avatar,
# # #                 c.created_at
# # #             FROM Comments c
# # #             JOIN Users u ON c.user_id = u.id
# # #             WHERE c.hero_id = %s
# # #             ORDER BY c.created_at DESC
# # #         """, (hero_id,))
# # #         comments = cur.fetchall()

# # #         # FAVORITE (optional, safe check)
# # #         cur.execute("""
# # #             SELECT *
# # #             FROM Favorites
# # #             WHERE hero_id = %s
# # #             LIMIT 1
# # #         """, (hero_id,))
# # #         favorite = cur.fetchone()

# # #     conn.close()

# # #     return jsonify({
# # #         "hero": hero,
# # #         "categories": categories,
# # #         "images": images,
# # #         "achievements": achievements,
# # #         "sources": sources,
# # #         "comments": comments,
# # #         "favorite": favorite,
# # #         "related_heroes": related_heroes
# # #     })
# # #     # return render_template(
# # #     #     "detail.html",
# # #     #     hero=hero,
# # #     #     categories=categories,
# # #     #     images=images,
# # #     #     achievements=achievements,
# # #     #     sources=sources,
# # #     #     comments=comments,
# # #     #     favorite=favorite,
# # #     #     user=user
# # #     # )



# #     # if "email_address" not in session:
# #     #     return redirect(url_for("auth.login"))

# #     # email = session["email_address"]
    
# # # # ------------------- Hero Detail -------------------
# # # @main_bp.route("/api/hero/<slug>")
# # # def hero_detail(slug):

# # #     conn = get_db()

# # #     try:
# # #         with conn.cursor(cursor_factory=RealDictCursor) as cur:

# # #             # ───────────────────────── HERO ─────────────────────────
# # #             cur.execute("""
# # #                 SELECT h.*, e.name AS era_name
# # #                 FROM Heroes h
# # #                 LEFT JOIN Eras e ON h.era_id = e.id
# # #                 WHERE h.slug = %s
# # #             """, (slug,))

# # #             hero = cur.fetchone()

# # #             if not hero:
# # #                 return jsonify({"error": "Hero not found"}), 404


# # #             # ───────────────────────── CATEGORIES ─────────────────────────
# # #             cur.execute("""
# # #                 SELECT c.name
# # #                 FROM Categories c
# # #                 JOIN HeroCategories hc ON c.id = hc.category_id
# # #                 WHERE hc.hero_id = %s
# # #             """, (hero["id"],))

# # #             categories = [c["name"] for c in cur.fetchall()]

# # #             # IMPORTANT FIX: prevent empty array crash in SQL ANY()
# # #             if not categories:
# # #                 categories = ["__none__"]


# # #             # ───────────────────────── RELATED HEROES ─────────────────────────
# # #             cur.execute("""
# # #                 SELECT DISTINCT
# # #                     h.id,
# # #                     h.name,
# # #                     h.slug,
# # #                     h.hero_image,
# # #                     h.short_description,
# # #                     e.name AS era_name
# # #                 FROM Heroes h
# # #                 LEFT JOIN Eras e ON h.era_id = e.id
# # #                 LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
# # #                 LEFT JOIN Categories c ON hc.category_id = c.id
# # #                 WHERE h.id != %s
# # #                 AND (
# # #                     h.era_id = %s
# # #                     OR c.name = ANY(%s::text[])
# # #                 )
# # #                 ORDER BY RANDOM()
# # #                 LIMIT 5
# # #             """, (
# # #                 hero["id"],
# # #                 hero["era_id"],
# # #                 categories
# # #             ))

# # #             related_heroes = cur.fetchall()


# # #             # ───────────────────────── IMAGES ─────────────────────────
# # #             cur.execute("""
# # #                 SELECT *
# # #                 FROM HeroImages
# # #                 WHERE hero_id = %s
# # #             """, (hero["id"],))
# # #             images = cur.fetchall()


# # #             # ───────────────────────── ACHIEVEMENTS ─────────────────────────
# # #             cur.execute("""
# # #                 SELECT *
# # #                 FROM Achievements
# # #                 WHERE hero_id = %s
# # #                 ORDER BY year ASC
# # #             """, (hero["id"],))
# # #             achievements = cur.fetchall()


# # #             # ───────────────────────── SOURCES ─────────────────────────
# # #             cur.execute("""
# # #                 SELECT *
# # #                 FROM Sources
# # #                 WHERE hero_id = %s
# # #             """, (hero["id"],))
# # #             sources = cur.fetchall()


# # #             # ───────────────────────── COMMENTS ─────────────────────────
# # #             cur.execute("""
# # #                 SELECT
# # #                     c.comment,
# # #                     u.full_name,
# # #                     u.avatar,
# # #                     c.created_at
# # #                 FROM Comments c
# # #                 JOIN Users u ON c.user_id = u.id
# # #                 WHERE c.hero_id = %s
# # #                 ORDER BY c.created_at DESC
# # #             """, (hero["id"],))

# # #             comments = cur.fetchall()


# # #         return jsonify({
# # #             "hero": hero,
# # #             "categories": categories,
# # #             "images": images,
# # #             "achievements": achievements,
# # #             "sources": sources,
# # #             "comments": comments,
# # #             "related_heroes": related_heroes
# # #         })

# # #     except Exception as e:
# # #         print("Hero API error:", e)
# # #         return jsonify({"error": "Internal server error"}), 500

# # #     finally:
# # #         conn.close()


# # # # ------------------- Favorites -------------------
# # # @main_bp.route("/hero/<int:hero_id>/add_favorite", methods=["POST"])
# # # def add_favorite(hero_id):
# # #     email = session.get("email_address")
# # #     if not email:
# # #         return redirect(url_for("auth.login"))

# # #     conn = get_db()
# # #     with conn.cursor() as cur:
# # #         cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
# # #         user = cur.fetchone()
# # #         cur.execute("INSERT INTO Favorites (user_id, hero_id) VALUES (%s, %s) ON CONFLICT DO NOTHING", (user["id"], hero_id))
# # #         conn.commit()
# # #     conn.close()
# # #     return redirect(url_for("main.hero_detail", hero_id=hero_id))

# # # @main_bp.route("/hero/<int:hero_id>/remove_favorite", methods=["POST"])
# # # def remove_favorite(hero_id):
# # #     email = session.get("email_address")
# # #     if not email:
# # #         return redirect(url_for("auth.login"))

# # #     conn = get_db()
# # #     with conn.cursor() as cur:
# # #         cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
# # #         user = cur.fetchone()
# # #         cur.execute("DELETE FROM Favorites WHERE user_id=%s AND hero_id=%s", (user["id"], hero_id))
# # #         conn.commit()
# # #     conn.close()
# # #     return redirect(url_for("main.hero_detail", hero_id=hero_id))

# # # # ------------------- Comments -------------------
# # # @main_bp.route("/hero/<int:hero_id>/add_comment", methods=["POST"])
# # # def add_comment(hero_id):
# # #     email = session.get("email_address")
# # #     if not email:
# # #         return redirect(url_for("auth.login"))

# # #     comment_text = request.form.get("comment")
# # #     conn = get_db()
# # #     with conn.cursor() as cur:
# # #         cur.execute("SELECT * FROM Users WHERE email_address=%s", (email,))
# # #         user = cur.fetchone()
# # #         cur.execute("INSERT INTO Comments (user_id, hero_id, comment) VALUES (%s, %s, %s)", (user["id"], hero_id, comment_text))
# # #         conn.commit()
# # #     conn.close()
# # #     return redirect(url_for("main.hero_detail", hero_id=hero_id))


# # main.py
# from flask import Blueprint, session, redirect, url_for, render_template, request
# import psycopg2
# from psycopg2.extras import RealDictCursor
# import os
# import json
# import datetime
# import pycountry
# from flask import jsonify, current_app

# main_bp = Blueprint('main', __name__)


# # ─────────────────────────────────────────────
# # DATE SERIALIZER — fixes the 500 error
# # ─────────────────────────────────────────────
# def serialize(obj):
#     """Converts date/datetime fields to strings so JSON doesn't crash."""
#     if isinstance(obj, (datetime.date, datetime.datetime)):
#         return obj.isoformat()
#     if isinstance(obj, datetime.timedelta):
#         return str(obj)
#     raise TypeError(f"Type {type(obj)} not serializable")

# def json_response(data, status=200):
#     """Drop-in replacement for jsonify() that handles dates."""
#     return current_app.response_class(
#         response=json.dumps(data, default=serialize),
#         status=status,
#         mimetype='application/json'
#     )


# # ─────────────────────────────────────────────
# # DATABASE
# # ─────────────────────────────────────────────
# def get_db():
#     conn = psycopg2.connect(
#         os.environ.get("DATABASE_URL"),
#         sslmode="require",
#         cursor_factory=RealDictCursor
#     )
#     return conn


# # ─────────────────────────────────────────────
# # HOME PAGE
# # ─────────────────────────────────────────────
# @main_bp.route("/api/heroes")
# def get_heroes():
#     page     = int(request.args.get("page", 1))
#     per_page = 5
#     offset   = (page - 1) * per_page

#     conn = get_db()
#     try:
#         with conn.cursor() as cur:
#             cur.execute("""
#                 SELECT DISTINCT
#                     h.id,
#                     h.name,
#                     h.hero_image,
#                     h.short_description,
#                     e.name AS era_name,
#                     c.name AS category_name
#                 FROM Heroes h
#                 LEFT JOIN Eras e ON h.era_id = e.id
#                 LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
#                 LEFT JOIN Categories c ON hc.category_id = c.id
#                 ORDER BY h.id DESC
#                 LIMIT %s OFFSET %s
#             """, (per_page, offset))
#             heroes = [dict(r) for r in cur.fetchall()]
#         return json_response(heroes)
#     except Exception as e:
#         print(f"[Heroes API Error] {e}")
#         return json_response({"error": "Internal server error"}, 500)
#     finally:
#         conn.close()


# # ─────────────────────────────────────────────
# # DIRECTORY PAGE
# # ─────────────────────────────────────────────
# @main_bp.route("/api/director")
# def director_heroes():
#     conn = get_db()
#     try:
#         with conn.cursor() as cur:
#             cur.execute("""
#                 SELECT
#                     h.id,
#                     h.name,
#                     h.hero_image,
#                     h.short_description,
#                     e.name AS era_name,
#                     STRING_AGG(c.name, ', ') AS categories
#                 FROM Heroes h
#                 LEFT JOIN Eras e ON h.era_id = e.id
#                 LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
#                 LEFT JOIN Categories c ON hc.category_id = c.id
#                 GROUP BY h.id, e.name
#                 ORDER BY h.id DESC
#             """)
#             heroes = [dict(r) for r in cur.fetchall()]
#         return json_response(heroes)
#     except Exception as e:
#         print(f"[Director API Error] {e}")
#         return json_response({"error": "Internal server error"}, 500)
#     finally:
#         conn.close()


# # ─────────────────────────────────────────────
# # SEARCH
# # ─────────────────────────────────────────────
# @main_bp.route("/api/search")
# def search():
#     query    = request.args.get("q", "")
#     category = request.args.get("category", "")
#     era      = request.args.get("era", "")
#     page     = int(request.args.get("page", 1))
#     per_page = 35
#     offset   = (page - 1) * per_page

#     conn = get_db()
#     try:
#         with conn.cursor() as cur:

#             # Count
#             count_sql    = """
#                 SELECT COUNT(DISTINCT h.id) AS total
#                 FROM Heroes h
#                 LEFT JOIN Eras e           ON h.era_id       = e.id
#                 LEFT JOIN HeroCategories hc ON h.id          = hc.hero_id
#                 LEFT JOIN Categories c     ON hc.category_id = c.id
#                 WHERE 1=1
#             """
#             count_params = []
#             if query:
#                 term = f"%{query}%"
#                 count_sql += " AND (h.name ILIKE %s OR h.short_description ILIKE %s OR h.full_biography ILIKE %s)"
#                 count_params += [term, term, term]
#             if category:
#                 count_sql += " AND c.name = %s"
#                 count_params.append(category)
#             if era:
#                 count_sql += " AND e.name = %s"
#                 count_params.append(era)

#             cur.execute(count_sql, count_params)
#             total_heroes = cur.fetchone()["total"]
#             total_pages  = (total_heroes + per_page - 1) // per_page

#             # Heroes
#             sql    = """
#                 SELECT
#                     h.id,
#                     h.slug,
#                     h.name,
#                     h.hero_image,
#                     h.short_description,
#                     e.name AS era_name,
#                     STRING_AGG(c.name, ', ') AS categories
#                 FROM Heroes h
#                 LEFT JOIN Eras e           ON h.era_id       = e.id
#                 LEFT JOIN HeroCategories hc ON h.id          = hc.hero_id
#                 LEFT JOIN Categories c     ON hc.category_id = c.id
#                 WHERE 1=1
#             """
#             params = []
#             term   = f"%{query}%"
#             if query:
#                 sql += " AND (h.name ILIKE %s OR h.short_description ILIKE %s OR h.full_biography ILIKE %s)"
#                 params += [term, term, term]
#             if category:
#                 sql += " AND c.name = %s"
#                 params.append(category)
#             if era:
#                 sql += " AND e.name = %s"
#                 params.append(era)

#             sql += " GROUP BY h.id, h.slug, h.name, h.hero_image, h.short_description, e.name"
#             sql += " ORDER BY h.id DESC LIMIT %s OFFSET %s"
#             params += [per_page, offset]

#             cur.execute(sql, params)
#             heroes = [dict(r) for r in cur.fetchall()]

#             cur.execute("SELECT * FROM Categories ORDER BY name")
#             categories = [dict(r) for r in cur.fetchall()]

#             cur.execute("SELECT * FROM Eras ORDER BY name")
#             eras = [dict(r) for r in cur.fetchall()]

#         return json_response({
#             "heroes":      heroes,
#             "categories":  categories,
#             "eras":        eras,
#             "total_pages": total_pages,
#         })

#     except Exception as e:
#         print(f"[Search API Error] q={query!r} | error={e}")
#         return json_response({"error": "Internal server error"}, 500)
#     finally:
#         conn.close()


# # ─────────────────────────────────────────────
# # HERO DETAIL  ← this was crashing with 500
# # ─────────────────────────────────────────────
# @main_bp.route("/api/hero/<slug>")
# def hero_detail(slug):

#     conn = get_db()
#     try:
#         with conn.cursor() as cur:

#             # 1. HERO
#             cur.execute("""
#                 SELECT h.*, e.name AS era_name
#                 FROM Heroes h
#                 LEFT JOIN Eras e ON h.era_id = e.id
#                 WHERE h.slug = %s
#             """, (slug,))
#             hero = cur.fetchone()

#             if not hero:
#                 return json_response({"error": "Hero not found"}, 404)

#             hero     = dict(hero)
#             hero_id  = hero["id"]
#             era_id   = hero["era_id"]

#             # 2. CATEGORIES
#             cur.execute("""
#                 SELECT c.name
#                 FROM Categories c
#                 JOIN HeroCategories hc ON c.id = hc.category_id
#                 WHERE hc.hero_id = %s
#             """, (hero_id,))
#             categories      = [row["name"] for row in cur.fetchall()]
#             category_filter = categories if categories else ["__none__"]

#             # # 3. RELATED HEROES
#             # cur.execute("""
#             #     SELECT DISTINCT
#             #         h.id, h.name, h.slug, h.hero_image, h.short_description,
#             #         e.name AS era_name
#             #     FROM Heroes h
#             #     LEFT JOIN Eras e            ON h.era_id       = e.id
#             #     LEFT JOIN HeroCategories hc ON h.id           = hc.hero_id
#             #     LEFT JOIN Categories c      ON hc.category_id = c.id
#             #     WHERE h.id != %s
#             #     AND (h.era_id = %s OR c.name = ANY(%s::text[]))
#             #     ORDER BY RANDOM()
#             #     LIMIT 5
#             # """, (hero_id, era_id, category_filter))
#             # related_heroes = [dict(r) for r in cur.fetchall()]
#             # 3. RELATED HEROES
#         # 3. RELATED HEROES
#             cur.execute("""
#                 WITH MatchedHeroes AS (
#                     SELECT DISTINCT
#                         h.id, h.name, h.slug, h.hero_image, h.short_description,
#                         e.name AS era_name
#                     FROM Heroes h
#                     LEFT JOIN Eras e            ON h.era_id       = e.id
#                     LEFT JOIN HeroCategories hc ON h.id           = hc.hero_id
#                     LEFT JOIN Categories c      ON hc.category_id = c.id
#                     WHERE h.id != %s
#                     AND (h.era_id = %s OR c.name = ANY(%s::text[]))
#                 )
#                 SELECT * FROM MatchedHeroes
#                 ORDER BY RANDOM()
#                 LIMIT 5
#             """, (hero_id, era_id, category_filter))
            
#             # ADD THIS LINE BACK IN:
#             related_heroes = [dict(r) for r in cur.fetchall()]

#             # 4. IMAGES
#             cur.execute("SELECT * FROM HeroImages WHERE hero_id = %s", (hero_id,))
#             images = [dict(r) for r in cur.fetchall()]

#             # 5. ACHIEVEMENTS
#             cur.execute("""
#                 SELECT * FROM Achievements
#                 WHERE hero_id = %s ORDER BY year ASC
#             """, (hero_id,))
#             achievements = [dict(r) for r in cur.fetchall()]

#             # 6. SOURCES
#             cur.execute("SELECT * FROM Sources WHERE hero_id = %s", (hero_id,))
#             sources = [dict(r) for r in cur.fetchall()]

#             # 7. COMMENTS
#             cur.execute("""
#                 SELECT c.comment, u.full_name, u.avatar, c.created_at
#                 FROM Comments c
#                 JOIN Users u ON c.user_id = u.id
#                 WHERE c.hero_id = %s
#                 ORDER BY c.created_at DESC
#             """, (hero_id,))
#             comments = [dict(r) for r in cur.fetchall()]

#         # ✅ json_response handles date/datetime fields — fixes the 500
#         return json_response({
#             "hero":           hero,
#             "categories":     categories,
#             "related_heroes": related_heroes,
#             "images":         images,
#             "achievements":   achievements,
#             "sources":        sources,
#             "comments":       comments,
#         })

#     except Exception as e:
#         print(f"[Hero API Error] slug={slug!r} | error={e}")
#         import traceback; traceback.print_exc()
#         return json_response({"error": "Internal server error"}, 500)

#     finally:
#         conn.close()


# @main_bp.route("/api/hero/<slug>/comment", methods=["POST"])
# def post_hero_comment(slug):
#     data = request.get_json()
#     comment_text = data.get("comment")

#     if not comment_text:
#         return json_response({"error": "Comment cannot be empty"}, 400)

#     # Note: You currently don't have user authentication in your frontend request.
#     # For now, I'm hardcoding a dummy user_id (e.g., 1) so it doesn't crash your DB.
#     # You MUST replace this with actual user session/token logic later!
#     dummy_user_id = 1 

#     conn = get_db()
#     try:
#         with conn.cursor() as cur:
#             # First, get the hero_id from the slug
#             cur.execute("SELECT id FROM Heroes WHERE slug = %s", (slug,))
#             hero = cur.fetchone()
#             if not hero:
#                 return json_response({"error": "Hero not found"}, 404)
            
#             hero_id = hero["id"]

#             # Insert the comment
#             cur.execute("""
#                 INSERT INTO Comments (hero_id, user_id, comment, created_at)
#                 VALUES (%s, %s, %s, NOW())
#             """, (hero_id, dummy_user_id, comment_text))
            
#             conn.commit()

#         return json_response({"message": "Comment posted successfully"}, 200)

#     except Exception as e:
#         print(f"[Comment API Error] {e}")
#         conn.rollback()
#         return json_response({"error": "Internal server error"}, 500)
#     finally:
#         conn.close()

# main.py
from flask import Blueprint, session, redirect, url_for, render_template, request
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import json
import datetime
import pycountry
from flask import jsonify, current_app

main_bp = Blueprint('main', __name__)


# ─────────────────────────────────────────────
# DATE SERIALIZER — fixes the 500 error
# ─────────────────────────────────────────────
def serialize(obj):
    """Converts date/datetime fields to strings so JSON doesn't crash."""
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    if isinstance(obj, datetime.timedelta):
        return str(obj)
    raise TypeError(f"Type {type(obj)} not serializable")

def json_response(data, status=200):
    """Drop-in replacement for jsonify() that handles dates."""
    return current_app.response_class(
        response=json.dumps(data, default=serialize),
        status=status,
        mimetype='application/json'
    )


# ─────────────────────────────────────────────
# DATABASE
# ─────────────────────────────────────────────
def get_db():
    conn = psycopg2.connect(
        os.environ.get("DATABASE_URL"),
        sslmode="require",
        cursor_factory=RealDictCursor
    )
    return conn


# ─────────────────────────────────────────────
# HOME PAGE
# ─────────────────────────────────────────────
@main_bp.route("/api/heroes")
def get_heroes():
    page     = int(request.args.get("page", 1))
    per_page = 5
    offset   = (page - 1) * per_page

    conn = get_db()
    try:
        with conn.cursor() as cur:
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
            heroes = [dict(r) for r in cur.fetchall()]
        return json_response(heroes)
    except Exception as e:
        print(f"[Heroes API Error] {e}")
        return json_response({"error": "Internal server error"}, 500)
    finally:
        conn.close()


# ─────────────────────────────────────────────
# DIRECTORY PAGE
# ─────────────────────────────────────────────
@main_bp.route("/api/director")
def director_heroes():
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    h.id,
                    h.name,
                    h.hero_image,
                    h.short_description,
                    e.name AS era_name,
                    STRING_AGG(c.name, ', ') AS categories
                FROM Heroes h
                LEFT JOIN Eras e ON h.era_id = e.id
                LEFT JOIN HeroCategories hc ON h.id = hc.hero_id
                LEFT JOIN Categories c ON hc.category_id = c.id
                GROUP BY h.id, e.name
                ORDER BY h.id DESC
            """)
            heroes = [dict(r) for r in cur.fetchall()]
        return json_response(heroes)
    except Exception as e:
        print(f"[Director API Error] {e}")
        return json_response({"error": "Internal server error"}, 500)
    finally:
        conn.close()


# ─────────────────────────────────────────────
# SEARCH
# ─────────────────────────────────────────────
@main_bp.route("/api/search")
def search():
    query    = request.args.get("q", "")
    category = request.args.get("category", "")
    era      = request.args.get("era", "")
    page     = int(request.args.get("page", 1))
    per_page = 35
    offset   = (page - 1) * per_page

    conn = get_db()
    try:
        with conn.cursor() as cur:

            # Count
            count_sql    = """
                SELECT COUNT(DISTINCT h.id) AS total
                FROM Heroes h
                LEFT JOIN Eras e           ON h.era_id       = e.id
                LEFT JOIN HeroCategories hc ON h.id          = hc.hero_id
                LEFT JOIN Categories c     ON hc.category_id = c.id
                WHERE 1=1
            """
            count_params = []
            if query:
                term = f"%{query}%"
                count_sql += " AND (h.name ILIKE %s OR h.short_description ILIKE %s OR h.full_biography ILIKE %s)"
                count_params += [term, term, term]
            if category:
                count_sql += " AND c.name = %s"
                count_params.append(category)
            if era:
                count_sql += " AND e.name = %s"
                count_params.append(era)

            cur.execute(count_sql, count_params)
            total_heroes = cur.fetchone()["total"]
            total_pages  = (total_heroes + per_page - 1) // per_page

            # Heroes
            sql    = """
                SELECT
                    h.id,
                    h.slug,
                    h.name,
                    h.hero_image,
                    h.short_description,
                    e.name AS era_name,
                    STRING_AGG(c.name, ', ') AS categories
                FROM Heroes h
                LEFT JOIN Eras e           ON h.era_id       = e.id
                LEFT JOIN HeroCategories hc ON h.id          = hc.hero_id
                LEFT JOIN Categories c     ON hc.category_id = c.id
                WHERE 1=1
            """
            params = []
            term   = f"%{query}%"
            if query:
                sql += " AND (h.name ILIKE %s OR h.short_description ILIKE %s OR h.full_biography ILIKE %s)"
                params += [term, term, term]
            if category:
                sql += " AND c.name = %s"
                params.append(category)
            if era:
                sql += " AND e.name = %s"
                params.append(era)

            sql += " GROUP BY h.id, h.slug, h.name, h.hero_image, h.short_description, e.name"
            sql += " ORDER BY h.id DESC LIMIT %s OFFSET %s"
            params += [per_page, offset]

            cur.execute(sql, params)
            heroes = [dict(r) for r in cur.fetchall()]

            cur.execute("SELECT * FROM Categories ORDER BY name")
            categories = [dict(r) for r in cur.fetchall()]

            cur.execute("SELECT * FROM Eras ORDER BY name")
            eras = [dict(r) for r in cur.fetchall()]

        return json_response({
            "heroes":      heroes,
            "categories":  categories,
            "eras":        eras,
            "total_pages": total_pages,
        })

    except Exception as e:
        print(f"[Search API Error] q={query!r} | error={e}")
        return json_response({"error": "Internal server error"}, 500)
    finally:
        conn.close()


# ─────────────────────────────────────────────
# HERO DETAIL  ← this was crashing with 500
# ─────────────────────────────────────────────
@main_bp.route("/api/hero/<slug>")
def hero_detail(slug):

    conn = get_db()
    try:
        with conn.cursor() as cur:

            # 1. HERO
            cur.execute("""
                SELECT h.*, e.name AS era_name
                FROM Heroes h
                LEFT JOIN Eras e ON h.era_id = e.id
                WHERE h.slug = %s
            """, (slug,))
            hero = cur.fetchone()

            if not hero:
                return json_response({"error": "Hero not found"}, 404)

            hero     = dict(hero)
            hero_id  = hero["id"]
            era_id   = hero["era_id"]

            # 2. CATEGORIES
            cur.execute("""
                SELECT c.name
                FROM Categories c
                JOIN HeroCategories hc ON c.id = hc.category_id
                WHERE hc.hero_id = %s
            """, (hero_id,))
            categories      = [row["name"] for row in cur.fetchall()]
            category_filter = categories if categories else ["__none__"]

            # 3. RELATED HEROES
            cur.execute("""
                SELECT * FROM (
                    SELECT DISTINCT
                        h.id, h.name, h.slug, h.hero_image, h.short_description,
                        e.name AS era_name
                    FROM Heroes h
                    LEFT JOIN Eras e            ON h.era_id        = e.id
                    LEFT JOIN HeroCategories hc ON h.id            = hc.hero_id
                    LEFT JOIN Categories c      ON hc.category_id = c.id
                    WHERE h.id != %s
                    AND (h.era_id = %s OR c.name = ANY(%s::text[]))
                ) AS distinct_heroes
                ORDER BY RANDOM()
                LIMIT 5
            """, (hero_id, era_id, category_filter))
            related_heroes = [dict(r) for r in cur.fetchall()]

            # 4. IMAGES
            cur.execute("SELECT * FROM HeroImages WHERE hero_id = %s", (hero_id,))
            images = [dict(r) for r in cur.fetchall()]

            # 5. ACHIEVEMENTS
            cur.execute("""
                SELECT * FROM Achievements
                WHERE hero_id = %s ORDER BY year ASC
            """, (hero_id,))
            achievements = [dict(r) for r in cur.fetchall()]

            # 6. SOURCES
            cur.execute("SELECT * FROM Sources WHERE hero_id = %s", (hero_id,))
            sources = [dict(r) for r in cur.fetchall()]

            # 7. COMMENTS
            cur.execute("""
                SELECT c.comment, u.full_name, u.avatar, c.created_at
                FROM Comments c
                JOIN Users u ON c.user_id = u.id
                WHERE c.hero_id = %s
                ORDER BY c.created_at DESC
            """, (hero_id,))
            comments = [dict(r) for r in cur.fetchall()]

        # ✅ json_response handles date/datetime fields — fixes the 500
        return json_response({
            "hero":           hero,
            "categories":     categories,
            "related_heroes": related_heroes,
            "images":         images,
            "achievements":   achievements,
            "sources":        sources,
            "comments":       comments,
        })

    except Exception as e:
        print(f"[Hero API Error] slug={slug!r} | error={e}")
        import traceback; traceback.print_exc()
        return json_response({"error": "Internal server error"}, 500)

    finally:
        conn.close()



@main_bp.route("/api/hero/<slug>/comment", methods=["POST"])
def post_hero_comment(slug):
    data = request.get_json()
    comment_text = data.get("comment")

    if not comment_text:
        return json_response({"error": "Comment cannot be empty"}, 400)

    # Note: You currently don't have user authentication in your frontend request.
    # For now, I'm hardcoding a dummy user_id (e.g., 1) so it doesn't crash your DB.
    # You MUST replace this with actual user session/token logic later!
    dummy_user_id = 1 

    conn = get_db()
    try:
        with conn.cursor() as cur:
            # First, get the hero_id from the slug
            cur.execute("SELECT id FROM Heroes WHERE slug = %s", (slug,))
            hero = cur.fetchone()
            if not hero:
                return json_response({"error": "Hero not found"}, 404)
            
            hero_id = hero["id"]

            # Insert the comment
            cur.execute("""
                INSERT INTO Comments (hero_id, user_id, comment, created_at)
                VALUES (%s, %s, %s, NOW())
            """, (hero_id, dummy_user_id, comment_text))
            
            conn.commit()

        return json_response({"message": "Comment posted successfully"}, 200)

    except Exception as e:
        print(f"[Comment API Error] {e}")
        conn.rollback()
        return json_response({"error": "Internal server error"}, 500)
    finally:
        conn.close()





# @main_bp.route("/api/heroes", methods=["POST"])
# def create_hero():
#     data = request.get_json()

#     # Required fields
#     name = data.get("name")
#     short_description = data.get("short_description")

#     if not name or not short_description:
#         return json_response({
#             "error": "name and short_description are required"
#         }, 400)

#     birth_year = data.get("birth_year")
#     death_year = data.get("death_year")
#     era_id = data.get("era_id")
#     full_biography = data.get("full_biography")
#     full_history = data.get("full_history")
#     nationality = data.get("nationality", "Ethiopian")
#     hero_image = data.get("hero_image")

#     conn = get_db()

#     try:
#         with conn.cursor() as cur:

#             cur.execute("""
#                 INSERT INTO Heroes(
#                     name,
#                     birth_year,
#                     death_year,
#                     era_id,
#                     short_description,
#                     full_biography,
#                     full_history,
#                     nationality,
#                     hero_image
#                 )
#                 VALUES (
#                     %s,%s,%s,%s,%s,%s,%s,%s,%s
#                 )
#                 RETURNING *
#             """, (
#                 name,
#                 birth_year,
#                 death_year,
#                 era_id,
#                 short_description,
#                 full_biography,
#                 full_history,
#                 nationality,
#                 hero_image
#             ))

#             hero = cur.fetchone()
#             conn.commit()

#         return json_response({
#             "message": "Hero created successfully",
#             "hero": dict(hero)
#         }, 201)

#     except Exception as e:
#         conn.rollback()
#         print(f"[Create Hero Error] {e}")

#         return json_response({
#             "error": str(e)
#         }, 500)

#     finally:
#         conn.close()

@main_bp.route("/api/heroes", methods=["POST"])
def create_hero():

    data = request.get_json()

    conn = get_db()

    try:

        with conn.cursor() as cur:

            name = data.get("name")

            if not name:
                return json_response(
                    {"error": "Hero name required"},
                    400
                )

            slug = generate_slug(name)

            # make slug unique

            original_slug = slug

            counter = 1

            while True:

                cur.execute(
                    """
                    SELECT id
                    FROM Heroes
                    WHERE slug=%s
                    """,
                    (slug,)
                )

                exists = cur.fetchone()

                if not exists:
                    break

                slug = (
                    f"{original_slug}-{counter}"
                )

                counter += 1

            # HERO

            cur.execute(
                """
                INSERT INTO Heroes(
                    name,
                    slug,
                    birth_year,
                    death_year,
                    era_id,
                    short_description,
                    full_biography,
                    full_history,
                    nationality,
                    hero_image
                )
                VALUES(
                    %s,%s,%s,%s,%s,%s,%s,%s,%s,%s
                )
                RETURNING id
                """,
                (
                    name,
                    slug,
                    data.get("birth_year"),
                    data.get("death_year"),
                    data.get("era_id"),
                    data.get("short_description"),
                    data.get("full_biography"),
                    data.get("full_history"),
                    data.get("nationality"),
                    data.get("hero_image")
                )
            )

            hero_id = cur.fetchone()["id"]

            # --------------------
            # CATEGORIES
            # --------------------

            for category_id in data.get(
                "categories",
                []
            ):

                cur.execute(
                    """
                    INSERT INTO HeroCategories(
                        hero_id,
                        category_id
                    )
                    VALUES(%s,%s)
                    """,
                    (
                        hero_id,
                        category_id
                    )
                )

            # --------------------
            # IMAGES
            # --------------------

            for image in data.get(
                "images",
                []
            ):

                cur.execute(
                    """
                    INSERT INTO HeroImages(
                        hero_id,
                        image_url,
                        caption
                    )
                    VALUES(%s,%s,%s)
                    """,
                    (
                        hero_id,
                        image.get(
                            "image_url"
                        ),
                        image.get(
                            "caption"
                        )
                    )
                )

            # --------------------
            # ACHIEVEMENTS
            # --------------------

            for achievement in data.get(
                "achievements",
                []
            ):

                cur.execute(
                    """
                    INSERT INTO Achievements(
                        hero_id,
                        title,
                        description,
                        year
                    )
                    VALUES(
                        %s,%s,%s,%s
                    )
                    """,
                    (
                        hero_id,
                        achievement.get(
                            "title"
                        ),
                        achievement.get(
                            "description"
                        ),
                        achievement.get(
                            "year"
                        )
                    )
                )

            # --------------------
            # SOURCES
            # --------------------

            for source in data.get(
                "sources",
                []
            ):

                cur.execute(
                    """
                    INSERT INTO Sources(
                        hero_id,
                        source_title,
                        source_link
                    )
                    VALUES(
                        %s,%s,%s
                    )
                    """,
                    (
                        hero_id,
                        source.get(
                            "source_title"
                        ),
                        source.get(
                            "source_link"
                        )
                    )
                )

            conn.commit()

            return json_response(
                {
                    "success": True,
                    "hero_id": hero_id,
                    "slug": slug,
                    "message":
                    "Hero created successfully"
                },
                201
            )

    except Exception as e:

        conn.rollback()

        print(
            f"[CREATE HERO ERROR] {e}"
        )

        return json_response(
            {
                "success": False,
                "error": str(e)
            },
            500
        )

    finally:
        conn.close()

@main_bp.route("/api/categories")
def get_categories():

    conn = get_db()

    try:
        with conn.cursor() as cur:

            cur.execute("""
                SELECT *
                FROM Categories
                ORDER BY name
            """)

            return json_response(
                cur.fetchall()
            )

    finally:
        conn.close()


@main_bp.route("/api/eras")
def get_eras():

    conn = get_db()

    try:
        with conn.cursor() as cur:

            cur.execute("""
                SELECT *
                FROM Eras
                ORDER BY name
            """)

            return json_response(
                cur.fetchall()
            )

    finally:
        conn.close()