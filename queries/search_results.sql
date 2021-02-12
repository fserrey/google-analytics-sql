/**********************************************************************************************************
    NAME:           Search terms results
    SYNOPSIS:       Comparison between search terms with and without results
    DEPENDENCIES:   BigQuery Editor role (at least)
    AUTHOR:         Francisco Serrano - @fserrey (inspiration source: ga4bigquery.com)
    
    CREATED:        2020-05-03
    
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
     20200503   1.0        fserrey            Open Sourced on GitHub
**********************************************************************************************************/

WITH searchs_per_sessions AS (
    SELECT
        date,
        hits.page.searchKeyword AS search_term,
        CONCAT(fullVisitorId, CAST(visitStartTime AS STRING)) AS session_id,
        (SELECT value FROM UNNEST(hits.customDimensions) WHERE index = 00 GROUP BY 1 ) AS custom_dimension_items_per_page,
        hits.page.pagePathLevel1 AS main_category
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*` AS ga,  UNNEST(hits) AS hits
        WHERE _TABLE_SUFFIX BETWEEN '20200403' AND '20200503'
        AND totals.visits = 1
        AND hits.type = 'PAGE'
        AND hits.page.searchKeyword IS NOT NULL
    )
SELECT 
    search_term AS search_term,  
    main_category AS main_category,
    COUNT(DISTINCT session_id) AS total_unique_searchs,
    COUNT(DISTINCT session_id) -  COUNT(DISTINCT CASE WHEN custom_dimension_items_per_page = 0 THEN session_id ELSE NULL END) AS search_terms_with_result,
    COUNT(DISTINCT CASE WHEN custom_dimension_items_per_page = 0 THEN session_id ELSE NULL END) AS search_terms_without_result,
FROM searchs_per_sessions 
GROUP BY 1, 2
ORDER BY 3 DESC
