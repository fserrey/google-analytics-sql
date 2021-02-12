# google-analytics-sql
[![Open Source? Yes!](https://badgen.net/badge/Open%20Source%20%3F/Yes%21/blue?icon=github)](https://github.com/Naereen/badges/)
### Useful scripts to get basic ecommerce KPIs querying GA 360 BigQuery export

## Description
This repo contains a set of queries in standard SQL useful to extract some of the main KPIs out of GA 360 (mainly, as we are moving to GA4 now). I hope you'll find them useful. Feel free to send your comments or make some suggestion in a PR form.

## Some context
It's true that you might get some of these KPIs straight from the GA UI. However, getting access to the raw data pulled from GA gives you the hability to personalise the type of calculous that sometimes you need to perform in an external tool (i.e. Excel, Google Spreadsheet, etc). Additionally, if you are dealing with terabites of data, the GA UI mostly provides sampled data and, spoiler alert, _you can get them all_ with BigQuery.

Each row in the Google Analytics BigQuery dump represents a single session and contains many fields, some of which can be repeated and nested, such as the hits, which contains a repeated set of fields within it representing the page views and events during the session, and custom dimensions, which is a single, repeated field . This is one of the main differences between BigQuery and a normal database. [(source)](https://www.bounteous.com/insights/2016/02/11/querying-google-analytics-data-bigquery/?ns=l)

## How to access nested fields?
One of the trickiest parts of working with the GA BigQuery export schema is that data is not organized in nice little rows and columns. Instead, you have something that reminds a JSON object. Don't panick! We will get through it together.

So, how can I access to this data? Well, something that helped me a lot is to think about the schema as a tree (inverted). You have the main body and, there ar some branches that grow from it (and even more branches that grow from those previous branches). In the end, you just have a bunch of field that comes from others. Like a nested JSON:
![Example of nested JSON](https://www.google.com/url?sa=i&url=https%3A%2F%2Fstackoverflow.com%2Fquestions%2F28319714%2Fhow-to-convert-this-nested-json-in-columnar-form-into-pandas-dataframe&psig=AOvVaw13I_bk0E3nwJtcOHQ4kRuM&ust=1613212125297000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCMCIlNOR5O4CFQAAAAAdAAAAABAD)

### [Here you can see an animated example of how the nested fields are structured in the GA schema](https://www.notion.so/Formaci-n-BQ-37b95b2cfedf4b1a9ea39940a32ff5df#b183b5becf1846b898489a5ef2aa42ce)

So, basically we expand the NESTED fields and then `JOIN` them with the table. In other words, we unfold them using the `UNNEST` function so we can later `CROSS JOIN` these fields with it's equivalents. The issue here is that as you "unfold" some fields, those that are not-nested are going to repeated themselves as much as "nested rows" are holded inside a nested field.

You can see a detailed explanation [here](https://medium.com/firebase-developers/using-the-unnest-function-in-bigquery-to-analyze-event-parameters-in-analytics-fb828f890b42) 

Additionally, check out these other resources:
- _[How to query and calculate Google Analytics data in BigQuery](https://towardsdatascience.com/how-to-query-and-calculate-google-analytics-data-in-bigquery-cab8fc4f396#3be4)_
- _[ga4bigquery.com](https://www.ga4bigquery.com/)_