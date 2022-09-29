SELECT *
FROM
	NFL.raw_data;


-- This is just me trying to figure out how to cast game date, which is text, as a date

SELECT 
	CAST(game_date AS date)
FROM
	NFL.raw_data;
    
SELECT
	CAST(game_date AS date) AS game_date,
    YEAR(game_date) AS year, 
    MONTH(game_date) as month, 
    DAY(game_date) as day
FROM
	NFL.raw_data;
    
SELECT
	DISTINCT player,
    pos,
    team
FROM
	NFL.raw_data
ORDER BY
	team;

-- Can look at specific players based on their positions, and examine their total stats
-- This looks at the QBs from 2020-2021 Season, and some basic pass statistics
    
SELECT
	player,
    SUM(pass_att) AS attempts,
    SUM(pass_cmp) AS completions,
    SUM(pass_yds) AS total_yds,
    SUM(pass_td) AS total_td,
    SUM(pass_int) AS total_int
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player
ORDER BY total_td DESC;
	
-- Looking at completion percentage for that year
-- Need to use HAVING clause for aggregate functions, and that goes after the group by clause

SELECT
	player,
    SUM(pass_att) AS attempts,
    SUM(pass_cmp) AS completions,
    (SUM(pass_cmp)/SUM(pass_att))*100 AS completion_percentage
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player
HAVING 
	SUM(pass_att) > '30'
ORDER BY completion_percentage DESC;

-- Messing around and seeing some bad stuff

SELECT
	player,
    team,
    (SUM(pass_cmp)/SUM(pass_att))*100 AS completion_percentage,
    SUM(pass_int) AS interceptions,
    SUM(fumbles_lost) AS fumbles,
    SUM(pass_poor_throws) AS poor_throws
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50'
ORDER BY poor_throws DESC;

-- See how many throws were completed, how many were picked, how many poor

SELECT
	player,
    team,
    SUM(pass_att) AS total_attempts,
    (SUM(pass_cmp)/SUM(pass_att))*100 AS completion_percentage,
    (SUM(pass_int)/SUM(pass_att))*100 AS interceptions_percentage,
    (SUM(pass_poor_throws)/SUM(pass_att))*100 AS poor_throws_percentage
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50'
ORDER BY completion_percentage;

-- Determine how many games played by each QB

SELECT
	player,
    team, 
    COUNT(player) AS games_played
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
ORDER BY games_played DESC;

-- Determine QBs with most rush yards, and most yards per rush

SELECT
	player,
    team,
    SUM(rush_att) AS total_rushes,
    SUM(designed_rush_att) AS designed_runs,
    SUM(rush_yds) AS total_yards
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
ORDER BY total_yards DESC;

-- Determine most turnover prone QB

SELECT
	player,
    team,
    SUM(pass_int) AS total_picks,
    SUM(fumbles_lost) AS total_lost_fumbles,
	SUM(pass_int) + SUM(fumbles_lost) AS total_turnovers
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
ORDER BY total_turnovers DESC;


-- At this point, I'm going to start finding some numbers to develop my own QB metric

SELECT
	player,
    team,
    SUM(offense) AS TotalPlays,
    SUM(pass_att) AS TotalPassAtt,
    SUM(pass_cmp) / SUM(pass_att) AS CompPerc,
    SUM(pass_yds) / SUM(pass_att) AS YdsPerAtt,
    SUM(pass_td) AS TotalTD,
    SUM(pass_td) / SUM(pass_att) AS TDPerc,
    SUM(pass_int) AS TotalInt,
    SUM(pass_int) / SUM(pass_att) AS IntPerc,
    SUM(pass_poor_throws) / SUM(pass_att) AS PoorThrowPerc,
    SUM(pass_sacked) AS TotalSacks,
    SUM(pass_sacked) / SUM(offense) AS SacksPerc,
    SUM(pass_sacked_yds) AS SackYardsLost,
    SUM(fumbles_lost) / SUM(offense) AS FumblePerc,
    SUM(rush_att) AS TotalRushAtt,
    SUM(rush_yds) / SUM(rush_att) AS RushYdsPerAtt,
    SUM(rush_td) / SUM(rush_att) AS RushTDPerc
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50';
    
-- Creating View of above query

CREATE VIEW NFL.QBStats AS
SELECT
	player,
    team,
    SUM(offense) AS TotalPlays,
    SUM(pass_att) AS TotalPassAtt,
    SUM(pass_cmp) / SUM(pass_att) AS CompPerc,
    SUM(pass_yds) / SUM(pass_att) AS YdsPerAtt,
    SUM(pass_td) AS TotalTD,
    SUM(pass_td) / SUM(pass_att) AS TDPerc,
    SUM(pass_int) AS TotalInt,
    SUM(pass_int) / SUM(pass_att) AS IntPerc,
    SUM(pass_poor_throws) / SUM(pass_att) AS PoorThrowPerc,
    SUM(pass_sacked) AS TotalSacks,
    SUM(pass_sacked) / SUM(offense) AS SacksPerc,
    SUM(pass_sacked_yds) AS SackYardsLost,
    SUM(fumbles_lost) / SUM(offense) AS FumblePerc,
    SUM(rush_att) AS TotalRushAtt,
    SUM(rush_yds) / SUM(rush_att) AS RushYdsPerAtt,
    SUM(rush_td) / SUM(rush_att) AS RushTDPerc
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50';
    
-- Querying on CTE to find averages from all QBs

WITH QBStats2122 (player, team, totalplays, totalpassatt, completionperc, ydsperatt, totaltd, tdperc, 
totalint, intperc, poorthrowperc, totalsacks, sackperc, sackyardslost, fumbleperc, totalrushatt, rushyadsperatt, rushtdper)
AS
(SELECT
	player,
    team,
    SUM(offense) AS TotalPlays,
    SUM(pass_att) AS TotalPassAtt,
    SUM(pass_cmp) / SUM(pass_att) AS CompPerc,
    SUM(pass_yds) / SUM(pass_att) AS YdsPerAtt,
    SUM(pass_td) AS TotalTD,
    SUM(pass_td) / SUM(pass_att) AS TDPerc,
    SUM(pass_int) AS TotalInt,
    SUM(pass_int) / SUM(pass_att) AS IntPerc,
    SUM(pass_poor_throws) / SUM(pass_att) AS PoorThrowPerc,
    SUM(pass_sacked) AS TotalSacks,
    SUM(pass_sacked) / SUM(offense) AS SacksPerc,
    SUM(pass_sacked_yds) AS SackYardsLost,
    SUM(fumbles_lost) / SUM(offense) AS FumblePerc,
    SUM(rush_att) AS TotalRushAtt,
    SUM(rush_yds) / SUM(rush_att) AS RushYdsPerAtt,
    SUM(rush_td) / SUM(rush_att) AS RushTDPerc
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50')
SELECT
	AVG(totalpassatt),
    AVG(completionperc),
    AVG(ydsperatt),
    AVG(tdperc),
    AVG(intperc),
    AVG(poorthrowperc),
    AVG(sackperc),
    AVG(fumbleperc),
    AVG(totalrushatt),
    AVG(rushyadsperatt), 
    AVG(rushtdper)
FROM QBstats2122;

-- Querying on CTE to find max and min for each stat

WITH QBStats2122 (player, team, totalplays, totalpassatt, completionperc, ydsperatt, totaltd, tdperc, 
totalint, intperc, poorthrowperc, totalsacks, sackperc, sackyardslost, fumbleperc, totalrushatt, rushyadsperatt, rushtdper)
AS
(SELECT
	player,
    team,
    SUM(offense) AS TotalPlays,
    SUM(pass_att) AS TotalPassAtt,
    SUM(pass_cmp) / SUM(pass_att) AS CompPerc,
    SUM(pass_yds) / SUM(pass_att) AS YdsPerAtt,
    SUM(pass_td) AS TotalTD,
    SUM(pass_td) / SUM(pass_att) AS TDPerc,
    SUM(pass_int) AS TotalInt,
    SUM(pass_int) / SUM(pass_att) AS IntPerc,
    SUM(pass_poor_throws) / SUM(pass_att) AS PoorThrowPerc,
    SUM(pass_sacked) AS TotalSacks,
    SUM(pass_sacked) / SUM(offense) AS SacksPerc,
    SUM(pass_sacked_yds) AS SackYardsLost,
    SUM(fumbles_lost) / SUM(offense) AS FumblePerc,
    SUM(rush_att) AS TotalRushAtt,
    SUM(rush_yds) / SUM(rush_att) AS RushYdsPerAtt,
    SUM(rush_td) / SUM(rush_att) AS RushTDPerc
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50')
SELECT
	MAX(totalpassatt),
    MAX(completionperc),
    MAX(ydsperatt),
    MAX(tdperc),
    MAX(intperc),
    MAX(poorthrowperc),
    MAX(sackperc),
    MAX(fumbleperc),
    MAX(totalrushatt),
    MAX(rushyadsperatt), 
    MAX(rushtdper)
FROM QBstats2122;

WITH QBStats2122 (player, team, totalplays, totalpassatt, completionperc, ydsperatt, totaltd, tdperc, 
totalint, intperc, poorthrowperc, totalsacks, sackperc, sackyardslost, fumbleperc, totalrushatt, rushyadsperatt, rushtdper)
AS
(SELECT
	player,
    team,
    SUM(offense) AS TotalPlays,
    SUM(pass_att) AS TotalPassAtt,
    SUM(pass_cmp) / SUM(pass_att) AS CompPerc,
    SUM(pass_yds) / SUM(pass_att) AS YdsPerAtt,
    SUM(pass_td) AS TotalTD,
    SUM(pass_td) / SUM(pass_att) AS TDPerc,
    SUM(pass_int) AS TotalInt,
    SUM(pass_int) / SUM(pass_att) AS IntPerc,
    SUM(pass_poor_throws) / SUM(pass_att) AS PoorThrowPerc,
    SUM(pass_sacked) AS TotalSacks,
    SUM(pass_sacked) / SUM(offense) AS SacksPerc,
    SUM(pass_sacked_yds) AS SackYardsLost,
    SUM(fumbles_lost) / SUM(offense) AS FumblePerc,
    SUM(rush_att) AS TotalRushAtt,
    SUM(rush_yds) / SUM(rush_att) AS RushYdsPerAtt,
    SUM(rush_td) / SUM(rush_att) AS RushTDPerc
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50')
SELECT
	MIN(totalpassatt),
    MIN(completionperc),
    MIN(ydsperatt),
    MIN(tdperc),
    MIN(intperc),
    MIN(poorthrowperc),
    MIN(sackperc),
    MIN(fumbleperc),
    MIN(totalrushatt),
    min(rushyadsperatt), 
    MIN(rushtdper)
FROM QBstats2122;

-- Reorganize Queries above so calculations match with letters in QBM
-- Season stats, without cap:

SELECT
	player,
    team,
    (SUM(pass_cmp) / SUM(pass_att)) * 2.2 AS A,
    (SUM(pass_yds) / SUM(pass_att)) * .2 AS B,
    (SUM(pass_td) / SUM(pass_att)) * 34 AS C,
    2 - ((SUM(pass_int) / SUM(pass_att)) * 23) AS D,
    2 - ((SUM(pass_poor_throws) / SUM(pass_att)) * 3.4) AS E,
    2 - ((SUM(pass_sacked) / SUM(offense)) * 18) AS F,
    2 - ((SUM(fumbles_lost) / SUM(offense)) * 180) AS G,
    (SUM(rush_yds) / SUM(rush_att)) * .33 AS H,
    (SUM(rush_td) / SUM(rush_att)) * 29 AS I
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50';

-- Season stats, with cap of 2: 

SELECT
	player,
    team,
    CASE
		WHEN (SUM(pass_cmp) / SUM(pass_att)) * 2.2 > 2 THEN 2
        ELSE (SUM(pass_cmp) / SUM(pass_att)) * 2.2
        END AS A,
    CASE
		WHEN (SUM(pass_yds) / SUM(pass_att)) * .2 > 2 THEN 2
        ELSE (SUM(pass_yds) / SUM(pass_att)) * .2
        END AS B,
    CASE
		WHEN (SUM(pass_td) / SUM(pass_att)) * 34 > 2 THEN 2
        ELSE(SUM(pass_td) / SUM(pass_att))
        END AS C,
	CASE 
		WHEN 2 - ((SUM(pass_int) / SUM(pass_att)) * 23) > 2 THEN 2
        ELSE 2 - ((SUM(pass_int) / SUM(pass_att)) * 23)
        END AS D,
    CASE
		WHEN 2 - ((SUM(pass_poor_throws) / SUM(pass_att)) * 3.4) > 2 THEN 2
        ELSE 2 - ((SUM(pass_poor_throws) / SUM(pass_att)) * 3.4)
        END AS E,
    CASE 
		WHEN 2 - ((SUM(pass_sacked) / SUM(offense)) * 18) > 2 THEN 2
        ELSE 2 - ((SUM(pass_sacked) / SUM(offense)) * 18)
        END AS F,
    CASE
		WHEN 2 - ((SUM(fumbles_lost) / SUM(offense)) * 180) > 2 THEN 2
        ELSE 2 - ((SUM(fumbles_lost) / SUM(offense)) * 180)
        END AS G,
    CASE
		WHEN (SUM(rush_yds) / SUM(rush_att)) * .33 > 2 THEN 2
        ELSE (SUM(rush_yds) / SUM(rush_att)) * .33
        END AS H,
    CASE
		WHEN (SUM(rush_td) / SUM(rush_att)) * 29 > 2 THEN 2
        ELSE (SUM(rush_td) / SUM(rush_att)) * 29
        END AS I
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50';


-- Single Game Stats, without cap:

SELECT
	player,
    team,
    game_id,
    (pass_cmp / pass_att) * 2.2 AS A,
    (pass_yds / pass_att) * .2 AS B,
    (pass_td / pass_att) * 34 AS C,
    2 - ((pass_int / pass_att) * 23) AS D,
    2 - ((pass_poor_throws / pass_att) * 3.4) AS E,
    2 - ((pass_sacked / offense) * 18) AS F,
    2 - ((fumbles_lost / offense) * 180) AS G,
    (rush_yds / rush_att) * .33 AS H,
    (rush_td / rush_att) * 29 AS I
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022';

-- Single game stats with Cap of 2
-- Two fixes here - added an IFNULL statement to the passatt and rushatt, so no nulls are returned
-- Not sure if to IFNULL passint or poorthrows - do they get the max 2 if they don't throw at all????

SELECT
	player,
    team,
    game_id,
    CASE
		WHEN IFNULL((pass_cmp / pass_att),0) * 2.2 > 2 THEN 2
        ELSE IFNULL((pass_cmp / pass_att),0) * 2.2
        END AS A,
    CASE
		WHEN IFNULL((pass_yds / pass_att),0) * .2 > 2 THEN 2
        ELSE IFNULL((pass_yds / pass_att),0) * .2
        END AS B,
    CASE
		WHEN IFNULL((pass_td / pass_att),0) * 34 > 2 THEN 2
        ELSE IFNULL((pass_td / pass_att),0) * 34
        END AS C,
    CASE
		WHEN IFNULL(2 - ((pass_int / pass_att) * 23),0) > 2 THEN 2
        ELSE IFNULL(2 - ((pass_int / pass_att) * 23),0)
        END AS D,
    CASE
		WHEN IFNULL(2 - ((pass_poor_throws / pass_att) * 3.4),0) > 2 THEN 2
        ELSE IFNULL(2 - ((pass_poor_throws / pass_att) * 3.4),0)
        END AS E,
    CASE
		WHEN 2 - ((pass_sacked / offense) * 18) > 2 THEN 2
        ELSE 2 - ((pass_sacked / offense) * 18)
        END AS F,
    CASE
		WHEN 2 - ((fumbles_lost / offense) * 180) > 2 THEN 2
        ELSE 2 - ((fumbles_lost / offense) * 180)
        END AS G,
    CASE
		WHEN IFNULL((rush_yds / rush_att),0) * .33 > 2 THEN 2
        ELSE IFNULL((rush_yds / rush_att),0) * .33
        END AS H,
    CASE
		WHEN IFNULL((rush_td / rush_att),0) * 29 > 2 THEN 2
        ELSE IFNULL((rush_td / rush_att),0) * 29
        END AS I
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022';
    

-- Determine Season QBM using CTE

WITH QBMSeasonStats (player, team, A, B, C, D, E, F, G, H, I)
AS
(SELECT
	player,
    team,
    CASE
		WHEN (SUM(pass_cmp) / SUM(pass_att)) * 2.2 > 2 THEN 2
        ELSE (SUM(pass_cmp) / SUM(pass_att)) * 2.2
        END AS A,
    CASE
		WHEN (SUM(pass_yds) / SUM(pass_att)) * .2 > 2 THEN 2
        ELSE (SUM(pass_yds) / SUM(pass_att)) * .2
        END AS B,
    CASE
		WHEN (SUM(pass_td) / SUM(pass_att)) * 34 > 2 THEN 2
        ELSE(SUM(pass_td) / SUM(pass_att))
        END AS C,
	CASE 
		WHEN 2 - ((SUM(pass_int) / SUM(pass_att)) * 23) > 2 THEN 2
        ELSE 2 - ((SUM(pass_int) / SUM(pass_att)) * 23)
        END AS D,
    CASE
		WHEN 2 - ((SUM(pass_poor_throws) / SUM(pass_att)) * 3.4) > 2 THEN 2
        ELSE 2 - ((SUM(pass_poor_throws) / SUM(pass_att)) * 3.4)
        END AS E,
    CASE 
		WHEN 2 - ((SUM(pass_sacked) / SUM(offense)) * 18) > 2 THEN 2
        ELSE 2 - ((SUM(pass_sacked) / SUM(offense)) * 18)
        END AS F,
    CASE
		WHEN 2 - ((SUM(fumbles_lost) / SUM(offense)) * 180) > 2 THEN 2
        ELSE 2 - ((SUM(fumbles_lost) / SUM(offense)) * 180)
        END AS G,
    CASE
		WHEN (SUM(rush_yds) / SUM(rush_att)) * .33 > 2 THEN 2
        ELSE (SUM(rush_yds) / SUM(rush_att)) * .33
        END AS H,
    CASE
		WHEN (SUM(rush_td) / SUM(rush_att)) * 29 > 2 THEN 2
        ELSE (SUM(rush_td) / SUM(rush_att)) * 29
        END AS I
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022'
GROUP BY player, team
HAVING 
	SUM(pass_att) > '50')
SELECT
	player,
    team,
    (((A + B + C)/3) * 30) + (((D + E + F + G)/4) * 10) + (((H + I)/2) * 10) AS QBM
FROM
	QBMSeasonStats
ORDER BY 3 DESC;


-- Determine Game QBM with CTE

WITH QBMGameStats (player, team, game_id, A, B, C, D, E, F, G, H, I)
AS
(SELECT
	player,
    team,
    game_id,
    CASE
		WHEN IFNULL((pass_cmp / pass_att),0) * 2.2 > 2 THEN 2
        ELSE IFNULL((pass_cmp / pass_att),0) * 2.2
        END AS A,
    CASE
		WHEN IFNULL((pass_yds / pass_att),0) * .2 > 2 THEN 2
        ELSE IFNULL((pass_yds / pass_att),0) * .2
        END AS B,
    CASE
		WHEN IFNULL((pass_td / pass_att),0) * 34 > 2 THEN 2
        ELSE IFNULL((pass_td / pass_att),0) * 34
        END AS C,
    CASE
		WHEN IFNULL(2 - ((pass_int / pass_att) * 23),0) > 2 THEN 2
        ELSE IFNULL(2 - ((pass_int / pass_att) * 23),0)
        END AS D,
    CASE
		WHEN IFNULL(2 - ((pass_poor_throws / pass_att) * 3.4),0) > 2 THEN 2
        ELSE IFNULL(2 - ((pass_poor_throws / pass_att) * 3.4),0)
        END AS E,
    CASE
		WHEN 2 - ((pass_sacked / offense) * 18) > 2 THEN 2
        ELSE 2 - ((pass_sacked / offense) * 18)
        END AS F,
    CASE
		WHEN 2 - ((fumbles_lost / offense) * 180) > 2 THEN 2
        ELSE 2 - ((fumbles_lost / offense) * 180)
        END AS G,
    CASE
		WHEN IFNULL((rush_yds / rush_att),0) * .33 > 2 THEN 2
        ELSE IFNULL((rush_yds / rush_att),0) * .33
        END AS H,
    CASE
		WHEN IFNULL((rush_td / rush_att),0) * 29 > 2 THEN 2
        ELSE IFNULL((rush_td / rush_att),0) * 29
        END AS I
FROM
	NFL.raw_data
WHERE
	pos = 'QB'
    AND SEASON = '2021-2022')
SELECT
	player,
    team,
    game_id,
    (((A + B + C)/3) * 30) + (((D + E + F + G)/4) * 10) + (((H + I)/2) * 10) AS QBM
FROM
	QBMGameStats
ORDER BY 4 DESC;

