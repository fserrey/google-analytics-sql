/**********************************************************************************************************
    NAME:           Product Detail Page Views
    SYNOPSIS:       Main metrics for basic ecommerce KPIs querying GA360 BigQuery export
    DEPENDENCIES:   BigQuery Editor role (at least)
    AUTHOR:         Francisco Serrano - @fserrey (inspiration source: ga4bigquery.com)
    
    CREATED:        2020-11-15
    
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
     20201115   1.0        fserrey            Open Sourced on GitHub
**********************************************************************************************************/


#standardSQL
WITH count_pdp_views AS (
    SELECT
      date AS full_date,
      fullVisitorId AS visit,
      product.productvariant AS product_ref,
      product.productSKU AS SKUcode,
      FORMAT_DATE("%B", PARSE_DATE('%Y%m%d', date)) AS month,
      FORMAT_DATE("%Y", PARSE_DATE('%Y%m%d', date))  AS year,
      hits.eCommerceAction.action_type AS action_type

    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`, UNNEST(hits) AS hits, UNNEST(product) AS product
    WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201130'
      AND totals.visits = 1
      AND (isImpression IS NULL OR isImpression = FALSE)
      AND hits.type = 'PAGE'
      AND product.productSKU IS NOT NULL
      AND hits.isInteraction IS NOT NULL
  )


SELECT                       
  full_date,
  product_ref,
  CASE WHEN SUBSTR(SKUcode,1,1) IN ('A') THEN 'type_A' ELSE 'type_b' END AS ref_type,
  SKUcode,
  COUNT(CASE WHEN action_type = '2' THEN visit ELSE NULL END) AS total_pdp_views
FROM count_pdp_views
WHERE SKUcode = 'A00000000' --this condition can be optional
GROUP BY 1, 2, 3, 4
