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
SELECT name, park_name, homegames.attendance/games AS avg_attendance_per_game		
FROM homegames  LEFT JOIN teams ON team = teamid AND year = yearid
				INNER JOIN parks ON homegames.park = parks.park
WHERE year = 2016
  AND games >= 10
ORDER BY avg_attendance_per_game DESC
LIMIT 5;
---
SELECT name, park_name, homegames.attendance/games AS avg_attendance_per_game		
FROM homegames  LEFT JOIN teams ON team = teamid AND year = yearid
				INNER JOIN parks ON homegames.park = parks.park
WHERE year = 2016
  AND games >= 10
ORDER BY avg_attendance_per_game
LIMIT 5;
---


---Q9 = 60
SELECT namefirst, namelast, name
FROM awardsmanagers LEFT JOIN managers USING(playerid, yearid)
					LEFT JOIN teams USING(teamid, yearid)
					LEFT JOIN people USING(playerid)
WHERE awardID = 'TSN Manager of the Year'
  AND awardsmanagers.lgid IN('NL', 'AL');


---Q10
SELECT playerid, namefirst, namelast, finalgame, debut, (TO_DATE(finalgame, 'YYYY-MM-DD')-TO_DATE(debut, 'YYYY-MM-DD'))/365.25 AS years_played
FROM people
WHERE namefirst = 'Justin'
AND namelast = 'Upton'

SELECT playerid, yearid, SUM(hr), MAX(SUM(hr)) OVER(PARTITION BY playerid) AS player_max
FROM batting
GROUP BY playerid, yearid
ORDER BY playerid, yearid;

SELECT playerid
FROM batting
WHERE yearid = 2016
GROUP BY playerid
HAVING(SUM(hr) > 0);

WITH players_w_time AS (
	SELECT playerid, namefirst, namelast, (TO_DATE(finalgame, 'YYYY-MM-DD')-TO_DATE(debut, 'YYYY-MM-DD'))/365.25 AS years_played
	FROM people
	),
	max_hr AS 
	(SELECT playerid, yearid, SUM(hr) AS year_max, MAX(SUM(hr)) OVER(PARTITION BY playerid) AS player_max
	FROM batting 
	WHERE playerid IN(SELECT playerid
	FROM batting
	WHERE yearid = 2016
	GROUP BY playerid
	HAVING(SUM(hr) >= 1))
	GROUP BY playerid, yearid
	ORDER BY playerid, yearid)
SELECT namefirst, namelast, year_max
FROM max_hr LEFT JOIN players_w_time USING(playerid)
WHERE  years_played >= 10
	AND year_max = player_max
	AND yearid = 2016
ORDER BY year_max;


---Q11
WITH ts AS (SELECT yearid, teamid, SUM(salary) AS total_salary, SUM(w) AS total_wins
	  FROM salaries LEFT JOIN teams USING(teamid, yearid)
	  WHERE yearid >= 2000
	  GROUP BY yearid, teamid
	  ORDER BY yearid, total_wins)

SELECT yearid, teamid, CORR(total_salary, total_wins) OVER(PARTITION BY teamid) AS correlated
FROM ts
GROUP BY yearid, teamid, total_salary, total_wins
ORDER BY yearid, total_wins;
---maybe


---Q12
WITH taw AS (SELECT year, name, SUM(homegames.attendance) AS ta, SUM(w) AS tw
			 FROM homegames  LEFT JOIN teams ON team = teamid AND year = yearid
			 GROUP BY year, name
			 HAVING(SUM(homegames.attendance) > 0)
			 ORDER BY tw DESC)
SELECT year, name, CORR(ta, tw) OVER(PARTITION BY name)
FROM taw
GROUP BY year, name, ta, tw
ORDER BY year, tw DESC
---
SELECT t.name, t.yearid, t.attendance, t_1more.attendance, t_1more.attendance - t.attendance AS boost
FROM teams AS t LEFT JOIN teams AS t_1more ON t.teamid = t_1more.teamid AND t.yearid = t_1more.yearid + 1
WHERE t.wswin = 'Y'
	AND t.attendance IS NOT NULL
---no

---Q13
SELECT ROUND((SELECT COUNT(*)
FROM people
WHERE throws = 'L')/COUNT(*)::numeric*100,2) AS left_percent
FROM people
WHERE throws IN('R', 'L');
---20.15%
SELECT ROUND(COUNT(*)/(SELECT COUNT(*)
					   FROM awardsplayers
					   WHERE awardID = 'Cy Young Award')::numeric*100,2) AS left_percent
FROM awardsplayers
WHERE awardID = 'Cy Young Award'
	AND playerid IN(SELECT DISTINCT playerid
					FROM people
					WHERE throws = 'L');
---33.04% left is alittle more likely
SELECT ROUND(COUNT(*)/(SELECT COUNT(*)
					   FROM halloffame
					   WHERE inducted = 'Y')::numeric*100,2) AS left_percent
FROM halloffame
WHERE inducted = 'Y'
	AND playerid IN(SELECT DISTINCT playerid
					FROM people
					WHERE throws = 'L');
---16.40% left is alittle less likely


---BQ1---a
SELECT DISTINCT lgid, (SELECT teamid
						FROM teams
						WHERE lgid = t.lgid
						AND yearid = 2016
						ORDER BY w DESC
						LIMIT 1)
FROM teams t
WHERE yearid = 2016;
---b

SELECT DISTINCT lgid, (SELECT teamid
						FROM teams
						WHERE lgid = t.lgid
						AND yearid = 2016
						ORDER BY w DESC
						LIMIT 1),
						(SELECT w
						FROM teams
						WHERE lgid = t.lgid
						AND yearid = 2016
						ORDER BY w DESC
						LIMIT 1)
FROM teams t
WHERE yearid = 2016;
---c
SELECT DISTINCT lgid, (SELECT DISTINCT ON (lgid) teamid
						FROM teams
						WHERE lgid = t.lgid
						AND yearid = 2016
						ORDER BY lgid, w DESC),
						(SELECT DISTINCT ON (lgid) w
						FROM teams
						WHERE lgid = t.lgid
						AND yearid = 2016
						ORDER BY lgid, w DESC)
FROM teams t
WHERE yearid = 2016;
---
SELECT DISTINCT t.lgid, ts.teamid, ts.w
FROM teams t, LATERAL (SELECT DISTINCT ON (lgid) teamid, w
						FROM teams
						WHERE lgid = t.lgid
						AND yearid = 2016
						ORDER BY lgid, w DESC) ts
WHERE yearid = 2016;
---d-e
SELECT *
FROM (SELECT DISTINCT lgid 
	  FROM teams
	  WHERE yearid = 2016) AS leagues,
	  LATERAL ( SELECT  teamid, w
						FROM teams
						WHERE lgid = leagues.lgid
						AND yearid = 2016
						ORDER BY w DESC
						LIMIT 3) as top_teams;


---BQ2---a
SELECT TO_DATE(birthyear||'-'||birthmonth||'-'||birthday, 'YYYY-MM-DD') AS birthdate
FROM people;
---b
SELECT namefirst, namelast, AGE(TO_DATE(debut, 'YYYY-MM-DD'),birthdate)
FROM people, LATERAL ( SELECT TO_DATE(birthyear||'-'||birthmonth||'-'||birthday, 'YYYY-MM-DD') AS birthdate);
---c
SELECT namefirst, namelast, AGE(TO_DATE(debut, 'YYYY-MM-DD'),birthdate) AS age
FROM people, LATERAL ( SELECT TO_DATE(birthyear||'-'||birthmonth||'-'||birthday, 'YYYY-MM-DD') AS birthdate)
ORDER BY age
LIMIT 1;
---"Joe"	"Nuxhall"	"15 years 10 mons 11 days"
---
SELECT namefirst, namelast, AGE(TO_DATE(finalgame, 'YYYY-MM-DD'),birthdate) AS age
FROM people, LATERAL ( SELECT TO_DATE(birthyear||'-'||birthmonth||'-'||birthday, 'YYYY-MM-DD') AS birthdate)
ORDER BY age DESC NULLS LAST
LIMIT 1;
"Satchel"	"Paige"	"59 years 2 mons 18 days"


---BQ3
