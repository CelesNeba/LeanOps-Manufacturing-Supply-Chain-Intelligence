USE manufacturing_analytics_db;

--  VIEW 1: OPERATIONS DASHBOARD LAYER
CREATE OR REPLACE VIEW v_executive_operations_overview AS
SELECT 
    Run_ID,
    ProductionVolume,
    ProductionCost,
    WorkerProductivity,
    MaintenanceHours,
    DowntimePercentage * 100 AS Downtime_Percentage_Rate,
    AssetAvailability * 100 AS Equipment_Availability_Rate,
    EnergyConsumption,
    EnergyUtilizationIntensity,
    LaborThroughputRatio,
    SafetyIncidents,
    DefectStatus
FROM factory_telemetry_logs;

--  VIEW 2: SUPPLIER PERFORMANCE ANALYSIS
CREATE OR REPLACE VIEW v_supplier_performance_analysis AS
SELECT 
    Run_ID,
    SupplierQuality AS Raw_Material_Quality_Pct,
    DeliveryDelay AS Logistics_Delay_Days,
    StockoutRate * 100 AS Inventory_Stockout_Rate_Pct,
    InventoryTurnover AS Material_Velocity_Index,
    SupplierRiskMultiplier AS Composite_Supplier_Risk_Score,
    DefectRate AS Factory_Floor_Defect_Rate_Pct,
    DefectStatus AS Batch_Inspection_Status
FROM factory_telemetry_logs;

--  VIEW 3: QUALITY CONTROL DIAGNOSTICS
CREATE OR REPLACE VIEW v_quality_control_diagnostics AS
SELECT 
    Run_ID,
    DefectRate,
    QualityScore,
    AdditiveProcessTime AS Treatment_Process_Minutes,
    AdditiveMaterialCost AS Specialized_Coating_Cost_GBP,
    ProductionCost,
    DefectStatus
FROM factory_telemetry_logs;

-- VALIDATE THAT VIEWS WORK
SHOW FULL TABLES WHERE Table_type = 'VIEW';
