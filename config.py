import os

# Load environment variables from .env file if it exists
from dotenv import load_dotenv
load_dotenv()

# Define basedir using os.path.abspath(__file__) to get the directory of the current file
basedir = os.path.abspath(os.path.dirname(__file__))

class Config:
    # Secret key for cryptographic operations (e.g., signing cookies)
    SECRET_KEY = os.environ.get('SECRET_KEY', 'your_secret_key_here')
    
    # Database URI for SQLAlchemy
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL', 'sqlite:///' + os.path.join(basedir, 'app.db')).replace(
        'postgres://', 'postgresql://')
    
    # Disable SQLAlchemy modification tracking to save memory
    SQLALCHEMY_TRACK_MODIFICATIONS = False