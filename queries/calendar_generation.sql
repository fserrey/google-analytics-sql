/*
How to generate an array of continuos dates
(src: stackoverflow.com)
*/
SELECT  * FROM  UNNEST(GENERATE_DATE_ARRAY( CURRENT_DATE(), DATE('2014-01-01'), INTERVAL -1 DAY) ) AS day -- Use -1, for DESC order
select  * from  UNNEST(GENERATE_TIMESTAMP_ARRAY('2015-10-01', '2015-10-03', INTERVAL 1 HOUR)) AS hour     -- Use  1, for  ASC order 

-- Example
WITH hours AS (
  SELECT *
  FROM UNNEST(GENERATE_TIMESTAMP_ARRAY('2015-10-01', '2015-10-03', INTERVAL 1 HOUR)) AS hour
)

SELECT
  hours.hour,
  COUNT(id)
FROM hours
LEFT JOIN `bigquery-public-data.hacker_news.comments` ON timestamp_trunc(`bigquery-public-data.hacker_news.comments`.time_ts,hour) = hours.hour
GROUP BY 1
ORDER BY 1;