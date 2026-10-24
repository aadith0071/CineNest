/* ============================================================
   CineNest v4 — main.js
   ============================================================ */

/* ── CONFETTI ────────────────────────────────────────────── */
function launchConfetti() {
  const canvas = document.createElement('canvas');
  canvas.id = 'confettiCanvas';
  document.body.appendChild(canvas);
  const ctx    = canvas.getContext('2d');
  canvas.width  = window.innerWidth;
  canvas.height = window.innerHeight;

  const COLORS  = ['#7c1034','#c44060','#c9a84c','#fff','#e07090','#fbbf24','#3b82f6'];
  const pieces  = [];
  const COUNT   = 160;

  for (let i = 0; i < COUNT; i++) {
    pieces.push({
      x:     Math.random() * canvas.width,
      y:     Math.random() * canvas.height - canvas.height,
      r:     Math.random() * 7 + 3,
      color: COLORS[Math.floor(Math.random() * COLORS.length)],
      tilt:  Math.random() * 10 - 10,
      tiltAngleInc: Math.random() * 0.07 + 0.05,
      tiltAngle: 0,
      vx:    Math.random() * 2 - 1,
      vy:    Math.random() * 3 + 2,
      shape: Math.random() > 0.5 ? 'rect' : 'circle',
    });
  }

  let frame;
  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    let allDone = true;
    pieces.forEach(p => {
      p.tiltAngle += p.tiltAngleInc;
      p.y  += p.vy;
      p.x  += p.vx;
      p.tilt = Math.sin(p.tiltAngle) * 12;
      if (p.y < canvas.height + 20) allDone = false;
      ctx.beginPath();
      ctx.fillStyle = p.color;
      ctx.globalAlpha = 0.85;
      if (p.shape === 'rect') {
        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate(p.tilt * Math.PI / 180);
        ctx.fillRect(-p.r / 2, -p.r / 2, p.r, p.r * 2.5);
        ctx.restore();
      } else {
        ctx.arc(p.x + p.tilt, p.y, p.r, 0, Math.PI * 2);
        ctx.fill();
      }
    });
    ctx.globalAlpha = 1;
    if (!allDone) {
      frame = requestAnimationFrame(draw);
    } else {
      canvas.remove();
    }
  }
  draw();
  setTimeout(() => { cancelAnimationFrame(frame); canvas.remove(); }, 5000);
}

/* ── SCROLL ANIMATIONS ───────────────────────────────────── */
function initScrollAnimations() {
  const cards = document.querySelectorAll('.movie-card');
  cards.forEach((c, i) => { c.style.setProperty('--idx', i); });

  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          e.target.style.opacity = '1';
          e.target.style.transform = 'translateY(0)';
        }
      });
    }, { threshold: 0.08 });

    document.querySelectorAll('.feature-card, .theater-card, .bk-ticket-card').forEach(el => {
      el.style.opacity = '0';
      el.style.transform = 'translateY(20px)';
      el.style.transition = 'opacity .4s ease, transform .4s ease';
      observer.observe(el);
    });
  }
}

/* ── SMOOTH FLASH DISMISS ────────────────────────────────── */
function initFlashDismiss() {
  document.querySelectorAll('.flash-item').forEach(item => {
    setTimeout(() => {
      item.style.transition = 'opacity .5s ease, transform .5s ease';
      item.style.opacity = '0';
      item.style.transform = 'translateX(30px)';
      setTimeout(() => item.remove(), 500);
    }, 4000);
  });
}

/* ── NAVBAR SCROLL EFFECT ───────────────────────────────── */
function initNavbar() {
  const nav = document.querySelector('.cn-navbar');
  if (!nav) return;
  window.addEventListener('scroll', () => {
    if (window.scrollY > 40) {
      nav.style.background = 'rgba(10,8,16,.97)';
      nav.style.boxShadow  = '0 2px 20px rgba(0,0,0,.4)';
    } else {
      nav.style.background = 'rgba(10,8,16,.85)';
      nav.style.boxShadow  = 'none';
    }
  }, { passive: true });
}

/* ── SEARCH FORM HELPERS ─────────────────────────────────── */
function initSearch() {
  // Close flash on ESC
  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
      document.querySelectorAll('.flash-item').forEach(f => f.remove());
    }
  });
}

/* ── INIT ────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
  initScrollAnimations();
  initFlashDismiss();
  initNavbar();
  initSearch();
});

/* ── GLOBAL TRAILER HELPERS ──────────────────────────────── */
function stopTrailer() {
  const frame = document.getElementById('trailerFrame');
  if (frame) frame.src = '';
}
