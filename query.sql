--	Find the total number of heart attack incidences for each age group in Germany
select age_group,sum(heart_attack_incidence) as total
from heartattackdata
group by  Age_Group;

--	Calculate the average BMI for each gender across all states
SELECT 
    Gender,State,
   round( AVG(BMI),2) AS Average_BMI
FROM heartattackdata
GROUP BY Gender,State;

--	List the top 5 states with the highest heart attack incidence rates among youth

select state,Age_Group, max(Region_Heart_Attack_Rate) as highest
from heartattackdata
where Age_Group='youth'
group by Age_Group,State
order by highest desc
limit 5;

--	Count the number of heart attack incidences in urban areas compared to rural areas

SELECT Urban_Rural, COUNT(*) AS Heart_Attack_Count
FROM heartattackdata
WHERE Heart_Attack_Incidence = 1
GROUP BY Urban_Rural;

--	Find the average heart attack incidence by socioeconomic status.
SELECT Socioeconomic_Status,AVG(heart_attack_incidence) AS AverageHeartAttackIncidence
FROM heartattackdata
GROUP BY Socioeconomic_Status
ORDER BY AverageHeartAttackIncidence DESC;

--	Identify the year with the highest heart attack incidences for adults.
select Year,Age_Group, sum(Heart_Attack_Incidence) as total
from heartattackdata
where Age_Group ='adult'
group by Year
order by total desc
limit 5;

--	Compare the heart attack incidence rates between youth and adults by region.
select Urban_Rural,age_group,round(sum(Region_Heart_Attack_Rate) ,2) as totalrates
from heartattackdata
where Age_Group in ('youth' ,'adult')
group by Urban_Rural,Age_Group
order by Urban_Rural,Age_Group;


--	Calculate the percentage of smokers who have had heart attacks across all age groups.

SELECT Age_Group,round(SUM(CASE WHEN Smoking_Status = 'Smoker' AND Heart_Attack_Incidence > 0 THEN 1 ELSE 0 END) * 100.0 / 
          SUM(CASE WHEN Smoking_Status = 'Smoker' THEN 1 ELSE 0 END), 2) AS PercentageOfSmokersWithHeartAttacks
FROM heartattackdata
group by Age_Group
order by PercentageOfSmokerswithHeartAttacks desc;

--	Find the average physical activity level for states with below-average heart attack rates

SELECT round(AVG(Physical_Activity_Level), 2) AS AvgPhysicalActivityLevel
FROM heartattackdata
WHERE Region_Heart_Attack_Rate < (
        SELECT AVG(Region_Heart_Attack_Rate) 
        FROM heartattackdata);
        
--	List the years in which alcohol consumption was above the national average
SELECT  distinct Year,round(AVG(Alcohol_Consumption), 2) AS NationalAverage
FROM heartattackdata
group by Year
order by year desc
limit 5;


 Group the data by gender and calculate the median heart attack incidence.	
WITH GenderRanked AS (	
    SELECT 	
        Gender,	
        Heart_Attack_Incidence,	
        ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY Heart_Attack_Incidence) AS RowNum,	
        COUNT(*) OVER (PARTITION BY Gender) AS TotalCount	
    FROM heartattackdata	
),	
MedianValues AS (	
    SELECT 	
        Gender,	
        CASE 	
            WHEN TotalCount % 2 = 1 THEN 	
                MAX(CASE WHEN RowNum = (TotalCount + 1) / 2 THEN Heart_Attack_Incidence END)	
            ELSE	
                AVG(CASE WHEN RowNum IN (TotalCount / 2, TotalCount / 2 + 1) THEN Heart_Attack_Incidence END)	
        END AS MedianHeartAttack	
    FROM GenderRanked	
    GROUP BY Gender, TotalCount	
)	
SELECT 	
    Gender, 	
    MedianHeartAttack	
FROM MedianValues;	
	
F27 Find the maximum and minimum heart attack incidences for each state and year	
select 	
	State,
	years,
    max(Heart_Attack_Incidence) maximum_value,	
    min(Heart_Attack_Incidence) minimum_value	
from heartattackdata	
group by State,years	
order by years,State;	
	
-- Calculate the average stress level for states with the top 10 highest air pollution indices.	
select 	
	State,
	Stress_Level,
    Air_Pollution_Index	
from heartattackdata	
group by State,Stress_Level,Air_Pollution_Index	
order by Air_Pollution_Index desc	
limit 10;	
	
-- Group the data by education level and Find the average cholesterol level for each group.	
select 	
	Education_Level,
    round(avg(Cholesterol_Level),2) Average_cholesterol_level	
from heartattackdata	
group by Education_Level;	
	
-- calculate the average heart attack rate in regions with above-average healthcare access.	
select 	
	round(avg(Region_Heart_Attack_Rate),2)
from heartattackdata	
where Healthcare_Access >	
(	
	select avg(Healthcare_Access)
	from heartattackdata
);	
-- Compare the total heart attack incidence rates for urban vs. rural areas grouped by socioeconomic status.	
select	
	Socioeconomic_Status,
	Urban_Rural,
    round(sum(Region_Heart_Attack_Rate),2) total_heart_attack_incidence_rates	
from heartattackdata	
group by Socioeconomic_Status,Urban_Rural	
order by total_heart_attack_incidence_rates desc;	
	
-- Find the most common diet quality rating among youth with heart attacks.	
select 	
	Diet_Quality,
	count(Diet_Quality) the_most_common_diet_quality
from heartattackdata	
where Age_Group = "Youth"	
and Heart_Attack_Incidence > 0	
group by Diet_Quality	
order by the_most_common_diet_quality desc	
limit 1;	
	
-- Identify the states where the heart attack incidence rate increased year-over-year for three consecutive years.	
WITH YearlyTrends AS (	
    SELECT 	
        State,	
        years,	
        Region_Heart_Attack_Rate,	
        LAG(Region_Heart_Attack_Rate) OVER (PARTITION BY State ORDER BY years) AS PrevYear1,	
        LAG(Region_Heart_Attack_Rate, 2) OVER (PARTITION BY State ORDER BY years) AS PrevYear2	
    FROM heartattackdata	
),	
ConsecutiveIncrease AS (	
    SELECT 	
        State,	
        years	
    FROM YearlyTrends	
    WHERE 	
        Region_Heart_Attack_Rate > PrevYear1 AND	
        PrevYear1 > PrevYear2	
)	
SELECT DISTINCT State	
FROM ConsecutiveIncrease	
ORDER BY State;	
	
-- calculate the average physical activity level grouped by employment status.	
select 	
	Employment_Status,
	avg(Physical_Activity_Level) average_physical_activity_level
from heartattackdata	
group by Employment_Status;	
	
-- Using a subquery, Find the states where the average BMI is above the national average.	
select 	
	State,
    round(avg(BMI),2) above_the_national_average	
from heartattackdata	
group by State	
having avg(BMI) > 	
(	
	select avg(BMI)
    from heartattackdata	
)	
order by above_the_national_average desc;	
	
-- Find the states where the youth heart attack rate is higher than the adult rate Using a self-join.	
SELECT	
	y.State
FROM	
    heartattackdata y	
JOIN	
    heartattackdata a	
ON	
     y.State = a.State	
WHERE	
    y.Age_Group = 'Youth'	
    AND a.Age_Group = 'Adult'	
    AND y.Heart_Attack_Incidence > a.Heart_Attack_Incidence;	
	
-- Identify the regions with heart attack rates above the average for their socioeconomic status Using a correlated subquery.	
WITH AvgRates AS (	
    SELECT 	
        Socioeconomic_Status,	
        AVG(Region_Heart_Attack_Rate) AS Avg_Heart_Attack_Rate	
    FROM 	
        heartattackdata	
    GROUP BY 	
        Socioeconomic_Status	
)	
SELECT 	
    h1.State,	
    h1.Region_Heart_Attack_Rate,	
    h1.Socioeconomic_Status	
FROM 	
    heartattackdata AS h1	
JOIN 	
    AvgRates AS ar	
ON 	
    h1.Socioeconomic_Status = ar.Socioeconomic_Status	
WHERE 	
    h1.Region_Heart_Attack_Rate > ar.Avg_Heart_Attack_Rate	
ORDER BY 	
    h1.Socioeconomic_Status, h1.Region_Heart_Attack_Rate DESC	
LIMIT 50000;	
	
-- Write a query to Find the states with the highest incidence rate for smokers and Compare it to nonsmokers Using a join.	
WITH SmokerRates AS (	
    SELECT 	
        State,	
        MAX(Heart_Attack_Incidence) AS MaxSmokerRate	
    FROM heartattackdata	
    WHERE Smoking_Status = 'Smoker'	
    GROUP BY State	
),	
NonSmokerRates AS (	
    SELECT 	
        State,	
        MAX(Heart_Attack_Incidence) AS MaxNonSmokerRate	
    FROM heartattackdata	
    WHERE Smoking_Status = 'Non-Smoker'	
    GROUP BY State	
)	
SELECT 	
    s.State,	
    s.MaxSmokerRate AS SmokerRate,	
    n.MaxNonSmokerRate AS NonSmokerRate,	
    CASE 	
        WHEN s.MaxSmokerRate > n.MaxNonSmokerRate THEN 'Smokers have higher rates'	
        WHEN s.MaxSmokerRate < n.MaxNonSmokerRate THEN 'Non-Smokers have higher rates'	
        ELSE 'Rates are equal'	
    END AS Comparison	
FROM SmokerRates s	
LEFT JOIN NonSmokerRates n 	
ON s.State = n.State	
ORDER BY s.State;	
	
-- Use a subquery to Find states with higher-than-average stress levels but lower-than-average heart attack incidences.	
SELECT 	
    State,	
    AVG(Stress_Level) AS AvgStressLevel,	
    AVG(Heart_Attack_Incidence) AS AvgHeartAttackIncidence	
FROM heartattackdata	
GROUP BY State	
HAVING 	
    AVG(Stress_Level) > (SELECT AVG(Stress_Level) FROM heartattackdata)	
    AND AVG(Heart_Attack_Incidence) < (SELECT AVG(Heart_Attack_Incidence) FROM heartattackdata)	
ORDER BY State;	
	
-- calculate the yearly percentage change in heart attack rates for each state.	
SELECT 	
    State,	
    years,	
    Heart_Attack_Incidence,	
    LAG(Heart_Attack_Incidence) OVER (PARTITION BY State ORDER BY years) AS PreviousYearRate,	
    CASE 	
        WHEN LAG(Heart_Attack_Incidence) OVER (PARTITION BY State ORDER BY years) IS NOT NULL THEN 	
            ((Heart_Attack_Incidence - LAG(Heart_Attack_Incidence) OVER (PARTITION BY State ORDER BY years)) 	
            / LAG(Heart_Attack_Incidence) OVER (PARTITION BY State ORDER BY years)) * 100	
        ELSE NULL	
    END AS PercentageChange	
FROM heartattackdata	
group by State,years,Heart_Attack_Incidence	
ORDER BY State, years;	
	
-- Rank the states by heart attack incidence rate in adults, partitioned by year.	
SELECT 	
    State,	
    years,	
    sum(Heart_Attack_Incidence) Total_Heart_Attack_Incidence,	
    RANK() OVER (PARTITION BY years ORDER BY sum(Heart_Attack_Incidence) DESC) AS Rank1	
FROM heartattackdata	
WHERE Age_Group = 'Adult'	
group by State,years	
ORDER BY years, Rank1;	
	
-- calculate the running total of heart attack incidences for youth in Germany, partitioned by year.	
SELECT 	
    distinct years,	
    State,	
    SUM(Heart_Attack_Incidence) OVER (PARTITION BY years ORDER BY State) AS Running_Total	
FROM 	
    heartattackdata	
WHERE 	
    Age_Group = 'Youth'	
ORDER BY 	
    years, State;	
	
-- Find the cumulatiive average cholesterol level for each state and year.	
SELECT 	
    State,	
    years,	
    round(AVG(Cholesterol_Level) OVER (PARTITION BY State ORDER BY years ROWS UNBOUNDED PRECEDING),2) AS CumulativeAvgCholesterol	
FROM heartattackdata	
ORDER BY State, years;	
	
-- Use a window function to identify the top 3 states with the highest youth heart attack rates each year.	
WITH RankedStates AS (	
    SELECT 	
        State,	
        years,	
        sum(Heart_Attack_Incidence) highest_youth_heart_attack_rates,	
        RANK() OVER (PARTITION BY years ORDER BY sum(Heart_Attack_Incidence) DESC) AS Rank1	
    FROM heartattackdata	
    WHERE Age_Group = 'Youth'	
    group by State,years	
)	
SELECT 	
    State,	
    years,	
    highest_youth_heart_attack_rates,	
    Rank1	
FROM RankedStates	
WHERE Rank1 <= 3	
group by state,years,highest_youth_heart_attack_rates,Rank1	
ORDER BY years, Rank1;	
	
-- calculate the difference in heart attack rates between urban and rural areas for each state Using a lag function.	
SELECT 	
    State,	
    Urban_Rural,	
    Heart_Attack_Incidence,	
    LAG(Heart_Attack_Incidence) OVER (PARTITION BY State ORDER BY Urban_Rural) AS PreviousRate,	
    Heart_Attack_Incidence - LAG(Heart_Attack_Incidence) OVER (PARTITION BY State ORDER BY Urban_Rural) AS RateDifference	
FROM heartattackdata	
WHERE Urban_Rural IN ('Urban', 'Rural')	
ORDER BY State, Urban_Rural;	
	
-- Find the correlation between air pollution index and heart attack incidence rates.	
SELECT 	
    (COUNT(*) * SUM(Air_Pollution_Index * Heart_Attack_Incidence) - SUM(Air_Pollution_Index) * SUM(Heart_Attack_Incidence)) /	
    (SQRT((COUNT(*) * SUM(POW(Air_Pollution_Index, 2)) - POW(SUM(Air_Pollution_Index), 2)) *	
          (COUNT(*) * SUM(POW(Heart_Attack_Incidence, 2)) - POW(SUM(Heart_Attack_Incidence), 2)))) AS Correlation	
FROM heartattackdata;	
	
-- Identify the regions with a consistent increase in heart attack rates across all socioeconomic levels.	
WITH Trend AS (	
    SELECT 	
        Region_Heart_Attack_Rate,	
        Socioeconomic_Status,	
        years,	
        Heart_Attack_Incidence,	
        LAG(Heart_Attack_Incidence) OVER (PARTITION BY Region_Heart_Attack_Rate, Socioeconomic_Status ORDER BY years) AS PreviousRate	
    FROM heartattackdata	
)	
SELECT DISTINCT Region_Heart_Attack_Rate	
FROM Trend	
WHERE Heart_Attack_Incidence > PreviousRate	
GROUP BY Region_Heart_Attack_Rate	
HAVING COUNT(DISTINCT Socioeconomic_Status) = (	
    SELECT COUNT(DISTINCT Socioeconomic_Status) FROM heartattackdata	
);	
	
-- Analyze the effect of diabetes on heart attack incidences for different age groups Using a Group-by analysis.	
SELECT 	
    Age_Group,	
    Diabetes,	
    round(AVG(Heart_Attack_Incidence),2) AS AvgHeartAttackRate	
FROM heartattackdata	
GROUP BY Age_Group, Diabetes;	
	
-- calculate the year-over-year growth in heart attack incidences for youth in Germany.	
SELECT 	
    years,	
    Heart_Attack_Incidence,	
    LAG(Heart_Attack_Incidence) OVER (PARTITION BY years ORDER BY years) AS PreviousYearRate,	
    (Heart_Attack_Incidence - LAG(Heart_Attack_Incidence) OVER (PARTITION BY years ORDER BY years)) /	
    LAG(Heart_Attack_Incidence) OVER (PARTITION BY years ORDER BY years	) * 100 AS GrowthRate
FROM heartattackdata	
WHERE Age_Group = 'Youth';	
	
-- Determine if smoking status or alcohol consumption has a stronger correlation with heart attack incidences.	
     -- smoking correlation	
SELECT 	
    (AVG((s.Smoking_Status - sub.avg_smoking) * (s.Heart_Attack_Incidence - sub.avg_incidence)) / 	
    (SQRT(AVG(POWER(s.Smoking_Status - sub.avg_smoking, 2))) * 	
     SQRT(AVG(POWER(s.Heart_Attack_Incidence - sub.avg_incidence, 2))))) AS SmokingCorrelation	
FROM 	
    (SELECT 	
         AVG(Smoking_Status) AS avg_smoking, 	
         AVG(Heart_Attack_Incidence) AS avg_incidence	
     FROM heartattackdata) sub,	
    heartattackdata s;	
     -- Alcohol Correlation 	
SELECT 	
    (AVG((a.Alcohol_Consumption - sub.avg_alcohol) * (a.Heart_Attack_Incidence - sub.avg_incidence)) / 	
    (SQRT(AVG(POWER(a.Alcohol_Consumption - sub.avg_alcohol, 2))) * 	
     SQRT(AVG(POWER(a.Heart_Attack_Incidence - sub.avg_incidence, 2))))) AS AlcoholCorrelation	
FROM 	
    (SELECT 	
         AVG(Alcohol_Consumption) AS avg_alcohol, 	
         AVG(Heart_Attack_Incidence) AS avg_incidence	
     FROM heartattackdata) sub,	
    heartattackdata a;	
	
-- Analyze the impact of education level on physical activity levels and its effect on heart attack rates.	
SELECT 	
    Education_Level,	
    round(AVG(Physical_Activity_Level),2) AS AvgPhysicalActivity,	
    round(AVG(Heart_Attack_Incidence),2) AS AvgHeartAttackRate	
FROM heartattackdata	
GROUP BY Education_Level;	
	
-- Identify the states where family history has the highest influence on heart attack rates, controlling for age Group and gender.	
WITH FamilyHistoryEffect AS (	
    SELECT 	
        State,	
        Age_Group,	
        Gender,	
        Family_History,	
        AVG(Heart_Attack_Incidence) AS Avg_Heart_Attack_Incidence	
    FROM 	
        heartattackdata	
    GROUP BY 	
        State, Age_Group, Gender, Family_History	
),	
StateImpact AS (	
    SELECT 	
        State,	
        Age_Group,	
        Gender,	
        MAX(CASE WHEN Family_History = 'Yes' THEN Avg_Heart_Attack_Incidence ELSE 0 END) AS Avg_With_Family_History,	
        MAX(CASE WHEN Family_History = 'No' THEN Avg_Heart_Attack_Incidence ELSE 0 END) AS Avg_Without_Family_History,	
        MAX(CASE WHEN Family_History = 'Yes' THEN Avg_Heart_Attack_Incidence ELSE 0 END) -	
        MAX(CASE WHEN Family_History = 'No' THEN Avg_Heart_Attack_Incidence ELSE 0 END) AS FamilyHistoryInfluence	
    FROM 	
        FamilyHistoryEffect	
    GROUP BY 	
        State, Age_Group, Gender	
)	
SELECT 	
    State,	
    Age_Group,	
    Gender,	
    FamilyHistoryInfluence	
FROM 	
    StateImpact	
ORDER BY 	
    FamilyHistoryInfluence DESC	
LIMIT 10;	
	
-- Use a CTE (common Table Expression) to Find the average diet quality and its relationship to heart attack rates in adults.	
WITH DietQualityStats AS (	
    SELECT 	
        Diet_Quality,	
        round(AVG(Heart_Attack_Incidence),2) AS Avg_Heart_Attack_Incidence,	
        COUNT(*) AS Total_Adults	
    FROM 	
        heartattackdata	
    WHERE 	
        Age_Group = 'Adult'	
    GROUP BY 	
        Diet_Quality	
)	
SELECT 	
    Diet_Quality,	
    Avg_Heart_Attack_Incidence,	
    Total_Adults	
FROM 	
    DietQualityStats	
ORDER BY 	
    Avg_Heart_Attack_Incidence DESC;	
	
-- Analyze the relationship between hypertension and cholesterol levels and their combined effect on heart attack incidence rates.	
WITH HypertensionCholesterolStats AS (	
    SELECT 	
        Hypertension,	
        CASE 	
            WHEN Cholesterol_Level < 150 THEN 'Low'	
            WHEN Cholesterol_Level BETWEEN 150 AND 200 THEN 'Normal'	
            ELSE 'High'	
        END AS Cholesterol_Category,	
        AVG(Heart_Attack_Incidence) AS Avg_Heart_Attack_Incidence,	
        COUNT(*) AS Total_Individuals	
    FROM 	
        heartattackdata	
    GROUP BY 	
        Hypertension, 	
        Cholesterol_Category	
)	
SELECT 	
    Hypertension,	
    Cholesterol_Category,	
    Avg_Heart_Attack_Incidence,	
    Total_Individuals	
FROM 	
    HypertensionCholesterolStats	
ORDER BY 	
    Hypertension DESC, 	
    Cholesterol_Category ASC;	
	
-- Write a query to segment the population into high-risk and low-risk groups for heart attacks based on stress level, BMI, and healthcare access.	
SELECT 	
    CASE 	
        WHEN Stress_Level > 70 AND BMI > 30 AND Healthcare_Access < 50 THEN 'High-Risk'	
        ELSE 'Low-Risk'	
    END AS RiskGroup,	
    COUNT(*) AS PopulationCount	
FROM heartattackdata	
GROUP BY RiskGroup;	
	
	









