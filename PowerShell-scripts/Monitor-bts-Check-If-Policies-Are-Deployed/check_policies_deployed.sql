use BizTalkRuleEngineDb
GO

/****** Sandro Pereira & José Barbosa - DevScope  ******/
;with 
cteHist as (
	select h.* from [BizTalkRuleEngineDb].[dbo].[re_deployment_history] h
join (select strname, max(dttimestamp) as dttimestamp from [BizTalkRuleEngineDb].[dbo].[re_deployment_history] group by strname) q on h.strName=q.strName and h.dtTimeStamp=q.dttimestamp
),
ctetDeployed as (
	SELECT StrName, nMajor, nMinor, nStatus
						FROM   (
						   SELECT StrName, nMajor, nMinor, nStatus
								, row_number() OVER(PARTITION BY StrName ORDER BY nMajor, nMinor DESC) AS rn
						   FROM   [BizTalkRuleEngineDb].[dbo].[re_ruleset]
						   ) sub
						WHERE  rn = 1
)
select * from ctetDeployed d
where nStatus = 0
or exists (select 1 from cteHist h  where h.strName=d.strname and bDeployedInd=0)