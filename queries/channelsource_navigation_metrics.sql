/**********************************************************************************************************
    NAME:           Channel source navigation metrics
    SYNOPSIS:       Main metrics for basic ecommerce KPIs querying GA360 BigQuery export
    DEPENDENCIES:   BigQuery Editor role (at least)
    AUTHOR:         Francisco Serrano - @fserrey (inspiration source: ga4bigquery.com)
    
    CREATED:        2020-07-22
    
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
     20200722   1.0        fserrey            Open Sourced on GitHub
**********************************************************************************************************/

#standardSQL            
SELECT 
  channelgrouping,
  COUNT(DISTINCT CONCAT(fullvisitorid, CAST(visitstarttime AS STRING))) AS total_sessions,
  COUNT( DISTINCT(CASE WHEN totals.newvisits = 1 THEN fullvisitorid ELSE NULL END)) AS new_users,
  COUNT(DISTINCT CASE WHEN totals.bounces = 1 THEN CONCAT(fullvisitorid, CAST(visitstarttime AS STRING)) ELSE NULL END ) / COUNT(DISTINCT CONCAT(fullvisitorid, CAST(visitstarttime AS STRING))) AS bounce_rate,
  SUM(totals.pageviews) / COUNT(DISTINCT CONCAT(fullvisitorid, CAST(visitstarttime AS STRING))) AS pages_per_session,
  IFNULL(SUM(totals.timeonsite) / COUNT(DISTINCT CONCAT(fullvisitorid, CAST(visitstarttime AS STRING))),0) AS average_session_duration,
  
FROM  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201130'
  AND totals.visits = 1
GROUP BY 1
