-- =====================================================================
-- TechCare Solutions Riwi S.A.S. - Querys SQL
-- =====================================================================
USE bd_steven_herrera_cumbia;

-- ---------------------------------------------------------------------
-- Query 1: Number of orders handled per technician
-- Requirement: Support coordinator wants to distribute the workload
-- among technicians.
-- ---------------------------------------------------------------------
SELECT
    t.id_riwi_technician,
    t.technician_name,
    COUNT(wo.id_riwi_work_order) AS total_orders
FROM riwi_technician t
LEFT JOIN riwi_work_order wo ON wo.id_riwi_technician = t.id_riwi_technician
GROUP BY t.id_riwi_technician, t.technician_name
ORDER BY total_orders DESC;

-- ---------------------------------------------------------------------
-- Query 2: Service history by city
-- Need: Regional manager wants to know in which cities the
-- highest number of technical services are performed.
-- ---------------------------------------------------------------------
SELECT
    ct.city_name,
    COUNT(wo.id_riwi_work_order) AS total_services
FROM riwi_city ct
JOIN riwi_branch b ON b.id_riwi_city = ct.id_riwi_city
JOIN riwi_client c ON c.id_riwi_branch = b.id_riwi_branch
JOIN riwi_work_order wo ON wo.id_riwi_client = c.id_riwi_client
GROUP BY ct.city_name
ORDER BY total_services DESC;

-- ---------------------------------------------------------------------
-- Query 3: Total services performed by service type
-- Need: The operations director wants to identify the services
-- most requested by clients.
-- ---------------------------------------------------------------------
SELECT
    st.service_type_name,
    COUNT(wo.id_riwi_work_order) AS total_orders,
    SUM(wo.cost) AS total_cost
FROM riwi_service_type st
LEFT JOIN riwi_work_order wo ON wo.id_riwi_service_type = st.id_riwi_service_type
GROUP BY st.service_type_name
ORDER BY total_orders DESC;

-- ---------------------------------------------------------------------
-- Query 4: Equipment with the highest number of maintenance interventions
-- Need: A support analyst wants to identify the equipment requiring
-- the most frequent technical attention.
-- ---------------------------------------------------------------------
SELECT
    e.equipment_name,
    ec.category_name,
    COUNT(wo.id_riwi_work_order) AS total_maintenances
FROM riwi_equipment e
JOIN riwi_equipment_category ec ON ec.id_riwi_equipment_category = e.id_riwi_equipment_category
LEFT JOIN riwi_work_order wo ON wo.id_riwi_equipment = e.id_riwi_equipment
GROUP BY e.equipment_name, ec.category_name
ORDER BY total_maintenances DESC;

-- ---------------------------------------------------------------------
-- Query 5: Clients with the highest number of service orders
-- Need: The commercial director wants to identify clients with
-- the highest demand in order to strengthen customer loyalty strategies.
-- ---------------------------------------------------------------------
SELECT
    c.client_name,
    COUNT(wo.id_riwi_work_order) AS total_orders
FROM riwi_client c
LEFT JOIN riwi_work_order wo ON wo.id_riwi_client = c.id_riwi_client
GROUP BY c.client_name
ORDER BY total_orders DESC;

-- ---------------------------------------------------------------------
-- Query 6: Number of orders managed by location
-- Need: The operations manager wants to know which locations have
-- the highest operational workload in order to plan resources and staffing.
-- ---------------------------------------------------------------------
SELECT
    b.branch_name,
    ct.city_name,
    COUNT(wo.id_riwi_work_order) AS total_orders
FROM riwi_branch b
JOIN riwi_city ct ON ct.id_riwi_city = b.id_riwi_city
LEFT JOIN riwi_client c ON c.id_riwi_branch = b.id_riwi_branch
LEFT JOIN riwi_work_order wo ON wo.id_riwi_client = c.id_riwi_client
GROUP BY b.branch_name, ct.city_name
ORDER BY total_orders DESC;
