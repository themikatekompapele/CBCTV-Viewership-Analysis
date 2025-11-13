-- Query to obtain an overview of data
SELECT * FROM user_profiles;

SELECT * FROM viewership;


-- Query to obtain an youngest and oldest viewer age

SELECT 
    MIN(age),
    MAX(age)
FROM user_profiles;
--Query to view earliest and latest viewing time
SELECT 
    MIN(LOCAL_TIMESTAMP),
    MAX(LOCAL_TIMESTAMP),
    --AVG(duration_2)
FROM viewership;


-- Query to count the number of records

SELECT COUNT(*)
FROM user_profiles;

SELECT COUNT(DISTINCT userid)
FROM user_profiles;

SELECT COUNT(*)
FROM viewership;

SELECT COUNT(user_id)
FROM viewership;



-- Query to check for completely duplicates rows

SELECT *, 
    COUNT(*)
FROM user_profiles
GROUP BY ALL
HAVING COUNT(*) > 1;

SELECT *, 
    COUNT(*)
FROM viewership
GROUP BY ALL
HAVING COUNT(*) > 1; --(5 records have duplicates)

-- Query to create a temporary table with no duplicates as viewership_new
WITH viewership_new AS (
    SELECT DISTINCT *
    FROM viewership 
    GROUP BY ALL)
    SELECT *
    FROM viewership;

SELECT *, 
    COUNT(*)
FROM viewership_new
GROUP BY ALL
HAVING COUNT(*) > 1;

SELECT COUNT(*)
FROM viewership_new;



-- Query to check for missing values in the tables

SELECT * FROM user_profiles
WHERE userid IS NULL OR NAME IS NULL OR surname IS NULL OR email IS NULL OR gender IS NULL OR RACE IS NULL OR AGE IS NULL OR PROVINCE IS NULL OR SOCIAL_MEDIA_HANDLE IS NULL;

SELECT * FROM viewership_new
WHERE user_id IS NULL OR channel_2 IS NULL OR record_date_2 IS NULL OR duration_2 IS NULL OR local_timestamp IS NULL OR month IS NULL OR year IS NULL;



-- Query to replace missing records with 'None' and creating a temp table

CREATE OR REPLACE TEMP TABLE
WITH user_profiles_new AS (
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
    GROUP BY ALL)
    SELECT * FROM user_profiles;

-- Query to retrieve data on and display users who have watched something, including the channels watched and the time of day.


SELECT
    u.userid,
    u.Name,
    u.Surname,
    u.Gender,
    u.Race,
    u.Province,
    u.Age_group,
    v.channel_2,
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
INNER JOIN viewership_new AS v ON u.userid = v.user_id;



-- Display the users and viewership per channel

SELECT
    v.channel_2 AS Channel,
    COUNT(u.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.user_id
GROUP BY v.channel_2
ORDER BY user_count DESC;




-- Query to retrieve data on and display the users and viewership per province

SELECT
    u.province,
    COUNT(u.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.user_id
GROUP BY 1
ORDER BY user_count DESC;



-- Query to retrieve data on and display the users and viewership per race

SELECT
    u.race,
    COUNT(u.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1
ORDER BY user_count DESC;



-- Query to retrieve data on and display the count of users and viewership per time of day

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



-- Query to retrieve data on and display the count of users and viewership per duration

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



-- Query to retrieve data on and display the average duration per channel

SELECT
channel_2 AS channel,
    avg(duration_2) AS average_watch_duration
FROM bright_tv_joined
GROUP BY channel;



-- Query to retrieve data on and display the count of users and viewership per age group

SELECT
    Age_group,
    COUNT(v.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;



-- Query to retrieve data on and display the count of users and viewership per gender

SELECT
    gender,
    COUNT(v.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;



-- Query to retrieve data on and display the count of users and viewership by month

SELECT
    month,
    COUNT(v.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;


-- Query to retrieve data on and display the count of users and viewership by Day

SELECT
    Day,
    COUNT(v.userid) AS user_count
FROM user_profiles_new AS u
INNER JOIN viewership_new AS v ON u.userid = v.userid
GROUP BY 1;












