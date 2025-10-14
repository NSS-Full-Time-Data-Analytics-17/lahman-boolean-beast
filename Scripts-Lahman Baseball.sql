SELECT *
FROM homegames;

SELECT *
FROM teams;
----Q.1----What range of years for baseball games played does the provided database cover?
SELECT MIN(year)
FROM homegames;

SELECT max(year)
FROM homegames;

SELECT MIN(yearid)
FROM teams;

SELECT max(yearid)
FROM teams;


------the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

----Q2--THE name and height of the shortest player in the database----'Eddie Gaedel,43'

SELECT*
FROM people;

SELECT namefirst AS first_name,namelast AS last_name ,MIN(height) as min_height
FROM people
GROUP BY first_name,last_name
ORDER BY min_height asc
LIMIT 1
----- How many games did he play in?----Team name sla-
SELECT*
FROM people;
SELECT*
FROM appearances;
SELECT*
FROM teams

SELECT teamid,namefirst,namelast,height
FROM people AS p
LEFT JOIN appearances AS a USING (playerid)
WHERE namefirst = 'Eddie' AND namelast = 'Gaedel';


----- How many games did he play in------St.Louis Browns----------


SELECT a.teamid AS teamname,g_all,namefirst,namelast,height,t.name AS team_name
FROM people AS p
LEFT JOIN appearances AS a USING (playerid)
LEFT JOIN teams AS t USING (teamid)
WHERE namefirst = 'Eddie' AND namelast = 'Gaedel'
GROUP BY teamname,namefirst,namelast,height,g_all,t.name;


----Q,3----- all players in the database who played at Vanderbilt University.

SELECT *
FROM people
SELECT *
FROM salaries;
SELECT *
FROM collegeplaying;
SELECT*
FROM schools;
-------David Price Vanderbilt player earned the most money in the majors---with total salary '245553888'-----
SELECT p.namefirst,p.namelast,s.schoolname,SUM(sa.salary) AS total_salary
FROM people AS p
LEFT JOIN collegeplaying  AS c USING (playerid)
LEFT JOIN schools AS s USING (schoolid)
INNER JOIN salaries AS sa ON p.playerid = sa.playerid
WHERE s.schoolname ILIKE '%Vanderbilt%'
GROUP BY p.namefirst,p.namelast,s.schoolname
ORDER BY total_salary DESC

----Q4.. group players into three groups based on their position: label players with position OF as "Outfield",position "SS", "1B", "2B", and "3B" -INfield
--and those with position "P" or "C" as "Battery"..

---Determine the number of putouts made by each of these three groups in 2016.


SELECT *
FROM fielding;

SELECT yearid,
     CASE WHEN pos = 'OF' THEN 'Outfield'
	      WHEN pos IN ('ss','1B','2B','3B') THEN 'Infield'
		  WHEN pos IN ('P','C') THEN 'Battery'
		  ELse 'Other' END as position, SUM(po) As total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position,yearid
ORDER BY total_putouts

------Q5,--average number of strikeouts per game by decade since 1920-------

SELECT *
FROM batting

SELECT (yearid/10 * 10) AS decade,ROUND(AVG(so::numeric / g), 2) AS strikeout_average_per_game,ROUND(AVG(hr::numeric / g), 2) AS homerun_average_per_game
FROM batting AS b
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;


--Q6...player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful...
-----Chris Owings---highest success rate of 91.30 ---
SELECT *
FROM people
SELECT *
FROM batting

WITH total_stolenbase AS (SELECT playerid, SUM(sb) AS total_sb,SUM(cs) AS total_cs
                    FROM batting
					WHERE yearid = 2016 
					GROUP BY playerid
					HAVING SUM(sb + cs) >=20)
					
SELECT p.namefirst, p.namelast,ROUND((ts.total_sb::numeric/(ts.total_sb + ts.total_cs)) * 100, 2) AS success_rate
FROM total_stolenbase AS ts
INNER JOIN people AS p USING (playerid)
ORDER BY success_rate desc
LIMIT 1;


------Q,7..From 1970 – 2016, what is the largest number of wins for a team that did not win the world series

SELECT *
FROM teams;
---Max wins---116 (Seatle Mariners 2001) who did not win world series---
SELECT name, yearid, w,wswin
FROM teams
WHERE wswin = 'N'
AND yearid BETWEEN 1970 AND 2016 
ORDER BY w desc
---MIN WINS --63(Los Angeles Dodgers in 1981) problem year 1981  as because The 1981 MLB season had the fewest wins because it was shortened by a 50-day strike. 
SELECT name, yearid, w,wswin
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN 1970 AND 2016 
ORDER BY w ;
------ST.Louis Cardinals '2006'  has the leaset win '83'after  year 1981 excluded.

SELECT name, yearid, w,wswin
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN 1970 AND 2016 
AND yearid <> 1981
ORDER BY w;
 --Excluding the year 1981 --min win  who did not won world series--
SELECT name, yearid, w,wswin
FROM teams
WHERE wswin = 'N'
AND yearid BETWEEN 1970 AND 2016 
AND yearid <> 1981
ORDER BY w ;

-----------How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

----team with most wins also won the world series--
---max wins 114 who won world series---
WITH most_wins AS (SELECT name,yearid, MAX(w)
                   FROM teams
                     WHERE wswin = 'Y'
                    AND yearid BETWEEN 1970 AND 2016 
                     AND yearid <> 1981
					 GROUP BY name, yearid)

				  

--------------