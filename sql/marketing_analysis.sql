-- =====================================================================
-- Social Media Marketing Campaign Analytics - SQL Analysis
-- Staging table: campaigns (loaded from
--   data/cleaned/social_media_campaigns_with_kpis.csv, 6000 rows)
-- Schema reference (table already exists in social_media_campaigns.db):
--   CREATE TABLE campaigns (
--     Campaign_ID TEXT, Platform TEXT, Campaign_Name TEXT,
--     Start_Date TEXT, End_Date TEXT, Spend REAL, Impressions INTEGER,
--     Clicks INTEGER, Conversions INTEGER, Revenue REAL,
--     Audience_AgeGroup TEXT, Audience_Location TEXT,
--     Device TEXT, Post_Type TEXT, CTR REAL, CPC REAL,
--     Conversion_Rate REAL, CPA REAL, ROAS REAL, ROI REAL,
--     Spend_bin TEXT
--   );
-- These queries mirror the Python analysis as an independent check.
-- Ratios are computed on totals (overall), never averaged.
-- =====================================================================

-- Q1a. Performance by Platform (spend, clicks, conversions, revenue,
--      overall ROAS, CPA and ROI)
SELECT
    Platform,
    COUNT(*) AS campaigns,
    ROUND(SUM(Spend), 2) AS total_spend,
    SUM(Clicks) AS total_clicks,
    SUM(Conversions) AS total_conversions,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Revenue) / SUM(Spend), 2) AS overall_roas,
    ROUND(SUM(Spend) / SUM(Conversions), 2) AS overall_cpa,
    ROUND((SUM(Revenue) - SUM(Spend)) / SUM(Spend), 2) AS overall_roi
FROM campaigns
GROUP BY Platform
ORDER BY overall_roas DESC;

-- Q1b. Conversions by Platform
SELECT
    Platform,
    SUM(Conversions) AS total_conversions
FROM campaigns
GROUP BY Platform
ORDER BY total_conversions DESC;

-- Q1c. Revenue by Platform
SELECT
    Platform,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM campaigns
GROUP BY Platform
ORDER BY total_revenue DESC;

-- Q2a. Performance by Post_Type (overall ROAS, CTR, Conversion Rate)
SELECT
    Post_Type,
    COUNT(*) AS campaigns,
    SUM(Impressions) AS total_impressions,
    ROUND(CAST(SUM(Clicks) AS REAL) / SUM(Impressions), 4) AS overall_ctr,
    ROUND(CAST(SUM(Conversions) AS REAL) / SUM(Clicks), 4) AS overall_conv_rate,
    ROUND(SUM(Revenue) / SUM(Spend), 2) AS overall_roas
FROM campaigns
GROUP BY Post_Type
ORDER BY overall_roas DESC;

-- Q2b. ROAS by Platform and Post_Type combination
SELECT
    Platform,
    Post_Type,
    ROUND(SUM(Revenue) / SUM(Spend), 2) AS overall_roas
FROM campaigns
GROUP BY Platform, Post_Type
ORDER BY overall_roas DESC;

-- Q3. Efficiency by spend range (diminishing returns check)
SELECT
    Spend_bin,
    COUNT(*) AS campaigns,
    ROUND(SUM(Spend), 2) AS total_spend,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Revenue) / SUM(Spend), 2) AS overall_roas,
    ROUND(SUM(Spend) / SUM(Conversions), 2) AS overall_cpa
FROM campaigns
WHERE Spend IS NOT NULL
GROUP BY Spend_bin
ORDER BY overall_roas DESC;

-- Q4. Segment comparison (AgeGroup and Device, overall ROAS and CPA)
SELECT
    Audience_AgeGroup AS segment,
    'AgeGroup' AS segment_type,
    ROUND(SUM(Revenue) / SUM(Spend), 2) AS overall_roas,
    ROUND(SUM(Spend) / SUM(Conversions), 2) AS overall_cpa
FROM campaigns
GROUP BY Audience_AgeGroup
UNION ALL
SELECT
    Device AS segment,
    'Device' AS segment_type,
    ROUND(SUM(Revenue) / SUM(Spend), 2) AS overall_roas,
    ROUND(SUM(Spend) / SUM(Conversions), 2) AS overall_cpa
FROM campaigns
GROUP BY Device
ORDER BY overall_roas DESC;

-- Q5a. Top 10 campaigns by ROAS (complete cases only)
SELECT
    Campaign_ID,
    Platform,
    Post_Type,
    Spend,
    Revenue,
    ROUND(Revenue / Spend, 2) AS roas
FROM campaigns
WHERE Spend IS NOT NULL AND Revenue IS NOT NULL AND Spend > 0
ORDER BY roas DESC
LIMIT 10;

-- Q5b. Top 10 campaigns by CPA, highest first (complete cases only)
SELECT
    Campaign_ID,
    Platform,
    Post_Type,
    Spend,
    Conversions,
    ROUND(Spend / Conversions, 2) AS cpa
FROM campaigns
WHERE Spend IS NOT NULL AND Conversions IS NOT NULL AND Conversions > 0
ORDER BY cpa DESC
LIMIT 10;

-- Q5c. Low-performing campaigns (ROAS below 1: revenue below spend)
SELECT
    Campaign_ID,
    Platform,
    Post_Type,
    Spend,
    Revenue,
    ROUND(Revenue / Spend, 2) AS roas
FROM campaigns
WHERE Spend IS NOT NULL AND Revenue IS NOT NULL AND Spend > 0
  AND Revenue / Spend < 1
ORDER BY roas ASC
LIMIT 20;

-- Temporal performance by month (based on Start_Date)
SELECT
    STRFTIME('%Y-%m', Start_Date) AS month,
    COUNT(*) AS campaigns,
    ROUND(SUM(Spend), 2) AS total_spend,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Revenue) / SUM(Spend), 2) AS overall_roas
FROM campaigns
GROUP BY month
ORDER BY month;
