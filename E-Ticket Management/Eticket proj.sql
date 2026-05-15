#is to design and implement an E-Ticket Booking System using MySQL 
#that manages user bookings, tracks seat availability, and generates insights into total bookings, revenue, and movie performance. 
#The system allows users to book tickets for movies/events and helps analyse booking trends, user behaviour, and seat utilisation. 
#It simulates the backend functionality of real-world platforms like BookMyShow.

CREATE DATABASE EticketDB;
USE EticketDB;

-- TABLES

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);

CREATE TABLE Events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(100),
    event_date DATE,
    total_seats INT,
    available_seats INT
);

CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    event_id INT,
    seats_booked INT,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- DATA INSERTION

INSERT INTO Users (name, email, phone) VALUES
('Vinay', 'vinay@gmail.com', '9876543210'),
('Rahul', 'rahul@gmail.com', '9123456780'),
('Amit', 'amit@gmail.com', '9988776655'),
('Sneha', 'sneha@gmail.com', '8899776655'),
('Priya', 'priya@gmail.com', '7766554433'),
('Karan', 'karan@gmail.com', '9090909090'),
('Neha', 'neha@gmail.com', '8888888888'),
('Arjun', 'arjun@gmail.com', '7777777777'),
('Pooja', 'pooja@gmail.com', '6666666666'),
('Rohit', 'rohit@gmail.com', '9555555555'),
('Anjali', 'anjali@gmail.com', '9444444444'),
('Vikas', 'vikas@gmail.com', '9333333333'),
('Meera', 'meera@gmail.com', '9222222222'),
('Suresh', 'suresh@gmail.com', '9111111111'),
('Divya', 'divya@gmail.com', '9000000000');

INSERT INTO Events (event_name, event_date, total_seats, available_seats) VALUES
('RRR', '2026-04-20', 120, 120),
('KGF Chapter 2', '2026-04-21', 150, 150),
('Pushpa 2', '2026-04-22', 130, 130),
('Baahubali 2', '2026-04-23', 140, 140),
('Jawan', '2026-04-24', 160, 160),
('Pathaan', '2026-04-25', 150, 150),
('Leo', '2026-04-26', 120, 120),
('Vikram', '2026-04-27', 110, 110),
('Master', '2026-04-28', 100, 100),
('Avengers Endgame', '2026-04-29', 200, 200),
('Spider-Man No Way Home', '2026-04-30', 180, 180),
('Inception', '2026-05-01', 140, 140),
('Interstellar', '2026-05-02', 150, 150),
('The Dark Knight', '2026-05-03', 160, 160),
('Dangal', '2026-05-04', 130, 130);

INSERT INTO Bookings (user_id, event_id, seats_booked) VALUES
(1,1,2),(2,2,3),(3,3,1),(4,4,4),(5,5,2),
(6,6,5),(7,7,1),(8,8,2),(9,9,3),(10,10,2),
(11,11,4),(12,12,1),(13,13,2),(14,14,3),(15,15,2);

-- BOOKING UPDATION PROCESS

UPDATE Events e
JOIN (
    SELECT event_id, SUM(seats_booked) AS total_booked
    FROM Bookings
    GROUP BY event_id
) AS booking_summary
ON e.event_id = booking_summary.event_id
SET e.available_seats = e.total_seats - booking_summary.total_booked;

-- Query Execution

-- Query 1:
-- Retrieve all booking details including user name, movie name, number of seats booked, and booking date.
SELECT 
    u.name AS user_name,
    e.event_name,
    b.seats_booked,
    b.booking_date
FROM Bookings b
JOIN Users u ON b.user_id = u.user_id
JOIN Events e ON b.event_id = e.event_id;

-- Query 2:
-- Calculate and display the total number of seats booked for each movie.
SELECT 
    e.event_name,
    SUM(b.seats_booked) AS total_tickets_sold
FROM Bookings b
JOIN Events e ON b.event_id = e.event_id
GROUP BY e.event_name;

-- Query 3:
-- Identify and display the top 5 most booked movies based on total tickets sold.
SELECT 
    e.event_name,
    SUM(b.seats_booked) AS total_tickets_sold
FROM Bookings b
JOIN Events e ON b.event_id = e.event_id
GROUP BY e.event_name
ORDER BY total_tickets_sold DESC
LIMIT 5;

-- Query 4:
-- Display the seat availability flow for each movie, including seats before booking, seats booked, and seats available after booking.
SELECT 
    e.event_name,
    (e.available_seats + IFNULL(SUM(b.seats_booked),0)) AS seats_before_booking,
    IFNULL(SUM(b.seats_booked),0) AS seats_booked,
    e.available_seats AS seats_after_booking
FROM Events e
LEFT JOIN Bookings b ON e.event_id = b.event_id
GROUP BY e.event_id, e.event_name, e.available_seats;

-- Query 5:
-- Retrieve and display the movies booked by each user along with the total number of seats booked.
SELECT 
    u.name AS user_name,
    e.event_name,
    SUM(b.seats_booked) AS total_seats_booked
FROM Bookings b
JOIN Users u ON b.user_id = u.user_id
JOIN Events e ON b.event_id = e.event_id
GROUP BY u.name, e.event_name;

-- Query 6:
-- Calculate and display the average number of seats booked for each movie.
SELECT 
    e.event_name,
    AVG(b.seats_booked) AS avg_seats_per_movie
FROM Bookings b
JOIN Events e ON b.event_id = e.event_id
GROUP BY e.event_name;

-- Query 7:
-- Identify and display movies that have above-average bookings based on total seats booked.
SELECT 
    e.event_name,
    SUM(b.seats_booked) AS total_tickets_sold
FROM Bookings b
JOIN Events e ON b.event_id = e.event_id
GROUP BY e.event_name
HAVING SUM(b.seats_booked) > (
    SELECT AVG(total_sold)
    FROM (
        SELECT SUM(seats_booked) AS total_sold
        FROM Bookings
        GROUP BY event_id
    ) AS avg_table
);

-- Query 8:
-- Calculate and display the total revenue generated from all bookings.
SELECT 
    SUM(seats_booked * 200) AS total_revenue
FROM Bookings;

-- Query 9:
-- Calculate and display the revenue generated by each movie (₹200 per ticket).
SELECT 
    e.event_name,
    SUM(b.seats_booked) AS total_tickets_sold,
    SUM(b.seats_booked * 200) AS revenue_generated
FROM Bookings b
JOIN Events e ON b.event_id = e.event_id
GROUP BY e.event_name
ORDER BY revenue_generated DESC;

-- Query 10:
-- Display total seats before booking, total seats booked, and available seats after booking for each movie.
SELECT 
    e.event_name,
    e.total_seats,
    e.available_seats AS seats_after_booking,
    (e.available_seats + IFNULL(SUM(b.seats_booked),0)) AS seats_before_booking,
    IFNULL(SUM(b.seats_booked),0) AS total_booked
FROM Events e
LEFT JOIN Bookings b ON e.event_id = b.event_id
GROUP BY e.event_id, e.event_name, e.total_seats, e.available_seats;