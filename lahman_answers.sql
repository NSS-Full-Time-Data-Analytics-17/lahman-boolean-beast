SELECT DISTINCT(year)
FROM homegames
ORDER BY year;

SELECT DISTINCT(p.namefirst), p.namelast, height,a.teamid,t.name
FROM people AS p FULL JOIN appearances AS a ON p.playerid = a.playerid
			FULL JOIN teams AS t ON t.teamid = a.teamid
ORDER BY height
LIMIT 1;

SELECT schoolname,namefirst,namelast,SUM(salary) As total_salary
FROM schools INNER JOIN collegeplaying USING(schoolid)
			 INNER JOIN people USING (playerid)
			 INNER JOIN salaries USING (playerid)
Where schoolname LIKE 'Vand%'
GROUP BY schoolname,namefirst,namelast
ORDER BY total_salary DESC;

-- question 4

SELECT SUM(po)AS total_putouts, CASE WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
			   WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
			   WHEN pos = 'OF' THEN 'Outfield' END AS positions
FROM fielding
WHERE yearid = 2016
GROUP BY positions;

-- question 6

SELECT (sb+cs) AS total_steal_attempts, namefirst, namelast
FROM batting INNER JOIN people USING (playerid);

WITH total_steal AS (SELECT SUM(sb) AS total_stolen, SUM(cs) AS total_caught,(batting.sb+batting.cs) AS total_steal_attempts, namefirst, namelast, playerid,sb,cs
					 FROM batting INNER JOIN people USING (playerid)
					 WHERE batting.yearid = 2016
					 GROUP BY namefirst,namelast,playerid,cs,sb)
SELECT DISTINCT (playerid), ts.namefirst, namelast,ts.cs, total_steal_attempts::numeric,ROUND(ts.sb::numeric/total_steal_attempts::numeric *100,2) AS successful_steal_percent
FROM batting INNER JOIN total_steal AS ts USING (playerid)
WHERE total_steal_attempts >= 20
	AND batting.yearid = 2016
ORDER BY successful_steal_percent DESC
LIMIT 1;

-- question 7 :  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team 
-- that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
-- Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
-- What percentage of the time?

SELECT w,l, teamid,name,wswin, yearid
FROM teams
WHERE  yearid BETWEEN 1970 AND 2016
	AND wswin = 'N'
ORDER BY w DESC;

SELECT w,l, teamid,name,wswin, yearid,(w+l) AS total_games
FROM teams
WHERE  yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
ORDER BY w; -- only 110 games in 1981 is why their wins so low

SELECT w,l, teamid,name,wswin, yearid
FROM teams
WHERE  yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
	AND yearid <> '1981'
ORDER BY w; -- excluded year 1981

-- how often does the most winning team get the worldseries, make it a percentage, windo function?
WITH max_wins AS(
	SELECT name,yearid, MAX(w) OVER(PARTITION BY yearid) AS most_win,w,wswin
	FROM teams
	WHERE yearid >= 1970)
SELECT COUNT(yearid) AS year,ROUND(COUNT(yearid)/(SELECT COUNT(DISTINCT yearid) FROM max_wins)::numeric*100,2) AS percentage-- add sub query
FROM max_wins
WHERE wswin = 'Y'
	AND w = most_win;

-- question 10 Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years,
-- and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

SELECT namefirst,namelast,((TO_DATE(finalgame, 'YYYY-MM-DD')-TO_DATE(debut, 'YYYY-MM-DD'))/364.25) AS total_years
FROM people;-- total years active

SELECT br.yearid,br.playerid,MAX(br.hr) AS most_hr, bl.yearid,bl.hr
FROM batting AS br INNER JOIN batting AS bl USING(playerid)
WHERE br.yearid = '2016'
GROUP BY br.yearid,br.playerid,bl.yearid,bl.playerid,bl.hr
ORDER BY most_hr DESC; -- where most home run is 2016


WITH total_active_years AS (SELECT namefirst,namelast,playerid,((TO_DATE(finalgame, 'YYYY-MM-DD')-TO_DATE(debut, 'YYYY-MM-DD'))/364.25) AS total_years
	FROM people)
SELECT tay.namefirst,tay.namelast,hr
FROM total_active_years AS tay JOIN batting AS b USING(playerid)
WHERE yearid = '2016'
	AND hr >= 1
	AND total_years >= 10
ORDER BY hr DESC;  --nearly there

WITH total_active_years AS (SELECT namefirst,namelast,playerid,((TO_DATE(finalgame, 'YYYY-MM-DD')-TO_DATE(debut, 'YYYY-MM-DD'))/364.25) AS total_years
	FROM people), most_homerun AS (
		SELECT playerid, yearid, SUM(hr) AS year_hr, MAX(SUM(hr)) OVER(PARTITION BY playerid) AS player_max
		FROM batting
		WHERE playerid IN(SELECT playerid
		FROM batting
		WHERE yearid = 2016
		GROUP BY playerid
		HAVING(SUM(hr)>=1))
		GROUP BY playerid, yearid
		Order BY playerid, yearid)
SELECT tay.namefirst,tay.namelast,year_hr
FROM total_active_years AS tay JOIN most_homerun AS mh USING(playerid)
WHERE  player_max >= 1
	AND total_years >= 10
	AND year_hr = player_max
	AND yearid = '2016'
ORDER BY year_hr DESC;

-- question 12 explore the connection between number of wins and attendance.
-- Does there appear to be any correlation between attendance at home games and number of wins
-- Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being
-- a division winner or a wild card winner selfjoin on team id, yearid = yearid+1

SELECT *
FROM homegames;
SELECT *
FROM teams;

SELECT t.w,SUM(t.l) AS total_loss,h.attendance,CORR(t.w,h.attendance) OVER (PARTITION BY t.name) 
	AS win_attendance
FROM homegames AS h INNER JOIN teams AS t ON h.year = t.yearid AND h.team = t.teamid -- needed to add team id so that it would not compare it to everything in that year
WHERE w > games
	AND h.attendance > 0
	AND h.games > 12
	AND divwin = 'Y'
GROUP BY h.attendance,yearid,t.w,t.name
ORDER BY t.w DESC;

SELECT t1.name,t1.w,t1.attendance,t2.w,t2.attendance
FROM teams AS t1 INNER JOIN teams AS t2 ON t1.yearid = t2.yearid+1 AND t1.name = t2.name
WHERE t1.divwin = 'Y'
	OR t1.wcwin = 'Y'
ORDER BY t2.attendance DESC;

-- bonus 1; First, write a query utilizing a correlated subquery to find the team with the most wins from each league in 2016

select DISTINCT lgid, MAX(w)
from teams
where yearid = 2016
group by lgid
order by MAX DESC;

SELECT t.lgid,t.w,t.name
FROM teams AS t
WHERE t.w = (SELECT MAX(t2.w) AS total_wins 
			FROM teams AS t2
			where t.lgid = t2.lgid and t.yearid = t2.yearid)
AND yearid = 2016;