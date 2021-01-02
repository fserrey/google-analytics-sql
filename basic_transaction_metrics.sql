/**********************************************************************************************************
    NAME:           Basic transaction metrics
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
  IFNULL(SUM(totals.transactions),0) AS total_transactions,
  IFNULL(SUM(totals.totaltransactionrevenue),0)/1000000 AS revenue,
  IFNULL(SUM(totals.transactions) / COUNT(DISTINCT CONCAT(fullvisitorid, CAST(visitstarttime AS STRING))),0) AS conversion_rate
FROM  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201130'
  AND totals.visits = 1
