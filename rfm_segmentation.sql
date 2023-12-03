with 
	RFM_statistics as (
		select 
			CustomerID,
			ABS(datediff(max(STR_TO_DATE(Purchase_Date,'%m/%d/%Y')), '2022-09-01')) as Recency ,
			ifnull(round(count(distinct(Purchase_Date))/round(abs(datediff(max(cast(created_date as DATE)),'2022-09-01'))/365,0),2),0) as Frequency ,
			ifnull(round(sum(GMV)/round(abs(datediff(max(cast(created_date as DATE)),'2022-09-01'))/365,0),0),0) AS Monetary
		from customer_transaction CT 
		RIGHT join Customer_Registered CR ON CT.CustomerID = CR.ID
		where CustomerID <> 0 and GMV <> 0 
		group by CustomerID
	) ,
	RFM_calculation as (
		select *,
			NTILE(4) OVER (ORDER BY Recency DESC) AS R,
			NTILE(4) OVER (ORDER BY Frequency ASC) AS F ,
			NTILE(4) OVER (ORDER BY Monetary ASC) AS M 
		from RFM_statistics
	)
	select *, 
		concat (R,F, M) as 'RFM Index'
	from RFM_calculation

----------------------------------------------------------


with 
	RFM_statistics as (
		select 
			CustomerID,
			ABS(datediff(max(STR_TO_DATE(Purchase_Date,'%m/%d/%Y')), '2022-09-01')) as Recency ,
			ifnull(round(count(distinct(Purchase_Date))/round(abs(datediff(max(cast(created_date as DATE)),'2022-09-01'))/365,0),2),0) as Frequency ,
			ifnull(round(sum(GMV)/round(abs(datediff(max(cast(created_date as DATE)),'2022-09-01'))/365,0),0),0) AS Monetary
		from customer_transaction CT 
		RIGHT join Customer_Registered CR ON CT.CustomerID = CR.ID
		where CustomerID <> 0 and GMV <> 0 
		group by CustomerID
	) ,
	RFM_calculation as (
		select *,
			case 
				when Recency >= 1 and Recency < 31 then '4'
				when Recency >= 31 and Recency < 62 then '3'
				when Recency >= 62 and Recency < 92 then '2'
				else '1'
			end AS R,
			case 
				when Frequency >= 0 and Frequency < 0.25 then '1'
				when Frequency >= 0.25 and Frequency < 0.5 then '2'
				when Frequency >= 0.5 and Frequency < 1 then '3'
				else '4'
			end AS F,
			case 
				when Monetary >= 0 and Monetary < 15000 then '1'
				when Monetary >= 15000 and Monetary < 50000 then '2'
				when Monetary >= 50000 and Monetary < 100000 then '3'
				else '4'
			end AS M
		from RFM_statistics
	) ,
	mapping_RFM as (
		select *, 
			concat (R,F, M) as RFM
		from RFM_calculation
	) 
-- 	segmentation_customer as (
		select *,
			case 
				when RFM in ('444','443','434','344','343') then 'Champions'
				when RFM in ('442','441','433','432','431','423','342','341','334','333','332','331') then 'Loyal Customers'
				when RFM in ('422','421','412','411','321','311') then 'Recent Customers'
				when RFM in ('424','414','413','324','314','313','312') then 'Promissing'
				when RFM in ('323','322','224','223') then 'Customer needing attention'
				when RFM in ('243','242','234','233','231','222') then 'At risk'
				when RFM in ('244','232','214','213','144','143','134','133','124','123','114','113') then 'Cant lose them'
				when RFM in ('241','221','212','211','142','132','122') then 'Hibernating'
				else 'Lost'
			end as Segmentation
		from mapping_RFM
			
