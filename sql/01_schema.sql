-- Smart Government Grievance Management System
-- MySQL 8.0+
-- WARNING: This script drops and recreates the project database.

DROP DATABASE IF EXISTS GrievanceDB;
CREATE DATABASE GrievanceDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE GrievanceDB;

CREATE TABLE Citizens (
    citizen_id INT AUTO_INCREMENT PRIMARY KEY,
    citizen_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(80) NOT NULL,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    service_level_days INT NOT NULL DEFAULT 7,
    CHECK (service_level_days > 0)
) ENGINE=InnoDB;

CREATE TABLE Complaint_Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE Officers (
    officer_id INT AUTO_INCREMENT PRIMARY KEY,
    officer_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    email VARCHAR(150) UNIQUE,
    active TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_officer_department
      FOREIGN KEY (department_id) REFERENCES Departments(department_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    citizen_id INT NOT NULL,
    department_id INT NOT NULL,
    category_id INT NOT NULL,
    officer_id INT NULL,
    complaint_title VARCHAR(180) NOT NULL,
    complaint_description TEXT,
    priority ENUM('Low','Medium','High','Critical') NOT NULL DEFAULT 'Medium',
    status ENUM('Pending','In Progress','Resolved','Rejected') NOT NULL DEFAULT 'Pending',
    complaint_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolution_date DATETIME NULL,
    CONSTRAINT fk_complaint_citizen
      FOREIGN KEY (citizen_id) REFERENCES Citizens(citizen_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_complaint_department
      FOREIGN KEY (department_id) REFERENCES Departments(department_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_complaint_category
      FOREIGN KEY (category_id) REFERENCES Complaint_Categories(category_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_complaint_officer
      FOREIGN KEY (officer_id) REFERENCES Officers(officer_id)
      ON UPDATE CASCADE ON DELETE SET NULL,
    CHECK (resolution_date IS NULL OR resolution_date >= complaint_date),
    CHECK ((status <> 'Resolved') OR resolution_date IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE Status_History (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    old_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100) NOT NULL DEFAULT 'system',
    note VARCHAR(255),
    CONSTRAINT fk_history_complaint
      FOREIGN KEY (complaint_id) REFERENCES Complaints(complaint_id)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL UNIQUE,
    rating TINYINT NOT NULL,
    comments VARCHAR(500),
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_complaint
      FOREIGN KEY (complaint_id) REFERENCES Complaints(complaint_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;
