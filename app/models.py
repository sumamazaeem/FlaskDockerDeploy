from . import db  # Import the database instance from the current package
from flask_login import UserMixin  # Import UserMixin for user authentication handling
from werkzeug.security import generate_password_hash, check_password_hash  # Import functions to hash and check passwords

# Define the User model
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)  # Primary key for the User model
    username = db.Column(db.String(150), nullable=False, unique=True)  # Username must be unique and cannot be null
    password_hash = db.Column(db.String(150), nullable=False)  # Store the hashed password

    # One-to-Many relationship: One user can have many blog posts
    posts = db.relationship('BlogPost', backref='author', lazy=True)

    # Method to set the password (hash it before storing)
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    # Method to check the password against the stored hash
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)


# Define the BlogPost model
class BlogPost(db.Model):
    id = db.Column(db.Integer, primary_key=True)  # Primary key for the BlogPost model
    title = db.Column(db.String(150), nullable=False)  # Title of the blog post, cannot be null
    content = db.Column(db.Text, nullable=False)  # Content of the blog post, cannot be null

    # Foreign key to the User model, establishes a many-to-one relationship (many posts per user)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', name='fk_user_blogpost_user_id'), nullable=False)