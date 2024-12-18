--STEP 1: INVESTIGATE INPUT TABLES USING SELECT *
--STEP 2: CLEAN UP DATA AND CREATE SUPPLEMENTARY COLUMNS
--STEP 3: JOIN TABLES TOGETHER TO CREATE MORE ROBUST DATASET
--STEP 4: COMBINE TEMP TABLES TO CTEs

--STEP 1
select * from finance.daily_subs;


--STEP 2: add date columns, supplementary subscription name
create or replace temp table finance.daily_subs_clean as (
    select sub_start_ts::date as sub_start_date,
        date_trunc('week',sub_start_ts::date) as sub_start_week,
        date_trunc('month',sub_start_ts::date) as sub_start_month,
        date_trunc('quarter',sub_start_ts::date) as sub_start_quarter,
        date_trunc('year',sub_start_ts::date) as sub_start_year,
        user,
        sub,
        sub_period,
        concat(sub, ' ', sub_period) as full_sub_name,
        price as local_price,
        price_usd,
        currency,
        country_code
    from finance.daily_subs
);

select * from finance.daily_subs_clean;

--STEP 3: add geographic region data, convert to USD
create or replace temp table finance.daily_subs_clean_country as (
    select *
    from finance.daily_subs_clean
    left join finance.geo_lookup
    on lower(daily_subs_clean.country_code) = lower(geo_lookup.country_iso)
);

select * from finance.daily_subs_clean_country limit 10;

--join daily subs clean table to exchange rates to get usd price
create or replace temp table finance.daily_subs_country_rates as (
    select daily_subs_clean_country.*,
        --error on current line
        case when daily_subs_clean_country.currency = 'USD' then local_price else local_price*rate end as price_usd_calc
    from finance.daily_subs_clean_country
    left join finance.exchange_rates
        on lower(daily_subs_clean_country.currency) = lower(exchange_rates.currency)
        and daily_subs_clean_country.sub_start_month = exchange_rates.date);

select * from finance.daily_subs_country_rates;
a
--create a script using CTEs to do all calculations in one query
with daily_subs_clean as (
    select sub_start_ts::date as sub_start_date,
        date_trunc('week',sub_start_ts::date) as sub_start_week,
        date_trunc('month',sub_start_ts::date) as sub_start_month,
        date_trunc('quarter',sub_start_ts::date) as sub_start_quarter,
        date_trunc('year',sub_start_ts::date) as sub_start_year,
        user,
        sub,
        sub_period,
        concat(sub, ' ', sub_period) as full_sub_name,
        price as local_price,
        price_usd,
        currency,
        country_code
    from finance.daily_subs
),

daily_subs_clean_country as (
    select *
    from finance.daily_subs_clean
    left join finance.geo_lookup
    on lower(daily_subs_clean.country_code) = lower(geo_lookup.country_iso)
),

daily_subs_country_rates as (
    select daily_subs_clean_country.*,
        --error on current line
        case when daily_subs_clean_country.currency = 'USD' then local_price else local_price*rate end as price_usd_calc
    from finance.daily_subs_clean_country
    left join finance.exchange_rates
        on lower(daily_subs_clean_country.currency) = lower(exchange_rates.currency)
        and daily_subs_clean_country.sub_start_month = exchange_rates.date)

select * from daily_subs_country_rates;


create or replace 
SELECT *
FROM ZOOM
WHERE 
    SUB_START_DATE IS NOT NULL AND
    SUB_START_WEEK IS NOT NULL AND
    SUB_START_MONTH IS NOT NULL AND
    SUB_START_QUARTER IS NOT NULL AND
    SUB_START_YEAR IS NOT NULL AND
    USER IS NOT NULL AND
    SUB IS NOT NULL AND
    SUB_PERIOD IS NOT NULL AND
    FULL_SUB_NAME IS NOT NULL AND
    LOCAL_PRICE IS NOT NULL AND
    PRICE_USD IS NOT NULL AND
    CURRENCY IS NOT NULL AND
    COUNTRY_CODE IS NOT NULL AND
    CONTINENT IS NOT NULL AND
    FULL_COUNTRY_NAME IS NOT NULL AND
    CONTINENT_ISO IS NOT NULL AND
    COUNTRY_ISO IS NOT NULL AND
    REGION IS NOT NULL AND
    REGION_DETAIL IS NOT NULL AND
    RECORD_DATE IS NOT NULL AND
    COUNTRY IS NOT NULL AND
    CURRENCY_DETAIL IS NOT NULL AND
    RATE IS NOT NULL

    
