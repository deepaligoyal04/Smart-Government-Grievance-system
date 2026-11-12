USE GrievanceDB;

-- Indexes for common filtering and join patterns
CREATE INDEX idx_complaints_status_date
    ON Complaints(status, complaint_date);
CREATE INDEX idx_complaints_department_priority
    ON Complaints(department_id, priority);
CREATE INDEX idx_complaints_citizen
    ON Complaints(citizen_id);
CREATE INDEX idx_history_complaint_changed
    ON Status_History(complaint_id, changed_at);

-- View: detailed complaint register
CREATE OR REPLACE VIEW vw_complaint_register AS
SELECT
    c.complaint_id,
    ci.citizen_name,
    ci.city,
    d.department_name,
    cc.category_name,
    o.officer_name,
    c.complaint_title,
    c.priority,
    c.status,
    c.complaint_date,
    c.resolution_date,
    CASE
      WHEN c.resolution_date IS NOT NULL
      THEN DATEDIFF(c.resolution_date, c.complaint_date)
      ELSE NULL
    END AS resolution_days
FROM Complaints c
JOIN Citizens ci ON ci.citizen_id = c.citizen_id
JOIN Departments d ON d.department_id = c.department_id
JOIN Complaint_Categories cc ON cc.category_id = c.category_id
LEFT JOIN Officers o ON o.officer_id = c.officer_id;

-- View: open complaints
CREATE OR REPLACE VIEW vw_open_complaints AS
SELECT *
FROM vw_complaint_register
WHERE status IN ('Pending', 'In Progress');

-- Trigger: automatically record every status change
DELIMITER //
CREATE TRIGGER trg_complaint_status_history
AFTER UPDATE ON Complaints
FOR EACH ROW
BEGIN
    IF NOT (OLD.status <=> NEW.status) THEN
        INSERT INTO Status_History
            (complaint_id, old_status, new_status, changed_by, note)
        VALUES
            (NEW.complaint_id, OLD.status, NEW.status,
             CURRENT_USER(), 'Status changed through database update');
    END IF;
END //
DELIMITER ;

-- Procedure: assign an officer only if they belong to the same department
DELIMITER //
CREATE PROCEDURE sp_assign_officer(
    IN p_complaint_id INT,
    IN p_officer_id INT
)
BEGIN
    DECLARE v_complaint_dept INT;
    DECLARE v_officer_dept INT;

    SELECT department_id INTO v_complaint_dept
    FROM Complaints
    WHERE complaint_id = p_complaint_id;

    SELECT department_id INTO v_officer_dept
    FROM Officers
    WHERE officer_id = p_officer_id AND active = 1;

    IF v_complaint_dept IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Complaint not found';
    ELSEIF v_officer_dept IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Active officer not found';
    ELSEIF v_complaint_dept <> v_officer_dept THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Officer does not belong to complaint department';
    ELSE
        UPDATE Complaints
        SET officer_id = p_officer_id
        WHERE complaint_id = p_complaint_id;
    END IF;
END //
DELIMITER ;

-- Procedure: update complaint status with resolution-date handling
DELIMITER //
CREATE PROCEDURE sp_update_complaint_status(
    IN p_complaint_id INT,
    IN p_new_status VARCHAR(30)
)
BEGIN
    IF p_new_status NOT IN ('Pending','In Progress','Resolved','Rejected') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid complaint status';
    END IF;

    UPDATE Complaints
    SET status = p_new_status,
        resolution_date = CASE
            WHEN p_new_status = 'Resolved' THEN CURRENT_TIMESTAMP
            ELSE NULL
        END
    WHERE complaint_id = p_complaint_id;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Complaint not found or no change made';
    END IF;
END //
DELIMITER ;

-- Procedure: department performance summary
DELIMITER //
CREATE PROCEDURE sp_department_summary()
BEGIN
    SELECT
        d.department_name,
        COUNT(c.complaint_id) AS total_complaints,
        SUM(c.status = 'Resolved') AS resolved_complaints,
        SUM(c.status IN ('Pending','In Progress')) AS open_complaints,
        ROUND(
          100.0 * SUM(c.status = 'Resolved') / NULLIF(COUNT(c.complaint_id),0),
          2
        ) AS resolution_rate_pct
    FROM Departments d
    LEFT JOIN Complaints c
      ON c.department_id = d.department_id
    GROUP BY d.department_id, d.department_name
    ORDER BY total_complaints DESC;
END //
DELIMITER ;

-- Example calls (uncomment to test individually)
-- CALL sp_assign_officer(1, 1);
-- CALL sp_update_complaint_status(1, 'In Progress');
-- CALL sp_department_summary();
