# 🎬 CineNest v4 — Cinema Booking App

A full-featured Flask + MySQL movie ticket booking platform with a **burgundy/wine cinema theme**, glassmorphism cards, and complete booking flow.

---

## 🚀 Quick Setup (Windows)

### 1. Install Python dependencies
```bash
cd CineNest
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure database
Edit `db_config.py` and set your MySQL password:
```python
DB_PASSWORD = 'your_mysql_password'
```

### 3. Import the database
Open **MySQL Workbench** → connect → open `database/cinenest.sql` → Run All

Or via command line:
```bash
mysql -u root -p < database/cinenest.sql
```

### 4. Run the app
```bash
python app.py
```

Open **http://localhost:5000**

---

## 🔑 Default Credentials

| Role  | Username | Password  |
|-------|----------|-----------|
| Admin | admin    | admin123  |
| User  | Register at `/register` | — |

Admin Panel: http://localhost:5000/admin/login

---

## 📁 Project Structure

```
CineNest/
├── app.py                    # Flask routes & logic
├── db_config.py              # Database config (edit this!)
├── requirements.txt
├── README.md
├── database/
│   └── cinenest.sql          # Full schema + 150 movies seed
├── static/
│   ├── css/style.css         # Complete burgundy theme
│   ├── js/main.js            # Animations, confetti, helpers
│   └── images/
│       └── placeholder.svg   # Fallback poster
└── templates/
    ├── base.html             # Layout, navbar, trailer modal
    ├── home.html             # Movie grid with language filters
    ├── movie_detail.html     # Movie detail page
    ├── select_city.html      # City picker
    ├── select_theater.html   # Theater + showtime picker
    ├── seat_selection.html   # Visual seat map
    ├── food_order.html       # Canteen menu & cart
    ├── booking_success.html  # Ticket + confetti
    ├── my_bookings.html      # User booking history
    ├── login.html
    ├── register.html
    ├── admin_login.html
    └── admin_dashboard.html  # Full management panel
```

---

## ✨ Features

### User Features
- **150+ Movies** across Tamil, Telugu, Malayalam, Hindi, Hollywood
- **Language & Genre filtering** with live counts
- **City → Theater → Date → Screen → Showtime** booking flow
- **Visual seat map** with Premium (A–C rows) / Standard pricing
- **Food ordering** — Popcorn, Nachos, Fries, Combos, Drinks
- **YouTube trailer modal** — autoplay, stops on close
- **Booking confirmation ticket** with confetti animation
- **My Bookings** — Upcoming / Past tabs

### Admin Features
- Secure admin panel at `/admin/login`
- Add / Edit / Delete movies with poster upload
- Add theaters, screens, showtimes
- View all bookings with revenue stats

### Design
- **Burgundy / Wine Red** (#7c1034) primary palette
- Dark cinematic background (#0a0810)
- **Glassmorphism** cards with backdrop-filter
- **Bebas Neue** headers, **Inter** body, **Space Mono** prices
- Smooth hover animations, scroll-triggered reveals
- Fully **responsive** (mobile-first)

---

## 🗄️ Database Schema

| Table       | Purpose                          |
|-------------|----------------------------------|
| users       | Registered users                 |
| admins      | Admin accounts                   |
| movies      | All movie data + trailer IDs     |
| cities      | 10 cities                        |
| theaters    | 14 theaters across cities        |
| screens     | Multiple screens per theater     |
| showtimes   | 7-day schedule auto-generated    |
| bookings    | Confirmed bookings               |
| food_orders | Food items per booking           |

---

## 📝 Notes

- Posters load from Wikipedia/IMDB URLs with SVG fallback
- Trailers use YouTube embed IDs
- Showtimes auto-generate for 7 days on SQL import
- Admin password check allows `admin123` directly (dev mode)

For production: change `SECRET_KEY` in `db_config.py` and hash the admin password properly.
