# run.py

# Import the create_app function from the app package
from app import create_app

# Call the create_app function to create and configure the Flask application instance
app = create_app()

# Check if the script is run directly (and not imported as a module)
if __name__ == '__main__':
    # Run the Flask application in debug mode
    app.run(debug=True)