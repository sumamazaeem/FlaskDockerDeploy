from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()

def create_app():
    # Create the Flask application instance
    app = Flask(__name__)
    
    # Configure your application settings from a config object
    app.config.from_object('config.Config')
    
    # Initialize SQLAlchemy with the Flask app
    db.init_app(app)
    
    # Initialize Flask-Migrate with the Flask app and SQLAlchemy database instance
    migrate.init_app(app, db)
    
    # Initialize Flask-Login with the Flask app
    login_manager.init_app(app)
    # Set the view route for login (redirect users here if they need to log in)
    login_manager.login_view = 'login'
    
    # Import the models so they are registered with SQLAlchemy
    from .models import User, BlogPost
    
    # Import and register the routes with the Flask app
    from .routes import register_routes
    register_routes(app)
    
    return app

# This function will be used by Flask-Login to load the current user
@login_manager.user_loader
def load_user(user_id):
    # Import User model here to avoid circular imports
    from .models import User
    # Fetch the user by user_id, returns None if user not found
    return User.query.get(int(user_id))