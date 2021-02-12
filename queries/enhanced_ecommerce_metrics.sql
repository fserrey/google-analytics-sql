/**********************************************************************************************************
    NAME:           Enhanced ecommerce metrics
    SYNOPSIS:       Main metrics for basic ecommerce KPIs querying GA360 BigQuery export
    DEPENDENCIES:   BigQuery Editor role (at least)
    AUTHOR:         Francisco Serrano - @fserrey (inspiration source: ga4bigquery.com)
    
    CREATED:        2020-09-11
    
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
     20200911   1.0        fserrey            Open Sourced on GitHub
**********************************************************************************************************/

#standardSQL          BASIC PEDIDOS
SELECT 
  COUNT(DISTINCT hits.transaction.transactionid) AS total_transactions,
  SUM(hits.transaction.transactionrevenue)/1000000) AS total_revenue,
  (SUM(hits.transaction.transactionrevenue)/1000000)) / COUNT(DISTINCT hits.transaction.transactionid) as avg_order_value,
  (SUM(hits.transaction.transactionrevenue)/1000000)) / COUNT(DISTINCT CONCAT(fullvisitorid, CAST(visitstarttime AS STRING))) as value_per_session,
  COUNT(DISTINCT hits.transaction.transactionid) / COUNT(DISTINCT CONCAT(fullvisitorid, CAST(visitstarttime AS STRING))),0) AS conversion_rate
FROM  `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) hits
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201130'
  AND totals.visits = 1
