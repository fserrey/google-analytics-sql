



--Navegación por mes | Canal | Tienda
-- Comparación 4 meses vs 4 meses 2019 --> 1,2T

#standardSQL
WITH year_2020 (
    SELECT
        FORMAT_DATE('%Y%m', PARSE_DATE("%Y%m%d", date)) AS month,
        CASE
        WHEN trafficSource.source = '(direct)' AND (trafficSource.medium = '(not set)' OR trafficSource.medium = '(none)') THEN 'Direct'
        WHEN trafficSource.medium = 'organic' THEN 'Organic Search'
        WHEN REGEXP_CONTAINS(trafficSource.medium, r'^(social|social-network|social-media|sm|social network|social media)$') THEN 'Social'
        WHEN trafficSource.medium = 'email' THEN 'Email'
        WHEN trafficSource.medium = 'affiliate' THEN 'Affiliates'
        WHEN trafficSource.medium = 'referral' THEN 'Referral'
        WHEN REGEXP_CONTAINS(trafficSource.medium, r'^(cpc|ppc|paidsearch)$') AND trafficSource.adwordsClickInfo.adNetworkType != 'Content' THEN 'Paid Search'
        WHEN REGEXP_CONTAINS(trafficSource.medium, r' ^(cpv|cpa|cpp|content-text)$') THEN 'Other Advertising'
        WHEN REGEXP_CONTAINS(trafficSource.medium, r'^(display|cpm|banner)$') OR trafficSource.adwordsClickInfo.adNetworkType = 'Content' THEN 'Display'
        ELSE '(Other)' END  AS Default_Channel_Grouping,
        --METRICS
        COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitStartTime AS STRING))) AS total_sessions,
        COUNT(DISTINCT CASE WHEN totals.bounces = 1 THEN CONCAT(fullVisitorId, CAST(visitStartTime AS STRING)) ELSE NULL END) / 
        COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitStartTime AS STRING))) AS bounce_rate,
        SUM(totals.timeOnSite) / COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitStartTime AS STRING))) AS avg_session_duration,
        SUM(totals.pageviews) AS pageviews,
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS ga--,  UNNEST(hits) AS hits  
    WHERE _TABLE_SUFFIX BETWEEN '20200101' AND '20200430'
        AND (SELECT MAX(hits.isEntrance) FROM UNNEST(hits) AS hits)  = TRUE
    GROUP BY 1,2,3
  )
  
 , year_2019 AS (
    SELECT
        FORMAT_DATE('%Y%m', PARSE_DATE("%Y%m%d", date)) AS month,
        CASE
        WHEN trafficSource.source = '(direct)' AND (trafficSource.medium = '(not set)' OR trafficSource.medium = '(none)') THEN 'Direct'
        WHEN trafficSource.medium = 'organic' THEN 'Organic Search'
        WHEN REGEXP_CONTAINS(trafficSource.medium, r'^(social|social-network|social-media|sm|social network|social media)$') THEN 'Social'
        WHEN trafficSource.medium = 'email' THEN 'Email'
        WHEN trafficSource.medium = 'affiliate' THEN 'Affiliates'
        WHEN trafficSource.medium = 'referral' THEN 'Referral'
        WHEN REGEXP_CONTAINS(trafficSource.medium, r'^(cpc|ppc|paidsearch)$') AND trafficSource.adwordsClickInfo.adNetworkType != 'Content' THEN 'Paid Search'
        WHEN REGEXP_CONTAINS(trafficSource.medium, r' ^(cpv|cpa|cpp|content-text)$') THEN 'Other Advertising'
        WHEN REGEXP_CONTAINS(trafficSource.medium, r'^(display|cpm|banner)$') OR trafficSource.adwordsClickInfo.adNetworkType = 'Content' THEN 'Display'
        ELSE '(Other)' END  AS Default_Channel_Grouping,
        --METRICS
        COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitStartTime AS STRING))) AS total_sessions,
        COUNT(DISTINCT CASE WHEN totals.bounces = 1 THEN CONCAT(fullVisitorId, CAST(visitStartTime AS STRING)) ELSE NULL END) / 
        COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitStartTime AS STRING))) AS bounce_rate,
        SUM(totals.timeOnSite) / COUNT(DISTINCT CONCAT(fullVisitorId, CAST(visitStartTime AS STRING))) AS avg_session_duration,
        SUM(totals.pageviews) AS pageviews,
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS ga--,  UNNEST(hits) AS hits  
    WHERE _TABLE_SUFFIX BETWEEN '201900101' AND '20190430'
        AND (SELECT MAX(hits.isEntrance) FROM UNNEST(hits) AS hits)  = TRUE
    GROUP BY 1,2,3
  )


SELECT  month, Default_Channel_Grouping, total_sessions, bounce_rate, pageviews 
FROM year_2020
  UNION ALL
SELECT  month, Default_Channel_Grouping, total_sessions, bounce_rate, pageviews 
FROM year_2019