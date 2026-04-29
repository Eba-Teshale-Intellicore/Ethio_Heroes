# app.py
from flask import Flask
from app.extensions import oauth
from app.routes.auth import auth_bp
from app.routes.main import main_bp
from dotenv import load_dotenv
import os
from flask_cors import CORS
# Load environment variables from .env
load_dotenv()

app = Flask(
    __name__,
    template_folder='app/templates',
    static_folder='app/static'
)

CORS(
    app,
    supports_credentials=True,
    origins=[
        "https://ethio-frontend.vercel.app"
    ]
)

app.secret_key = os.environ.get("SECRET_KEY")
# Secret key for session management
# app.config["SECRET_KEY"] = os.environ.get("feiwkabgwjbfsjfbsaifkbsfjhcsabfikcasfbcjsdfhbciaskfhecdapadaddfndsfehfh348fbdsfbsdkfbcs", "supersecretkey")

# Initialize OAuth with app
oauth.init_app(app)

# Register blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(main_bp)

if __name__ == "__main__":
    # Get PORT from environment (for Render)
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)