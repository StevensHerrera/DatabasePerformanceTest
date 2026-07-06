-- =====================================================================
-- TechCare Solutions Riwi S.A.S. - DML Operations
-- =====================================================================
USE bd_steven_herrera_cumbia;

-- ---------------------------------------------------------------------
-- INSERTION: register a new client along with a service order
-- ---------------------------------------------------------------------
START TRANSACTION;

INSERT INTO riwi_client (client_name, id_riwi_branch)
VALUES ('FarmaCenter', 2); -- branch: Headquarters (Medellin)

INSERT INTO riwi_work_order (order_code, service_date, hours, cost,
                              id_riwi_technician, id_riwi_client,
                              id_riwi_equipment, id_riwi_service_type)
VALUES ('WO1021', CURDATE(), 5, 510,
        1,                              -- techncian: Juan Perez
        LAST_INSERT_ID(),               -- client: recien creado
        1,                              -- equipment: Dell Latitude 5420
        1);                             -- service: Preventive Maintenance

COMMIT;

-- Verification
SELECT c.id_riwi_client, c.client_name, wo.order_code, wo.service_date
FROM riwi_client c
JOIN riwi_work_order wo ON wo.id_riwi_client = c.id_riwi_client
WHERE c.client_name = 'FarmaCenter';

-- ---------------------------------------------------------------------
-- UPDATE: Update information for an existing technician.
-- ---------------------------------------------------------------------
UPDATE riwi_technician
SET technician_name = 'Juan Perez Gomez'
WHERE id_riwi_technician = 1;

SELECT * FROM riwi_technician WHERE id_riwi_technician = 1;

-- ---------------------------------------------------------------------
-- DELETION: delete a piece of equipment that has NO associated
-- service orders. The FK constraint (ON DELETE RESTRICT) prevents the deletion
-- of equipment that does have associated orders, thereby protecting integrity.
-- ---------------------------------------------------------------------

-- Step 1: Identify equipment with no associated orders.
SELECT e.id_riwi_equipment, e.equipment_name
FROM riwi_equipment e
LEFT JOIN riwi_work_order wo ON wo.id_riwi_equipment = e.id_riwi_equipment
WHERE wo.id_riwi_work_order IS NULL;

-- Step 2: Insert a test record with no associated orders to demonstrate
-- that deletion proceeds correctly when there are no dependencies.
INSERT INTO riwi_equipment (equipment_name, id_riwi_equipment_category)
VALUES ('Epson L3250 (equipo de prueba)', 4);

-- Step 3: Delete the equipment with no associated orders (works)
DELETE FROM riwi_equipment
WHERE equipment_name = 'Epson L3250 (equipo de prueba)';

-- Step 4 (integrity demonstration): Attempt to delete a piece of equipment
-- WITH associated orders should fail due to the foreign key restriction
-- (error 1451 - Cannot delete or update a parent row).
-- DELETE FROM riwi_equipment WHERE id_riwi_equipment = 1;
--> Expected error: ROW is referenced from `riwi_work_order`
