-- ================================================================
--  Travel & Tourism Management System — COMPLETE DATABASE SETUP
--  Run this entire file in MySQL Workbench or MySQL CLI
--  This script is safe to re-run (uses IF NOT EXISTS / IGNORE)
-- ================================================================

CREATE DATABASE IF NOT EXISTS tour_db;
USE tour_db;

-- ============================================================
-- STEP 1: Create tables (won't touch them if they exist)
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    phone      VARCHAR(20),
    password   VARCHAR(255) NOT NULL,
    is_admin   BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS packages (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    title       VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    price       DECIMAL(10,2) NOT NULL,
    image       VARCHAR(255) NOT NULL,
    short_desc  VARCHAR(500),
    long_desc   TEXT,
    duration    VARCHAR(100),
    image_url   VARCHAR(255),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bookings (
    id             INT PRIMARY KEY AUTO_INCREMENT,
    user_id        INT NOT NULL,
    package_id     INT NOT NULL,
    travelers      INT DEFAULT 1,
    booking_date   DATE,
    total_amount   DECIMAL(10,2),
    status         VARCHAR(50) DEFAULT 'confirmed',
    payment_method VARCHAR(50),
    payment_date   TIMESTAMP NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reviews (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    user_id    INT NOT NULL,
    package_id INT NOT NULL,
    rating     INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment    TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS contacts (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL,
    subject    VARCHAR(200) NOT NULL,
    message    TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- STEP 2: Safe ALTER — add columns only if missing
-- ============================================================

-- Add payment_method to bookings if not exists
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='tour_db' AND TABLE_NAME='bookings' AND COLUMN_NAME='payment_method'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE bookings ADD COLUMN payment_method VARCHAR(50) AFTER status',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Add payment_date to bookings if not exists
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA='tour_db' AND TABLE_NAME='bookings' AND COLUMN_NAME='payment_date'
);
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE bookings ADD COLUMN payment_date TIMESTAMP NULL AFTER payment_method',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ============================================================
-- STEP 3: Seed default admin (password = admin123)
-- Change email/password before going to production!
-- ============================================================
INSERT IGNORE INTO users (name, email, phone, password, is_admin)
VALUES ('Admin', 'admin@travelexplorer.com', '9999999999',
        SHA2('admin123', 256), TRUE);

-- ============================================================
-- STEP 4: Seed sample packages (only if table is empty)
-- ============================================================
INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Goa Beach Vacation' AS title,
    'Experience the beautiful beaches and vibrant nightlife of Goa. Enjoy water sports, beach parties and fresh seafood with our exclusive package.' AS description,
    8999.00 AS price, 'goa.jpg' AS image, 'Sun, sand and sea in Goa' AS short_desc, '4 Days, 3 Nights' AS duration
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Goa Beach Vacation');

INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Paris Romantic Getaway', 'Discover the City of Love with romantic dinners at the Eiffel Tower, Louvre Museum visits and iconic Parisian landmarks.', 49999.00, 'paris.jpg', 'Romantic Paris experience', '6 Days, 5 Nights'
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Paris Romantic Getaway');

INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Swiss Alpine Adventure', 'Ski through the Alps, explore Zurich, and enjoy breathtaking mountain scenery in the heart of Europe.', 79999.00, 'swiss.jpg', 'Swiss mountain adventure', '7 Days, 6 Nights'
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Swiss Alpine Adventure');

INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Kashmir Valley Tour', 'Explore paradise on earth with houseboat stays on Dal Lake, Mughal gardens and pristine snowy valleys.', 25999.00, 'kashmir.jpg', 'Beautiful Kashmir valley', '5 Days, 4 Nights'
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Kashmir Valley Tour');

INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Bali Cultural Journey', 'Discover ancient temples, emerald rice terraces, vibrant nightlife and pristine beaches in the Island of Gods.', 32999.00, 'bali.jpg', 'Tropical Bali paradise', '6 Days, 5 Nights'
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Bali Cultural Journey');

INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Dubai Desert & Skyline', 'Experience the Burj Khalifa, desert safari, gold souk and the ultramodern wonders of Dubai.', 45999.00, 'dubai.jpg', 'Luxury Dubai experience', '5 Days, 4 Nights'
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Dubai Desert & Skyline');

INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Thailand Explorer', 'Explore Bangkok temples, Chiang Mai jungles and Phuket beaches — the best of Thailand in one trip.', 25999.00, 'thailand.jpg', 'Amazing Thailand tour', '8 Days, 7 Nights'
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Thailand Explorer');

INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Maldives Luxury Getaway', 'Stay in overwater bungalows, snorkel in crystal-clear blue waters and enjoy world-class luxury in the Maldives.', 55999.00, 'maldives.jpg', 'Luxury Maldives escape', '5 Days, 4 Nights'
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Maldives Luxury Getaway');

INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Japan Cultural Tour', 'Visit Tokyo, Kyoto temples, Mount Fuji and experience authentic Japanese culture and cuisine.', 68999.00, 'japan.jpg', 'Authentic Japan experience', '9 Days, 8 Nights'
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Japan Cultural Tour');

INSERT INTO packages (title, description, price, image, short_desc, duration)
SELECT * FROM (SELECT
    'Singapore City Experience', 'Marvel at Gardens by the Bay, Marina Bay Sands, Sentosa Island and world-class cuisine in Singapore.', 38999.00, 'singapore.jpg', 'Modern Singapore city tour', '4 Days, 3 Nights'
) t WHERE NOT EXISTS (SELECT 1 FROM packages WHERE title='Singapore City Experience');

-- ============================================================
-- Done! Verify with:
-- SELECT * FROM packages;
-- SELECT id, name, email, is_admin FROM users;
-- ============================================================

show tables;
select * from users;
