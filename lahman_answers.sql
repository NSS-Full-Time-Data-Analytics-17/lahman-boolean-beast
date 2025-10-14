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

-- how often does the most winning team get the worldseries, make it a percentage

SELECT name, w, l, wswin, yearid, (w+l) AS total_games
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
ORDER BY yearid