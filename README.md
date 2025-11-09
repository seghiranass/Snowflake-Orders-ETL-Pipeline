# ELT Pipeline Project (dbt, Snowflake, Airflow)

This repository contains the code for building a modern Extract, Load, Transform (ELT) data pipeline from scratch, using **dbt** for data transformation, **Snowflake** as the cloud data warehouse, and **Apache Airflow** (via **Astronomer Cosmos**) for orchestration.

The project uses the free `TPCH` sample dataset provided by Snowflake to demonstrate setting up a data environment, implementing data modeling techniques (staging, marts, fact tables), creating reusable code (macros), and setting up robust data quality tests.

---

## 🚀 Technologies

* **Data Warehouse:** [Snowflake](https://www.snowflake.com/)
* **Transformation:** [dbt™ Core (data build tool)](https://www.getdbt.com/)
* **Orchestration:** [Apache Airflow](https://airflow.apache.org/) (using [Astronomer Cosmos](https://cosmos.docs.astronomer.io/) for dbt integration)
* **Data Source:** Snowflake Sample Data (`TPCH` dataset)

---

## ✨ Features

* **Snowflake Environment Setup:** Configuration of dedicated Warehouse, Database, Schema, and Role using Role-Based Access Control (RBAC).
* **dbt Project Structure:** Organized transformation logic into `staging` (views) and `marts` (tables) layers.
* **Data Modeling:** Implementation of basic dimensional modeling, including fact tables (`fct_orders`) leveraging surrogate keys.
* **Reusable Code:** Creation of dbt Macros for templating business logic (e.g., calculating discounted amounts).
* **Data Quality Testing:** Includes both **Generic Tests** (uniqueness, not-null, relationships, accepted values) and **Singular Tests** (custom SQL checks for business logic).
* **Airflow Orchestration:** Deployment and scheduling of the entire dbt project as an Airflow DAG using the `cosmos` library.

---

## ⚙️ Prerequisites

Before getting started, ensure you have the following accounts and tools set up:

1.  **Snowflake Account:** A personal or trial account is sufficient.
2.  **dbt Core:** Installed locally.
    ```bash
    pip install dbt-core dbt-snowflake
    ```
3.  **Astro CLI:** For local development and running Airflow.
    ```bash
    # Install Astro CLI (requires Homebrew on macOS/Linux)
    brew install astro
    ```
4.  **Virtual Environment (Recommended):** To manage dependencies.

---

## 🛠️ Project Setup

### 1. Snowflake Environment Configuration

Using your Snowflake worksheet (as shown in the video):

1.  **Create Resources:** Use `ACCOUNTADMIN` role to set up the necessary components.

    ```sql
    -- 1. Create Warehouse, Database, and Role
    CREATE WAREHOUSE DBT_WAREHOUSE WITH WAREHOUSE_SIZE = 'XSMALL';
    CREATE DATABASE DBT_DB;
    CREATE ROLE DBT_ROLL;

    -- 2. Grant privileges to the new role
    GRANT USAGE ON WAREHOUSE DBT_WAREHOUSE TO ROLE DBT_ROLL;
    GRANT ALL ON DATABASE DBT_DB TO ROLE DBT_ROLL;

    -- 3. Assign the role to your user (Replace `YOUR_USER` with your actual username)
    GRANT ROLE DBT_ROLL TO USER YOUR_USER;

    -- 4. Switch to the new role and create a schema
    USE ROLE DBT_ROLL;
    CREATE SCHEMA DBT_DB.DBT_SCHEMA;
    ```
2.  **Clean up (Optional):** If you need to re-run the setup or drop resources to avoid cost.

    ```sql
    USE ROLE ACCOUNTADMIN;
    DROP WAREHOUSE IF EXISTS DBT_WAREHOUSE;
    DROP DATABASE IF EXISTS DBT_DB;
    DROP ROLE IF EXISTS DBT_ROLL;
    ```

### 2. dbt Project Initialization and Profile

1.  **Initialize the dbt project:**
    ```bash
    dbt init data_pipeline
    cd data_pipeline
    ```
2.  **Configure dbt Profile:** Select `snowflake` and enter the connection details matching the resources created above:

| Setting | Value |
| :--- | :--- |
| **Account** | Your Snowflake Account Locator |
| **User** | Your Snowflake Username |
| **Password** | Your Snowflake Password |
| **Role** | `DBT_ROLL` |
| **Warehouse** | `DBT_WAREHOUSE` |
| **Database** | `DBT_DB` |
| **Schema** | `DBT_SCHEMA` |
| **Threads** | `10` (or desired value) |

3.  **Install dbt Packages:** This project uses `dbt-utils`.

    * Create `packages.yml` in the root directory.
        ```yaml
        packages:
          - package: dbt-labs/dbt_utils
            version: [latest version used]
        ```
    * Run:
        ```bash
        dbt deps
        ```
4.  **Run dbt Models:**
    ```bash
    dbt run
    dbt test
    ```

### 3. Airflow Orchestration (Using Astro CLI)

1.  **Initialize Astro Project:** This sets up a local Airflow environment.
    ```bash
    # In a separate directory (e.g., outside of the dbt project)
    mkdir dbt_dag
    cd dbt_dag
    astro dev init
    ```
2.  **Add Dependencies:** Update `requirements.txt` to include the necessary libraries:
    ```
    apache-airflow-providers-snowflake
    astronomer-cosmos
    ```
3.  **Update Dockerfile:** Add dbt-snowflake to the environment. Add this to your `Dockerfile`:
    ```dockerfile
    # Install dbt-snowflake adapter
    RUN pip install dbt-snowflake
    ```
4.  **Move dbt Project:** Copy your `data_pipeline` dbt project into the Airflow `dags` folder and define your DAG file using `cosmos` to reference the project.
5.  **Start Airflow:**
    ```bash
    astro dev start
    ```
6.  **Configure Airflow Connection:** Access the Airflow UI (`localhost:8080`), go to **Admin** > **Connections**, and create a new **Snowflake** connection named `snowflake_con` with the same credentials used in the dbt profile.
7.  **Run the DAG:** The dbt models will be visualized and runnable as a standard Airflow DAG.
