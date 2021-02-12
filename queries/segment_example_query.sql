/**********************************************************************************************************
    NAME:           Segment example
    SYNOPSIS:       Main metrics for basic ecommerce KPIs querying GA360 BigQuery export
    DEPENDENCIES:   BigQuery Editor role (at least)
    AUTHOR:         Francisco Serrano - @fserrey (inspiration source: ga4bigquery.com)
    
    CREATED:        2020-12-22
    
    VERSION:        1.0
    LICENSE:        Apache License v2
    ----------------------------------------------------------------------------
    DISCLAIMER: 
    This code and information are provided "AS IS" without warranty of any kind,
    either expressed or implied, including but not limited to the implied 
    warranties or merchantability and/or fitness for a particular purpose.
    ----------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------
 --  DATE       VERSION     AUTHOR                  DESCRIPTION                                        --
 ---------------------------------------------------------------------------------------------------------
     20201222   1.0        fserrey            Open Sourced on GitHub
**********************************************************************************************************/


#standardSQL 
WITH transactions AS(
    SELECT
        CONCAT(fullVisitorId, CAST(visitStartTime AS STRING)) AS session_id,
        hits.transaction.transactionId AS transaction_id,
                
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hits, UNNEST(product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201130'
      AND totals.visits = 1 
      AND (STARTS_WITH(v2ProductCategory, "Category_1/") OR REGEXP_CONTAINS(v2ProductCategory, "Category_1/"))
),

 segment AS (
     SELECT 
        CONCAT(fullVisitorId, CAST(visitStartTime AS STRING)) AS session_id,
        COUNT(CASE WHEN hits.eCommerceAction.action_type = '2' THEN fullvisitorid ELSE NULL END) AS product_detail_views,
     FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hits
     WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201130'
       AND totals.visits = 1
       AND REGEXP_CONTAINS(hits.page.pagePath, "Category_1/") 
     GROUP BY 1 
     HAVING product_detail_views >= 1
 )


SELECT 
    COUNT(DISTINCT transaction_id) AS total_transactions_of_sessions_that_visited_a_pdp 
FROM transactions t 
JOIN segmento s ON t.session_id = s.session_id
--For this purpose, you can use a WHERE filter too (instead of JOIN):
--WHERE session_id IN (SELECT DISTINCT session_id FROM segment)
