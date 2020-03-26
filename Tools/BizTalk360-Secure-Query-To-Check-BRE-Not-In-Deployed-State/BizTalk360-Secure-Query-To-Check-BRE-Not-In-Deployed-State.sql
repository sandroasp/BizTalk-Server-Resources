/****** use BizTalkRuleEngineDb ******/
/****** GO ******/

/****** Sandro Pereira & José Barbosa - DevScope  ******/
;with 
cteHist as (
	select h.* from [BizTalkRuleEngineDb].[dbo].[re_deployment_history] h
join (select strname, max(dttimestamp) as dttimestamp from [BizTalkRuleEngineDb].[dbo].[re_deployment_history] group by strname) q on h.strName=q.strName and h.dtTimeStamp=q.dttimestamp
),
ctetDeployed as (
	SELECT Policy, Status, StrName, nStatus
						FROM   (
						   SELECT StrName, StrName + ' (v' + LTRIM(STR(nMajor)) + '.' + LTRIM(STR(nMinor)) + ')' as 'Policy', nMajor, nMinor, CASE nStatus WHEN 0 THEN 'Saved' WHEN '1' THEN 'Published' END as Status, nStatus
								, row_number() OVER(PARTITION BY StrName ORDER BY StrName, nMajor, nMinor DESC) AS rn
						   FROM   [BizTalkRuleEngineDb].[dbo].[re_ruleset]
						   ) sub
						WHERE  rn = 1
)
select Policy, Status from ctetDeployed d
where nStatus = 0
or exists (select 1 from cteHist h  where h.strName=d.strname and bDeployedInd=0)