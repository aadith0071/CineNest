-- ============================================================
-- CineNest v4 — Complete Database
-- ============================================================
DROP DATABASE IF EXISTS cinenest;
CREATE DATABASE cinenest CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cinenest;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(180) NOT NULL UNIQUE,
  phone VARCHAR(20),
  password VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(80) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL
);

CREATE TABLE movies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  language ENUM('Tamil','Telugu','Malayalam','Hindi','Hollywood') NOT NULL,
  genre VARCHAR(200),
  duration VARCHAR(20),
  rating DECIMAL(3,1) DEFAULT 0,
  cast_members TEXT,
  director VARCHAR(120),
  release_year INT,
  poster_url VARCHAR(600),
  trailer_id VARCHAR(60),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE theaters (
  id INT AUTO_INCREMENT PRIMARY KEY,
  city_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  address VARCHAR(400),
  FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE TABLE screens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  theater_id INT NOT NULL,
  name VARCHAR(80) NOT NULL,
  total_seats INT DEFAULT 80,
  FOREIGN KEY (theater_id) REFERENCES theaters(id) ON DELETE CASCADE
);

CREATE TABLE showtimes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  movie_id INT NOT NULL,
  screen_id INT NOT NULL,
  show_date DATE NOT NULL,
  show_time TIME NOT NULL,
  price_standard DECIMAL(8,2) DEFAULT 200,
  price_premium DECIMAL(8,2) DEFAULT 350,
  FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
  FOREIGN KEY (screen_id) REFERENCES screens(id) ON DELETE CASCADE
);

CREATE TABLE bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_ref VARCHAR(20) NOT NULL UNIQUE,
  user_id INT NOT NULL,
  showtime_id INT NOT NULL,
  seat_numbers TEXT NOT NULL,
  ticket_amount DECIMAL(10,2) DEFAULT 0,
  food_amount DECIMAL(10,2) DEFAULT 0,
  total_amount DECIMAL(10,2) DEFAULT 0,
  status ENUM('confirmed','cancelled') DEFAULT 'confirmed',
  booked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (showtime_id) REFERENCES showtimes(id)
);

CREATE TABLE food_orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT NOT NULL,
  item_name VARCHAR(120) NOT NULL,
  quantity INT DEFAULT 1,
  unit_price DECIMAL(8,2),
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);

-- ── ADMIN (password: admin123) ────────────────────────────────
INSERT INTO admins (username, password) VALUES
('admin','pbkdf2:sha256:260000$cinenest$8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92');

-- ── CITIES ───────────────────────────────────────────────────
INSERT INTO cities (name) VALUES
('Chennai'),('Mumbai'),('Delhi'),('Hyderabad'),('Bangalore'),
('Kolkata'),('Pune'),('Kochi'),('Coimbatore'),('Vizag');

-- ── THEATERS ─────────────────────────────────────────────────
INSERT INTO theaters (city_id, name, address) VALUES
(1,'AGS Cinemas Velachery','Velachery Main Road, Chennai 600042'),
(1,'SPI Palazzo','Phoenix Marketcity, Velachery, Chennai 600042'),
(1,'Rohini Silver Screens','Koyambedu, Chennai 600107'),
(1,'Mayajaal Multiplex','ECR Kovalam, Chennai 603112'),
(1,'Vox Cinemas VR Mall','VR Chennai, Anna Salai, Chennai 600002'),
(2,'PVR IMAX Juhu','Sun n Sand Hotel, Juhu Tara Road, Mumbai 400049'),
(2,'INOX R-City Mall','R City Mall, Ghatkopar West, Mumbai 400086'),
(2,'Cinepolis Andheri','Infiniti Mall, Andheri, Mumbai 400053'),
(3,'PVR Select City Walk','District Centre, Saket, New Delhi 110017'),
(3,'INOX Nehru Place','3 Local Shopping Centre, Nehru Place, Delhi 110019'),
(4,'Prasads Multiplex','NTR Marg, Near Birla Mandir, Hyderabad 500004'),
(4,'AMB Cinemas','Gachibowli, Hyderabad 500032'),
(5,'PVR Forum Koramangala','Forum Mall, Koramangala, Bangalore 560095'),
(5,'INOX Garuda Mall','Magrath Road, Ashok Nagar, Bangalore 560025');

-- ── SCREENS ──────────────────────────────────────────────────
INSERT INTO screens (theater_id, name, total_seats) VALUES
(1,'Screen 1',80),(1,'Screen 2',80),(1,'Screen 3',60),
(2,'Screen 1',100),(2,'Screen 2',80),(2,'Screen 3',80),
(3,'Screen 1',120),(3,'Screen 2',80),
(4,'Screen 1',100),(4,'Screen 2',80),(4,'Screen 3',60),
(5,'Screen 1',90),(5,'Screen 2',80),
(6,'Screen 1 IMAX',200),(6,'Screen 2',100),
(7,'Screen 1',120),(7,'Screen 2',80),
(8,'Screen 1',100),(8,'Screen 2',80),
(9,'Screen 1',120),(9,'Screen 2',100),
(10,'Screen 1',100),(10,'Screen 2',80),
(11,'Screen 1',150),(11,'Screen 2',100),(11,'Screen 3',80),
(12,'Screen 1',120),(12,'Screen 2',80),
(13,'Screen 1',100),(13,'Screen 2',80),
(14,'Screen 1',120),(14,'Screen 2',80);

-- ── MOVIES ───────────────────────────────────────────────────
-- TAMIL (30 movies)
INSERT INTO movies (title,description,language,genre,duration,rating,cast_members,director,release_year,poster_url,trailer_id) VALUES
('Leo','An ex-gangster living quietly is forced back into his violent past when his family is threatened in a remote town.','Tamil','Action, Thriller','2h 44m',8.2,'Vijay, Trisha, Sanjay Dutt, Arjun','Lokesh Kanagaraj',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/e/ee/Leo_2023_film_poster.jpg/220px-Leo_2023_film_poster.jpg','QV29STzQVxY'),
('Vikram','Hardened cop Karnan is a one-man army against a deadly masked gang of vigilantes executing drug lords.','Tamil','Action, Thriller','2h 54m',9.1,'Kamal Haasan, Vijay Sethupathi, Fahadh Faasil, Kalidas Jayaram','Lokesh Kanagaraj',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/4/47/Vikram_Movie_Poster.jpg/220px-Vikram_Movie_Poster.jpg','OKBMCL7vdFg'),
('Jailer','A retired jailer with a fearsome reputation is forced to hunt down the gangsters who murdered his son.','Tamil','Action, Drama','2h 48m',7.6,'Rajinikanth, Mohanlal, Jackie Shroff, Yogi Babu','Nelson Dilipkumar',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/1/1c/Jailer_film_poster.jpg/220px-Jailer_film_poster.jpg','ogCWaDLVR2A'),
('Thunivu','A mysterious charming man leads a bank heist with a shocking larger social agenda.','Tamil','Action, Thriller','2h 30m',6.8,'Ajith Kumar, Manju Warrier, Samuthirakani','H. Vinoth',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/3/3a/Thunivu_poster.jpg/220px-Thunivu_poster.jpg','VkNy-mMiVwA'),
('Doctor','A deadly special agent named Devil goes on a rescue mission to save kidnapped children from traffickers.','Tamil','Action, Comedy','2h 33m',7.8,'Sivakarthikeyan, Priyanka Arul Mohan, Vinay','Nelson Dilipkumar',2021,'https://upload.wikimedia.org/wikipedia/en/thumb/4/42/Doctor_2021_Tamil_film_poster.jpg/220px-Doctor_2021_Tamil_film_poster.jpg','I6qZQkSFo8Q'),
('Ponniyin Selvan I','A sweeping historical epic following the political intrigue and conspiracy within the powerful Chola dynasty.','Tamil','Historical, Drama','2h 47m',8.0,'Vikram, Aishwarya Rai, Jayam Ravi, Karthi, Trisha','Mani Ratnam',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/b/b5/Ponniyin_Selvan_poster.jpg/220px-Ponniyin_Selvan_poster.jpg','SFq5p_zKD8A'),
('Ponniyin Selvan II','The conclusion of the grand Chola dynasty saga with breathtaking battles and emotional revelations.','Tamil','Historical, Drama','2h 36m',7.8,'Vikram, Aishwarya Rai, Jayam Ravi, Karthi, Trisha','Mani Ratnam',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/e/e9/Ponniyin_Selvan_2_poster.jpg/220px-Ponniyin_Selvan_2_poster.jpg','FqCGQPWsL_s'),
('Varisu','A billionaire patriarch wants his estranged son to take charge of their business empire and family legacy.','Tamil','Drama, Family','2h 47m',6.5,'Vijay, Rashmika Mandanna, R. Sarath Kumar','Vamshi Paidipally',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/4/40/Varisu_film_poster.jpg/220px-Varisu_film_poster.jpg','bPnYzUNhMwI'),
('Maaveeran','A cowardly cartoonist discovers he can hear the voice of his comic superhero, gaining extraordinary powers.','Tamil','Action, Comedy','2h 43m',7.2,'Sivakarthikeyan, Aditi Shankar, Yogi Babu','Madonne Ashwin',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/3/32/Maaveeran_film_poster.jpg/220px-Maaveeran_film_poster.jpg','HJZ6f49U9U0'),
('Viduthalai Part I','A young constable uncovers the truth behind a feared forest rebel during a 1990s mission.','Tamil','Drama, Thriller','2h 21m',8.1,'Vijay Sethupathi, Soori, Bhavani Sre','Vetri Maaran',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/3/38/Viduthalai_Part_1_poster.jpg/220px-Viduthalai_Part_1_poster.jpg','C1r5gDvGUMc'),
('Ayalaan','A warm-hearted alien stranded on Earth bonds with a compassionate man who protects him from evil scientists.','Tamil','Sci-Fi, Family','2h 27m',7.0,'Sivakarthikeyan, Rakul Preet Singh, Yogi Babu','Ravikumar',2021,'https://upload.wikimedia.org/wikipedia/en/thumb/2/26/Ayalaan_film.jpg/220px-Ayalaan_film.jpg','VnUSqRFtFlI'),
('Master','A carefree professor takes charge at a juvenile jail and clashes with a ruthless gangster.','Tamil','Action, Thriller','2h 59m',7.8,'Vijay, Vijay Sethupathi, Malavika Mohanan','Lokesh Kanagaraj',2021,'https://upload.wikimedia.org/wikipedia/en/thumb/0/05/Master_film_poster.jpg/220px-Master_film_poster.jpg','1e2e8hHIVbU'),
('Bigil','A former football star hiding his gang leader past must coach a women football team to national glory.','Tamil','Sports, Action','2h 58m',7.4,'Vijay, Nayanthara, Indhuja Ravichandran','Atlee Kumar',2019,'https://upload.wikimedia.org/wikipedia/en/thumb/9/95/Bigil_film_poster.jpg/220px-Bigil_film_poster.jpg','QHVAZ1U1tNk'),
('Kaithi','An ex-convict on his way to meet his daughter gets caught up in a police vs drug cartel night siege.','Tamil','Action, Thriller','2h 25m',8.5,'Karthi, Narain, George Maryan','Lokesh Kanagaraj',2019,'https://upload.wikimedia.org/wikipedia/en/thumb/f/f8/Kaithi_movie_poster.jpg/220px-Kaithi_movie_poster.jpg','D2BNBLH9sSE'),
('Amaran','Biographical war film about Major Mukund Varadarajan who was martyred fighting militants in Kashmir.','Tamil','War, Biography, Drama','2h 49m',9.2,'Sivakarthikeyan, Sai Pallavi, Bhuvan Arora','Rajkumar Periasamy',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/1/1a/Amaran_film_poster.jpg/220px-Amaran_film_poster.jpg','9mcFPqEj1qk'),
('Vettaiyan','A veteran cop confronts a vigilante who executes repeat criminals, questioning the justice system itself.','Tamil','Action, Drama','2h 40m',7.1,'Rajinikanth, Amitabh Bachchan, Fahadh Faasil','T.J. Gnanavel',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/2/2a/Vettaiyan_poster.jpg/220px-Vettaiyan_poster.jpg','bNxT1CJWCQA'),
('Viduthalai Part II','The powerful conclusion of the revolutionary 1990s drama reveals the truth behind the uprising.','Tamil','Drama, Thriller','2h 30m',8.3,'Vijay Sethupathi, Manju Warrier, Bhavani Sre','Vetri Maaran',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/a/a8/Viduthalai_part_2_poster.jpg/220px-Viduthalai_part_2_poster.jpg','qrXajPcRiIY'),
('Raayan','A feared gangster tries to live peacefully but is dragged back into violence when his family is targeted.','Tamil','Action, Drama','2h 35m',7.9,'Dhanush, Sundeep Kishan, S.J. Suryah','Dhanush',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/50/Raayan_poster.jpg/220px-Raayan_poster.jpg','ZjSTJqFjLrg'),
('Vada Chennai','A young carrom champion gets drawn into the ruthless world of north Chennai gangs across generations.','Tamil','Crime, Drama','2h 59m',8.8,'Dhanush, Andrea Jeremiah, Aishwarya Rajesh','Vetri Maaran',2018,'https://upload.wikimedia.org/wikipedia/en/thumb/e/ed/Vada_Chennai_poster.jpg/220px-Vada_Chennai_poster.jpg','3UJLO_f3-1o'),
('96','Two school sweethearts reunite after decades and spend a night revisiting their beautiful memories.','Tamil','Romance, Drama','2h 38m',8.7,'Vijay Sethupathi, Trisha, Gouri G. Kishan','C. Prem Kumar',2018,'https://upload.wikimedia.org/wikipedia/en/thumb/a/a9/96_Tamil_film.jpg/220px-96_Tamil_film.jpg','R0q7TKa4dys'),
('Pariyerum Perumal','A first-generation college student faces brutal caste discrimination while studying law.','Tamil','Drama, Social','2h 28m',8.6,'Kathir, Anandhi, Yogi Babu','Mari Selvaraj',2018,'https://upload.wikimedia.org/wikipedia/en/thumb/9/90/PariyerumPerumalFilmPoster.jpg/220px-PariyerumPerumalFilmPoster.jpg','NJHu-CJnqeI'),
('Coolie','Rajinikanth plays a train coolie who turns out to be far more dangerous than he appears.','Tamil','Action, Drama','2h 50m',8.3,'Rajinikanth, Upendra, Nagarjuna','Lokesh Kanagaraj',2025,'https://m.media-amazon.com/images/M/MV5BNWY1MWMwYzktNzBmOS00MTM1LWE2MzAtMGQzNTkwZGEzODc0XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Thug Life','Kamal Haasan stars in Mani Ratnam''s stylish gangster epic about loyalty and revenge.','Tamil','Crime, Drama','2h 45m',8.0,'Kamal Haasan, Silambarasan, Trisha','Mani Ratnam',2025,'https://m.media-amazon.com/images/M/MV5BOTBkMWI4NTMtZmMzZC00ZmIyLWIzMDQtNTBjN2U4YzZmNGY4XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Good Bad Ugly','Ajith Kumar stars in a high-voltage action entertainer directed by Adhik Ravichandran.','Tamil','Action, Comedy','2h 30m',7.5,'Ajith Kumar, Trisha, Prabhu Deva','Adhik Ravichandran',2025,'https://m.media-amazon.com/images/M/MV5BN2U5OTRiMDktZTU1YS00ZjIzLWI1MTQtZTVmMzkyOTlkZDU4XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Retro','Suriya and Pooja Hegde star in a mass entertainer combining action and romance.','Tamil','Action, Romance','2h 30m',7.8,'Suriya, Pooja Hegde','Karthik Subbaraj',2025,'https://m.media-amazon.com/images/M/MV5BZjQ5MGQ4ZmMtMjE1Zi00YTYxLWI4ZDMtNjNjZmE0NWFiZjRiXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Indian 2','Vigilante Senapathi returns to continue his relentless crusade against corruption in modern India.','Tamil','Action, Thriller','2h 52m',6.4,'Kamal Haasan, Siddharth, Rakul Preet Singh','Shankar',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/b/b7/Indian_2_poster.jpg/220px-Indian_2_poster.jpg','hQxNGZxR3mE'),
('The Greatest of All Time','A special agent uses revolutionary time-reversal technology to unravel a deadly conspiracy.','Tamil','Sci-Fi, Action','2h 50m',6.2,'Vijay, Prabhu Deva, Mohan','Venkat Prabhu',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/c/cd/The_Greatest_of_All_Time_film_poster.jpg/220px-The_Greatest_of_All_Time_film_poster.jpg','t5M7KHv5Jvk'),
('Kanguva','An ancient warrior living thousands of years apart shares a powerful destiny across time.','Tamil','Fantasy, Action','2h 35m',5.8,'Suriya, Disha Patani, Bobby Deol','Siva',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/8/8d/Kanguva_poster.jpg/220px-Kanguva_poster.jpg','N-Pj_K-d9RM'),
('Thalapathy 69','Vijay returns in his much-anticipated second film post-retirement from acting.','Tamil','Action, Drama','2h 45m',8.5,'Vijay, Pooja Hegde','H. Vinoth',2025,'https://m.media-amazon.com/images/M/MV5BYTQyZTMwNGMtNmJiYy00ZmFkLThhMzQtYTNmMGY5NTFiMzA0XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Dhanush Next','Dhanush reunites with Vetri Maaran for another gritty realistic drama.','Tamil','Drama, Crime','2h 30m',8.4,'Dhanush, Aishwarya Lekshmi','Vetri Maaran',2025,'https://m.media-amazon.com/images/M/MV5BNzAyNzY3MDEtMmUyZC00N2RkLTkzNjktNTFjYzE0MmE5YzdhXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder');

-- TELUGU (30 movies)
INSERT INTO movies (title,description,language,genre,duration,rating,cast_members,director,release_year,poster_url,trailer_id) VALUES
('Pushpa: The Rise','A laborer rises through the dangerous red sandalwood smuggling syndicate in the Seshachalam forests.','Telugu','Action, Crime','2h 59m',7.6,'Allu Arjun, Rashmika Mandanna, Fahadh Faasil','Sukumar',2021,'https://upload.wikimedia.org/wikipedia/en/thumb/8/8e/Pushpa_The_Rise_poster.jpg/220px-Pushpa_The_Rise_poster.jpg','Q1mHzGgSQqY'),
('Pushpa 2: The Rule','Pushpa Raj faces his deadliest nemesis SP Shekhawat as he expands his smuggling empire worldwide.','Telugu','Action, Crime','3h 21m',8.0,'Allu Arjun, Rashmika Mandanna, Fahadh Faasil','Sukumar',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/c/ce/Pushpa_2_poster.jpg/220px-Pushpa_2_poster.jpg','z7cGYrCrONM'),
('RRR','Two legendary freedom fighters — Ram and Bheem — befriend each other unaware of their secret missions.','Telugu','Action, Drama, History','3h 7m',7.9,'Jr. NTR, Ram Charan, Alia Bhatt, Ajay Devgn','S.S. Rajamouli',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/7/70/RRR_Movie_Poster.jpg/220px-RRR_Movie_Poster.jpg','NgKgLCTHGMs'),
('Baahubali: The Beginning','A young man raised by a tribal woman discovers his royal heritage and leads a rebellion.','Telugu','Action, Fantasy','2h 39m',8.0,'Prabhas, Rana Daggubati, Anushka Shetty, Tamannaah','S.S. Rajamouli',2015,'https://upload.wikimedia.org/wikipedia/en/thumb/2/2b/Baahubali_The_Beginning_poster.jpg/220px-Baahubali_The_Beginning_poster.jpg','7EBiPTjSHcs'),
('Baahubali 2: The Conclusion','The breathtaking conclusion reveals why Kattappa killed Baahubali in this epic historical saga.','Telugu','Action, Fantasy','2h 47m',8.2,'Prabhas, Rana Daggubati, Anushka Shetty, Tamannaah','S.S. Rajamouli',2017,'https://upload.wikimedia.org/wikipedia/en/thumb/3/30/Baahubali_2_The_Conclusion.jpg/220px-Baahubali_2_The_Conclusion.jpg','7EBiPTjSHcs'),
('Kalki 2898 AD','A futuristic warrior is destined to be the Kalki avatar to protect the last unborn child and save humanity.','Telugu','Sci-Fi, Mythology','3h 1m',6.8,'Prabhas, Deepika Padukone, Amitabh Bachchan, Kamal Haasan','Nag Ashwin',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/50/Kalki_2898_AD_poster.jpg/220px-Kalki_2898_AD_poster.jpg','X9BjcjlYeUg'),
('Ala Vaikunthapurramuloo','A man raised in the wrong family all his life discovers his true identity and privileged destiny.','Telugu','Comedy, Drama','2h 55m',7.7,'Allu Arjun, Pooja Hegde, Tabu, Jayaram','Trivikram Srinivas',2020,'https://upload.wikimedia.org/wikipedia/en/thumb/2/24/Ala_Vaikunthapurramuloo_poster.jpg/220px-Ala_Vaikunthapurramuloo_poster.jpg','FDJ_VCTHy5c'),
('Arjun Reddy','A short-tempered medical student spirals into dangerous self-destruction after losing his love.','Telugu','Romance, Drama','3h 5m',8.4,'Vijay Deverakonda, Shalini Pandey','Sandeep Vanga',2017,'https://upload.wikimedia.org/wikipedia/en/thumb/e/ed/Arjun_Reddy_poster.jpg/220px-Arjun_Reddy_poster.jpg','J3yW3vKzXdM'),
('Rangasthalam','A hard-of-hearing man and his brother fight a corrupt panchayat president terrorizing their village.','Telugu','Drama, Action','2h 58m',8.3,'Ram Charan, Samantha, Aadhi Pinisetty','Sukumar',2018,'https://upload.wikimedia.org/wikipedia/en/thumb/3/32/Rangasthalam_2018_film_poster.jpg/220px-Rangasthalam_2018_film_poster.jpg','NpEKfBY6g_s'),
('Uppena','A fearless fisherman defies a powerful caste barrier to pursue his passionate love for a landlord''s daughter.','Telugu','Romance, Drama','2h 17m',8.2,'Krithi Shetty, Vaishnav Tej, Vijay Sethupathi','Buchi Babu Sana',2021,'https://upload.wikimedia.org/wikipedia/en/thumb/0/0b/Uppena_film_poster.jpg/220px-Uppena_film_poster.jpg','_5j6wZxC4Ro'),
('HanuMan','A common man from a drought-stricken village gains the divine powers of Lord Hanuman to fight evil.','Telugu','Superhero, Mythology','2h 32m',8.1,'Teja Sajja, Amritha Aiyer, Varalaxmi Sarathkumar','Prasanth Varma',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/0/0b/HanuMan_film_poster.jpg/220px-HanuMan_film_poster.jpg','HVMqh4bBiqk'),
('Lucky Baskhar','A middle-class bank employee stumbles into a dangerous money laundering scheme that changes his life.','Telugu','Crime, Thriller','2h 37m',8.4,'Dulquer Salmaan, Meenakshi Chaudhary','Venky Atluri',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/8/85/Lucky_Baskhar_poster.jpg/220px-Lucky_Baskhar_poster.jpg','_e7jF0g1bBw'),
('Dasara','A miner''s son must choose between loyalty to his friends and his love as coal mine tensions explode.','Telugu','Action, Drama','2h 54m',6.9,'Nani, Keerthy Suresh, Shine Tom Chacko','Srikanth Odela',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/8/82/Dasara_film_poster.jpg/220px-Dasara_film_poster.jpg','VhVS5jn8xqQ'),
('Salar','A violent and feared man visits a childhood friend and discovers a deadly kingdom''s conspiracy.','Telugu','Action, Drama','3h 3m',6.5,'Prabhas, Prithviraj Sukumaran, Shruti Haasan','Prashanth Neel',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/e/ef/Salaar_poster.jpg/220px-Salaar_poster.jpg','I2xLkq5L9TY'),
('Tillu Square','The lovably chaotic Tillu returns for more laugh-out-loud misadventures in this entertaining sequel.','Telugu','Comedy, Action','2h 11m',7.6,'Siddhu Jonnalagadda, Anupama Parameswaran','Mallik Ram',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/1/1d/Tillu_Square_poster.jpg/220px-Tillu_Square_poster.jpg','RtH3m3Rv_k8'),
('Thandel','The gripping true story of Indian fishermen abducted by the Pakistan Navy and their dramatic rescue.','Telugu','Drama, Thriller','2h 20m',7.8,'Naga Chaitanya, Sai Pallavi','Chandoo Mondeti',2025,'https://upload.wikimedia.org/wikipedia/en/thumb/a/a1/Thandel_film_poster.jpg/220px-Thandel_film_poster.jpg','FQ8j7gRJQb4'),
('Game Changer','A fiery IAS officer goes undercover to take down a political kingpin dominating an entire state.','Telugu','Action, Drama','2h 43m',5.6,'Ram Charan, Kiara Advani, SJ Suryah','Shankar',2025,'https://upload.wikimedia.org/wikipedia/en/thumb/a/a7/Game_Changer_film_poster.jpg/220px-Game_Changer_film_poster.jpg','u4h8iXpXw1o'),
('Sankranthiki Vasthunam','A hilarious cop comedy set against the vibrant backdrop of the Sankranti festival celebrations.','Telugu','Comedy, Action','2h 40m',7.2,'Venkatesh, Aishwarya Rajesh, Meenakshi Chaudhary','Anil Ravipudi',2025,'https://m.media-amazon.com/images/M/MV5BMzlmZjQ3ZGMtMDNlNy00NTcxLTk4NDUtNDQxNjQ5YzYzZjhjXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Bimbisara','An arrogant ancient king is magically transported to the present day as punishment for his cruelty.','Telugu','Fantasy, Action','2h 34m',7.1,'Kalyan Ram, Catherine Tresa, Samyuktha Menon','Vasantha Krishna',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/d/dd/Bimbisara_2022_poster.jpg/220px-Bimbisara_2022_poster.jpg','Yk5cGXmOPMw'),
('Saaho','A brooding man with a mysterious past gets swept into a global criminal conspiracy involving stolen diamonds.','Telugu','Action, Thriller','2h 51m',4.9,'Prabhas, Shraddha Kapoor, Neil Nitin Mukesh','Sujeeth',2019,'https://upload.wikimedia.org/wikipedia/en/thumb/c/c5/Saaho_poster.jpg/220px-Saaho_poster.jpg','lxvqJv0lU5I'),
('Dhamaka','An unemployed youth accidentally uncovers a dangerous political conspiracy that puts his life at risk.','Telugu','Action, Thriller','2h 15m',7.0,'Ravi Teja, Sreeleela, Jayaram','Trinadha Rao Nakkina',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/3/3e/Dhamaka_Telugu_film_poster.jpg/220px-Dhamaka_Telugu_film_poster.jpg','M7ybMeaW5FE'),
('Guntur Kaaram','A young man struggles to reconcile his estranged mother and her long-suffering father.','Telugu','Family, Drama','2h 30m',5.8,'Mahesh Babu, Sreeleela, Meenakshi Chaudhary','Trivikram Srinivas',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/b/b2/Guntur_Kaaram_poster.jpg/220px-Guntur_Kaaram_poster.jpg','uR6EFSbGACI'),
('Robinhood','A modern-day Robin Hood takes on the corrupt establishment with wit and action in equal measure.','Telugu','Action, Comedy','2h 25m',7.3,'Nithiin, Sreeleela, Vennela Kishore','Venky Kudumula',2024,'https://m.media-amazon.com/images/M/MV5BOGEzZjk2OWQtMDExNy00MzFjLTg3OGMtZjM3MGNlZjZhNjM3XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Hanu-Man 2','The superhero saga continues as Hanumanthu faces an even more powerful cosmic threat.','Telugu','Superhero, Action','2h 30m',8.5,'Teja Sajja, Varalaxmi Sarathkumar, Priyanka Arul Mohan','Prasanth Varma',2025,'https://m.media-amazon.com/images/M/MV5BZGVlMzk2ZTUtNDI4Yi00MjQzLThiZGMtZjUwZjMzMjZkMWM1XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Mahesh Rajamouli Film','The most anticipated Indian film — Mahesh Babu in Rajamouli''s pan-India adventure extravaganza.','Telugu','Action, Adventure','2h 50m',9.1,'Mahesh Babu, Priyanka Chopra','S.S. Rajamouli',2025,'https://m.media-amazon.com/images/M/MV5BNzYyMzIyNDMtYjJhMy00ZDZkLTgxMzktN2Q0MGRmZjk2N2YxXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Sye Raa Narasimha Reddy','The legendary warrior who inspired the 1857 rebellion against British colonialism.','Telugu','Historical, Action','2h 52m',6.4,'Chiranjeevi, Ram Charan, Amitabh Bachchan, Nayanthara','Surender Reddy',2019,'https://upload.wikimedia.org/wikipedia/en/thumb/6/6e/Sye_Raa_Narasimha_Reddy.jpg/220px-Sye_Raa_Narasimha_Reddy.jpg','3FUzUhbNoxc'),
('Goat Life','A Malaysian Indian''s extraordinary survival story after being enslaved on a Saudi Arabian desert farm.','Telugu','Drama, Survival','2h 41m',8.6,'Prithviraj Sukumaran, Amala Paul, K.R. Gokul','Blessy',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/a/a2/Aadujeevitham_film_poster.jpg/220px-Aadujeevitham_film_poster.jpg','V1dePiH1Fzk'),
('Devara','The son of a feared sea monster must fight to claim his rightful inheritance in a violent coastal world.','Telugu','Action, Drama','2h 59m',6.9,'Jr. NTR, Saif Ali Khan, Janhvi Kapoor','Koratala Siva',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/7/74/Devara_film_poster.jpg/220px-Devara_film_poster.jpg','dUKSTiTY-W8'),
('Mechanic Rocky','A charming mechanic''s life turns upside down when he gets entangled with gangsters and politics.','Telugu','Action, Comedy','2h 15m',7.1,'Vishwak Sen, Meenakshi Chaudhary','Anand Annamalai',2024,'https://m.media-amazon.com/images/M/MV5BZGEzNTk4NjgtNTZiYy00NDdmLTg0NjctNzIwMzJhZjM3NDc2XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Eagle','A secret agent unravels a terrifying conspiracy spanning decades in this action thriller.','Telugu','Action, Spy','2h 22m',6.8,'Ravi Teja, Kavya Thapar','Karthik Ghattamaneni',2024,'https://m.media-amazon.com/images/M/MV5BNGYwNzQyZWMtZjkyMi00NzRhLTk5ZjgtY2Y4ZDNhMzFkMmJlXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder');

-- MALAYALAM (30 movies)
INSERT INTO movies (title,description,language,genre,duration,rating,cast_members,director,release_year,poster_url,trailer_id) VALUES
('Manjummel Boys','A group of friends on a trek get trapped in the deadly Guna Caves, inspiring a miraculous rescue attempt.','Malayalam','Adventure, Thriller','2h 17m',8.6,'Soubin Shahir, Sreenath Bhasi, Deepak Parambol','Chidambaram',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/5e/Manjummel_Boys_poster.jpg/220px-Manjummel_Boys_poster.jpg','WKCXBJ0P8c4'),
('2018: Everyone Is a Hero','Based on the true story of the catastrophic 2018 Kerala floods and ordinary heroes who emerged.','Malayalam','Disaster, Drama','2h 46m',8.7,'Tovino Thomas, Kunchacko Boban, Asif Ali','Jude Anthany Joseph',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/9/9b/2018_film_poster.jpg/220px-2018_film_poster.jpg','AhLKBRzjLuk'),
('Bramayugam','A man from the 20th century stumbles upon a dark 17th-century estate owned by a sinister immortal master.','Malayalam','Horror, Thriller','2h 11m',8.9,'Mammootty, Arjun Ashokan, Sidharth Bharathan','Rahul Sadasivan',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/3/3c/Bramayugam_poster.jpg/220px-Bramayugam_poster.jpg','DkyQNj5WTKY'),
('Varshangalkku Shesham','Two aspiring actors fight through four tumultuous decades to find success, love, and their place in cinema.','Malayalam','Drama, Comedy','2h 48m',9.1,'Pranav Mohanlal, Dhyan Sreenivasan, Nivin Pauly','Vineeth Sreenivasan',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/d/d0/Varshangalkku_Shesham_poster.jpg/220px-Varshangalkku_Shesham_poster.jpg','YImTFJiVzJA'),
('Premalu','A software engineer adjusting to life in Hyderabad unexpectedly falls for a free-spirited girl.','Malayalam','Romance, Comedy','2h 14m',8.3,'Naslen K. Gafoor, Mamitha Baiju','Girish A.D.',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Premalu_poster.jpg/220px-Premalu_poster.jpg','p1xzlkD5mFg'),
('Aavesham','Engineering hostel students in a tight spot accidentally befriend a volatile local gangster.','Malayalam','Comedy, Action','2h 30m',8.5,'Fahadh Faasil, Hipzster, Roshan Shanavas','Jithu Madhavan',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/f/f3/Aavesham_poster.jpg/220px-Aavesham_poster.jpg','6kx2rxOxfN8'),
('Marco','An ordinary soft-spoken man transforms into a one-man army of justice against a powerful drug network.','Malayalam','Action, Thriller','2h 18m',8.4,'Unni Mukundan, Kabir Duhan Singh','Haneef Adeni',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/55/Marco_2024_film_poster.jpg/220px-Marco_2024_film_poster.jpg','BaQVeMzMPfc'),
('Kishkindha Kaandam','A violent family property dispute in an apartment complex gets unexpectedly entangled with a monkey menace.','Malayalam','Dark Comedy, Thriller','2h 28m',8.8,'Aparna Balamurali, Asif Ali, Vijayaraghavan','Dinjith Ayyathan',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/d/df/Kishkindha_Kaandam_poster.jpg/220px-Kishkindha_Kaandam_poster.jpg','K4-s6KIiAvY'),
('Aadujeevitham','A young man''s dream of a better life abroad becomes a nightmare when he is enslaved in a Saudi desert.','Malayalam','Drama, Survival','2h 41m',8.5,'Prithviraj Sukumaran, Amala Paul, K.R. Gokul','Blessy',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/a/a2/Aadujeevitham_film_poster.jpg/220px-Aadujeevitham_film_poster.jpg','V1dePiH1Fzk'),
('Drishyam 2','Georgekutty''s carefully buried secrets resurface when a new relentless investigation begins.','Malayalam','Thriller, Drama','2h 32m',8.4,'Mohanlal, Meena, Ansiba Hassan','Jeethu Joseph',2021,'https://upload.wikimedia.org/wikipedia/en/thumb/3/38/Drishyam_2_film_poster.jpg/220px-Drishyam_2_film_poster.jpg','y-OqS_RyeaQ'),
('Lucifer','A political thriller following the mysterious power struggle and dark intrigue after a chief minister dies.','Malayalam','Action, Thriller','2h 43m',7.3,'Mohanlal, Prithviraj Sukumaran, Vivek Oberoi','Prithviraj Sukumaran',2019,'https://upload.wikimedia.org/wikipedia/en/thumb/1/1a/Lucifer_2019_film_poster.jpg/220px-Lucifer_2019_film_poster.jpg','YhpOaRzSVqc'),
('Ullozhukku','A deeply moving family drama set in a flood-submerged Kerala village about two women and unspoken truths.','Malayalam','Drama','2h 6m',8.6,'Parvathy Thiruvothu, Urvashi','Christo Tomy',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/2/2b/Ullozhukku_film_poster.jpg/220px-Ullozhukku_film_poster.jpg','N9Ksa3uHW20'),
('Turbo','A fierce man with a short fuse clashes with a determined cop in this high-energy action entertainer.','Malayalam','Action, Comedy','2h 19m',7.7,'Mammootty, Anjali, Suraj Venjaramoodu','Vysakh',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/4/43/Turbo_2024_film_poster.jpg/220px-Turbo_2024_film_poster.jpg','zg8G1Mf2c-4'),
('L2: Empuraan','The sequel to Lucifer reveals Priyadarshan''s fearsome past and a global conspiracy threatening India.','Malayalam','Action, Thriller','2h 50m',7.8,'Mohanlal, Prithviraj Sukumaran, Tovino Thomas','Prithviraj Sukumaran',2025,'https://m.media-amazon.com/images/M/MV5BNGNkY2I4YmItMjFmMC00OTA3LTlkOWQtNjQ4ZGE4OTBhNGU0XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Thudarum','Mohanlal stars in a powerful action drama about a common man fighting against a corrupt system.','Malayalam','Action, Drama','2h 30m',8.2,'Mohanlal, Shobana, Mammootty','Tharun Moorthy',2025,'https://m.media-amazon.com/images/M/MV5BMDljNWUzYjItMGVjMC00N2E5LWI2MDYtNGIwZTI0Y2UyYWJjXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Bheeshma Parvam','An aging patriarch from a crime family returns to Kochi to resolve a violent feud with personal sacrifice.','Malayalam','Action, Drama','2h 52m',7.7,'Mammootty, Shine Tom Chacko, Soubin Shahir','Amal Neerad',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/4/4b/Bheeshma_Parvam_poster.jpg/220px-Bheeshma_Parvam_poster.jpg','Y2gkdLEHFPQ'),
('Minnal Murali','A small-town tailor and a petty thief both get struck by the same lightning bolt and develop superpowers.','Malayalam','Superhero, Drama','2h 38m',7.8,'Tovino Thomas, Guru Somasundaram, Femina George','Basil Paulose',2021,'https://upload.wikimedia.org/wikipedia/en/thumb/1/16/Minnal_Murali_poster.jpg/220px-Minnal_Murali_poster.jpg','v3C2-8BkXBs'),
('Thallumaala','An impulsive fighter''s series of street brawls connects him to the love of his life in this vibrant film.','Malayalam','Romance, Action','2h 17m',7.9,'Tovino Thomas, Kalyani Priyadarshan, Lukman','Khalid Rahman',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/7/79/Thallumaala.jpg/220px-Thallumaala.jpg','bFcQDKnHNas'),
('Kumbalangi Nights','Four dysfunctional brothers in a fishing village find themselves and each other while learning to love.','Malayalam','Drama, Romance','2h 14m',8.5,'Fahadh Faasil, Soubin Shahir, Shane Nigam','Madhu C. Narayanan',2019,'https://upload.wikimedia.org/wikipedia/en/thumb/3/33/Kumbalangi_nights_poster.jpg/220px-Kumbalangi_nights_poster.jpg','uQmAHiLPEPo'),
('Purusha Pretham','A wickedly funny black comedy about a dead body that absolutely nobody is willing to claim.','Malayalam','Comedy, Mystery','2h 2m',8.1,'Chemban Vinod Jose, Suraj Venjaramoodu, Joju George','Krishand R.',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/a/a4/Purusha_Pretham_film_poster.jpg/220px-Purusha_Pretham_film_poster.jpg','Y3D8_UlKoTw'),
('Rekhachithram','A detective uses CCTV footage to track a mysterious killer in this gripping procedural thriller.','Malayalam','Thriller, Crime','2h 13m',8.0,'Asif Ali, Vineeth Sreenivasan, Shine Tom Chacko','Jithin K. Jose',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/f/fc/Rekhachithram_poster.jpg/220px-Rekhachithram_poster.jpg','Hj8Lg8xfYYU'),
('Android Kunjappan','A worried son builds a compassionate robot to care for his aging father left alone in the village.','Malayalam','Drama, Sci-Fi','2h 14m',7.8,'Soubin Shahir, Kendy Zirdo','Ratheesh Balakrishnan Poduval',2019,'https://upload.wikimedia.org/wikipedia/en/thumb/5/51/Android_Kunjappan_poster.jpg/220px-Android_Kunjappan_poster.jpg','pu2wYc9mWw8'),
('Helen','A young woman becomes trapped alone in a freezing cold storage unit with no way to signal for help.','Malayalam','Thriller, Survival','1h 53m',8.0,'Anna Ben, Lal, Vineeth','Mathukutty Xavier',2019,'https://upload.wikimedia.org/wikipedia/en/thumb/5/5d/Helen_movie_poster.jpg/220px-Helen_movie_poster.jpg','7Z-i3pzX1-M'),
('Irul','A couple stranded in a stormy remote house for the night harbor growing suspicions about a mysterious stranger.','Malayalam','Thriller, Mystery','1h 54m',7.4,'Fahadh Faasil, Darshana Rajendran','Naseef Yusuf Izuddin',2021,'https://upload.wikimedia.org/wikipedia/en/thumb/b/b0/Irul_film_poster.jpg/220px-Irul_film_poster.jpg','D4I3m_JKPN8'),
('Barroz','A mythical 500-year-old guardian of Vasco da Gama''s treasure is awakened by a child''s spirit.','Malayalam','Fantasy, Adventure','2h 9m',6.0,'Mohanlal, Guru Somasundaram, Maya Rao','Mohanlal',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/5a/Barroz_poster.jpg/220px-Barroz_poster.jpg','UCB4r9GUbqE'),
('Guruvayoor Ambalanadayil','A laugh-out-loud wedding comedy set in the chaos of Tamil Nadu''s most famous temple town.','Malayalam','Comedy, Drama','2h 15m',7.2,'Prithviraj Sukumaran, Basil Paulose, Unni Mukundan','Viswanath J. Nair',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/0/0f/Guruvayoor_Ambalanadayil_poster.jpg/220px-Guruvayoor_Ambalanadayil_poster.jpg','placeholder'),
('Identity','An officer chasing a missing person case uncovers a psychologically complex web of lies and identities.','Malayalam','Thriller, Mystery','2h 10m',8.1,'Tovino Thomas','Akhil Paul, Anas Khan',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/b/bb/Identity_2024_film_poster.jpg/220px-Identity_2024_film_poster.jpg','placeholder'),
('Oru Small Family Matter','A warm and funny look at how modern relationships strain the fabric of a loving extended family.','Malayalam','Comedy, Family','2h 10m',7.5,'Prithviraj Sukumaran, Manju Warrier','Jeethu Joseph',2024,'https://m.media-amazon.com/images/M/MV5BMzMwNGIyNDgtZGQ4Yi00Y2RiLTlkZWMtN2E2YWI3ZDgxMmRlXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Kottukkaali (The Trap)','A young woman labeled as mentally ill is sent to a village for healing in this haunting slow-burn drama.','Malayalam','Drama, Thriller','2h 0m',8.4,'Nitya Mammen, Nivin Pauly','Manoj Kana',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/a/a0/Kottukkaali_poster.jpg/220px-Kottukkaali_poster.jpg','placeholder'),
('Anweshippin Kandethum','A newly appointed constable solves a decade-old missing person mystery through relentless dedication.','Malayalam','Crime, Drama','2h 12m',8.5,'Shane Nigam, Shine Tom Chacko','Darwin Kuriakose',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/e/e4/Anweshippin_Kandethum_poster.jpg/220px-Anweshippin_Kandethum_poster.jpg','placeholder'),
('Neru','A blind witness to a brutal crime is the only hope for justice in this tense legal courtroom thriller.','Malayalam','Legal, Thriller','2h 22m',8.0,'Mohanlal, Anaswara Rajan, Sidhique','Jeethu Joseph',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/6/6b/Neru_film_poster.jpg/220px-Neru_film_poster.jpg','4Fkm7emwkn4');

-- HINDI (30 movies)
INSERT INTO movies (title,description,language,genre,duration,rating,cast_members,director,release_year,poster_url,trailer_id) VALUES
('Pathaan','A disgraced RAW spy returns from exile to prevent a deadly biological attack on India.','Hindi','Action, Spy','2h 26m',5.9,'Shah Rukh Khan, Deepika Padukone, John Abraham','Siddharth Anand',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/5/52/Pathaan_poster.jpg/220px-Pathaan_poster.jpg','vfu6PxCMFYY'),
('Jawan','A vengeful man raises a vigilante army of women to fight against a corrupt industrialist and failing system.','Hindi','Action, Social','2h 49m',7.1,'Shah Rukh Khan, Nayanthara, Vijay Sethupathi, Deepika Padukone','Atlee Kumar',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/0/0c/Jawan_film_poster.jpg/220px-Jawan_film_poster.jpg','_L3lIMFz72Y'),
('Animal','A son''s toxic obsessive love for his cold father leads him down an increasingly violent and dark path.','Hindi','Action, Drama','3h 21m',5.6,'Ranbir Kapoor, Anil Kapoor, Rashmika Mandanna, Bobby Deol','Sandeep Vanga',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/5/50/Animal_2023_poster.jpg/220px-Animal_2023_poster.jpg','TH-CPsP1wKI'),
('Stree 2','The terrifying spirit Stree returns to haunt Chanderi in this wildly entertaining horror-comedy sequel.','Hindi','Horror, Comedy','2h 21m',8.3,'Rajkummar Rao, Shraddha Kapoor, Aparshakti Khurana','Amar Kaushik',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/2/2e/Stree_2_poster.jpg/220px-Stree_2_poster.jpg','XLMf0b_GUwQ'),
('12th Fail','An IPS aspirant from a small underprivileged village battles extreme hardship to crack the UPSC exam.','Hindi','Drama, Biography','2h 27m',9.0,'Vikrant Massey, Medha Shankar','Vidhu Vinod Chopra',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/4/45/12th_Fail_poster.jpg/220px-12th_Fail_poster.jpg','HbkT5TBcpco'),
('Chhaava','The extraordinary story of Chhatrapati Sambhaji Maharaj who defied the Mughal empire with fierce courage.','Hindi','Historical, Drama','2h 37m',8.9,'Vicky Kaushal, Rashmika Mandanna, Akshaye Khanna','Laxman Utekar',2025,'https://upload.wikimedia.org/wikipedia/en/thumb/e/e3/Chhaava_poster.jpg/220px-Chhaava_poster.jpg','pWmhOOHFqFI'),
('Dunki','A group of friends use the dangerous illegal Donkey route to pursue their dream of living abroad.','Hindi','Drama, Comedy','2h 41m',5.8,'Shah Rukh Khan, Taapsee Pannu, Boman Irani','Rajkumar Hirani',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/3/36/Dunki_film_poster.jpg/220px-Dunki_film_poster.jpg','cZgL3jxekek'),
('Fighter','India''s first aerial action franchise following elite Air Force pilots defending their nation with pride.','Hindi','Action, War','2h 47m',6.5,'Hrithik Roshan, Deepika Padukone, Anil Kapoor','Siddharth Anand',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/1/13/Fighter_2024_film.jpg/220px-Fighter_2024_film.jpg','Cle_P_3fWpM'),
('Sam Bahadur','A rousing biographical tribute to Field Marshal Sam Manekshaw, India''s greatest military hero.','Hindi','Biography, War','2h 30m',7.7,'Vicky Kaushal, Sanya Malhotra, Fatima Sana Shaikh','Meghna Gulzar',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/5/58/Sam_Bahadur_poster.jpg/220px-Sam_Bahadur_poster.jpg','4R0D7L5ROXY'),
('Sikandar','Salman Khan stars in this action spectacle from director A.R. Murugadoss about a formidable warrior.','Hindi','Action, Drama','2h 45m',8.1,'Salman Khan, Rashmika Mandanna, Sathyaraj','A.R. Murugadoss',2025,'https://m.media-amazon.com/images/M/MV5BNWY1MWMwYzktNzBmOS00MTM1LWE2MzAtMGQzNTkwZGEzODc0XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Sky Force','The untold true story of India''s deadliest airstrike on Pakistan in 1965 and the pilot behind it.','Hindi','War, Action','2h 25m',7.6,'Akshay Kumar, Veer Pahariya, Sara Ali Khan','Abhishek Anil Kapur',2025,'https://upload.wikimedia.org/wikipedia/en/thumb/8/8e/Sky_Force_poster.jpg/220px-Sky_Force_poster.jpg','9boCfHrEt0c'),
('Kill','A highly trained army commando takes on ruthless gangsters who have hijacked his beloved''s train.','Hindi','Action, Thriller','1h 45m',7.7,'Lakshya, Raghav Juyal, Tanya Maniktala','Nikhil Nagesh Bhat',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/d/d4/Kill_2024_film_poster.jpg/220px-Kill_2024_film_poster.jpg','nGbOqz0Gixo'),
('Munjya','A supernatural comedy about a child spirit trapped between worlds who haunts a modern-day family.','Hindi','Horror, Comedy','1h 55m',7.2,'Sharvari Wagh, Abhay Verma, Mona Singh','Aditya Sarpotdar',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/d/d5/Munjya_film_poster.jpg/220px-Munjya_film_poster.jpg','EJhj-h2sxzw'),
('Singham Again','Inspector Singham and the entire police universe unite to face their most powerful enemy yet.','Hindi','Action, Police','2h 37m',5.8,'Ajay Devgn, Deepika Padukone, Tiger Shroff, Ranveer Singh','Rohit Shetty',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/f/f5/Singham_Again_poster.jpg/220px-Singham_Again_poster.jpg','2KSPX-1bXiQ'),
('Article 370','A gripping political thriller dramatizing the historic abrogation of Article 370 in Jammu & Kashmir.','Hindi','Political, Drama','2h 23m',7.8,'Yami Gautam, Priyamani, Arun Govil','Aditya Suhas Jambhale',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/1/17/Article_370_poster.jpg/220px-Article_370_poster.jpg','hcEE9rJe1JU'),
('Laapata Ladies','Two brides accidentally get swapped at a crowded rural railway station in this charming social comedy.','Hindi','Comedy, Social','2h 1m',7.9,'Nitanshi Goel, Pratibha Ranta, Sparsh Shrivastava','Kiran Rao',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/3/3a/Laapataa_Ladies_film_poster.jpg/220px-Laapataa_Ladies_film_poster.jpg','8XVYP5cY5UQ'),
('Madgaon Express','Three lifelong friends plan a dream Goa trip that spectacularly spirals into absolute chaos.','Hindi','Comedy','2h 8m',7.9,'Divyenndu, Pratik Gandhi, Avinash Tiwary, Nora Fatehi','Kunal Kemmu',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/7/79/Madgaon_Express_poster.jpg/220px-Madgaon_Express_poster.jpg','ynOqY3YtHp0'),
('Bhool Bhulaiyaa 3','The psycho-horror franchise returns with new supernatural terrors and unexpected twists.','Hindi','Horror, Comedy','2h 24m',6.2,'Kartik Aaryan, Vidya Balan, Madhuri Dixit','Anees Bazmee',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/6/66/Bhool_Bhulaiyaa_3_poster.jpg/220px-Bhool_Bhulaiyaa_3_poster.jpg','vdTW00vmq8c'),
('Deva','A reckless amnesiac cop investigates a mysterious case that may reveal the truth about his violent past.','Hindi','Action, Thriller','2h 19m',6.8,'Shahid Kapoor, Pooja Hegde','Rosshan Andrrews',2025,'https://upload.wikimedia.org/wikipedia/en/thumb/0/0c/Deva_poster_2025.jpg/220px-Deva_poster_2025.jpg','VCOeunYPCTc'),
('Crew','Three resourceful flight attendants get accidentally entangled in a gold smuggling scandal at 30,000 feet.','Hindi','Comedy, Thriller','2h 1m',6.4,'Tabu, Kareena Kapoor, Kriti Sanon, Kapil Sharma','Rajesh Krishnan',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/0/0a/Crew_2024_poster.jpg/220px-Crew_2024_poster.jpg','FEFNamlbGqo'),
('Emergency','A controversial biopic about former Prime Minister Indira Gandhi and the 1975 Emergency period.','Hindi','Political, Drama, Biography','2h 36m',6.1,'Kangana Ranaut, Anupam Kher, Mahima Chaudhry','Kangana Ranaut',2025,'https://upload.wikimedia.org/wikipedia/en/thumb/2/2e/Emergency_poster.jpg/220px-Emergency_poster.jpg','wBvvGgfkOXU'),
('War 2','The Spy Universe''s most explosive chapter with Hrithik and Jr. NTR in a deadly cat-and-mouse game.','Hindi','Action, Spy','2h 40m',8.5,'Hrithik Roshan, Jr. NTR, Kiara Advani','Ayan Mukerji',2025,'https://m.media-amazon.com/images/M/MV5BZjQ5MGQ4ZmMtMjE1Zi00YTYxLWI4ZDMtNjNjZmE0NWFiZjRiXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Rocky Aur Rani Kii Prem Kahaani','A big-hearted Punjabi and an intellectual Bengali navigate their wildly different families in this love story.','Hindi','Romance, Drama','2h 48m',6.5,'Ranveer Singh, Alia Bhatt, Dharmendra, Jaya Bachchan','Karan Johar',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/0/0e/Rocky_Aur_Rani_Kii_Prem_Kahaani_poster.jpg/220px-Rocky_Aur_Rani_Kii_Prem_Kahaani_poster.jpg','5GXLa5m2t-M'),
('Kalki 2898 AD','Hindi dub of the groundbreaking mythological sci-fi spectacle set in a dystopian future.','Hindi','Sci-Fi, Mythology','3h 1m',6.8,'Prabhas, Deepika Padukone, Amitabh Bachchan, Kamal Haasan','Nag Ashwin',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/50/Kalki_2898_AD_poster.jpg/220px-Kalki_2898_AD_poster.jpg','X9BjcjlYeUg'),
('Fighter 2','The sequel to India''s top aerial action franchise goes global with even bigger stakes.','Hindi','Action, War','2h 50m',8.0,'Hrithik Roshan, Deepika Padukone','Siddharth Anand',2026,'https://m.media-amazon.com/images/M/MV5BNzAyNzY3MDEtMmUyZC00N2RkLTkzNjktNTFjYzE0MmE5YzdhXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Merry Christmas','A chance meeting on Christmas Eve leads to an unexpected night of love, crime, and dangerous secrets.','Hindi','Thriller, Romance','2h 26m',7.2,'Katrina Kaif, Vijay Sethupathi','Sriram Raghavan',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/52/Merry_Christmas_2024_poster.jpg/220px-Merry_Christmas_2024_poster.jpg','9T95IJbdIxk'),
('Metro In Dino','A modern anthology of Mumbai love stories exploring connection and longing in a fast-paced city.','Hindi','Romance, Drama','2h 20m',7.4,'Sara Ali Khan, Aditya Roy Kapoor, Fatima Sana Shaikh','Anurag Basu',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/57/Metro_In_Dino_poster.jpg/220px-Metro_In_Dino_poster.jpg','hcEE9rJe1JU'),
('Devara (Hindi)','Hindi dub of the Telugu mass action drama about a feared sea monster and his son''s battle for dominance.','Hindi','Action, Drama','2h 59m',6.9,'Jr. NTR, Saif Ali Khan, Janhvi Kapoor','Koratala Siva',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/7/74/Devara_film_poster.jpg/220px-Devara_film_poster.jpg','dUKSTiTY-W8'),
('Pushpa 2 (Hindi)','Hindi dub of the biggest Indian blockbuster about Pushpa Raj''s unstoppable rise to power.','Hindi','Action, Crime','3h 21m',8.0,'Allu Arjun, Rashmika Mandanna, Fahadh Faasil','Sukumar',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/c/ce/Pushpa_2_poster.jpg/220px-Pushpa_2_poster.jpg','z7cGYrCrONM'),
('Do Aur Do Pyaar','Two married individuals having secret affairs discover an unexpected intersection of their parallel lives.','Hindi','Romance, Comedy','2h 1m',7.2,'Vidya Balan, Pratik Gandhi, Ileana D''Cruz','Shirsha Guha Thakurta',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/Do_Aur_Do_Pyaar_poster.jpg/220px-Do_Aur_Do_Pyaar_poster.jpg','vj3aVOCsP7w');

-- HOLLYWOOD (30 movies)
INSERT INTO movies (title,description,language,genre,duration,rating,cast_members,director,release_year,poster_url,trailer_id) VALUES
('Oppenheimer','The epic story of J. Robert Oppenheimer and his creation of the world''s first atomic bomb.','Hollywood','Biography, Drama, History','3h 0m',8.9,'Cillian Murphy, Emily Blunt, Matt Damon, Robert Downey Jr.','Christopher Nolan',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/4/4a/Oppenheimer_%28film%29.jpg/220px-Oppenheimer_%28film%29.jpg','uYPbbksJxIg'),
('Dune: Part Two','Paul Atreides unites with the Fremen warriors and seeks revenge against the conspirators who destroyed his family.','Hollywood','Sci-Fi, Adventure','2h 46m',8.5,'Timothée Chalamet, Zendaya, Austin Butler, Rebecca Ferguson','Denis Villeneuve',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/52/Dune_Part_Two_poster.jpg/220px-Dune_Part_Two_poster.jpg','Way9Dexny3w'),
('Deadpool & Wolverine','The foul-mouthed mercenary Wade Wilson teams up with a grumpy Wolverine on a mission that saves the MCU.','Hollywood','Action, Comedy','2h 7m',7.8,'Ryan Reynolds, Hugh Jackman, Emma Corrin','Shawn Levy',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/b/b1/Deadpool_%26_Wolverine_poster.jpg/220px-Deadpool_%26_Wolverine_poster.jpg','73_3eGPdoJQ'),
('Inside Out 2','As Riley enters adolescence, her emotions welcome an intense new arrival — Anxiety — to headquarters.','Hollywood','Animation, Drama','1h 40m',7.8,'Amy Poehler, Maya Hawke, Kensington Tallman, Liza Lapira','Kelsey Mann',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/b/b5/Inside_Out_2_logo.jpg/220px-Inside_Out_2_logo.jpg','LEjhY15eCx0'),
('Avengers: Endgame','The surviving Avengers assemble one final time to undo Thanos''s snap and restore the universe.','Hollywood','Action, Sci-Fi','3h 1m',8.4,'Robert Downey Jr., Chris Evans, Scarlett Johansson, Josh Brolin','Anthony and Joe Russo',2019,'https://upload.wikimedia.org/wikipedia/en/thumb/0/0d/Avengers_Endgame_poster.jpg/220px-Avengers_Endgame_poster.jpg','TcMBFSGVi1c'),
('Top Gun: Maverick','Pete Mitchell returns as a daring naval aviator on an impossible mission to destroy a rogue nuclear facility.','Hollywood','Action, Drama','2h 10m',8.2,'Tom Cruise, Miles Teller, Jennifer Connelly, Jon Hamm','Joseph Kosinski',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/1/13/Top_Gun_Maverick_Poster.jpg/220px-Top_Gun_Maverick_Poster.jpg','giXco2jaZ_4'),
('The Dark Knight','Batman faces the Joker, a criminal mastermind who wants to plunge Gotham City into complete anarchy.','Hollywood','Action, Crime','2h 32m',9.0,'Christian Bale, Heath Ledger, Aaron Eckhart, Maggie Gyllenhaal','Christopher Nolan',2008,'https://upload.wikimedia.org/wikipedia/en/thumb/1/1c/The_Dark_Knight_%282008_film%29.jpg/220px-The_Dark_Knight_%282008_film%29.jpg','EXeTwQWrcwY'),
('Inception','A skilled thief who enters people''s dreams to steal secrets is given a reverse task — planting an idea.','Hollywood','Sci-Fi, Thriller','2h 28m',8.8,'Leonardo DiCaprio, Joseph Gordon-Levitt, Ellen Page, Ken Watanabe','Christopher Nolan',2010,'https://upload.wikimedia.org/wikipedia/en/thumb/2/2e/Inception_%282010%29_theatrical_poster.jpg/220px-Inception_%282010%29_theatrical_poster.jpg','YoHD9XEInc0'),
('Interstellar','A team of astronauts travels through a newly discovered wormhole to find a new home for humanity.','Hollywood','Sci-Fi, Drama','2h 49m',8.7,'Matthew McConaughey, Anne Hathaway, Jessica Chastain, Matt Damon','Christopher Nolan',2014,'https://upload.wikimedia.org/wikipedia/en/thumb/b/bc/Interstellar_film_poster.jpg/220px-Interstellar_film_poster.jpg','zSWdZVtXT7E'),
('Spider-Man: No Way Home','Peter Parker''s world is turned upside down when multiverse villains invade his reality.','Hollywood','Action, Superhero','2h 28m',8.2,'Tom Holland, Zendaya, Benedict Cumberbatch, Alfred Molina','Jon Watts',2021,'https://upload.wikimedia.org/wikipedia/en/thumb/9/9c/Spider-Man_No_Way_Home_poster.jpg/220px-Spider-Man_No_Way_Home_poster.jpg','JfVOs4VSpmA'),
('Avatar: The Way of Water','Jake and Neytiri fight to protect their family as an old threat returns to Pandora''s oceans.','Hollywood','Sci-Fi, Adventure','3h 12m',7.6,'Sam Worthington, Zoe Saldana, Sigourney Weaver, Kate Winslet','James Cameron',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/5/56/Avatar_The_Way_of_Water_poster.jpg/220px-Avatar_The_Way_of_Water_poster.jpg','a8Gx8wiNbs8'),
('Barbie','Barbie has a life crisis and journeys to the real world with Ken to find her true purpose.','Hollywood','Comedy, Fantasy','1h 54m',6.9,'Margot Robbie, Ryan Gosling, Kate McKinnon, America Ferrera','Greta Gerwig',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/3/35/Barbie_2023_poster.jpg/220px-Barbie_2023_poster.jpg','pBk4NYhWNMM'),
('Alien: Romulus','Young space colonizers searching for a better life encounter the deadliest species in the universe.','Hollywood','Sci-Fi, Horror','1h 59m',7.3,'Cailee Spaeny, David Jonsson, Archie Renaux','Fede Álvarez',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/d/d3/Alien_Romulus_poster.jpg/220px-Alien_Romulus_poster.jpg','eBMoHi3tCFM'),
('Gladiator II','Lucius, now grown, must fight through the brutal Colosseum to avenge Rome''s fallen heroes.','Hollywood','Action, History','2h 28m',7.0,'Paul Mescal, Denzel Washington, Pedro Pascal, Joseph Quinn','Ridley Scott',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/d/dd/Gladiator_II_poster.jpg/220px-Gladiator_II_poster.jpg','3oBflEBwFSI'),
('Wicked','The untold story of the witches of Oz — Elphaba and Glinda — before Dorothy ever arrived.','Hollywood','Musical, Fantasy','2h 40m',7.9,'Cynthia Erivo, Ariana Grande, Jonathan Bailey','Jon M. Chu',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/7/7f/Wicked_film_poster.jpg/220px-Wicked_film_poster.jpg','Kp3nMKKRWE4'),
('Nosferatu','A terrifying gothic tale of obsession between a haunted young woman and an ancient vampire Count.','Hollywood','Horror, Gothic','2h 12m',7.6,'Bill Skarsgård, Lily-Rose Depp, Nicholas Hoult, Aaron Taylor-Johnson','Robert Eggers',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/5/5f/Nosferatu_2024_film_poster.jpg/220px-Nosferatu_2024_film_poster.jpg','3lmmMqGpLNo'),
('Twisters','Rival storm chasers come together to face monstrous back-to-back tornadoes tearing through Oklahoma.','Hollywood','Action, Disaster','2h 2m',7.2,'Daisy Edgar-Jones, Glen Powell, Anthony Ramos','Lee Isaac Chung',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/7/7d/Twisters_film_poster.jpg/220px-Twisters_film_poster.jpg','aVzqFZmCxRY'),
('Kingdom of the Planet of the Apes','Many years after Caesar''s reign, a young ape discovers his true legacy on a dangerous journey.','Hollywood','Sci-Fi, Action','2h 25m',7.1,'Owen Teague, Freya Allan, Kevin Durand, Peter Macon','Wes Ball',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/3/38/Kingdom_of_the_Planet_of_the_Apes_poster.jpg/220px-Kingdom_of_the_Planet_of_the_Apes_poster.jpg','AUZL7rBm2eI'),
('Godzilla x Kong: The New Empire','Godzilla and Kong must form an unlikely alliance to face a monstrous ancient threat.','Hollywood','Action, Sci-Fi','1h 55m',5.9,'Rebecca Hall, Brian Tyree Henry, Dan Stevens, Kaylee Hottle','Adam Wingard',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/e/ec/GxK_TNE_poster.jpg/220px-GxK_TNE_poster.jpg','odM92ap8_c0'),
('Moana 2','Moana embarks on a thrilling new oceanic voyage to discover a mysterious long-lost island.','Hollywood','Animation, Adventure','1h 40m',6.8,'Auli''i Cravalho, Dwayne Johnson, Temuera Morrison','David Derrick Jr.',2024,'https://upload.wikimedia.org/wikipedia/en/thumb/7/7a/Moana_2_poster.jpg/220px-Moana_2_poster.jpg','7gFLVENRBPs'),
('Mission: Impossible – The Final Reckoning','Ethan Hunt faces his ultimate reckoning with the terrifying AI Entity in the franchise finale.','Hollywood','Action, Spy','2h 50m',8.5,'Tom Cruise, Hayley Atwell, Ving Rhames, Angela Bassett','Christopher McQuarrie',2025,'https://m.media-amazon.com/images/M/MV5BNzAyNzY3MDEtMmUyZC00N2RkLTkzNjktNTFjYzE0MmE5YzdhXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Avengers: Doomsday','The Avengers face an existential threat from the terrifying Doctor Doom across multiple realities.','Hollywood','Action, Superhero','2h 30m',9.0,'Robert Downey Jr., Chris Evans, Anthony Mackie, Benedict Cumberbatch','Anthony and Joe Russo',2026,'https://m.media-amazon.com/images/M/MV5BNzAyNzY3MDEtMmUyZC00N2RkLTkzNjktNTFjYzE0MmE5YzdhXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Captain America: Brave New World','Sam Wilson steps up as the new Captain America and faces a conspiracy involving the US government.','Hollywood','Action, Superhero','2h 0m',6.0,'Anthony Mackie, Harrison Ford, Danny Ramirez','Julius Onah',2025,'https://upload.wikimedia.org/wikipedia/en/thumb/f/fd/Captain_America_Brave_New_World_poster.jpg/220px-Captain_America_Brave_New_World_poster.jpg','placeholder'),
('A Minecraft Movie','A live-action adventure where players are transported into the pixelated world of Minecraft.','Hollywood','Adventure, Comedy','1h 41m',6.5,'Jack Black, Jason Momoa, Emma Myers','Jared Hess',2025,'https://upload.wikimedia.org/wikipedia/en/thumb/5/58/A_Minecraft_Movie_poster.jpg/220px-A_Minecraft_Movie_poster.jpg','placeholder'),
('Jurassic World Rebirth','A new Jurassic saga begins in a breathtaking exotic location filled with rediscovered dinosaur species.','Hollywood','Sci-Fi, Adventure','2h 8m',6.2,'Scarlett Johansson, Jonathan Bailey, Mahershala Ali','Gareth Edwards',2025,'https://m.media-amazon.com/images/M/MV5BZGVlMzk2ZTUtNDI4Yi00MjQzLThiZGMtZjUwZjMzMjZkMWM1XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('The Batman Part II','Bruce Wayne continues his brutal war on crime and corruption in a darker, more complex Gotham City.','Hollywood','Action, Crime','2h 45m',8.8,'Robert Pattinson, Zoë Kravitz, Barry Keoghan','Matt Reeves',2026,'https://m.media-amazon.com/images/M/MV5BNzAyNzY3MDEtMmUyZC00N2RkLTkzNjktNTFjYzE0MmE5YzdhXkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder'),
('Doctor Strange in the Multiverse of Madness','Strange faces the terrifying Scarlet Witch as they traverse dangerous parallel universes.','Hollywood','Action, Superhero','2h 6m',6.9,'Benedict Cumberbatch, Elizabeth Olsen, Rachel McAdams, Xochitl Gomez','Sam Raimi',2022,'https://upload.wikimedia.org/wikipedia/en/thumb/8/8e/Doctor_Strange_in_the_Multiverse_of_Madness_poster.jpg/220px-Doctor_Strange_in_the_Multiverse_of_Madness_poster.jpg','aWzlQ2N6qqg'),
('The Super Mario Bros. Movie','Mario and Luigi embark on an epic adventure through the Mushroom Kingdom to rescue Princess Peach.','Hollywood','Animation, Comedy','1h 32m',7.1,'Charlie Day, Chris Pratt, Jack Black, Anya Taylor-Joy','Aaron Horvath',2023,'https://upload.wikimedia.org/wikipedia/en/thumb/7/7a/The_Super_Mario_Bros._Movie_poster.jpg/220px-The_Super_Mario_Bros._Movie_poster.jpg','i7MNbcNPbRc'),
('Snow White','A live-action retelling of the classic fairy tale about a princess who escapes her evil stepmother.','Hollywood','Fantasy, Musical','1h 49m',2.3,'Rachel Zegler, Gal Gadot, Andrew Burnap','Marc Webb',2025,'https://upload.wikimedia.org/wikipedia/en/thumb/1/18/Snow_White_2025_poster.jpg/220px-Snow_White_2025_poster.jpg','placeholder'),
('Thunderbolts*','A team of antiheroes and reformed villains is assembled for a dangerous mission.','Hollywood','Action, Superhero','2h 7m',7.2,'Florence Pugh, Sebastian Stan, David Harbour, Hannah John-Kamen','Jake Schreier',2025,'https://m.media-amazon.com/images/M/MV5BYTQyZTMwNGMtNmJiYy00ZmFkLThhMzQtYTNmMGY5NTFiMzA0XkEyXkFqcGdeQXVyMTUzNTgzNzM0._V1_SY500_.jpg','placeholder');

-- ── SHOWTIMES (7 days for first 30 movies across screens) ────
DROP PROCEDURE IF EXISTS gen_showtimes;
DELIMITER //
CREATE PROCEDURE gen_showtimes()
BEGIN
  DECLARE d INT DEFAULT 0;
  DECLARE m INT DEFAULT 1;
  DECLARE sc INT;
  DECLARE max_movies INT;
  DECLARE max_screens INT;
  SELECT COUNT(*) INTO max_movies FROM movies;
  SELECT COUNT(*) INTO max_screens FROM screens;
  WHILE d < 7 DO
    SET m = 1;
    WHILE m <= LEAST(max_movies, 150) DO
      SET sc = ((m - 1) % max_screens) + 1;
      INSERT IGNORE INTO showtimes (movie_id,screen_id,show_date,show_time,price_standard,price_premium) VALUES
        (m,sc,DATE_ADD(CURDATE(),INTERVAL d DAY),'10:00:00',200,350),
        (m,sc,DATE_ADD(CURDATE(),INTERVAL d DAY),'13:30:00',220,380),
        (m,sc,DATE_ADD(CURDATE(),INTERVAL d DAY),'17:00:00',250,400),
        (m,sc,DATE_ADD(CURDATE(),INTERVAL d DAY),'21:00:00',280,450);
      SET m = m + 1;
    END WHILE;
    SET d = d + 1;
  END WHILE;
END//
DELIMITER ;
CALL gen_showtimes();
DROP PROCEDURE IF EXISTS gen_showtimes;
