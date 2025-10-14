---Q1
SELECT MIN(yearid), MAX(yearid)
FROM teams;
---1871-2016


---Q2
SELECT namefirst, namelast, height, name, g_all
FROM people INNER JOIN appearances USING(playerid)
			INNER JOIN teams USING(teamid, yearid)
WHERE height = 43
ORDER BY height;
---"Eddie"	"Gaedel"	43	"St. Louis Browns"  played 1 time


---Q3
SELECT namefirst, namelast, SUM(salary) AS total_salary
FROM schools INNER JOIN collegeplaying USING(schoolid)
			 INNER JOIN salaries USING(playerid)
			 INNER JOIN people USING(playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;
---"David Price"  $245,553,888


---Q4
SELECT SUM(po) AS number_of_putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		 WHEN pos IN('SS', '1B', '2B', '3B') THEN 'Infield'
		 WHEN pos IN('P', 'C') THEN 'Battery'
		 ELSE 'Other' END AS position
FROM fielding
WHERE yearid = 2016
GROUP BY position
ORDER BY number_of_putouts;
---29560	"Outfield"
---41424	"Battery"
---58934	"Infield"


---Q5
WITH games AS (
SELECT ((year / 10) * 10)::text || 's' AS decade, SUM(games) AS tg
FROM homegames
WHERE year >= 1920
GROUP BY decade
ORDER BY decade),
stats AS (
SELECT ((yearid / 10) * 10)::text || 's' AS decade, SUM(so) AS ts, SUM(hr) AS th
FROM batting
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade)

SELECT decade, ROUND(ts/tg::numeric,2) AS avg_strikeouts, ROUND(th/tg::numeric,2) AS avg_homeruns
FROM games INNER JOIN stats USING(decade);
--- they seem to be correlated


---Q6
SELECT namefirst, namelast, ROUND(SUM(sb)/(SUM(sb)::numeric + SUM(cs))*100,2) AS successful_attempt_precent
FROM batting LEFT JOIN people USING(playerid)
WHERE yearid = 2016
GROUP BY namefirst, namelast
HAVING  SUM(sb) + SUM(cs) >= 20
ORDER BY successful_attempt_precent DESC;
---"Chris"	"Owings"	91.30


---Q7
SELECT name, yearid, w
FROM teams
WHERE yearid >= 1970
	  AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;
---"Seattle Mariners"	2001	116
SELECT name, yearid, w
FROM teams
WHERE yearid >= 1970
	  AND wswin = 'Y'
ORDER BY w
LIMIT 1;
---"Los Angeles Dodgers"	1981	63
SELECT year, SUM(games) AS tg
FROM homegames
WHERE year >= 1970
GROUP BY year
ORDER BY year;
--- about 700 less games than normal
SELECT name, yearid, w
FROM teams
WHERE yearid >= 1970
	  AND wswin = 'Y'
	  AND yearid <> 1981
ORDER BY w
LIMIT 1;
---"St. Louis Cardinals"	2006	83
WITH maxwin AS (
SELECT yearid, w, wswin, MAX(w) OVER(PARTITION BY yearid) AS year_max
FROM teams
WHERE yearid >= 1970
ORDER BY yearid)
SELECT COUNT(yearid), ROUND(COUNT(yearid)/(SELECT COUNT(DISTINCT yearid) FROM maxwin)::numeric*100,2) AS percent
FROM maxwin
WHERE wswin = 'Y'
	  AND w = year_max;
---12	25.53%


---Q8
