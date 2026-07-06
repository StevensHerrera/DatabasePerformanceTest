# TechCare Solutions Riwi S.A.S. — Relational Database Project

**Developer:** Steven Herrera
**Clan:** Cumbia
**Database name:** `bd_steven_herrera_cumbia`

## Project description

TechCare Solutions Riwi S.A.S. provides preventive and corrective maintenance
This project analyzes the original Excel file, applies 1NF/2NF/3NF
normalization, designs an Entity-Relationship Model, and implements a fully
normalized relational database in MySQL, including data loading, DML
operations and business intelligence queries.

## Technologies used

- MySQL 8 / MariaDB 10.11 (compatible SQL, InnoDB engine)
- Graphviz + DBML (`dbdiagram.io`) for the ER diagram
- Python (pandas/openpyxl) used only to analyze the source Excel and
  generate the data-load script

## Normalization process

**1NF (atomicity, no repeating groups):**
Every attribute already held a single value per row and there were no
repeating groups, so the data satisfied 1NF once each concept (city,
branch, client, technician, equipment, category, service type, work order)
was represented in its own table with an atomic value per column.

**2NF (no partial dependency on a composite key):**
All tables use a single-column surrogate primary key (`id_riwi_*`), so there
are no composite keys and therefore no partial-dependency violations.
Attributes such as `category_name` were kept out of `riwi_equipment` and
moved into their own `riwi_equipment_category` table, since the category
name only depends on the category, not on each individual equipment row.

**3NF (no transitive dependency):**
- `branch_name` depends on the branch itself, not on the client, so a
  `riwi_branch` table (populated from the `Hoja1` sheet) references
  `riwi_city` by `id_riwi_city` — this removes the transitive dependency
  `client -> branch -> city` that would exist if the branch/city names were
  stored directly next to the client.
- `service_type_name` and `category_name` were extracted into their own
  catalog tables for the same reason (they don't depend on the work order or
  the equipment row itself, only on the type/category they represent).
- In `riwi_work_order`, the city/branch of a service is now obtained
  transitively through `riwi_client -> riwi_branch -> riwi_city`, instead of
  being duplicated as a column in the work order. This guarantees that every
  non-key attribute depends only on the primary key of its own table.

## Database engine

MySQL (InnoDB storage engine, `utf8mb4` charset). All scripts were validated
end-to-end against a local MariaDB 10.11 instance (MySQL wire-compatible).

## Data loading strategy (justification)

The original `riwi_work_order` sheet only linked each order to a technician.
To demonstrate that the 3NF model is fully viable and that referential
integrity holds across every relationship required by the business (client,technician, equipment, service type, branch/city)

## Database structure

| Table | Purpose | Key constraints |
|---|---|---|
| `riwi_city` | Unique catalog of cities |
| `riwi_branch` | Service branches, each tied to one city |
| `riwi_client` | Clients, each served by one branch |
| `riwi_technician` | Technicians |
| `riwi_service_type` | Catalog of service types |
| `riwi_equipment_category` | Catalog of equipment categories | 
| `riwi_equipment` | Equipment, each tied to one category 
| `riwi_work_order` | Service orders (fact table)

All foreign keys use `ON DELETE RESTRICT` so that a parent record (city,
branch, client, technician, equipment, category, service type) cannot be
deleted while a work order or other dependent record still references it —
this is what makes the required "delete an equipment with no associated
orders" rule enforceable at the database level (see
`dml/03_dml_operations.sql`).

## Entity Relationship Diagram

- `erd/riwi_erd.png` / `erd/riwi_erd.pdf` — rendered diagram
- `erd/riwi_erd.dbml` — source in DBML format

## Database creation instructions

```bash
mysql -u root -p < ddl/01_ddl_bd_steven_herrera_cumbia.sql
```

This creates the database `bd_steven_herrera_cumbia` and all 8 tables with
their primary keys, foreign keys, `NOT NULL`, `UNIQUE` and `CHECK`
constraints.

## Data loading instructions

```bash
mysql -u root -p < data/02_data_load_bd_steven_herrera_cumbia.sql
```

Loads all catalog data and the 20 work orders described in section 6.

## DML scripts

```bash
mysql -u root -p < dml/03_dml_operations.sql
```

Contains:
- **Insert:** a new client together with a new service order (wrapped in a
  transaction, using `LAST_INSERT_ID()` to link them).
- **Update:** update of an existing technician's data.
- **Delete:** deletion of an equipment with no associated orders, plus a
  commented-out example showing the `ON DELETE RESTRICT` protection that
  blocks deleting an equipment that still has orders (evidence in
  `evidence/evidence_fk_restriction.txt`).

## Business queries (`queries/04_business_queries.sql`)

1. **Orders per technician** — supports workload balancing across the team.
2. **Service history by city** — shows which cities generate the most
   technical services.
3. **Total services by service type** — identifies the most requested
   service types and their total cost.
4. **Equipment with the most maintenances** — highlights equipment requiring
   the most technical attention.
5. **Clients with the most service orders** — supports loyalty/retention
   strategy for high-demand clients.
6. **Orders managed per branch** — shows operational load per branch to help
   plan staff and resources.

All six queries were executed successfully against the loaded data.


## Repository structure

```
├── README.md
├── Dataset_TechCareSolutions_jonada_intermedia.xlsx   (original file)
├── ddl/01_ddl_bd_steven_herrera_cumbia.sql
├── data/02_data_load_bd_steven_herrera_cumbia.sql
├── dml/03_dml_operations.sql
├── queries/04_business_queries.sql
├── erd/riwi_erd.dbml
├── erd/riwi_erd.png
├── erd/riwi_erd.pdf
```

## Developer information

- **Full name:** Steven Herrera
- **Clan:** Cumbia
