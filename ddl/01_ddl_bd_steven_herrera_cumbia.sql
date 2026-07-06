-- =====================================================================
-- TechCare Solutions Riwi S.A.S.
-- Script DDL - database relacional (3FN) - MySQL
-- Database: bd_steven_herrera_cumbia
-- Autor: Steven Herrera - Clan Cumbia
-- =====================================================================

DROP DATABASE IF EXISTS bd_steven_herrera_cumbia;
CREATE DATABASE bd_steven_herrera_cumbia
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bd_steven_herrera_cumbia;

-- ---------------------------------------------------------------------
-- 1. riwi_city : create table with the city in ours database
-- ---------------------------------------------------------------------
CREATE TABLE riwi_city (
    id_riwi_city    INT AUTO_INCREMENT PRIMARY KEY,
    city_name       VARCHAR(80) NOT NULL,
    CONSTRAINT uq_riwi_city_name UNIQUE (city_name)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. riwi_branch : service locations, each location belongs to a city
-- ---------------------------------------------------------------------
CREATE TABLE riwi_branch (
    id_riwi_branch  INT AUTO_INCREMENT PRIMARY KEY,
    branch_name     VARCHAR(100) NOT NULL,
    id_riwi_city    INT NOT NULL,
    CONSTRAINT uq_riwi_branch_name UNIQUE (branch_name),
    CONSTRAINT fk_branch_city FOREIGN KEY (id_riwi_city)
        REFERENCES riwi_city (id_riwi_city)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. riwi_client : clients; each client is served by a branch
--    (name uniqueness to avoid duplicate clients)
-- ---------------------------------------------------------------------
CREATE TABLE riwi_client (
    id_riwi_client  INT AUTO_INCREMENT PRIMARY KEY,
    client_name     VARCHAR(120) NOT NULL,
    id_riwi_branch  INT NOT NULL,
    CONSTRAINT uq_riwi_client_name UNIQUE (client_name),
    CONSTRAINT fk_client_branch FOREIGN KEY (id_riwi_branch)
        REFERENCES riwi_branch (id_riwi_branch)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. riwi_technician : technical (unique names to avoid
--    technical entries being registered multiple times)
-- ---------------------------------------------------------------------
CREATE TABLE riwi_technician (
    id_riwi_technician  INT AUTO_INCREMENT PRIMARY KEY,
    technician_name     VARCHAR(120) NOT NULL,
    CONSTRAINT uq_riwi_technician_name UNIQUE (technician_name)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. riwi_service_type : catalog of service types
-- ---------------------------------------------------------------------
CREATE TABLE riwi_service_type (
    id_riwi_service_type  INT AUTO_INCREMENT PRIMARY KEY,
    service_type_name     VARCHAR(80) NOT NULL,
    CONSTRAINT uq_riwi_service_type_name UNIQUE (service_type_name)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. riwi_equipment_category : Equipment category catalog
-- ---------------------------------------------------------------------
CREATE TABLE riwi_equipment_category (
    id_riwi_equipment_category  INT AUTO_INCREMENT PRIMARY KEY,
    category_name               VARCHAR(80) NOT NULL,
    CONSTRAINT uq_riwi_category_name UNIQUE (category_name)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. riwi_equipment : equipment serviced; each piece of equipment belongs to
--    a category
-- ---------------------------------------------------------------------
CREATE TABLE riwi_equipment (
    id_riwi_equipment            INT AUTO_INCREMENT PRIMARY KEY,
    equipment_name               VARCHAR(120) NOT NULL,
    id_riwi_equipment_category   INT NOT NULL,
    CONSTRAINT uq_riwi_equipment_name UNIQUE (equipment_name),
    CONSTRAINT fk_equipment_category FOREIGN KEY (id_riwi_equipment_category)
        REFERENCES riwi_equipment_category (id_riwi_equipment_category)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. riwi_work_order : service orders (transactional table /
--    fact table). Links technician, client, equipment, and type of
--    service. The branch/city is derived transitively via
--    the client (riwi_client -> riwi_branch -> riwi_city), avoiding
--    redundancy and ensuring 3NF (no non-key attribute depends
--    on another non-key attribute).
-- ---------------------------------------------------------------------
CREATE TABLE riwi_work_order (
    id_riwi_work_order    INT AUTO_INCREMENT PRIMARY KEY,
    order_code            VARCHAR(20) NOT NULL,
    service_date          DATE NOT NULL,
    hours                 DECIMAL(5,2) NOT NULL,
    cost                  DECIMAL(10,2) NOT NULL,
    id_riwi_technician     INT NOT NULL,
    id_riwi_client         INT NOT NULL,
    id_riwi_equipment      INT NOT NULL,
    id_riwi_service_type   INT NOT NULL,
    CONSTRAINT uq_riwi_order_code UNIQUE (order_code),
    CONSTRAINT chk_hours_positive CHECK (hours > 0),
    CONSTRAINT chk_cost_positive CHECK (cost >= 0),
    CONSTRAINT fk_order_technician FOREIGN KEY (id_riwi_technician)
        REFERENCES riwi_technician (id_riwi_technician)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_client FOREIGN KEY (id_riwi_client)
        REFERENCES riwi_client (id_riwi_client)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_equipment FOREIGN KEY (id_riwi_equipment)
        REFERENCES riwi_equipment (id_riwi_equipment)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_service_type FOREIGN KEY (id_riwi_service_type)
        REFERENCES riwi_service_type (id_riwi_service_type)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Support indexes for business queries (joins / grouping)
CREATE INDEX idx_wo_technician ON riwi_work_order (id_riwi_technician);
CREATE INDEX idx_wo_client ON riwi_work_order (id_riwi_client);
CREATE INDEX idx_wo_equipment ON riwi_work_order (id_riwi_equipment);
CREATE INDEX idx_wo_service_type ON riwi_work_order (id_riwi_service_type);
CREATE INDEX idx_branch_city ON riwi_branch (id_riwi_city);
CREATE INDEX idx_client_branch ON riwi_client (id_riwi_branch);
