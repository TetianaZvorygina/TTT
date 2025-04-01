       -- facebook_ads_basic_daily
       -- google_ads_basic_daily
       --facebook_adset
       --facebook_campaign


select * from public.facebook_ads_basic_daily
limit 1

select * from public.google_ads_basic_daily
limit 1

select * from public.facebook_adset
limit 1

select * from public.facebook_campaign
limit 1

   


--HW 6



with CTE_fb_gg as (
select
	ad_date,
	'Fb' as media_source,	
	coalesce(spend, 0) as spend,
	coalesce(impressions, 0) as impressions,
	coalesce(reach, 0) as reach,
	coalesce(clicks, 0) as clicks,
	coalesce(leads, 0) as leads,
	coalesce(value, 0) as value,
	coalesce(
		substring(url_parameters from 'utm_campaign=([^&]+)'), 'nan')                          --chatGPT
		as utm_campaign_temp
from public.facebook_ads_basic_daily 
union all
select
	ad_date,
	'Gg' as media_source,
	coalesce(spend,	0) as spend,
	coalesce(impressions, 0) as impressions,
	coalesce(reach, 0) as reach,
	coalesce(clicks, 0) as clicks,
	coalesce(leads, 0) as leads,
	coalesce(value, 0) as value,
	coalesce(
		substring(url_parameters from 'utm_campaign=([^&]+)'),'nan') 
		as utm_campaign_temp
from public.google_ads_basic_daily
)
select
	ad_date,
	case
		when lower(utm_campaign_temp) = 'nan' then null                                     
		else lower(utm_campaign_temp)


		end 
	as utm_campaign,
	sum(spend) as t_spend,
	sum(impressions) as t_impressions,
	sum(clicks) as t_clicks,
	sum(value) as t_value,
    case
		when sum(clicks)>0 then round(sum(spend)/sum(clicks)::numeric,4)
		else 0
	end 
	as "CPC",
	case
		when sum(impressions)>0 then round((sum(spend)/sum(impressions)::numeric)*1000,4)
		else 0
	end 
	as "CPM",
	case
		when sum(impressions)>0 then round(100*sum(clicks)/sum(impressions)::numeric,4)
		else 0
	end
	as "CTR",
	case
		when sum(spend)>0 then round(((sum(value)-sum(spend))::numeric/sum(spend)),4)
		else 0
	end 
	as "ROMI"
from CTE_fb_gg
group by ad_date, utm_campaign_temp
order by ad_date --utm_campaign
;



--HW6*

--sorry, i couldnt create function by myself but i found created one which appears to fit 
-- i used сyrillic_decoding

with CTE_fb_gg as (
select
	ad_date,
	'Fb' as media_source,	
	coalesce(spend, 0) as spend,
	coalesce(impressions, 0) as impressions,
	coalesce(reach, 0) as reach,
	coalesce(clicks, 0) as clicks,
	coalesce(leads, 0) as leads,
	coalesce(value, 0) as value,
	coalesce(
		substring(url_parameters from 'utm_campaign=([^&]+)'), 'nan')                          --chatGPT
		as utm_campaign_temp
from public.facebook_ads_basic_daily 
union all
select
	ad_date,
	'Gg' as media_source,
	coalesce(spend, 0) as spend,
	coalesce(impressions, 0) as impressions,
	coalesce(reach, 0) as reach,
	coalesce(clicks, 0) as clicks,
	coalesce(leads, 0) as leads,
	coalesce(value, 0) as value,
	coalesce(
		substring(url_parameters from 'utm_campaign=([^&]+)'),'nan') 
		as utm_campaign_temp
from public.google_ads_basic_daily
)
select
	ad_date,
	/*case
		when lower(utm_campaign_temp) = 'nan' then null                                     
		else lower(decode(utm_campaign_temp, 'escape'))
	end 
	as utm_campaign,*/
	case
    when lower(utm_campaign_temp) = 'nan' then null                                     
    else lower(сyrillic_decoding(utm_campaign_temp))
	end 
	as utm_campaign,
	sum(spend) as t_spend,
	sum(impressions) as t_impressions,
	sum(clicks) as t_clicks,
	sum(value) as t_value,
    case
		when sum(clicks) > 0 then round(sum(spend) / sum(clicks)::numeric, 4)
		else 0
	end 
	as "CPC",
	case
		when sum(impressions) > 0 then round((sum(spend) / sum(impressions)::numeric) * 1000, 4)
		else 0
	end 
	as "CPM",
	case
		when sum(impressions) > 0 then round(100 * sum(clicks) / sum(impressions)::numeric, 4)
		else 0
	end
	as "CTR",
	case
		when sum(spend) > 0 then round(((sum(value) - sum(spend))::numeric / sum(spend)), 4)
		else 0
	end 
	as "ROMI"
from CTE_fb_gg
group by ad_date, utm_campaign_temp
order by ad_date;


/*
with CTE_fb_gg as (
select
	ad_date,
	'Fb' as media_source,	
	coalesce(spend, 0) as spend,
	coalesce(impressions, 0) as impressions,
	coalesce(reach, 0) as reach,
	coalesce(clicks, 0) as clicks,
	coalesce(leads, 0) as leads,
	coalesce(value, 0) as value,
	coalesce(
		substring(url_parameters from 'utm_campaign=([^&]+)'), 'nan') --chatGPT
		as utm_campaign_temp
from public.facebook_ads_basic_daily fabd
union all
select
	ad_date,
	'Gg' as media_source,
	coalesce(spend,	0) as spend,
	coalesce(impressions, 0) as impressions,
	coalesce(reach, 0) as reach,
	coalesce(clicks, 0) as clicks,
	coalesce(leads, 0) as leads,
	coalesce(value, 0) as value,
	--coalesce(
		--case
			--when substring(url_parameters from 'utm_campaign=([^&]+)') is not null
			--then decode(replace(substring(url_parameters from 'utm_campaign=([^&]+)'), '%', ''), 'hex')::text
            --else 'nan'
       -- end, 
       -- 'nan')
        --as utm_campaign_temp
            --substring(url_parameters from 'utm_campaign=([^&]+)'),'nan') 
			--as utm_campaign_temp 
			/*
                WHEN SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)') IS NOT NULL THEN 
                    decode(replace(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)'), '%', ''), 'hex')::TEXT
                ELSE nan'
            END, 
            'nan'
        ) AS utm_campaign_raw,
		substring(url_parameters from 'utm_campaign=([^&]+)'),'nan') 
		as utm_campaign_temp */
from public.google_ads_basic_daily gabd
)
select
	ad_date,
	--case
	
	--	when lower(utm_campaign_temp) = 'nan' then null        --chat
	--	else lower(utm_campaign_temp)
	--end 
	case
    when lower(utm_campaign_temp) = 'nan' then null                                     
    else lower(url_decode(utm_campaign_temp))
	end 
	as utm_campaign,
	sum(spend) as t_spend,
	sum(impressions) as t_impressions,
	sum(clicks) as t_clicks,
	sum(value) as t_value,
    case
		when sum(clicks)>0 then (sum(spend)/sum(clicks))
		else 0
	end 
	as "CPC",
	case
		when sum(impressions)>0 then (sum(spend)/sum(impressions))*1000
		else 0
	end 
	as "CPM",
	case
		when sum(impressions)>0 then sum(clicks)*100/sum(impressions)
		else 0
	end
	as "CTR",
	case
		when sum(spend)>0 then round(((sum(value)-sum(spend))::numeric/sum(spend)),3)
		else 0
	end 
	as "ROMI"
from CTE_fb_gg
group by ad_date, utm_campaign_temp
order by ad_date --utm_campaign
;
/*

WITH CTE_combined AS (
    SELECT 
        ad_date, 
        'Facebook' AS media_source,
        COALESCE(
            CASE 
                WHEN SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)') IS NOT NULL THEN 
                    decode(replace(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)'), '%', ''), 'hex')::TEXT
                ELSE 'nan'
            END, 
            'nan'
        ) AS utm_campaign_raw,
        COALESCE(spend, 0) AS spend, 
        COALESCE(impressions, 0) AS impressions, 
        COALESCE(reach, 0) AS reach,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(leads, 0) AS leads,
        COALESCE(value, 0) AS value
    FROM public.facebook_ads_basic_daily fabd

    UNION ALL

    SELECT 
        ad_date, 
        'Google' AS media_source,
        COALESCE(
            CASE 
                WHEN SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)') IS NOT NULL THEN 
                    decode(replace(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)'), '%', ''), 'hex')::TEXT
                ELSE 'nan'
            END, 
            'nan'
        ) AS utm_campaign_raw,
        COALESCE(spend, 0) AS spend, 
        COALESCE(impressions, 0) AS impressions, 
        COALESCE(reach, 0) AS reach,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(leads, 0) AS leads,
        COALESCE(value, 0) AS value
    FROM public.google_ads_basic_daily gabd
)
SELECT
    ad_date,
    CASE 
        WHEN LOWER(utm_campaign_raw) = 'nan' THEN NULL
        ELSE LOWER(utm_campaign_raw)
    END AS utm_campaign,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(value) AS total_value,
    -- CTR: (Clicks / Impressions) * 100
    CASE 
        WHEN SUM(impressions) > 0 THEN (SUM(clicks) * 100.0 / SUM(impressions))
        ELSE 0 
    END AS ctr,
    -- CPC: Spend / Clicks
    CASE 
        WHEN SUM(clicks) > 0 THEN (SUM(spend) * 1.0 / SUM(clicks))
        ELSE 0 
    END AS cpc,
    -- CPM: (Spend / Impressions) * 1000
    CASE 
        WHEN SUM(impressions) > 0 THEN (SUM(spend) * 1000.0 / SUM(impressions))
        ELSE 0 
    END AS cpm,
    -- ROMI: Value / Spend
    CASE 
        WHEN SUM(spend) > 0 THEN (SUM(value) * 1.0 / SUM(spend))
        ELSE 0 
    END AS romi
FROM CTE_combined
GROUP BY ad_date, utm_campaign_raw
ORDER BY ad_date, utm_campaign;*/

--function from chat

CREATE OR REPLACE FUNCTION url_decode(url text)
RETURNS text AS $$
DECLARE
    decoded text;
BEGIN
    -- Replace '+' with space
    decoded := replace(url, '+', ' ');
    -- Decode percent-encoded characters
    decoded := regexp_replace(decoded, '%([0-9A-Fa-f]{2})', 
        chr(x'\\1'::bit(8)::int), 'g');
    RETURN decoded;
END;
$$ LANGUAGE plpgsql IMMUTABLE;





*/
--HW4

with Fb_Gg_united as (
select 
ad_date, 
'Facebook' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach,
clicks,
leads,
value
from public.facebook_ads_basic_daily fabd
left join public.facebook_adset fa on
fabd.adset_id =fa.adset_id 
left join public.facebook_campaign fc on
fabd.campaign_id =fc.campaign_id 
group by ad_date, media_source, campaign_name, adset_name, spend, impressions, 
clicks, reach, leads, value
union
select ad_date,
'Google' as media_source,
campaign_name,
adset_name,
spend, 
impressions, 
reach,
clicks,
leads,
value
from public.google_ads_basic_daily gabd
)
select
ad_date,
media_source,
campaign_name,
adset_name,
sum(spend) as T_spends, 
sum(impressions) as T_impressions, 
sum(clicks) as T_clicks,
 sum(value) as T_value
 from Fb_Gg_united 
 WHERE 
    ad_date IS NOT NULL AND
    media_source IS NOT NULL AND
    campaign_name IS NOT NULL AND
    adset_name IS NOT NULL AND
    spend IS NOT NULL AND
    impressions IS NOT NULL AND
    clicks IS NOT NULL AND
    value IS NOT NULL
 group by ad_date, media_source, campaign_name,
adset_name

 --order by ad_date
;

--HW 4*

with Fb_Gg_united as (
select 
campaign_name,
adset_name,
spend, 
impressions, 
reach,
clicks,
leads,
value
from public.facebook_ads_basic_daily fabd
left join public.facebook_adset fa on
fabd.adset_id =fa.adset_id 
left join public.facebook_campaign fc on
fabd.campaign_id =fc.campaign_id 
group by  campaign_name , adset_name,  spend, impressions, 
clicks, reach, leads, value
union
select 
campaign_name ,
adset_name,
spend, 
impressions, 
reach,
clicks,
leads,
value
from public.google_ads_basic_daily gabd
)
select
campaign_name,
adset_name,
(sum(value)-sum(spend))/sum(spend)::numeric as "ROMI" 
--sum(value) as value_total
from Fb_Gg_united
where spend>0  
group by campaign_name, adset_name 
having sum (spend)> 500000
order by "ROMI" desc
limit 10
;


/*
with Fb_Gg_united as (
select 
ad_date,
fabd.campaign_id as campaign_id,
fa.adset_name as adset_name,
spend, 
impressions, 
reach,
clicks,
leads,
value
from public.facebook_ads_basic_daily fabd
left join public.facebook_adset fa on
fabd.adset_id =fa.adset_id 
left join public.facebook_campaign fc on
fabd.campaign_id =fc.campaign_id 
group by ad_date, fabd.campaign_id, fa.adset_name, spend, impressions, 
clicks, reach, leads, value
union
select ad_date,
campaign_name as campaign_id,
adset_name,
spend, 
impressions, 
reach,
clicks,
leads,
value
from public.google_ads_basic_daily gabd
)
select campaign_id, 
adset_name
(sum(value)-sum(spend))/sum(spend)::numeric as "ROMI", 
sum(value) as value_total
from Fb_Gg_united
where spend>0
group by campaign_id, adset_name
having sum (spend)> 500000
order by "ROMI" desc
limit 1


/*
 
--HW 3


with FB_Google_CTE as (
select ad_date,
'Facebook Ads' as media_source,
 spend, 
impressions, 
clicks,
reach,
leads,
value
from public.facebook_ads_basic_daily
 group by ad_date, media_source, spend, impressions, 
clicks, reach, leads, value
 union 
 select ad_date,
'Google Ads' as media_source,
spend, 
impressions, 
clicks,
reach,
leads,
value
from public.google_ads_basic_daily
 group by ad_date, media_source, spend, impressions, 
clicks, reach, leads, value
)
select 
ad_date,
media_source,
sum(spend) as T_spends, 
sum(impressions) as T_impressions, 
sum(clicks) as T_clicks,
--sum(reach)as reaches,
--sum(leads) as leads,
 sum(value) as T_value
 from FB_Google_CTE
 group by ad_date, media_source
 --order by ad_date
;


/*
with Facebook_CTE as 
(select 
ad_date,
'Facebook Ads' as media_source,
sum(spend) as spends, 
sum(impressions) as impressions, 
sum(clicks) as clicks,
sum(reach)as reaches,
sum(leads) as leads,
sum(value) as total_value
 from facebook_ads_basic_daily
 group by ad_date, media_source)
 select ad_date,
media_source,
spends, 
impressions,
reaches,
clicks,
leads,
total_value
from Facebook_CTE
union
select 
ad_date,
'Google Ads' as media_source,
sum(spend) as spends, 
sum(impressions) as impressions, 
sum(clicks) as clicks,
sum(value) as total_value
 from google_ads_basic_daily
 group by ad_date,media_source
 ;
 
 */ 
 

/* HW 1
select ad_date,
spend,
clicks,
spend/clicks as spend_per_click
from public.facebook_ads_basic_daily
where clicks > 0
order by ad_date desc
;
*/

--select *
--from public.facebook_ads_basic_daily
--limit 1
;

--HW 2.1

select ad_date,
campaign_id,
sum (spend) as spend_total,
sum (impressions) as show_total,
sum(clicks) as clicks_total,
sum(value) as value_total
from public.facebook_ads_basic_daily
where spend>0 and impressions >0 and clicks>0  
group by ad_date , campaign_id
order by ad_date
;

--HW 2.2 
-- i removed public.* table link but still couldnt understand whats wrong with ad_date
-- i changed its place but it shouldnt have any impact except of column location

select campaign_id ,
sum (spend)/sum(clicks) as "CPC",
sum (spend)*1000/sum(impressions) as "CPM",
sum (clicks)/sum(impressions)::numeric as "CTR",
round ((sum(value)-sum(spend))/ sum(spend)::numeric, 4) as "ROMI",
ad_date
from facebook_ads_basic_daily
where spend>0 and impressions >0 and clicks>0  
group by campaign_id, ad_date
;



--HW 2.3 

--Yeah, we dont need second select as we have group by as aggregator. Ty for help.
--

select campaign_id,
(sum(value)-sum(spend))/sum(spend)::numeric as "ROMI", 
sum(value) as value_total
from public.facebook_ads_basic_daily
where spend>0
group by campaign_id
having sum (spend)> 500000
order by "ROMI" desc
limit 1
;







