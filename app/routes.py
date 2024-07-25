from flask import render_template, redirect, url_for, flash, request
from flask_login import login_user, login_required, logout_user, current_user
from . import db  # Import the database instance
from .models import User, BlogPost  # Import the User and BlogPost models

# Function to register routes
def register_routes(app):
    
    # Route for user registration
    @app.route('/register', methods=['GET', 'POST'])
    def register():
        if request.method == 'POST':
            username = request.form['username']
            password = request.form['password']

            # Check if the username already exists
            existing_user = User.query.filter_by(username=username).first()
            if existing_user:
                flash('Username already exists. Please choose a different username.', 'warning')
                return redirect(url_for('register'))
            
            # Create a new user with hashed password
            new_user = User(username=username)
            new_user.set_password(password)  # Store the password in hash form
            db.session.add(new_user)
            db.session.commit()
            flash('Registration successful! You can now log in.', 'success')
            return redirect(url_for('login'))
        
        # Render the registration template if GET request
        return render_template('register.html')

    # Route for user login
    @app.route('/login', methods=['GET', 'POST'])
    def login():
        if request.method == 'POST':
            username = request.form['username']
            password = request.form['password']
            user = User.query.filter_by(username=username).first()
            if user and user.check_password(password):
                login_user(user)
                return redirect(url_for('admin'))
            flash('Invalid username or password', 'danger')
        
        # Render the login template if GET request
        return render_template('login.html')

    # Route for user logout
    @app.route('/logout')
    @login_required  # Ensure the user is logged in to access this route
    def logout():
        logout_user()
        return redirect(url_for('login'))

    # Route for admin page (create blog post)
    @app.route('/admin', methods=['GET', 'POST'])
    @login_required  # Ensure the user is logged in to access this route
    def admin():
        if request.method == 'POST':
            title = request.form['title']
            content = request.form['content']

            # Create a new blog post
            new_post = BlogPost(title=title, content=content, author=current_user)
            db.session.add(new_post)
            db.session.commit()
            flash('Blog post created successfully!', 'success')
            return redirect(url_for('admin'))
        
        # Render the admin template if GET request
        return render_template('admin.html')

    # Route for displaying list of blog posts
    @app.route('/')
    def blog_list():
        posts = BlogPost.query.all()
        return render_template('blog_list.html', posts=posts)

    # Route for displaying a single blog post
    @app.route('/posts/<title>')
    def blog_post(title):
        post = BlogPost.query.filter_by(title=title).first_or_404()  # Get the blog post or return 404 if not found
        return render_template('blog.html', post=post)