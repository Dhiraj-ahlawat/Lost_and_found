-- CAMPUS LOST & FOUND MANAGEMENT SYSTEM
-- Course: Database Management Systems (DBMS) Mini-Project
-- Target DBMS: MySQL 8.0+
-- File: campus_lost_found.sql
-- Description: Complete executable SQL script containing database definition,
--              table structures, constraints, sample dataset, analytical queries,
--              views, indexes, stored procedures, triggers, and transactions.

-- 1. DATABASE INITIALIZATION
DROP DATABASE IF EXISTS campus_lost_found;
CREATE DATABASE campus_lost_found
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE campus_lost_found;

-- 2. TABLE CREATION & INTEGRITY CONSTRAINTS

-- Table 1: Students
-- Stores demographic and contact information of registered campus students.
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    CONSTRAINT pk_students PRIMARY KEY (student_id),
    CONSTRAINT uq_students_email UNIQUE (email),
    CONSTRAINT chk_students_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_students_phone CHECK (LENGTH(phone) >= 10)
) ENGINE=InnoDB;

-- Table 2: Categories
-- Classifies items into standardized groups (e.g., Electronics, Documents, Keys).
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,
    CONSTRAINT pk_categories PRIMARY KEY (category_id),
    CONSTRAINT uq_categories_name UNIQUE (category_name)
) ENGINE=InnoDB;

-- Table 3: Items
-- Tracks every reported lost or found article across campus grounds.
CREATE TABLE Items (
    item_id INT AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    description TEXT NOT NULL,
    item_type VARCHAR(10) NOT NULL,
    location VARCHAR(150) NOT NULL,
    report_date DATE NOT NULL,
    item_status VARCHAR(20) NOT NULL DEFAULT 'Reported',
    student_id INT NOT NULL,
    CONSTRAINT pk_items PRIMARY KEY (item_id),
    CONSTRAINT fk_items_category FOREIGN KEY (category_id)
        REFERENCES Categories (category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_items_student FOREIGN KEY (student_id)
        REFERENCES Students (student_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_items_type CHECK (item_type IN ('Lost', 'Found')),
    CONSTRAINT chk_items_status CHECK (item_status IN ('Reported', 'Claimed', 'Resolved', 'Returned'))
) ENGINE=InnoDB;

-- Table 4: Claims
-- Records ownership claims submitted by students for discovered items.
CREATE TABLE Claims (
    claim_id INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    student_id INT NOT NULL,
    claim_date DATE NOT NULL,
    claim_reason TEXT NOT NULL,
    claim_status VARCHAR(15) NOT NULL DEFAULT 'Pending',
    CONSTRAINT pk_claims PRIMARY KEY (claim_id),
    CONSTRAINT fk_claims_item FOREIGN KEY (item_id)
        REFERENCES Items (item_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_claims_student FOREIGN KEY (student_id)
        REFERENCES Students (student_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_claims_status CHECK (claim_status IN ('Pending', 'Approved', 'Rejected'))
) ENGINE=InnoDB;

-- 3. INDEXES FOR PERFORMANCE OPTIMIZATION
-- Accelerate keyword searches on item titles
CREATE INDEX idx_items_item_name ON Items (item_name);

-- Optimize location-based filtering (e.g., Library, Canteen)
CREATE INDEX idx_items_location ON Items (location);

-- Composite index to support dashboard queries filtering by type & status
CREATE INDEX idx_items_type_status ON Items (item_type, item_status);

-- Foreign key & status index for accelerated claim verification joins
CREATE INDEX idx_claims_item_status ON Claims (item_id, claim_status);

-- 4. SAMPLE DATA POPULATION

-- A. Insert Students (12 realistic students across campus departments)
INSERT INTO Students (student_id, student_name, email, department, phone) VALUES
(101, 'Aarav Sharma',     'aarav.sharma@campus.edu',     'Computer Science',        '9876543210'),
(102, 'Priya Patel',      'priya.patel@campus.edu',      'Electronics Engineering', '9876543211'),
(103, 'Rohan Verma',      'rohan.verma@campus.edu',      'Mechanical Engineering',  '9876543212'),
(104, 'Sneha Kulkarni',   'sneha.kulkarni@campus.edu',   'Information Technology',  '9876543213'),
(105, 'Aditya Singh',     'aditya.singh@campus.edu',     'Civil Engineering',       '9876543214'),
(106, 'Ananya Iyer',      'ananya.iyer@campus.edu',      'Biotechnology',           '9876543215'),
(107, 'Vikram Malhotra',  'vikram.malhotra@campus.edu',  'Business Administration', '9876543216'),
(108, 'Neha Deshmukh',    'neha.deshmukh@campus.edu',    'Computer Science',        '9876543217'),
(109, 'Kabir Mehta',      'kabir.mehta@campus.edu',      'Electrical Engineering',  '9876543218'),
(110, 'Ishita Roy',       'ishita.roy@campus.edu',       'Mathematics & Computing', '9876543219'),
(111, 'Devendra Yadav',   'devendra.yadav@campus.edu',   'Mechanical Engineering',  '9876543220'),
(112, 'Tanvi Joshi',      'tanvi.joshi@campus.edu',      'Information Technology',  '9876543221');

-- B. Insert Categories (8 campus-relevant categories)
INSERT INTO Categories (category_id, category_name, description) VALUES
(1, 'Electronics',          'Laptops, mobile phones, chargers, headphones, and electronic gadgets'),
(2, 'Identification Cards', 'Student identity cards, library cards, driver licenses, and badges'),
(3, 'Study Material',       'Textbooks, class notebooks, lab manuals, and scientific calculators'),
(4, 'Personal Accessories', 'Wristwatches, prescription spectacles, rings, and water bottles'),
(5, 'Bags & Luggage',       'Backpacks, laptop sleeves, gym bags, and side pouches'),
(6, 'Keys',                 'Dorm room keys, vehicle key chains, bicycle lock keys, and locker keys'),
(7, 'Sports Equipment',     'Badminton racquets, basketballs, gym gloves, and athletic gear'),
(8, 'Apparel & Outerwear',  'College hoodies, lab coats, sports jerseys, and umbrellas');

-- C. Insert Items (18 realistic campus records: Lost and Found)
INSERT INTO Items (item_id, item_name, category_id, description, item_type, location, report_date, item_status, student_id) VALUES
(201, 'MacBook Air M2 Silver',          1, 'Silver 13-inch laptop with NASA and Linux stickers on outer lid',        'Lost',  'Central Library 2nd Floor',       '2026-09-15', 'Reported', 101),
(202, 'Sony WH-1000XM4 Headphones',     1, 'Black wireless over-ear noise-cancelling headphones in black hard case',  'Found', 'Auditorium Row F',                '2026-09-16', 'Claimed',  102),
(203, 'Student ID Card - Aarav Sharma', 2, 'Official university smart ID card badge with red lanyard',              'Found', 'Student Cafeteria Counter 3',     '2026-09-17', 'Resolved', 103),
(204, 'Casio FX-991EX Calculator',      3, 'Black scientific calculator with name tag initials SK on battery cover',  'Lost',  'Computer Lab 3',                  '2026-09-18', 'Reported', 104),
(205, 'Wildcraft Blue Backpack',        5, 'Navy blue college backpack containing engineering notebooks and pencil box','Found', 'Sports Complex Pavilion',        '2026-09-19', 'Reported', 105),
(206, 'Honda Bike Key Ring',            6, 'Ignition key attached to metallic Superman keychain',                   'Lost',  'Main Campus Parking Lot B',       '2026-09-20', 'Reported', 103),
(207, 'Titan Edge Wristwatch',          4, 'Slim silver stainless steel mesh strap analog watch',                    'Lost',  'Mechanical Seminar Hall',         '2026-09-21', 'Reported', 111),
(208, 'Ray-Ban Wayfarer Sunglasses',    4, 'Matte black prescription sunglasses inside brown leather case',          'Found', 'Central Library Reading Hall A',  '2026-09-22', 'Reported', 106),
(209, 'Yonex Carbonex Badminton Racket',7, 'Red and black graphite badminton racket with neon yellow grip',         'Found', 'Badminton Court 2',               '2026-09-23', 'Reported', 107),
(210, 'White Lab Coat',                 8, 'Cotton white apron with Department of Biotechnology embroidery',         'Lost',  'Biochemistry Lab 102',            '2026-09-24', 'Reported', 106),
(211, 'Apple AirPods Pro 2nd Gen',      1, 'White wireless earbuds case with minor scratch near charging port',      'Found', 'Gymnasium Locker Room',           '2026-09-25', 'Claimed',  108),
(212, 'Database System Concepts Book',  3, '7th edition Silberschatz textbook with yellow highlighter marks',        'Lost',  'Department Library CS Wing',      '2026-09-26', 'Reported', 108),
(213, 'Dorm Room 304 Brass Key',        6, 'Single brass Yale key with blue plastic identifier tag number 304',      'Found', 'Hostel Block C Corridor',         '2026-09-27', 'Reported', 109),
(214, 'Fastrack Black Leather Wallet',  4, 'Bi-fold black leather wallet with cash and metro card inside',           'Lost',  'Bus Stop Near Gate 1',            '2026-09-28', 'Reported', 110),
(215, 'Dell 65W USB-C Laptop Charger',  1, 'Original Dell black AC power adapter with round black cable clip',       'Found', 'IT Department Project Lab',       '2026-09-29', 'Reported', 112),
(216, 'Hydro Flask 32oz Water Bottle',  4, 'Olive green insulated stainless steel flask with dent at base',          'Lost',  'Open Air Amphitheatre',           '2026-09-30', 'Reported', 105),
(217, 'Samsung Galaxy Tab S8',          1, 'Dark grey tablet with S-Pen attached magnetically inside magnetic cover','Lost',  'ECE Department Seminar Hall',     '2026-10-01', 'Reported', 102),
(218, 'Black Foldable Rain Umbrella',   8, 'Compact 3-fold black umbrella with automatic open button',               'Found', 'Main Building Reception Lobby',   '2026-10-02', 'Reported', 104);

-- D. Insert Claims (10 records demonstrating Pending, Approved, and Rejected states)
INSERT INTO Claims (claim_id, item_id, student_id, claim_date, claim_reason, claim_status) VALUES
(301, 202, 107, '2026-09-17', 'I misplaced my Sony headphones during the symposium in the Auditorium row F. Serial number ends in 4491.', 'Approved'),
(302, 203, 101, '2026-09-18', 'This is my college ID card. Name is Aarav Sharma, CS department, roll STU101.',                             'Approved'),
(303, 205, 103, '2026-09-20', 'The Wildcraft backpack belongs to me. It has my mechanical thermodynamics drawing sheets inside.',         'Pending'),
(304, 208, 110, '2026-09-23', 'I forgot my prescription Ray-Ban sunglasses at Table 4 in Library Hall A. Power is -1.5 in both eyes.',     'Pending'),
(305, 209, 111, '2026-09-24', 'I left my Yonex racket on court 2 after intramural practice. Grip tape is neon yellow.',                    'Pending'),
(306, 211, 104, '2026-09-26', 'My AirPods Pro match this description. Serial number matches my iPhone bluetooth pairing history.',         'Approved'),
(307, 213, 105, '2026-09-28', 'Room 304 is my room in Block C. I lost my spare key while going down the corridor staircase.',              'Pending'),
(308, 215, 101, '2026-09-30', 'I think this Dell charger is mine, left it in the lab.',                                                     'Rejected'),
(309, 215, 103, '2026-10-01', 'Left my Dell charger during the afternoon workshop. Serial sticker has a small tear.',                       'Pending'),
(310, 218, 106, '2026-10-03', 'I left my umbrella in the lobby during heavy rain. It has a distinctive red stitching tag on sleeve.',      'Pending');

-- 5. DATABASE VIEWS

-- View 1: vw_lost_items
-- Presents all active lost item notices with reporter contact details and category name.
CREATE OR REPLACE VIEW vw_lost_items AS
SELECT
    i.item_id,
    i.item_name,
    c.category_name,
    i.description,
    i.location AS lost_location,
    i.report_date,
    i.item_status,
    s.student_name AS reported_by,
    s.department,
    s.email AS contact_email,
    s.phone AS contact_phone
FROM Items i
INNER JOIN Categories c ON i.category_id = c.category_id
INNER JOIN Students s ON i.student_id = s.student_id
WHERE i.item_type = 'Lost';

-- View 2: vw_found_items
-- Displays all items turned in to campus security/authorities.
CREATE OR REPLACE VIEW vw_found_items AS
SELECT
    i.item_id,
    i.item_name,
    c.category_name,
    i.description,
    i.location AS found_location,
    i.report_date,
    i.item_status,
    s.student_name AS found_by,
    s.department AS finder_department,
    s.email AS finder_email
FROM Items i
INNER JOIN Categories c ON i.category_id = c.category_id
INNER JOIN Students s ON i.student_id = s.student_id
WHERE i.item_type = 'Found';

-- View 3: vw_pending_claims
-- Administrative view tracking claims awaiting institutional verification.
CREATE OR REPLACE VIEW vw_pending_claims AS
SELECT
    cl.claim_id,
    i.item_id,
    i.item_name,
    c.category_name,
    i.location AS found_location,
    i.item_status AS item_current_status,
    cl.claim_date,
    cl.claim_reason,
    cl.claim_status,
    claimant.student_name AS claimant_name,
    claimant.email AS claimant_email,
    claimant.phone AS claimant_phone,
    claimant.department AS claimant_department,
    finder.student_name AS reported_by_student
FROM Claims cl
INNER JOIN Items i ON cl.item_id = i.item_id
INNER JOIN Categories c ON i.category_id = c.category_id
INNER JOIN Students claimant ON cl.student_id = claimant.student_id
INNER JOIN Students finder ON i.student_id = finder.student_id
WHERE cl.claim_status = 'Pending';

-- 6. STORED PROCEDURES
DELIMITER //

-- Procedure 1: sp_SearchItemsByCategory
-- Allows filtering lost and found items dynamically by category name.
CREATE PROCEDURE sp_SearchItemsByCategory(IN p_category_name VARCHAR(50))
BEGIN
    SELECT
        i.item_id,
        i.item_name,
        c.category_name,
        i.item_type,
        i.location,
        i.report_date,
        i.item_status,
        s.student_name AS reported_by,
        s.email AS reporter_email
    FROM Items i
    INNER JOIN Categories c ON i.category_id = c.category_id
    INNER JOIN Students s ON i.student_id = s.student_id
    WHERE c.category_name = p_category_name
    ORDER BY i.report_date DESC;
END //

-- Procedure 2: sp_GetStudentReportedItems
-- Retrieves all items reported by a specific student roll ID with claim counts.
CREATE PROCEDURE sp_GetStudentReportedItems(IN p_student_id INT)
BEGIN
    SELECT
        i.item_id,
        i.item_name,
        c.category_name,
        i.item_type,
        i.location,
        i.report_date,
        i.item_status,
        COUNT(cl.claim_id) AS total_claims_received
    FROM Items i
    INNER JOIN Categories c ON i.category_id = c.category_id
    LEFT JOIN Claims cl ON i.item_id = cl.item_id
    WHERE i.student_id = p_student_id
    GROUP BY i.item_id, i.item_name, c.category_name, i.item_type, i.location, i.report_date, i.item_status
    ORDER BY i.report_date DESC;
END //

-- Procedure 3: sp_ProcessClaimDecision
-- Transactional procedure to approve or reject a claim with validation.
CREATE PROCEDURE sp_ProcessClaimDecision(
    IN p_claim_id INT,
    IN p_decision VARCHAR(15)
)
BEGIN
    DECLARE v_item_id INT;
    DECLARE v_current_status VARCHAR(15);
    
    -- Validate decision input parameter
    IF p_decision NOT IN ('Approved', 'Rejected') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid decision parameter. Must be Approved or Rejected.';
    END IF;

    -- Retrieve target claim information
    SELECT item_id, claim_status
    INTO v_item_id, v_current_status
    FROM Claims
    WHERE claim_id = p_claim_id;

    IF v_item_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Claim ID does not exist.';
    END IF;

    IF v_current_status <> 'Pending' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot process claim: current status is not Pending.';
    END IF;

    -- Execute transactional status updates
    START TRANSACTION;
        UPDATE Claims
        SET claim_status = p_decision
        WHERE claim_id = p_claim_id;

        IF p_decision = 'Approved' THEN
            -- Update item status to Claimed
            UPDATE Items
            SET item_status = 'Claimed'
            WHERE item_id = v_item_id;

            -- Auto-reject any other pending claims for this specific item
            UPDATE Claims
            SET claim_status = 'Rejected'
            WHERE item_id = v_item_id
              AND claim_id <> p_claim_id
              AND claim_status = 'Pending';
        END IF;
    COMMIT;
    
    SELECT CONCAT('Claim #', p_claim_id, ' successfully marked as ', p_decision, '.') AS result_message;
END //

DELIMITER ;

-- 7. TRIGGERS FOR BUSINESS LOGIC ENFORCEMENT
DELIMITER //

-- Trigger 1: trg_prevent_invalid_claim
-- Ensures:
-- 1. A student cannot claim an item they themselves reported.
-- 2. No claims can be submitted against items that are already Claimed or Resolved.
CREATE TRIGGER trg_prevent_invalid_claim
BEFORE INSERT ON Claims
FOR EACH ROW
BEGIN
    DECLARE v_reporting_student_id INT;
    DECLARE v_item_status VARCHAR(20);

    SELECT student_id, item_status
    INTO v_reporting_student_id, v_item_status
    FROM Items
    WHERE item_id = NEW.item_id;

    -- Prevent self-claim
    IF v_reporting_student_id = NEW.student_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business Rule Violation: You cannot submit a claim for an item you reported.';
    END IF;

    -- Prevent claiming already resolved or claimed items
    IF v_item_status IN ('Claimed', 'Resolved', 'Returned') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business Rule Violation: This item is already claimed or resolved.';
    END IF;
END //

-- Trigger 2: trg_sync_item_status_on_approval
-- Synchronizes Items table status when a claim is approved via manual UPDATE statement.
CREATE TRIGGER trg_sync_item_status_on_approval
AFTER UPDATE ON Claims
FOR EACH ROW
BEGIN
    IF NEW.claim_status = 'Approved' AND OLD.claim_status <> 'Approved' THEN
        UPDATE Items
        SET item_status = 'Claimed'
        WHERE item_id = NEW.item_id;
    END IF;
END //

DELIMITER ;

-- 8. DEMONSTRATION SQL QUERIES (25 COMPREHENSIVE QUERIES)

-- CATEGORY B: DATA MANIPULATION (INSERT, SELECT, UPDATE, DELETE)

-- Query 01: Standard Table Select
-- Inspect all registered campus students
SELECT student_id, student_name, email, department, phone
FROM Students
ORDER BY student_id;

-- Query 02: Record Insertion Demonstration
-- Register a newly found set of laboratory safety goggles
INSERT INTO Items (item_id, item_name, category_id, description, item_type, location, report_date, item_status, student_id)
VALUES (219, 'UV Safety Goggles', 4, 'Clear polycarbonate safety eyewear left on lab bench 4', 'Found', 'Chemistry Lab 201', '2026-10-04', 'Reported', 106);

-- Query 03: Safe Record Update
-- Update contact phone number for a student
UPDATE Students
SET phone = '9876599999'
WHERE student_id = 112;

-- Query 04: Safe Record Deletion
-- Remove newly inserted test item (219)
DELETE FROM Items
WHERE item_id = 219;

-- CATEGORY C: SEARCH AND FILTERING (WHERE, AND/OR, LIKE, IN, BETWEEN, ORDER BY, DISTINCT)

-- Query 05: Filtering with WHERE and AND
-- Find all currently 'Reported' Lost items
SELECT item_id, item_name, location, report_date, item_status
FROM Items
WHERE item_type = 'Lost' AND item_status = 'Reported';

-- Query 06: Filtering with OR and Parentheses
-- Search items located either in Central Library or Cafeteria
SELECT item_id, item_name, item_type, location, report_date
FROM Items
WHERE location LIKE '%Library%' OR location LIKE '%Cafeteria%'
ORDER BY report_date DESC;

-- Query 07: Wildcard Pattern Matching with LIKE
-- Search for electronic items containing 'Apple', 'Dell', or 'Casio'
SELECT item_id, item_name, description, item_type, location
FROM Items
WHERE item_name LIKE '%Apple%'
   OR item_name LIKE '%Dell%'
   OR item_name LIKE '%Casio%';

-- Query 08: Membership Filtering with IN Operator
-- Find items belonging to specific categories (Electronics, Keys, Identification Cards)
SELECT item_id, item_name, category_id, location, report_date
FROM Items
WHERE category_id IN (1, 2, 6)
ORDER BY category_id, report_date;

-- Query 09: Range Filtering with BETWEEN
-- List all reports submitted during the third week of September 2026
SELECT item_id, item_name, item_type, location, report_date
FROM Items
WHERE report_date BETWEEN '2026-09-15' AND '2026-09-22'
ORDER BY report_date ASC;

-- Query 10: Eliminating Duplicate Values with DISTINCT
-- List distinct campus locations where items were lost or found
SELECT DISTINCT location
FROM Items
ORDER BY location ASC;

-- CATEGORY D: AGGREGATE FUNCTIONS & GROUPING (COUNT, SUM, MIN, MAX, GROUP BY, HAVING)

-- Query 11: System-wide KPI Aggregates
-- Total counts of students, categories, reported items, and filed claims
SELECT
    (SELECT COUNT(*) FROM Students) AS total_students,
    (SELECT COUNT(*) FROM Categories) AS total_categories,
    COUNT(item_id) AS total_items,
    MIN(report_date) AS earliest_report,
    MAX(report_date) AS latest_report
FROM Items;

-- Query 12: Aggregate Breakdown by Category with Conditional SUM
-- Distribution of Lost vs Found items per category
SELECT
    c.category_name,
    COUNT(i.item_id) AS total_items,
    SUM(CASE WHEN i.item_type = 'Lost' THEN 1 ELSE 0 END) AS lost_items_count,
    SUM(CASE WHEN i.item_type = 'Found' THEN 1 ELSE 0 END) AS found_items_count
FROM Categories c
LEFT JOIN Items i ON c.category_id = i.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_items DESC;

-- Query 13: Department-level Reporting Activity with HAVING Filter
-- Departments that have reported more than 1 item
SELECT
    s.department,
    COUNT(i.item_id) AS items_reported_count
FROM Students s
INNER JOIN Items i ON s.student_id = i.student_id
GROUP BY s.department
HAVING COUNT(i.item_id) > 1
ORDER BY items_reported_count DESC;

-- CATEGORY E: TABLE JOINS (INNER, LEFT, MULTI-TABLE JOINS)

-- Query 14: Two-Table INNER JOIN
-- Retrieve Items with Category Name and Reporter Name
SELECT
    i.item_id,
    i.item_name,
    c.category_name,
    i.item_type,
    i.location,
    s.student_name AS reported_by,
    s.department
FROM Items i
INNER JOIN Categories c ON i.category_id = c.category_id
INNER JOIN Students s ON i.student_id = s.student_id
ORDER BY i.item_id;

-- Query 15: LEFT OUTER JOIN
-- List all registered students and any items they reported (including students with 0 reports)
SELECT
    s.student_id,
    s.student_name,
    s.department,
    COUNT(i.item_id) AS total_reports_filed
FROM Students s
LEFT JOIN Items i ON s.student_id = i.student_id
GROUP BY s.student_id, s.student_name, s.department
ORDER BY total_reports_filed DESC, s.student_id ASC;

-- Query 16: Comprehensive 4-Table JOIN
-- Cross-examine claim records with item, category, claimant, and reporting student details
SELECT
    cl.claim_id,
    i.item_name,
    c.category_name,
    i.location AS item_location,
    finder.student_name AS reported_by,
    claimant.student_name AS claimed_by,
    cl.claim_date,
    cl.claim_status,
    cl.claim_reason
FROM Claims cl
INNER JOIN Items i ON cl.item_id = i.item_id
INNER JOIN Categories c ON i.category_id = c.category_id
INNER JOIN Students claimant ON cl.student_id = claimant.student_id
INNER JOIN Students finder ON i.student_id = finder.student_id
ORDER BY cl.claim_id ASC;

-- CATEGORY F: SUBQUERIES (SCALAR, IN, NOT IN, CORRELATED EXISTS)

-- Query 17: Subquery with IN
-- Find students who have submitted at least one claim
SELECT student_id, student_name, email, department
FROM Students
WHERE student_id IN (SELECT DISTINCT student_id FROM Claims)
ORDER BY student_id;

-- Query 18: Subquery with NOT IN
-- Find categories that currently have zero items reported
SELECT category_id, category_name
FROM Categories
WHERE category_id NOT IN (SELECT DISTINCT category_id FROM Items WHERE category_id IS NOT NULL);

-- Query 19: Correlated Subquery with EXISTS
-- Find all items that currently have pending claims awaiting administrative action
SELECT
    i.item_id,
    i.item_name,
    i.item_type,
    i.location,
    i.report_date
FROM Items i
WHERE EXISTS (
    SELECT 1
    FROM Claims cl
    WHERE cl.item_id = i.item_id
      AND cl.claim_status = 'Pending'
);

-- Query 20: Subquery in FROM Clause (Derived Table)
-- Calculate average claims received per claimed item
SELECT
    ROUND(AVG(claim_count), 2) AS avg_claims_per_claimed_item,
    MAX(claim_count) AS max_claims_for_single_item
FROM (
    SELECT item_id, COUNT(*) AS claim_count
    FROM Claims
    GROUP BY item_id
) AS item_claim_stats;

-- CATEGORY G: VIEWS DEMONSTRATION

-- Query 21: Querying View 1 (Lost Items)
SELECT item_id, item_name, category_name, lost_location, reported_by, contact_email
FROM vw_lost_items
ORDER BY report_date DESC;

-- Query 22: Querying View 3 (Pending Claims)
SELECT claim_id, item_name, category_name, claimant_name, claimant_department, claim_reason
FROM vw_pending_claims
ORDER BY claim_id ASC;

-- CATEGORY H: STORED PROCEDURES EXECUTION

-- Query 23: Execute Stored Procedure 1 (Search by Category)
CALL sp_SearchItemsByCategory('Electronics');

-- Query 24: Execute Stored Procedure 2 (Student Reports)
CALL sp_GetStudentReportedItems(106);

-- CATEGORY I: TRANSACTIONS & CONCURRENCY CONTROL (COMMIT & ROLLBACK)

-- Query 25: Transaction Demonstration 1 - Successful Atomic Approval (COMMIT)
-- Approve claim #303 for Item #205 and atomically update Item status
START TRANSACTION;
    -- Step 1: Update claim status to Approved
    UPDATE Claims
    SET claim_status = 'Approved'
    WHERE claim_id = 303;

    -- Step 2: Update item status to Claimed
    UPDATE Items
    SET item_status = 'Claimed'
    WHERE item_id = 205;
COMMIT;

-- Verify Transaction 1 result
SELECT cl.claim_id, cl.claim_status, i.item_id, i.item_status
FROM Claims cl
INNER JOIN Items i ON cl.item_id = i.item_id
WHERE cl.claim_id = 303;

-- Transaction Demonstration 2 - Atomic Rollback Scenario (ROLLBACK)
-- Simulate erroneous status assignment rolled back safely
START TRANSACTION;
    -- Erroneously set claim to Rejected
    UPDATE Claims
    SET claim_status = 'Rejected'
    WHERE claim_id = 304;

    -- System detects claimant submitted additional proof; rollback transaction
ROLLBACK;

-- Verify Transaction 2 rollback preserved original status
SELECT claim_id, claim_status
FROM Claims
WHERE claim_id = 304;


