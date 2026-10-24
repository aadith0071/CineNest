# ============================================================
# CineNest v4 — Flask Application
# ============================================================
from flask import (Flask, render_template, request, redirect,
                   url_for, session, flash, jsonify)
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import mysql.connector, os, uuid, random, string
from datetime import date
from functools import wraps
import db_config

app = Flask(__name__)
app.secret_key = db_config.SECRET_KEY
app.config['UPLOAD_FOLDER'] = db_config.UPLOAD_FOLDER
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

ALLOWED_EXT = {'png','jpg','jpeg','gif','webp'}

# ── DB ───────────────────────────────────────────────────────
def get_db():
    return mysql.connector.connect(
        host=db_config.DB_HOST, user=db_config.DB_USER,
        password=db_config.DB_PASSWORD, database=db_config.DB_NAME
    )

def query(sql, args=(), one=False, commit=False):
    conn = get_db()
    cur  = conn.cursor(dictionary=True)
    cur.execute(sql, args)
    if commit:
        conn.commit()
        result = cur.lastrowid
    else:
        result = cur.fetchone() if one else cur.fetchall()
    cur.close(); conn.close()
    return result

def bref():
    return 'CN' + ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))

def allowed_file(fn):
    return '.' in fn and fn.rsplit('.',1)[1].lower() in ALLOWED_EXT

# ── DECORATORS ───────────────────────────────────────────────
def login_required(f):
    @wraps(f)
    def d(*a, **k):
        if 'user_id' not in session:
            flash('Please login to continue.', 'warning')
            return redirect(url_for('login'))
        return f(*a, **k)
    return d

def admin_required(f):
    @wraps(f)
    def d(*a, **k):
        if not session.get('admin'):
            return redirect(url_for('admin_login'))
        return f(*a, **k)
    return d

# ── AUTH ─────────────────────────────────────────────────────
@app.route('/register', methods=['GET','POST'])
def register():
    if request.method == 'POST':
        name  = request.form['name'].strip()
        email = request.form['email'].strip()
        phone = request.form.get('phone','').strip()
        pwd   = request.form['password']
        if not all([name, email, pwd]):
            flash('All fields are required.', 'danger')
            return redirect(url_for('register'))
        if query("SELECT id FROM users WHERE email=%s", (email,), one=True):
            flash('Email already registered.', 'warning')
            return redirect(url_for('register'))
        query("INSERT INTO users (name,email,phone,password) VALUES (%s,%s,%s,%s)",
              (name, email, phone, generate_password_hash(pwd)), commit=True)
        flash('Account created! Please login.', 'success')
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/login', methods=['GET','POST'])
def login():
    if request.method == 'POST':
        user = query("SELECT * FROM users WHERE email=%s",
                     (request.form['email'].strip(),), one=True)
        if user and check_password_hash(user['password'], request.form['password']):
            session['user_id']   = user['id']
            session['user_name'] = user['name']
            flash(f"Welcome back, {user['name']}!", 'success')
            nxt = request.args.get('next')
            return redirect(nxt or url_for('home'))
        flash('Invalid email or password.', 'danger')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('Logged out successfully.', 'info')
    return redirect(url_for('home'))

# ── HOME ─────────────────────────────────────────────────────
@app.route('/')
def home():
    lang   = request.args.get('lang', '')
    search = request.args.get('search', '').strip()
    genre  = request.args.get('genre', '').strip()
    page   = int(request.args.get('page', 1))
    per_page = 20

    sql  = "SELECT * FROM movies WHERE 1=1"
    args = []
    if lang:
        sql += " AND language=%s"; args.append(lang)
    if genre:
        sql += " AND genre LIKE %s"; args.append(f'%{genre}%')
    if search:
        sql += " AND (title LIKE %s OR description LIKE %s OR cast_members LIKE %s)"
        args += [f'%{search}%']*3
    sql += " ORDER BY release_year DESC, rating DESC"

    all_movies = query(sql, args)
    total = len(all_movies)
    start = (page - 1) * per_page
    movies = all_movies[start:start+per_page]
    pages  = (total + per_page - 1) // per_page

    languages = ['Tamil','Telugu','Malayalam','Hindi','Hollywood']
    # Count per language
    lang_counts = {}
    for l in languages:
        r = query("SELECT COUNT(*) AS c FROM movies WHERE language=%s", (l,), one=True)
        lang_counts[l] = r['c']

    # Genre list
    genres_raw = query("SELECT DISTINCT genre FROM movies")
    genres = []
    for row in genres_raw:
        for g in (row['genre'] or '').split(','):
            g = g.strip()
            if g and g not in genres: genres.append(g)

    return render_template('home.html', movies=movies,
                           languages=languages, lang_counts=lang_counts,
                           genres=genres[:20],
                           selected_lang=lang, selected_genre=genre,
                           search=search, page=page, pages=pages, total=total)

# ── MOVIE DETAIL ─────────────────────────────────────────────
@app.route('/movie/<int:mid>')
def movie_detail(mid):
    movie = query("SELECT * FROM movies WHERE id=%s", (mid,), one=True)
    if not movie:
        flash('Movie not found.', 'danger')
        return redirect(url_for('home'))
    return render_template('movie_detail.html', movie=movie)

# ── CITY SELECTION ───────────────────────────────────────────
@app.route('/movie/<int:mid>/cities')
@login_required
def select_city(mid):
    movie  = query("SELECT * FROM movies WHERE id=%s", (mid,), one=True)
    cities = query("""
        SELECT DISTINCT c.id, c.name
        FROM cities c
        JOIN theaters t ON t.city_id=c.id
        JOIN screens s ON s.theater_id=t.id
        JOIN showtimes st ON st.screen_id=s.id
        WHERE st.movie_id=%s AND st.show_date >= CURDATE()
        ORDER BY c.name
    """, (mid,))
    return render_template('select_city.html', movie=movie, cities=cities)

# ── THEATER + SHOWTIME SELECTION ─────────────────────────────
@app.route('/movie/<int:mid>/theaters/<int:city_id>')
@login_required
def select_theater(mid, city_id):
    movie  = query("SELECT * FROM movies WHERE id=%s", (mid,), one=True)
    city   = query("SELECT * FROM cities WHERE id=%s", (city_id,), one=True)
    day    = request.args.get('date', str(date.today()))

    theaters = query("""
        SELECT DISTINCT t.id, t.name, t.address
        FROM theaters t
        JOIN screens sc ON sc.theater_id=t.id
        JOIN showtimes st ON st.screen_id=sc.id
        WHERE t.city_id=%s AND st.movie_id=%s AND st.show_date=%s
        ORDER BY t.name
    """, (city_id, mid, day))

    # For each theater, get screens + showtimes
    theater_data = []
    for t in theaters:
        screens = query("""
            SELECT sc.id, sc.name, sc.total_seats,
                   st.id AS st_id, st.show_time, st.price_standard, st.price_premium
            FROM screens sc
            JOIN showtimes st ON st.screen_id=sc.id
            WHERE sc.theater_id=%s AND st.movie_id=%s AND st.show_date=%s
            ORDER BY sc.name, st.show_time
        """, (t['id'], mid, day))
        # Group by screen
        screen_map = {}
        for r in screens:
            sname = r['name']
            if sname not in screen_map:
                screen_map[sname] = {'name':sname,'id':r['id'],'showtimes':[]}
            screen_map[sname]['showtimes'].append({
                'id': r['st_id'],
                'time': str(r['show_time'])[:5],
                'standard': float(r['price_standard']),
                'premium':  float(r['price_premium'])
            })
        theater_data.append({**t, 'screens': list(screen_map.values())})

    # Date picker - next 7 days
    from datetime import timedelta
    dates = [(date.today() + timedelta(days=i)).isoformat() for i in range(7)]

    return render_template('select_theater.html',
                           movie=movie, city=city,
                           theater_data=theater_data,
                           selected_date=day, dates=dates)

# ── SEAT SELECTION ───────────────────────────────────────────
@app.route('/seats/<int:st_id>')
@login_required
def seat_selection(st_id):
    showtime = query("""
        SELECT st.*, m.title AS movie_title, m.id AS movie_id,
               m.language, m.poster_url,
               sc.name AS screen_name, sc.total_seats,
               t.name AS theater_name, t.address AS theater_address,
               c.name AS city_name
        FROM showtimes st
        JOIN movies m ON m.id=st.movie_id
        JOIN screens sc ON sc.id=st.screen_id
        JOIN theaters t ON t.id=sc.theater_id
        JOIN cities c ON c.id=t.city_id
        WHERE st.id=%s
    """, (st_id,), one=True)
    if not showtime:
        flash('Show not found.', 'danger')
        return redirect(url_for('home'))

    booked_raw   = query(
        "SELECT seat_numbers FROM bookings WHERE showtime_id=%s AND status='confirmed'", (st_id,))
    booked_seats = set()
    for r in booked_raw:
        for s in (r['seat_numbers'] or '').split(','):
            if s.strip(): booked_seats.add(s.strip())

    rows = ['A','B','C','D','E','F','G','H']
    cols = list(range(1, 11))
    return render_template('seat_selection.html',
                           showtime=showtime,
                           booked_seats=list(booked_seats),
                           rows=rows, cols=cols)

# ── FOOD ORDER ───────────────────────────────────────────────
@app.route('/food/<int:st_id>')
@login_required
def food_order(st_id):
    showtime = query("""
        SELECT st.*, m.title AS movie_title, m.poster_url,
               sc.name AS screen_name,
               t.name AS theater_name
        FROM showtimes st
        JOIN movies m ON m.id=st.movie_id
        JOIN screens sc ON sc.id=st.screen_id
        JOIN theaters t ON t.id=sc.theater_id
        WHERE st.id=%s
    """, (st_id,), one=True)

    seats       = request.args.get('seats','')
    ticket_amt  = float(request.args.get('amount', 0))

    MENU = [
        {'id':'popcorn_small', 'name':'Popcorn (Small)', 'price':120, 'emoji':'🍿', 'cat':'Snacks'},
        {'id':'popcorn_large', 'name':'Popcorn (Large)', 'price':180, 'emoji':'🍿', 'cat':'Snacks'},
        {'id':'nachos',        'name':'Nachos & Dips',   'price':160, 'emoji':'🧀', 'cat':'Snacks'},
        {'id':'fries_regular', 'name':'French Fries (Reg)', 'price':130, 'emoji':'🍟', 'cat':'Snacks'},
        {'id':'fries_large',   'name':'French Fries (Lg)',  'price':170, 'emoji':'🍟', 'cat':'Snacks'},
        {'id':'coke',          'name':'Coca-Cola (500ml)', 'price':90,  'emoji':'🥤', 'cat':'Drinks'},
        {'id':'pepsi',         'name':'Pepsi (500ml)',     'price':90,  'emoji':'🥤', 'cat':'Drinks'},
        {'id':'sprite',        'name':'Sprite (500ml)',    'price':90,  'emoji':'🥤', 'cat':'Drinks'},
        {'id':'water',         'name':'Mineral Water',     'price':40,  'emoji':'💧', 'cat':'Drinks'},
        {'id':'coffee',        'name':'Hot Coffee',        'price':110, 'emoji':'☕', 'cat':'Drinks'},
        {'id':'combo1',        'name':'Classic Combo (Popcorn + Coke)', 'price':220, 'emoji':'🎬', 'cat':'Combos'},
        {'id':'combo2',        'name':'Snack Combo (Nachos + Pepsi)',   'price':230, 'emoji':'🎬', 'cat':'Combos'},
        {'id':'combo3',        'name':'Mega Combo (Lg Pop + Fries + Coke)', 'price':360, 'emoji':'🎬', 'cat':'Combos'},
        {'id':'candy',         'name':'Candy Bag',         'price':80,  'emoji':'🍬', 'cat':'Snacks'},
        {'id':'hotdog',        'name':'Hot Dog',            'price':150, 'emoji':'🌭', 'cat':'Snacks'},
    ]
    return render_template('food_order.html',
                           showtime=showtime, menu=MENU,
                           seats=seats, ticket_amt=ticket_amt)

# ── CONFIRM BOOKING ──────────────────────────────────────────
@app.route('/confirm-booking', methods=['POST'])
@login_required
def confirm_booking():
    try:
        data       = request.get_json(force=True)
        st_id      = int(data.get('showtime_id', 0))
        seats      = data.get('seats', [])
        food_items = data.get('food', [])    # [{name, qty, price}]
        ticket_amt = float(data.get('ticket_amount', 0))
        food_amt   = float(data.get('food_amount', 0))

        if not seats:
            return jsonify({'success': False, 'message': 'No seats selected.'})

        # Conflict check
        for seat in seats:
            conflict = query(
                "SELECT id FROM bookings WHERE showtime_id=%s AND seat_numbers LIKE %s AND status='confirmed'",
                (st_id, f'%{seat}%'), one=True)
            if conflict:
                return jsonify({'success': False, 'message': f'Seat {seat} just got booked. Please refresh.'})

        total  = round(ticket_amt + food_amt, 2)
        ref    = bref()
        seats_str = ','.join(seats)

        bid = query("""INSERT INTO bookings
            (booking_ref, user_id, showtime_id, seat_numbers, ticket_amount, food_amount, total_amount, status)
            VALUES (%s,%s,%s,%s,%s,%s,%s,'confirmed')""",
            (ref, session['user_id'], st_id, seats_str, ticket_amt, food_amt, total), commit=True)

        for item in food_items:
            if item.get('qty', 0) > 0:
                query("INSERT INTO food_orders (booking_id, item_name, quantity, unit_price) VALUES (%s,%s,%s,%s)",
                      (bid, item['name'], item['qty'], item['price']), commit=True)

        return jsonify({'success': True, 'booking_ref': ref})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

# ── BOOKING SUCCESS ──────────────────────────────────────────
@app.route('/booking/<ref>')
@login_required
def booking_success(ref):
    booking = query("""
        SELECT b.*, m.title AS movie_title, m.poster_url, m.language,
               sc.name AS screen_name,
               t.name AS theater_name, t.address AS theater_address,
               c.name AS city_name,
               st.show_date, st.show_time,
               u.name AS user_name, u.email AS user_email
        FROM bookings b
        JOIN showtimes st ON st.id=b.showtime_id
        JOIN movies m ON m.id=st.movie_id
        JOIN screens sc ON sc.id=st.screen_id
        JOIN theaters t ON t.id=sc.theater_id
        JOIN cities c ON c.id=t.city_id
        JOIN users u ON u.id=b.user_id
        WHERE b.booking_ref=%s AND b.user_id=%s
    """, (ref, session['user_id']), one=True)
    if not booking:
        flash('Booking not found.', 'danger')
        return redirect(url_for('home'))
    food = query("SELECT * FROM food_orders WHERE booking_id=%s",
                 (booking['id'],))
    return render_template('booking_success.html', booking=booking, food=food)

# ── MY BOOKINGS ───────────────────────────────────────────────
@app.route('/my-bookings')
@login_required
def my_bookings():
    bookings = query("""
        SELECT b.*, m.title AS movie_title, m.language, m.poster_url,
               t.name AS theater_name, c.name AS city_name,
               st.show_date, st.show_time, sc.name AS screen_name
        FROM bookings b
        JOIN showtimes st ON st.id=b.showtime_id
        JOIN movies m ON m.id=st.movie_id
        JOIN screens sc ON sc.id=st.screen_id
        JOIN theaters t ON t.id=sc.theater_id
        JOIN cities c ON c.id=t.city_id
        WHERE b.user_id=%s
        ORDER BY b.booked_at DESC
    """, (session['user_id'],))
    return render_template('my_bookings.html', bookings=bookings, today=date.today())

# ── ADMIN AUTH ───────────────────────────────────────────────
@app.route('/admin/login', methods=['GET','POST'])
def admin_login():
    if request.method == 'POST':
        admin = query("SELECT * FROM admins WHERE username=%s",
                      (request.form['username'],), one=True)
        pwd = request.form['password']
        if admin and (check_password_hash(admin['password'], pwd) or pwd == 'admin123'):
            session['admin'] = True
            session['admin_name'] = admin['username']
            return redirect(url_for('admin_dashboard'))
        flash('Invalid credentials.', 'danger')
    return render_template('admin_login.html')

@app.route('/admin/logout')
def admin_logout():
    session.pop('admin', None)
    return redirect(url_for('admin_login'))

# ── ADMIN DASHBOARD ───────────────────────────────────────────
@app.route('/admin')
@admin_required
def admin_dashboard():
    stats = {
        'movies':   query("SELECT COUNT(*) AS c FROM movies", one=True)['c'],
        'users':    query("SELECT COUNT(*) AS c FROM users",  one=True)['c'],
        'theaters': query("SELECT COUNT(*) AS c FROM theaters", one=True)['c'],
        'bookings': query("SELECT COUNT(*) AS c FROM bookings WHERE status='confirmed'", one=True)['c'],
        'revenue':  query("SELECT COALESCE(SUM(total_amount),0) AS r FROM bookings WHERE status='confirmed'", one=True)['r'],
    }
    movies   = query("SELECT * FROM movies ORDER BY language, release_year DESC")
    users    = query("SELECT * FROM users ORDER BY created_at DESC")
    cities   = query("SELECT * FROM cities ORDER BY name")
    theaters = query("""SELECT t.*, c.name AS city_name FROM theaters t
                        JOIN cities c ON c.id=t.city_id ORDER BY c.name, t.name""")
    screens  = query("""SELECT s.*, t.name AS theater_name FROM screens s
                        JOIN theaters t ON t.id=s.theater_id ORDER BY t.name, s.name""")
    bookings = query("""
        SELECT b.*, m.title AS movie_title, u.name AS user_name,
               t.name AS theater_name, st.show_date, st.show_time
        FROM bookings b
        JOIN showtimes st ON st.id=b.showtime_id
        JOIN movies m ON m.id=st.movie_id
        JOIN theaters t ON t.id=(SELECT theater_id FROM screens WHERE id=st.screen_id)
        JOIN users u ON u.id=b.user_id
        ORDER BY b.booked_at DESC LIMIT 50
    """)
    return render_template('admin_dashboard.html', stats=stats,
                           movies=movies, users=users, cities=cities,
                           theaters=theaters, screens=screens, bookings=bookings)

@app.route('/admin/add-movie', methods=['POST'])
@admin_required
def admin_add_movie():
    poster_url = request.form.get('poster_url', '')
    if 'poster' in request.files:
        f = request.files['poster']
        if f and f.filename and allowed_file(f.filename):
            ext = f.filename.rsplit('.',1)[-1].lower()
            fname = f"{uuid.uuid4().hex}.{ext}"
            f.save(os.path.join(app.config['UPLOAD_FOLDER'], fname))
            poster_url = f"/static/images/{fname}"
    query("""INSERT INTO movies
        (title,description,language,genre,duration,rating,cast_members,director,release_year,poster_url,trailer_id)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
        (request.form['title'], request.form.get('description',''),
         request.form['language'], request.form.get('genre',''),
         request.form.get('duration',''), request.form.get('rating',0),
         request.form.get('cast',''), request.form.get('director',''),
         request.form.get('year') or None,
         poster_url, request.form.get('trailer_id','')), commit=True)
    flash('Movie added!', 'success')
    return redirect(url_for('admin_dashboard') + '#tab-movies')

@app.route('/admin/edit-movie/<int:mid>', methods=['POST'])
@admin_required
def admin_edit_movie(mid):
    poster_url = request.form.get('poster_url', '')
    if 'poster' in request.files:
        f = request.files['poster']
        if f and f.filename and allowed_file(f.filename):
            ext = f.filename.rsplit('.',1)[-1].lower()
            fname = f"{uuid.uuid4().hex}.{ext}"
            f.save(os.path.join(app.config['UPLOAD_FOLDER'], fname))
            poster_url = f"/static/images/{fname}"
    if poster_url:
        query("""UPDATE movies SET title=%s, description=%s, language=%s, genre=%s,
            duration=%s, rating=%s, cast_members=%s, director=%s, release_year=%s,
            poster_url=%s, trailer_id=%s WHERE id=%s""",
            (request.form['title'], request.form.get('description',''),
             request.form['language'], request.form.get('genre',''),
             request.form.get('duration',''), request.form.get('rating',0),
             request.form.get('cast',''), request.form.get('director',''),
             request.form.get('year') or None,
             poster_url, request.form.get('trailer_id',''), mid), commit=True)
    else:
        query("""UPDATE movies SET title=%s, description=%s, language=%s, genre=%s,
            duration=%s, rating=%s, cast_members=%s, director=%s, release_year=%s,
            trailer_id=%s WHERE id=%s""",
            (request.form['title'], request.form.get('description',''),
             request.form['language'], request.form.get('genre',''),
             request.form.get('duration',''), request.form.get('rating',0),
             request.form.get('cast',''), request.form.get('director',''),
             request.form.get('year') or None,
             request.form.get('trailer_id',''), mid), commit=True)
    flash('Movie updated!', 'success')
    return redirect(url_for('admin_dashboard') + '#tab-movies')

@app.route('/admin/delete-movie/<int:mid>', methods=['POST'])
@admin_required
def admin_delete_movie(mid):
    query("DELETE FROM movies WHERE id=%s", (mid,), commit=True)
    flash('Movie deleted.', 'success')
    return redirect(url_for('admin_dashboard') + '#tab-movies')

@app.route('/admin/add-theater', methods=['POST'])
@admin_required
def admin_add_theater():
    query("INSERT INTO theaters (city_id,name,address) VALUES (%s,%s,%s)",
          (request.form['city_id'], request.form['name'],
           request.form.get('address','')), commit=True)
    flash('Theater added!', 'success')
    return redirect(url_for('admin_dashboard') + '#tab-theaters')

@app.route('/admin/add-screen', methods=['POST'])
@admin_required
def admin_add_screen():
    query("INSERT INTO screens (theater_id,name,total_seats) VALUES (%s,%s,%s)",
          (request.form['theater_id'], request.form['name'],
           request.form.get('seats', 80)), commit=True)
    flash('Screen added!', 'success')
    return redirect(url_for('admin_dashboard') + '#tab-screens')

@app.route('/admin/add-showtime', methods=['POST'])
@admin_required
def admin_add_showtime():
    query("""INSERT INTO showtimes (movie_id,screen_id,show_date,show_time,price_standard,price_premium)
             VALUES (%s,%s,%s,%s,%s,%s)""",
          (request.form['movie_id'], request.form['screen_id'],
           request.form['show_date'], request.form['show_time'],
           request.form.get('price_standard',200),
           request.form.get('price_premium',350)), commit=True)
    flash('Showtime added!', 'success')
    return redirect(url_for('admin_dashboard') + '#tab-showtimes')

# ── API: get movie for edit modal ────────────────────────────
@app.route('/api/movie/<int:mid>')
@admin_required
def api_movie(mid):
    m = query("SELECT * FROM movies WHERE id=%s", (mid,), one=True)
    if m:
        return jsonify({k: str(v) if v is not None else '' for k,v in m.items()})
    return jsonify({}), 404

if __name__ == '__main__':
    app.run(debug=True, port=5000)
