/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [S No]
      ,[Destination_Latitude]
      ,[Destination_Longitude]
      ,[Total_Demand]
      ,[ClusterNo]
  FROM [DB1].[dbo].['ClusterDataPython]


  SELECT 
      [Destination_Latitude]
      ,[Destination_Longitude]
      ,[Total_Demand]
      ,[ClusterNo]
	  ,[Destination_Latitude]*[Total_Demand] as Weighted_Lat
	  ,[Destination_Longitude]*[Total_Demand] as weighted_Long

	  Into [DB1].[dbo].Cluster_01
  FROM [DB1].[dbo].['ClusterDataPython]


  select * from [DB1].[dbo].Cluster_01

  drop table if exists [DB1].[dbo].Cluster_02_Grp

  select SUM([Total_Demand]) as [Total_Demand]
		,SUM( Weighted_Lat) as  T_Weighted_Lat
		,SUM( weighted_Long) as  T_weighted_Long
		,[ClusterNo]
		,COUNT([ClusterNo]) as store_count
  Into [DB1].[dbo].Cluster_02_Grp
  from [DB1].[dbo].Cluster_01
		  group By [ClusterNo]
		  having COUNT([ClusterNo])>10

drop table if exists  [DB1].[dbo].Cluster_03_WH
select *
	,T_Weighted_Lat/[Total_Demand] as WH_Lat
	,T_weighted_Long/[Total_Demand] as WH_Long
	,concat('WH',[ClusterNo]) as cluster_name
Into [DB1].[dbo].Cluster_03_WH
from [DB1].[dbo].Cluster_02_Grp


select * from [DB1].[dbo].Cluster_03_WH



drop table if exists [DB1].[dbo].Cluster_05_Lat

SELECT [WH0] as WH_Lat_0
      ,[WH2] as WH_Lat_2
	  ,[WH3] as WH_Lat_3 
	  , 1 as id
into [DB1].[dbo].Cluster_05_Lat
FROM [DB1].[dbo].Cluster_03_WH
PIVOT 
( 
SUM(WH_Lat) FOR cluster_name 
IN (   [WH0],
    [WH2],
    [WH3] ) 
) AS PivotTable 
select * from [DB1].[dbo].Cluster_05_Lat

drop table if exists [DB1].[dbo].Cluster_05_Long

SELECT [WH0] as WH_Long_0
      ,[WH2] as WH_Long_2
	  ,[WH3] as WH_Long_3 
	  , 1 as id
into [DB1].[dbo].Cluster_05_Long
FROM [DB1].[dbo].Cluster_03_WH
PIVOT 
( 
SUM(WH_Long) FOR cluster_name 
IN (   [WH0],
    [WH2],
    [WH3] ) 
) AS PivotTable 

select Min(WH_Lat_0) as WH_Lat_0
, Min(WH_Lat_2) as WH_Lat_2
, Min(WH_Lat_3) as WH_Lat_3
, id
into  [DB1].[dbo].Cluster_05_Lat_1
from [DB1].[dbo].Cluster_05_Lat
group by id

select * from [DB1].[dbo].Cluster_05_Lat_1

select Min(WH_Long_0) as WH_Long_0
, Min(WH_Long_2) as WH_Long_2
, Min(WH_Long_3) as WH_Long_3
, id
into  [DB1].[dbo].Cluster_05__Long_1
from [DB1].[dbo].Cluster_05_Long
group by id

select * from [DB1].[dbo].Cluster_05_Lat
select * from [DB1].[dbo].Cluster_05_Long


select	a.WH_Lat_0, a.WH_Lat_2, a.WH_Lat_3, 
		b.WH_Long_0, b.WH_Long_2, b.WH_Long_3 
from [DB1].[dbo].Cluster_05_Lat_1 a , [DB1].[dbo].Cluster_05__Long_1 b
