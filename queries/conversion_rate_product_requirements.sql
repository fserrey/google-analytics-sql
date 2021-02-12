/**********************************************************************************************************
    NAME:           Navigation metrics comparison between years
    SYNOPSIS:       The comparison between years made with UNION ALL reduce the volumen of data processed
    DEPENDENCIES:   BigQuery Editor role (at least)
    AUTHOR:         Francisco Serrano - @fserrey 
    
    CREATED:        2020-11-08
    
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
     20201108   1.0        fserrey            Open Sourced on GitHub
**********************************************************************************************************/

WITH traffic AS (
  SELECT
    date,
    device.deviceCategory AS device,
    CONCAT(CAST(fullVisitorId AS STRING), CAST(visitStartTime AS STRING)) AS session_id,
    CONCAT(CAST(fullvisitorid AS string), CAST(visitstarttime AS string)) AS sessionId,
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` ga, UNNEST(hits) hits
  WHERE _TABLE_SUFFIX BETWEEN '20200917'  AND FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
    AND totals.visits = 1
    AND REGEXP_CONTAINS(hits.page.pagePath, '/my-promotion/') 
),
products AS(
  SELECT 
    CONCAT(CAST(fullVisitorId AS STRING), CAST(visitStartTime AS STRING)) as session_id, 
    hits.transaction.transactionid AS transactionId,
    hits.transaction.transactionrevenue AS transactionRevenue,
    product.productQuantity AS quantity,
    product.productPrice AS price,
    productRevenue/1000000 AS pd_revenue,
    MAX(hits.transaction.transactionrevenue) OVER (PARTITION BY hits.transaction.transactionid) AS transaction_rev
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` ga, UNNEST(hits) hits, UNNEST(hits.product) product
  WHERE _TABLE_SUFFIX BETWEEN '20200917'  AND FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
    AND totals.visits = 1
    AND REGEXP_CONTAINS(v2ProductCategory, 'My promotion')
)

SELECT
  date AS Fecha,
  COUNT(DISTINCT sessionId) AS total_sessions,
  COUNT(DISTINCT transactionId) AS total_transactions,
  MAX(transactionRevenue)/1000000 AS revenue, -- As this field is repeated due to the unnest, we select just the max value
  SAFE_DIVIDE(COUNT(DISTINCT transactionId) , COUNT(DISTINCT sessionId)) AS ecommerce_conversion_rate,
  SAFE_DIVIDE( (MAX(transactionRevenue)/1000000) , COUNT(DISTINCT transactionId)) AS avg_order_value, 
  SAFE_DIVIDE( (MAX(transactionRevenue)/1000000) , COUNT(DISTINCT sessionId)) AS per_session_value,
FROM  traffic t 
FULL OUTER JOIN products p ON t.sessionId = p.session_id 
GROUP BY  1  