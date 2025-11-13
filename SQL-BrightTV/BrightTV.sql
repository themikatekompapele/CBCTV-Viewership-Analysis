SELECT * FROM user_profiles;

SELECT * FROM viewership;


-- General checks

SELECT 
    MIN(age),
    MAX(age)
FROM user_profiles;

SELECT 
    MIN(LOCAL_TIMESTAMP),
    MAX(LOCAL_TIMESTAMP),
    --AVG(duration_2)
FROM viewership;


-- Checking number of records

SELECT COUNT(*)
FROM user_profiles;

SELECT COUNT(DISTINCT userid)
FROM user_profiles;

SELECT COUNT(*)
FROM viewership;

SELECT COUNT(userid)
FROM viewership;



-- Checking for completely duplicates rows

SELECT *, 
    COUNT(*)
FROM user_profiles
GROUP BY ALL
HAVING COUNT(*) > 1;

SELECT *, 
    COUNT(*)
FROM viewership
GROUP BY ALL
HAVING COUNT(*) > 1; --(5 recodrs have duplicates)



-- Creating a temporary table with no duplicates as viewership_new

SELECT DISTINCT *
FROM viewership;

CREATE OR REPLACE TEMPORARY TABLE viewership_new AS (
    SELECT DISTINCT *
    FROM viewership
);

SELECT *, 
    COUNT(*)
FROM viewership_new
GROUP BY ALL
HAVING COUNT(*) > 1;

SELECT COUNT(*)
FROM viewership_new;



-- Checking for missing values in the tables

SELECT * FROM user_profiles
WHERE userid IS NULL OR NAME IS NULL OR surname IS NULL OR email IS NULL OR gender IS NULL OR RACE IS NULL OR AGE IS NULL OR PROVINCE IS NULL OR SOCIAL_MEDIA_HANDLE IS NULL;

SELECT * FROM viewership_new
WHERE userid IS NULL OR channel2 IS NULL OR recorddate2 IS NULL OR duration_2 IS NULL OR userid2 IS NULL OR local_timestamp IS NULL OR month IS NULL OR year IS NULL;



-- Replacing missing records with 'None' and creating a temp table

CREATE OR REPLACE TEMP TABLE user_profiles_new AS (
    SELECT 
        userid,
        age,
        IFNULL(name, 'None') AS Name,
        IFNULL(surname, 'None') AS Surname,
        IFNULL(email, 'None') AS email,
        IFNULL(gender, 'None') AS Gender,
        IFNULL(race, 'None') AS Race,
        IFNULL(province, 'None') AS Province,
        IFNULL(social_media_handle, 'None') AS social_media_handle,
        CASE
            WHEN age BETWEEN 1 AND 12 THEN 'Younger than 13'
            WHEN age BETWEEN 13 AND 25 THEN '13 to 25'
            WHEN age BETWEEN 26 AND 44 THEN '26 to 44'
            WHEN age >= 45 THEN '45 and older'
            ELSE 'Not Specified'
        END AS Age_group
    FROM user_profiles
);



-- Display users who have watched something, including the channels watched and the time of day.


SELECT
    u.userid,
    u.Name,
    u.Surname,
    u.Gender,
    u.Race,
    u.Province,
    u.Age_group,
    v.channel2,
    v.duration_2,
    CASE
        WHEN v.duration_2 between '00:00:00' AND '02:59:59' THEN '0 - 3 Hrs'
        WHEN v.duration_2 between '03:00:00' AND '05:59:59' THEN '3 - 6 Hrs'
        WHEN v.duration_2 between '06:00:00' AND '08:59:59' THEN '6 - 9 Hrs'
        ELSE '9 - 12 Hrs'
    END AS Watch_Duration,
    v.day,
    v.time,
    CASE
        WHEN v.time between '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN v.time between '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN v.time between '18:00:00' AND '23:59:59' THEN 'Evening'
        ELSE 'Night'
    END AS Time_Type,
    v.month
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid;



-- Display the users and viewership per channel

SELECT
    v.channel2 AS Channel,
    COUNT(u.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY v.channel2
ORDER BY user_count DESC;



-- Display the users and viewership per province

SELECT
    u.province,
    COUNT(u.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1
ORDER BY user_count DESC;



-- Display the users and viewership per race

SELECT
    u.race,
    COUNT(u.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1
ORDER BY user_count DESC;



-- Display the count of users and viewership per time of day

SELECT
    CASE
        WHEN v.time between '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN v.time between '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN v.time between '18:00:00' AND '23:59:59' THEN 'Evening'
        ELSE 'Night'
    END AS Time_Type,
    COUNT(u.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;



-- Display the count of users and viewership per duration

SELECT
    CASE
        WHEN v.duration_2 between '00:00:00' AND '02:59:59' THEN '0 - 3 Hrs'
        WHEN v.duration_2 between '03:00:00' AND '05:59:59' THEN '3 - 6 Hrs'
        WHEN v.duration_2 between '06:00:00' AND '08:59:59' THEN '6 - 9 Hrs'
        ELSE '9 - 12 Hrs'
    END AS Watch_Duration,
    COUNT(u.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;



-- Display the average duration per channel

-- SELECT
--     v.channel2 AS channel,
--     AVG(v.duration_2)
-- FROM user_profiles_new AS u
-- INNER JOIN viewership_new AS v ON u.userid = v.userid
-- GROUP BY 1;



-- Display the count of users and viewership per age group

SELECT
    Age_group,
    COUNT(v.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;



-- Display the count of users and viewership per gender

SELECT
    gender,
    COUNT(v.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;



-- Display the count of users and viewership by month

SELECT
    month,
    COUNT(v.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;


-- Display the count of users and viewership by Day

SELECT
    Day,
    COUNT(v.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;












