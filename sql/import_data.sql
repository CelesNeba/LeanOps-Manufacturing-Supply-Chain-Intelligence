-- Pipline component: 1 Database creation
-- Project target: Manufacturing and operations analytics environment
-- Standard enforced: Relational integrity, strict data typing and not null drive
-- =======================================================================================================

-- 1. Initialize the analytical core database container
CREATE DATABASE IF NOT EXISTS manufacturing_analytics_db;
USE manufacturing_analytics_db;

-- 2 Reset trace path by purching pre-existing stsructural conflicts
DROP TABLE IF EXISTS factory_telemetry_logs;

-- 3 Construct structure enforcing explicit relational data fields
CREATE TABLE factory_telemetry_logs (
    -- Primary Surrogate Key to uniquely identify and audit every individual run
    Run_ID INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Ingested Base Features from Python Processing Engine
    ProductionVolume INT NOT NULL,
    ProductionCost DECIMAL(12, 2) NOT NULL,
    SupplierQuality DECIMAL(5, 2) NOT NULL,
    DeliveryDelay INT NOT NULL,
    DefectRate DECIMAL(5, 2) NOT NULL,
    QualityScore DECIMAL(5, 2) NOT NULL,
    MaintenanceHours INT NOT NULL,
    DowntimePercentage DECIMAL(6, 5) NOT NULL,
    InventoryTurnover DECIMAL(5, 2) NOT NULL,
    StockoutRate DECIMAL(6, 5) NOT NULL,
    WorkerProductivity DECIMAL(5, 2) NOT NULL,
    SafetyIncidents INT NOT NULL,
    EnergyConsumption DECIMAL(12, 2) NOT NULL,
    EnergyEfficiency DECIMAL(6, 5) NOT NULL,
    AdditiveProcessTime DECIMAL(8, 2) NOT NULL,
    AdditiveMaterialCost DECIMAL(10, 2) NOT NULL,
    DefectStatus TINYINT(1) NOT NULL, -- Strict binary logic constraint (0 = Compliant, 1 = Out of Compliance)
    
    -- Ingested Engineered Metrics synthesized in Phase 2 Data Pipeline
    EnergyUtilizationIntensity DECIMAL(10, 5) NOT NULL,
    SupplierRiskMultiplier DECIMAL(8, 2) NOT NULL,
    AssetAvailability DECIMAL(6, 5) NOT NULL,
    LaborThroughputRatio DECIMAL(10, 2) NOT NULL,
    
    -- Database Auditing Timestamps for standard enterprise tracing
    Record_Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. VERIFY SCRIPT INTERFACE EXECUTION FOOTPRINT
SHOW TABLES;
DESCRIBE factory_telemetry_logs;
-- ===========================================================================================================

-- BUSINESS QUESTION 2: MACHINE ENERGY UTILIZATION EFFICIENCY AND RISK TIERS
-- Objective: Isolate equipment running under heavy mechanical drag.
-- Technique: NTILE() Window Function to split runs into 5 distinct energy-burn zones.

WITH RankedSupplierBatches AS (
    SELECT 
        Run_ID,
        SupplierQuality,
        DeliveryDelay,
        SupplierRiskMultiplier,
        DefectRate,
        DefectStatus,
        RANK() OVER (ORDER BY SupplierRiskMultiplier DESC) AS Supply_Risk_Rank
    FROM factory_telemetry_logs
)
SELECT 
    CASE 
        WHEN Supply_Risk_Rank <= 300 THEN 'SEVERE RISK BATCHES (Top 300)'
        WHEN Supply_Risk_Rank <= 1000 THEN 'MODERATE RISK VOLATILITY'
        ELSE 'COMPLIANT/STABLE BATCHES'
    END AS 'Vendor_Risk_Classification_Tier',
    COUNT(*) AS 'Total_Monitored_Batches',
    ROUND(AVG(SupplierQuality), 2) AS 'Avg_Raw_Material_Quality_Score',
    ROUND(AVG(DeliveryDelay), 1) AS 'Avg_Logistics_Delay_Days',
    ROUND(AVG(SupplierRiskMultiplier), 2) AS 'Avg_Composite_Risk_Index',
    ROUND(AVG(DefectRate), 2) AS 'Avg_Factory_Floor_Defect_Rate',
    SUM(DefectStatus) AS 'Total_Failed_Batches',
    ROUND((SUM(DefectStatus) / COUNT(*)) * 100, 2) AS 'Batch_Rejection_Rate_Pct'
FROM RankedSupplierBatches
GROUP BY 
    CASE 
        WHEN Supply_Risk_Rank <= 300 THEN 'SEVERE RISK BATCHES (Top 300)'
        WHEN Supply_Risk_Rank <= 1000 THEN 'MODERATE RISK VOLATILITY'
        ELSE 'COMPLIANT/STABLE BATCHES'
    END
ORDER BY AVG(SupplierRiskMultiplier) DESC;




-- ==============================================================================
-- PIPELINE COMPONENT: 2. IMPORT_DATA.SQL
-- PROJECT TARGET: MANUFACTURING DATA INGESTION UTILITY LOG
-- STANDARDS ENFORCED: DATA LINEAGE RECORDING & AUDIT TRAILS
-- ==============================================================================

USE manufacturing_analytics_db;

-- [PORTFOLIO NOTE]: This log reflects the data pipeline intake mapping 
-- executed via the Python SQLAlchemy engine to seamlessly stream records 
-- and bypass standard OS secure-file-priv permission restrictions.

/*
import sqlalchemy
engine = sqlalchemy.create_engine("mysql+pymysql://root:***@localhost:3306/manufacturing_analytics_db")
check_df.to_sql(name='factory_telemetry_logs', con=engine, if_exists='replace', index=False)
*/

-- VERIFY WAREHOUSE BULK LOAD INTEGRITY AND TALLY TOTAL RUNS REGISTERED
SELECT COUNT(*) AS Total_Stored_Records FROM factory_telemetry_logs;

-- PREVIEW THE TOP THREE ARCHIVED INDUSTRIAL TELEMETRY DATA ROWS
SELECT * FROM factory_telemetry_logs LIMIT 3;


