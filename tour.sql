SELECT CURRENT_USER();
CREATE DATABASE tour_db;
SELECT DATABASE();
Use tour_db;
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE packages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    image VARCHAR(255) NOT NULL,
    short_desc VARCHAR(500),
    long_desc TEXT,
    duration VARCHAR(100),
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    package_id INT NOT NULL,
    travelers INT DEFAULT 1,
    booking_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'confirmed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE
);
CREATE TABLE contacts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO users (name, email, phone, password, is_admin) VALUES 
('Dharshini', 'dharshini@gmail.com', NULL, 'f9a76f13274a7c19f92109f03edfd187e1b102011725cc8485a95a30e5f792e2', TRUE);
INSERT INTO users (name, email, phone, password) VALUES 
('Nithish', 'nithish@gmail.com', NULL, 'b0cc0920b67b0ece395f6a76d42c224ec0eddd0f88f12b8470c07b46e02754e3');

INSERT INTO packages (title, description, price, image, short_desc, long_desc, duration) VALUES 
('Goa Beach Vacation', 'Experience the beautiful beaches and vibrant nightlife of Goa with our exclusive package.', 8999.00, 'goa.jpg', 'Sun, sand and sea in Goa', 'Detailed description of Goa package including all amenities and activities', '4 Days, 3 Nights'),
('Paris Romantic Getaway', 'Discover the city of love with romantic dinners and iconic landmarks.', 49999.00, 'paris.jpg', 'Romantic Paris experience', 'Detailed Paris itinerary with hotel stays and guided tours', '6 Days, 5 Nights'),
('Swiss Alpine Adventure', 'Enjoy scenic beauty and alpine adventures in the heart of Europe.', 79999.00, 'swiss.jpg', 'Swiss mountain adventure', 'Comprehensive Swiss tour including mountain excursions', '7 Days, 6 Nights'),
('Kashmir Valley Tour', 'Explore the paradise on earth with houseboat stays and garden visits.', 25999.00, 'kashmir.jpg', 'Beautiful Kashmir valley', 'Amazing Kashmir tour with houseboat experience', '5 Days, 4 Nights');

-- Migration for existing databases (run manually if needed):
-- ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER email;
-- UPDATE users SET password = 'f9a76f13274a7c19f92109f03edfd187e1b102011725cc8485a95a30e5f792e2' WHERE email = 'dharshini@gmail.com';
-- UPDATE users SET password = 'b0cc0920b67b0ece395f6a76d42c224ec0eddd0f88f12b8470c07b46e02754e3' WHERE email = 'nithish@gmail.com';
-- UPDATE bookings SET status = LOWER(status);

SHOW GRANTS FOR 'Dharsha'@'localhost';

select * from users;
use travel_db;
INSERT INTO packages (title, description, price, image) VALUES
('Kashmir', 'Experience the paradise on earth with beautiful valleys and snow-capped mountains.', 29999, 'kashmir.jpg'),
('Bali, Indonesia', 'Experience tropical paradise with beautiful beaches and rich culture.', 32999, 'bali.jpg'),
('Dubai, UAE', 'Luxury shopping, ultramodern architecture and a lively nightlife scene.', 45999, 'dubai.jpg'),
('Thailand', 'Golden beaches, opulent royal palaces, ancient ruins and ornate temples.', 25999, 'thailand.jpg'),
('Maldives', 'Crystal clear waters, white sandy beaches and luxurious overwater villas.', 55999, 'maldives.jpg'),
('Japan', 'Mix of traditional and modern, from neon-lit skyscrapers to historic temples.', 68999, 'japan.jpg');

SELECT id, title, description, price FROM packages WHERE title LIKE '%Kashmir%'
DELETE FROM users WHERE id = 12;
SELECT id, title, price FROM packages ORDER BY id;
INSERT INTO packages (id, title, description, price, image) 
VALUES (5, 'Singapore City Tour', 'Experience the modern marvel of Singapore with futuristic gardens and vibrant city life', 38999.00, 'singapore.jpg');


select * from users;
select * from bookings;
select * from packages;
show tables;

desc bookings;

ALTER TABLE bookings ADD COLUMN payment_method VARCHAR(50) AFTER status, ADD COLUMN payment_date TIMESTAMP NULL AFTER payment_method;
