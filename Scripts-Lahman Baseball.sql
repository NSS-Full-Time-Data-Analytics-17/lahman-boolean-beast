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
---max wins 114 who won world series---
---teams with most wins also won the world series and the percentage
---cte had teams most wins that year 
---2016-1970-(47 years)- 1981 so 46 years
WITH max_wins AS (SELECT yearid, MAX(w) AS max_wins
                   FROM teams
                    WHERE yearid BETWEEN 1970 AND 2016 
                     AND yearid <> 1981
					 GROUP BY yearid)
SELECT COUNT(*) AS years_max_wins,
       ROUND(COUNT(*) * 100.0 / 46, 2) AS percentage
FROM max_wins AS ms
INNER JOIN teams AS t
  ON t.yearid = ms.yearid
  AND t.w = ms.max_wins
WHERE t.wswin = 'Y';
				  

------Q8,find the teams and parks which had the top 5 average attendance per game in 2016 (

SELECT *
FROM homegames;
SELECT *
FROM parks
-----where average attendance is defined as total attendance divided by number of games

SELECT h.team,p.park_name,ROUND(SUM(attendance)::numeric/SUM(h.games), 2) AS average_attendance
FROM homegames AS h
INNER JOIN parks AS p USING (park)
WHERE h.year = 2016 AND h.games >= 10
GROUP BY h.team,p.park_name
ORDER BY average_attendance DESC
LIMIT 5;

------Repeat for the lowest 5 average attendance.
SELECT h.team,p.park_name,ROUND(SUM(attendance)::numeric/SUM(h.games), 2) AS average_attendance
FROM homegames AS h
INNER JOIN parks AS p USING (park)
WHERE h.year = 2016 AND h.games >= 10
GROUP BY h.team,p.park_name
ORDER BY average_attendance ASC
LIMIT 5;

------------------UNION WAY

(SELECT h.team,p.park_name,ROUND(SUM(attendance)::numeric/SUM(h.games), 2) AS average_attendance
FROM homegames AS h
INNER JOIN parks AS p USING (park)
WHERE h.year = 2016 AND h.games >= 10
GROUP BY h.team,p.park_name
ORDER BY average_attendance DESC
LIMIT 5)
UNION
(SELECT h.team,p.park_name,ROUND(SUM(attendance)::numeric/SUM(h.games), 2) AS average_attendance
FROM homegames AS h
INNER JOIN parks AS p USING (park)
WHERE h.year = 2016 AND h.games >= 10
GROUP BY h.team,p.park_name
ORDER BY average_attendance ASC
LIMIT 5)


--------Q,9...managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)....

SELECT *
FROM managers;
SELECT *
FROM awardsmanagers
SELECT*
FROM teams
SELECT DISTINCT lgwin 
FROM teams;

WITH awards_manager AS (SELECT playerid,awardid
                       FROM awardsmanagers
                       WHERE awardid ILIKE '%TSN%'
                        AND lgid IN ('NL','AL')
						GROUP BY playerid,awardid
						HAVING COUNT (DISTINCT lgid) = 2 );
----name of the manger who won both (AL.NL)- Johnson Davey----
SELECT DISTINCT(p.namefirst),p.namelast,t.name,a.lgid,a.yearid
FROM awardsmanagers AS a
INNER JOIN managers AS m USING (playerid, yearid)
	INNER JOIN people AS p USING(playerid)
	INNER JOIN teams AS t USING(teamid, yearid)
WHERE a.playerid IN (SELECT playerid
                       FROM awardsmanagers
                       WHERE awardid ILIKE '%TSN%'
                        AND lgid IN ('NL','AL')
						GROUP BY playerid
						HAVING COUNT (DISTINCT lgid) = 2 )
ORDER BY p.namelast		

----Q10,--players who hit their career highest number of home runs in 2016. --

SELECT *
FROM batting
SELECT *
FROM people;
----------players who have played in the league for at least 10 years---
WITH maxyears_players AS (SELECT playerid
                             FROM batting 
                             GROUP BY playerid
                             HAVING COUNT(DISTINCT yearid) >= 10),
---------------players career highest number of home runs -------------
               max_2016players AS (SELECT playerid, MAX(hr) AS max_homeruns
                                   FROM batting
                                   GROUP BY playerid)
SELECT p.namefirst,p.namelast,b.hr,b.yearid
FROM batting AS b 
INNER JOIN people  AS p USING (playerid)
INNER JOIN maxyears_players AS m USING (playerid)
INNER JOIN max_2016players AS mp USING(playerid)
WHERE b.yearid = 2016 
AND b.hr = mp.max_homeruns
AND b.hr >= 1
ORDER BY b.hr


-----Q,11---correlation between number of wins and team salary

SELECT *
FROM teams

SELECT *
FROM salaries;

SELECT teamid,COUNT(w)
FROM teams
WHERE yearid >= 2000
GROUP BY teamid
----I can see from year 2004 to 2006 correlation of salary is rising could be the reason of more total number of wins and teams are getting more salary--
---after 2007 it started falling -smaller payroll player were more efficient compared to higher ones or might be the finacial reson..
SELECT yearid, CORR(total_wins, total_salary) AS correlation_salary
FROM(
SELECT t.teamid,t.yearid ,t.w AS total_wins,SUM(s.salary) AS total_salary
FROM teams AS t
INNER JOIN salaries AS s USING (teamid,yearid)
WHERE t.yearid >= 2000
GROUP BY t.teamid,t.yearid,t.w
ORDER BY t.yearid) AS yearly_wins_salary
GROUP BY yearid
ORDER BY yearid;

-----Q,12..correlation between attendance at home games and number of wins----

SELECT *
FROM teams;
SELECT *
FROM homegames;

---12 A.-Corelation between total wins and attendance----

SELECT yearid,CORR (total_wins,total_attendance) AS correlation_wins_attendance
FROM (SELECT t.yearid,t.teamid, t.w AS total_wins,SUM(h.attendance) AS total_attendance
      FROM teams AS t
      INNER JOIN homegames AS h ON t.teamid = h.team
	  GROUP BY t.teamid,t.w,t.yearid) AS team_a
GROUP BY yearid	  

-------B-Do teams that win the world series see a boost in attendance the following year

SELECT prev_t.yearid,prev_t.teamid,prev_t.attendance,next_t.yearid,next_t.teamid,next_t.attendance,next_t.attendance - prev_t.attendance AS attendance_boost
FROM teams AS prev_t
INNER JOIN teams AS next_t ON prev_t.teamid = next_t.teamid
AND prev_t.yearid = next_t.yearid - 1
WHERE prev_t.wswin= 'Y'
AND next_t.attendance IS NOT NULL AND prev_t.attendance IS NOT NULL


-------c--Making the playoffs means either being a division winner or a wild card winner(Wcwin-'y')
SELECT prev_t.yearid AS previous_year,prev_t.teamid,prev_t.attendance,next_t.yearid AS next_year,next_t.teamid,next_t.attendance,next_t.attendance - prev_t.attendance AS attendance_boost
FROM teams AS prev_t
INNER JOIN teams AS next_t ON prev_t.teamid = next_t.teamid
AND prev_t.yearid = next_t.yearid - 1
WHERE prev_t.wcwin= 'Y'
AND next_t.attendance IS NOT NULL AND prev_t.attendance IS NOT NULl		


---Q,13...determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award
SELECT *
FROM people
SELECT *
FROM pitching;
SELECT *
FROM halloffame

----Left hand--NUMBER of left hand player who selected for hall of fame is 23.....
SELECT COUNT (DISTINCT p.playerid) AS number_lefthand_player
FROM people AS p
INNER JOIN pitching AS pi USING (playerid)
INNER JOIN halloffame AS h USING (playerid)
WHERE p.throws = 'L' and h.inducted = 'Y'

---percentage of left hand player '22.00 AND RIGHT hand player-77.00--
WITH hand_player AS (SELECT 
                       SUM(CASE WHEN p.throws = 'L' THEN 1 ELSE 0 END) AS lefty,
					   SUM(CASE WHEN p.throws ='R'THEN 1 ELSE 0 END) AS right_hand
					   FROM people AS p
					   INNER JOIN pitching AS pi USING (playerid)
                       INNER JOIN halloffame AS h USING (playerid)
					   WHERE h.inducted ='Y')
SELECT lefty,right_hand,ROUND(lefty * 100 /(lefty + right_hand), 2)  AS lefty_percentage,ROUND(right_hand * 100 /(lefty + right_hand), 2) AS right_percentage
from hand_player;


-----Right hand---NUMBER of righ hand player who selected for hall of fame is 78....

SELECT COUNT(DISTINCT p.playerid) AS number_righthand_player
FROM people AS p
INNER JOIN pitching AS pi USING (playerid)
INNER JOIN halloffame AS h USING (playerid)
WHERE p.throws = 'R' and h.inducted = 'Y'

------------BONUS----------------------------------

-------1,A....the team with the most wins from each league in 2016.....

SELECT MAX(w)
FROM teams

SELECT t1.lgid,t1.teamid,t1.w
FROM teams AS t1
WHERE t1.w = (
          SELECT MAX(t.w) AS max_wins
          FROM teams AS t
           WHERE t.lgid = t1.lgid AND t.yearid = t1.yearid) 
AND t1.yearid = 2016;		   
		   
------if we wanted to pull in not just the teamid but also the number of wins, we couldn't do so using just a single subquery. (Try it and see the error you get).
---error---subquery must return only one column
SELECT t1.lgid,t1.teamid
FROM teams AS t1
WHERE t1.w = (
          SELECT t1.teamid,MAX(t.w) AS max_wins
          FROM teams AS t
           WHERE t.lgid = t1.lgid AND t.yearid = t1.yearid) 
AND t1.yearid = 2016
GROUP BY lgid,t1.teamid;	

-----Multiple corelated subquery--count of wins in select column and max number of wins among all wins in where  clause--
SELECT 
    t1.lgid,
    (SELECT t2.teamid
     FROM teams AS t2
     WHERE t2.lgid = t1.lgid
       AND t2.yearid = 2016
     ORDER BY t2.w DESC
     LIMIT 1) AS top_teamid,
	 (SELECT t3.w
     FROM teams AS t3
     WHERE t3.lgid = t1.lgid
       AND t3.yearid = 2016
     ORDER BY t3.w DESC
     LIMIT 1) AS top_wins
FROM teams AS t1
WHERE t1.yearid = 2016
GROUP BY t1.lgid
ORDER BY t1.lgid;

		   
-----c-- Rewrite your previous query into one which uses DISTINCT ON to return the top team by league in terms of number of wins in 2016.    
-----Your query should return the league, the teamid, and the number of wins

SELECT 
   DISTINCT ON(t1.lgid)lgid,t1.teamid,t1.w
FROM teams AS t1
WHERE t1.yearid = 2016
ORDER BY t1.lgid;
---d-- Rewrite your previous query using the LATERAL keyword so that your result shows the teamid and number of wins for the team--
-------with the most wins from each league in 2016.
SELECT league_year.lgid,TEAMS1.W,teams1.teamid
FROM (SELECT DISTINCT lgid
FROM teams
WHERE yearid = 2016) AS league_year,
LATERAL(
SELECT teamid,w
FROM teams
WHERE teams.lgid = league_year.lgid AND yearid =2016
ORDER BY w DESC
LIMIT 1) AS teams1;
