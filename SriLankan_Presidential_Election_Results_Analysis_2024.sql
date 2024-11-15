-- 1) Which candidate received the highest total votes overall?

SELECT TOP 1 
	cd.CandidateName, 
	cd.PartyName, 
	cr.CandidatewiseTotalVotes
FROM 
	Candidatewise_Details AS cd
JOIN 
	Candidatewise_Results AS cr
ON 
	cd.CandidateID=cr.CandidateID
ORDER BY 
	cr.CandidatewiseTotalVotes DESC;

------------------------------------------------------------------------
-- 2) What is the leading and trailing candidate in each district?

SELECT 
	d.DistrictName, 
	lc.CandidateName AS Leading_Candidate, 
	tc.CandidateName AS Trailing_Candidate, 
	dr.LeadingCandidateTotal
FROM 
	Districtwise_Results AS dr
JOIN 
	Candidatewise_Details AS lc 
		ON 
			dr.LeadingCandidateID=lc.CandidateID
JOIN 
	Candidatewise_Details AS tc 
		ON 
			dr.TrailingCandidateID=tc.CandidateID
JOIN 
	District AS d 
		ON 
			dr.DistrictID=d.DistrictID;

---------------------------------------------------------------------------------------
-- 3) What is the total number of registered electors and votes polled per district?

SELECT 
	d.DistrictName, 
	SUM(pr.NoRegisteredElectors) AS TotalRegisteredElectors, 
	SUM(pr.NoVotesPolled) AS TotalVotesPolled
FROM 
	PollingStationwise_Results AS pr
JOIN 
	District AS d 
		ON 
			pr.DistrictID=d.DistrictID
GROUP BY 
	d.DistrictName;

--------------------------------------------------------------------------------------------

-- 4) What is the vote distribution by type (EVM, Postal, Preferential) for each candidate?

SELECT 
	cd.CandidateName, 
    cr.PartyName,
	cr.CandidatewiseTotalVotes,
    cr.CandidatewisePreferential,
    cr.CandidatewiseTotal
FROM 
	Candidatewise_details cd
JOIN 
	CandidateWise_Results cr 
		ON 
			cd.CandidateID = cr.CandidateID
ORDER BY 
	cr.CandidatewiseTotal DESC;

----------------------------------------------------------------------------------------------------------------------------------------

-- 5) Retrieve each candidate's name, party, and total votes only for candidates whose party received more than 500,000 votes overall.

SELECT 
	cd.CandidateName, 
	cd.PartyName, 
	cr.CandidatewiseTotal
FROM 
	Candidatewise_Results AS cr
JOIN 
	Candidatewise_Details AS cd 
		ON 
			cr.CandidateID=cd.CandidateID
WHERE 
	cr.CandidatewiseTotalVotes > 500000
ORDER BY 
cr.CandidatewiseTotalVotes DESC;

--------------------------------------------------------------------------------------------------------------------------------------------
-- 6) Retrieve each district’s name and the total votes of the Leading candidate, 
-- only for districts where the Leading candidate’s name starts with "A" and their total votes exceed 100,000.

SELECT 
	d.DistrictName, 
	cd.CandidateName AS 'Anura as Winning candidate', 
	dr.LeadingCandidateTotal AS Results
FROM 
	District AS d 
JOIN 
	Districtwise_Results AS dr 
		ON 
			d.DistrictID=dr.DistrictID
JOIN 
	Candidatewise_Details AS cd 
		ON 
			dr.LeadingCandidateID=cd.CandidateID
WHERE 
	cd.CandidateName LIKE 'A%'
	AND dr.LeadingCandidateTotal > 100000;

------------------------------------------------------------------------------------------------------------------------------------

-- 7) Find the top three candidates in terms of total votes across all polling stations, along with their polling station details 

SELECT 
cd.	CandidateName, 
		cd.PartyName, 
		pr.PollingStation, 
		pr.TotalNoValidVotes
FROM 
		PollingStationwise_Results AS pr
JOIN 
		Candidatewise_Details AS cd 
			ON 
				pr.WinningCandidateID=cd.CandidateID
WHERE 
			pr.TotalNoValidVotes 
			IN 
(SELECT TOP 5 TotalNoValidVotes FROM PollingStationwise_Results ORDER BY TotalNoValidVotes DESC)
ORDER BY 
	TotalNoValidVotes DESC;

---------------------------------------------------------------------------------------------------------------

-- 8) Calculate the total number of registered electors, valid votes, and rejected votes for each district, 
-- only for districts where the total registered electors exceed 100,000.

SELECT 
	d.DistrictName, 
	SUM(pr.NoRegisteredElectors) AS 'Total No. Registered Electors', 
	SUM(pr.TotalNoValidVotes) AS 'Total No. Valid Votes',
	SUM(pr.NoRejectedVotes) AS 'Total No. Rejected Votes',
	SUM(pr.NoVotesPolled ) AS 'Total No. Polled Votes'
FROM 
	PollingStationwise_Results AS pr
JOIN 
	District AS d 
		ON 
			pr.DistrictID=d.DistrictID
GROUP BY 
	d.DistrictName
HAVING 
	SUM(pr.NoRegisteredElectors) > 100000
ORDER BY 
	d.DistrictName;

----------------------------------------------------------------------------
