/*
Testing Notes:
--Update the Where clause to pull from active period rather than specific round
*/
select 
(select [value] from [config] where ([key] = 'https')) + '/manage/lookup-duo/record?id='+convert(char(36),p.[id]) as [Link],
'EXP' as [Division], --we use a 3 character identifier for our subsytsems, i.e. 'PSD' for 'Physical Sciences Division'
p.[ref] as [Ref],
'EXP' + p.[ref] as [SlateID],
a.[ref] as [SlateAppID],
(select [value] from dbo.getFieldTopTable(p.[id], 'ucid')) as [UCID],
p.[last] as [LastName], 
p.[first] as [FirstName], 
p.[middle] as [MiddleName],
p.[preferred] as [PreferredName],
(select [value] from dbo.getFieldTopTable(p.[id], 'birthplace')) as [BirthCity], 
(case when ((select [value] from dbo.getFieldTopTable(p.[id], 'birthnation')) = 'US') then (select [value] from dbo.getFieldTopTable(p. 
[id], 'birthregion')) end) as [BirthRegion], 
(case when ((select [value] from dbo.getFieldTopTable(p.[id], 'birthnation')) != 'US') then (select [alpha2] from world.dbo.[country] where 
([id] = (select [value] from dbo.getFieldTopTable(p.[id], 'birthnation')))) end) as [BirthCountry], 
p.[ssn] as [SSN], 
p.[birthdate] as [DateOfBirth], 
p.[sex] as [Gender], 
(case when p.[id] in (select [record] from [field] where [field] = 'hispanic' and [value] = '1') then 'SA' else (select top 1 _p.[export] 
from [field] _f 
inner join [lookup.prompt] _p on (_p.[id] = _f.[prompt]) 
where (_f.[record] = p.[id]) and (_f.[field] = 'race') and (_p.[export] is not null) and (_p.[value] not like '% - %') order by _p.[index] asc) end) as 
[RaceType], 
(case when p.[id] in (select [record] from [field] where [field] = 'hispanicOrigin') then (select [value] from dbo.getFieldExportTable(p.[id], 'hispanicOrigin')) else (select top 1 _p.[export] 
from [field] _f 
inner join [lookup.prompt] _p on (_p.[id] = _f.[prompt]) 
where (_f.[record] = p.[id]) and (_f.[field] = 'race') and (_p.[export] is not null) and (_p.[value] like '% - %') order by _p.[index] asc) end) 
as [RaceCode], 
p.[citizenship] as [CitizenshipStatus], 
(select [alpha2] from world.dbo.[country] where ([id] = p.[citizenship1])) as [Citizenship1], 
(select [alpha2] from world.dbo.[country] where ([id] = p.[citizenship2])) as [Citizenship2], 
dl.[name] as [Status], 
lr.[name] as [Round],
coalesce((select [value] from dbo.getFieldTable(a.[id], 'quarter')),'Autumn') as [Quarter],
p.[phone] as [Phone], 
dbo.getToken(char(10), ad.[street], 1) as [MailStreet1], 
dbo.getToken(char(10), ad.[street], 2) as [MailStreet2], 
dbo.getToken(char(10), ad.[street], 3) as [MailStreet3],
ad.[city] as [MailCity], 
ad.[region] as [MailRegion], 
ad.[postal] as [MailPostal], 
adc.[alpha2] as [MailCountry],
dbo.getToken(char(10), adp.[street], 1) as [PermStreet1], 
dbo.getToken(char(10), adp.[street], 2) as [PermStreet2], 
dbo.getToken(char(10), adp.[street], 3) as [PermStreet3], 
adp.[city] as [PermCity], 
(select top 1 [id] from [lookup.region] where ([id] = adp.[region])) as [PermRegion], 
adp.[postal] as [PermPostal], 
adpc.[alpha2] as [PermCountry],
(select [value] from dbo.getFieldTable(a.[id], 'program')) as [Degree], 
	(select [value] from dbo.getFieldTable(a.[id], 'program_type')) as [DegreeProgram],
(coalesce(((select _p.[xml].value('(p[k = "gargoyle"]/v)[1]', 'varchar(max)') from [field] _f inner join [lookup.prompt] _p on (_p.[id] = 
_f.[prompt]) where (_f.[record] = a.[id]) and (_f.[field] = 'program_type'))), (select _p.[xml].value('(p[k = "gargoyle"]/v)[1]', 'varchar(max)') 
from [field] _f inner join [lookup.prompt] _p on (_p.[id] = _f.[prompt]) where (_f.[record] = a.[id]) and (_f.[field] = 'program_type_area')), 
(select _p.[xml].value('(p[k = "gargoyle"]/v)[1]', 'varchar(max)') from [field] _f inner join [lookup.prompt] _p on (_p.[id] = _f.[prompt]) where 
(_f.[record] = a.[id]) and (_f.[field] = 'program')))) as [DegreeProgramCode], 

--null as [Major1], 
--null as [Major2], 
--null as [Major3],
null as [SAT Verbal], 
null as [SAT Math], 
null as [SAT Writing], 
null as [ACT English], 
null as [ACT Math], 
null as [ACT Reading], 
null as [ACT Science], 
null as [TOEFL],
(select top 1 [summary] from [activity] where ([record] = a.[id]) and ([code] = 'PAYMENT') and ([body] = 'Enrollment Deposit') order by [date] desc) as [DepositStatus],
(select top 1 [date] from [activity] where ([record] = a.[id]) and ([code] = 'PAYMENT') and ([body] = 'Enrollment Deposit') order by [date] desc) as [DepositDate],
(select top 1 [data] from [activity] where ([record] = a.[id]) and ([code] = 'PAYMENT') and ([body] = 'Enrollment Deposit') order by [date] desc) as [DepositInfo],

s1.[name] as [PrevSchool1], 
--s1.[key] as [PrevSchool1Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s1.[name])),s1.[key]
	) as [PrevSchool1Key], 
s1.[type] as [PrevSchool1Category],
case when f1.[value] = '1' then 'Yes' else null end as [PrevSchool1Verified],
--datediff(year, s1.[from], s1.[to]) as [PrevSchool1Years],
concat(convert(varchar(16),s1.[from],1), '-', convert(varchar(16),s1.[to],1)) as [PrevSchool1Years],
(select [value] from dbo.getPromptExportTable(s1.[degree])) as [PrevSchool1Degree],
format(s1.[conferred], 'yyyy') as [PrevSchool1DegreeYear],

s2.[name] as [PrevSchool2], 
--s2.[key] as [PrevSchool2Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s2.[name])),s2.[key]
	) as [PrevSchool2Key], 
s2.[type] as [PrevSchool2Category],
case when f2.[value] = '1' then 'Yes' else null end as [PrevSchool2Verified],
--datediff(year, s2.[from], s2.[to]) as [PrevSchool2Years],
concat(convert(varchar(16),s2.[from],1), '-', convert(varchar(16),s2.[to],1)) as [PrevSchool2Years],
(select [value] from dbo.getPromptExportTable(s2.[degree])) as [PrevSchool2Degree],
format(s2.[conferred], 'yyyy') as [PrevSchool2DegreeYear],

s3.[name] as [PrevSchool3], 
--s3.[key] as [PrevSchool3Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s3.[name])),s3.[key]
	) as [PrevSchool3Key], 
s3.[type] as [PrevSchool3Category],
case when f3.[value] = '1' then 'Yes' else null end as [PrevSchool3Verified],
--datediff(year, s3.[from], s3.[to]) as [PrevSchool3Years],
concat(convert(varchar(16),s3.[from],1), '-', convert(varchar(16),s3.[to],1)) as [PrevSchool3Years],
(select [value] from dbo.getPromptExportTable(s3.[degree])) as [PrevSchool3Degree],
format(s3.[conferred], 'yyyy') as [PrevSchool3DegreeYear],

s4.[name] as [PrevSchool4], 
--s4.[key] as [PrevSchool4Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s4.[name])),s4.[key]
	) as [PrevSchool4Key], 
s4.[type] as [PrevSchool4Category],
case when f4.[value] = '1' then 'Yes' else null end as [PrevSchool4Verified],
--datediff(year, s4.[from], s4.[to]) as [PrevSchool4Years],
concat(convert(varchar(16),s4.[from],1), '-', convert(varchar(16),s4.[to],1)) as [PrevSchool4Years],
(select [value] from dbo.getPromptExportTable(s4.[degree])) as [PrevSchool4Degree],
format(s4.[conferred], 'yyyy') as [PrevSchool4DegreeYear],

s5.[name] as [PrevSchool5], 
--s5.[key] as [PrevSchool5Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s5.[name])),s5.[key]
	) as [PrevSchool5Key], 
s5.[type] as [PrevSchool5Category],
case when f5.[value] = '1' then 'Yes' else null end as [PrevSchool5Verified],
--datediff(year, s5.[from], s5.[to]) as [PrevSchool5Years],
concat(convert(varchar(16),s5.[from],1), '-', convert(varchar(16),s5.[to],1)) as [PrevSchool5Years],
(select [value] from dbo.getPromptExportTable(s5.[degree])) as [PrevSchool5Degree],
format(s5.[conferred], 'yyyy') as [PrevSchool5DegreeYear],

s6.[name] as [PrevSchool6], 
--s6.[key] as [PrevSchool6Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s6.[name])),s6.[key]
	) as [PrevSchool6Key], 
s6.[type] as [PrevSchool6Category],
case when f6.[value] = '1' then 'Yes' else null end as [PrevSchool6Verified],
--datediff(year, s6.[from], s6.[to]) as [PrevSchool6Years],
concat(convert(varchar(16),s6.[from],1), '-', convert(varchar(16),s6.[to],1)) as [PrevSchool6Years],
(select [value] from dbo.getPromptExportTable(s6.[degree])) as [PrevSchool6Degree],
format(s6.[conferred], 'yyyy') as [PrevSchool6DegreeYear],

s7.[name] as [PrevSchool7], 
--s7.[key] as [PrevSchool7Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s7.[name])),s7.[key]
	) as [PrevSchool7Key], 
s7.[type] as [PrevSchool7Category],
case when f7.[value] = '1' then 'Yes' else null end as [PrevSchool7Verified],
--datediff(year, s7.[from], s7.[to]) as [PrevSchool7Years],
concat(convert(varchar(16),s7.[from],1), '-', convert(varchar(16),s7.[to],1)) as [PrevSchool7Years],
(select [value] from dbo.getPromptExportTable(s7.[degree])) as [PrevSchool7Degree],
format(s7.[conferred], 'yyyy') as [PrevSchool7DegreeYear],

s8.[name] as [PrevSchool8], 
--s8.[key] as [PrevSchool8Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s8.[name])),s8.[key]
	) as [PrevSchool8Key], 
s8.[type] as [PrevSchool8Category],
case when f8.[value] = '1' then 'Yes' else null end as [PrevSchool8Verified],
--datediff(year, s8.[from], s8.[to]) as [PrevSchool8Years],
concat(convert(varchar(16),s8.[from],1), '-', convert(varchar(16),s8.[to],1)) as [PrevSchool8Years],
(select [value] from dbo.getPromptExportTable(s8.[degree])) as [PrevSchool8Degree],
format(s8.[conferred], 'yyyy') as [PrevSchool8DegreeYear],

s9.[name] as [PrevSchool9], 
--s9.[key] as [PrevSchool9Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s9.[name])),s9.[key]
	) as [PrevSchool9Key], 
s9.[type] as [PrevSchool9Category],
case when f9.[value] = '1' then 'Yes' else null end as [PrevSchool9Verified],
--datediff(year, s9.[from], s9.[to]) as [PrevSchool9Years],
concat(convert(varchar(16),s9.[from],1), '-', convert(varchar(16),s9.[to],1)) as [PrevSchool9Years],
(select [value] from dbo.getPromptExportTable(s9.[degree])) as [PrevSchool9Degree],
format(s9.[conferred], 'yyyy') as [PrevSchool9DegreeYear],

s10.[name] as [PrevSchool10], 
--s10.[key] as [PrevSchool10Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s10.[name])),s10.[key]
	) as [PrevSchool10Key], 
s10.[type] as [PrevSchool10Category],
case when f10.[value] = '1' then 'Yes' else null end as [PrevSchool10Verified],
--datediff(year, s10.[from], s10.[to]) as [PrevSchool10Years],
concat(convert(varchar(16),s10.[from],1), '-', convert(varchar(16),s10.[to],1)) as [PrevSchool10Years],
(select [value] from dbo.getPromptExportTable(s10.[degree])) as [PrevSchool10Degree],
format(s10.[conferred], 'yyyy') as [PrevSchool10DegreeYear],

s11.[name] as [UGSchool], 
--s11.[key] as [PrevSchool11Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s11.[name])),s11.[key]
	) as [UGSchoolKey], 
s11.[type] as [UGSchoolCategory], 
s11.[gpa] as [UGSchoolGPA], 
s11.[gpaScale] as [UGSchoolGPAscale], 
--case when f11.[value] = '1' then 'Yes' else null end as [UGSchoolVerified], 
--datediff(year, s11.[from], s11.[to]) as [UGSchoolYears], 
concat(convert(varchar(16),s11.[from],1), '-', convert(varchar(16),s11.[to],1)) as [UGSchoolYears], 
(select [value] from dbo.getPromptExportTable(s11.[degree])) as [UGSchoolDegree], 
format(s11.[conferred], 'yyyy') as [UGSchoolDegreeYear], 

s12.[name] as [MSchool], 
--s12.[key] as [PrevSchool12Key], 
coalesce(
(select top 1 [key] from [dataset.row] where ([name] = s12.[name])),s12.[key]
	) as [MSchoolKey], 
s12.[type] as [MSchoolCategory], 
s12.[gpa] as [MSchoolGPA], 
s12.[gpaScale] as [MSchoolGPAscale], 
--case when f12.[value] = '1' then 'Yes' else null end as [MSchoolVerified], 
--datediff(year, s12.[from], s12.[to]) as [MSchoolYears], 
concat(convert(varchar(16),s12.[from],1), '-', convert(varchar(16),s12.[to],1)) as [MSchoolYears], 
(select [value] from dbo.getPromptExportTable(s12.[degree])) as [MSchoolDegree], 
format(s12.[conferred], 'yyyy') as [MSchoolDegreeYear], 

p.[email] as [Email],

--Additional fields for filtering and joint feeds
lp.[active] as [ActivePeriod],
d.[code] as [DecisionCode],
d.[released] as [ReleasedDate],
dl.[name] as [Decision],
a.[submitted] as [AppSubmitted],
(select [value] from dbo.getFieldTable(a.[id], 'other_chicago')) as [OtherCurrentApplications], 
(select [value] from dbo.getFieldTable(a.[id], 'joint_degree_apply')) as [IndicatedJointDualProgram], 
(select [value] from dbo.getFieldTable(a.[id], 'alum')) as [PreviouslyEnrolledUChicago], 
(select [value] from dbo.getFieldTable(a.[id], 'alum_program')) as [DepartmentPreviouslyAttended],
(select top 1 [name] from [school] where ([record] = p.[id]) order by [conferred] desc) as [MostRecentSchool], 
(select top 1 [conferred] from [school] where ([record] = p.[id]) order by [conferred] desc) as [MostRecentConferred],
(select [value] from dbo.getFieldTable(p.[id], 'term')) as [ProspectEntryTerm], 
(select [value] from dbo.getFieldTable(p.[id], 'interest_degree')) as [ProspectDegreeInterest], 
(select [value] from dbo.getFieldTable(p.[id], 'interest_program')) as [ProspectProgramInterest], 
(select [value] from dbo.getFieldTable(p.[id], 'interest_program_type')) as [ProspectProgramArea],
case when
(d.[code] in ('DN'))
and 
(a.[id] in (select [application] from [decision] where ([code] in ('AT','AM','AW','AD'))))
then '1' else '0' end as [DecisionUpdate],

dbo.getToken(char(10), adi.[street], 1) as [IntlStreet1], 
dbo.getToken(char(10), adi.[street], 2) as [IntlStreet2], 
dbo.getToken(char(10), adi.[street], 3) as [IntlStreet3],
adi.[city] as [IntlCity], 
(select top 1 [id] from [lookup.region] where ([id] = adi.[region])) as [IntlRegion], 
adi.[postal] as [IntlPostal], 
adic.[alpha2] as [IntlCountry],

--official reporting fields

coalesce((select [value] from dbo.getFieldTopTable(a.[id], 'orig_program')),
	(select [value] from dbo.getFieldTopTable(a.[id], 'program'))) as [OriginalDegreeType], 
	coalesce((select [value] from dbo.getFieldTopTable(a.[id], 'orig_program_type')),
	(select [value] from dbo.getFieldTopTable(a.[id], 'program_type'))) as [OriginalProgram], 
	dbo.getField(p.[id], 'race') as [Race],
	(CASE when (p.[citizenship] IN ('US', 'PR')) 
	and 
	((p.[id] IN (select [record] from [field] where ([field] = 'hispanic') and ([value] = ('1'))))
	or 
	(p.[id] IN (select [record] from [field] where ([field] = 'race') 
		and ([prompt] in ('920576e2-a19e-4927-8ee3-fabe02b85997', 
			'a86614f8-ddcd-4886-9a5f-a9d3adfc78b1', 
			'0ff452d4-635e-4877-9403-860b65750b3c', 
			'ee8feb62-ea7e-4fd0-8e5f-900f8ff5e82d', 
			'e510db57-676c-4757-a6d4-be3135ce6d20', 
			'8a00978d-2cc4-4182-a7a9-2e5ef8fc70fc', 
			'06936124-6812-49e5-8ece-c42f9410de51', 
			'd36a6305-bc20-4318-adba-19fe9fa88f25', 
			'05f95187-f148-4249-9b95-e20f56ca2870', 
			'51d31f03-de9a-4d9f-8e3b-808c3230312a', 
			'092654f2-a2ec-4d0a-b03a-282522022df1', 
			'124a7511-7931-44b3-ba31-e84e8456b4bb', 
			'121f1f39-6956-4ba0-97a2-1aa3f827fc48', 
			'c024cc2c-d90f-4945-8a3d-66a2d735c9a6', 
			'0ab4827c-26c0-488b-8176-4c2fe9229bf1', 
			'b3a5a8a2-87c3-44f3-9f75-c758e5fe867d', 
			'ccd2cec1-cf86-48a4-918c-4292376e2998', 
			'ca313099-cd8f-4c22-b5d9-bb88bb6fb72d', 
			'81c7fe23-c247-431b-9575-31f8169f646b', 
			'cce80f17-983b-41ce-8bd5-f07d7cbb9507', 
			'f0ec0273-855b-415f-b392-42a07d1a219b', 
			'd1eef5c3-e084-4390-a7f4-c7b2961ab92a', 
			'5fe03622-c1a8-4bf7-9b37-ebb8e8993234', 
			'291d2dfc-19c0-4235-b54a-df1381bd2663'))))
	) then 'Yes' else 'No' end) as [InsitutionalURM], 
(case when ((select [value] from dbo.getFieldTable(p.[id], 'hispanic')) = '1') then 'Yes' when ((select [value] from dbo.getFieldTable(p.[id], 'hispanic')) = '0') then 'No' end) as [Hispanic], 
a.[created] as [AppCreated], 
a.[submitted] as [AppSubmitted],
(select [value] from dbo.getFieldTable(a.[id], 'affiliated_programs')) as [AffiliatedPrograms],
(select [value] from dbo.getFieldTable(a.[id], 'member_peacecorps')) as [PeaceCorps],
(select [value] from dbo.getFieldTable(a.[id], 'member_americorps')) as [Americorps],
(select [value] from dbo.getFieldTable(a.[id], 'member_TFA')) as [TeachforAmerica],
(select [value] from dbo.getFieldTable(a.[id], 'veteran')) as [Veteran],
(select [value] from dbo.getFieldTable(a.[id], 'member_pell_grant')) as [PellGrant],
(select [value] from dbo.getFieldTable(a.[id], 'first_gen')) as [FirstGeneration],
(select [value] from dbo.getFieldTable(a.[id], 'mcnair')) as [McNair],
(select top 1 [score1] from [test] where ([record] = p.[id]) and ([type] = 'GRE') and ([rank_confirmed_score1] = 1)) as [greverb], 
(select top 1 [percentile1] from [test] where ([record] = p.[id]) and ([type] = 'GRE') and ([rank_confirmed_score1] = 1)) as [greverb%], 
(select top 1 [score2] from [test] where ([record] = p.[id]) and ([type] = 'GRE') and ([rank_confirmed_score2] = 1)) as [grequant], 
(select top 1 [percentile2] from [test] where ([record] = p.[id]) and ([type] = 'GRE') and ([rank_confirmed_score2] = 1)) as [grequant%], 
(select top 1 [score3] from [test] where ([record] = p.[id]) and ([type] = 'GRE') and ([rank_confirmed_score3] = 1)) as [greawa], 
(select top 1 [percentile3] from [test] where ([record] = p.[id]) and ([type] = 'GRE') and ([rank_confirmed_score3] = 1)) as [greawa%], 
(select top 1 [total] from [test] where ([record] = p.[id]) and ([type] = 'TOEFL') and ([rank_confirmed] = 1)) as [toefltotal], 
(select top 1 [score1] from [test] where ([record] = p.[id]) and ([type] = 'TOEFL') and ([rank_confirmed_score1] = 1)) as [toefllistening], 
(select top 1 [score2] from [test] where ([record] = p.[id]) and ([type] = 'TOEFL') and ([rank_confirmed_score2] = 1)) as [toeflreading], 
(select top 1 [score3] from [test] where ([record] = p.[id]) and ([type] = 'TOEFL') and ([rank_confirmed_score3] = 1)) as [toeflwriting], 
(select top 1 [score4] from [test] where ([record] = p.[id]) and ([type] = 'TOEFL') and ([rank_confirmed_score4] = 1)) as [toeflspeaking], 
(select top 1 [total] from [test] where ([record] = p.[id]) and ([type] = 'IELTS') and ([rank_confirmed] = 1)) as [ieltstotal], 
(select top 1 [score1] from [test] where ([record] = p.[id]) and ([type] = 'IELTS') and ([rank_confirmed_score1] = 1)) as [ieltslistening], 
(select top 1 [score2] from [test] where ([record] = p.[id]) and ([type] = 'IELTS') and ([rank_confirmed_score2] = 1)) as [ieltsreading], 
(select top 1 [score3] from [test] where ([record] = p.[id]) and ([type] = 'IELTS') and ([rank_confirmed_score3] = 1)) as [ieltswriting], 
(select top 1 [score4] from [test] where ([record] = p.[id]) and ([type] = 'IELTS') and ([rank_confirmed_score4] = 1)) as [ieltsspeaking]


from
[application] a
inner join [person] p on (p.[id] = a.[person])
inner join [lookup.round] lr on (lr.[id] = a.[round])
inner join [lookup.period] lp on (lp.[id] = lr.[period])
left outer join [decision] d on (d.[application] = a.[id]) and (d.[rank] = 1)
left outer join [lookup.decision] dl on (dl.[id] = d.[code])
left outer join [address] ad on (ad.[record] = p.[id]) and (ad.[type] is null) and (ad.[rank] = 1)
left outer join [lookup.country] adc on (adc.[id] = ad.[country])
left outer join [address] adp on (adp.[record] = p.[id]) and (adp.[type] = 'permanent') and (adp.[rank] = 1)
left outer join [lookup.country] adpc on (adpc.[id] = adp.[country])

left outer join [address] adi on (adi.[record] = p.[id]) and (adi.[type] = 'permanent') and (adi.[rank] = 1) and (adi.[country] != 'US') and (adi.[record] in (select [id] from [person] where ([id] = p.[id]) and ([citizenship] = 'FN')))
left outer join [lookup.country] adic on (adic.[id] = adi.[country])

left outer join [field] hs_f on (hs_f.[record] = p.[id]) and (hs_f.[field] = 'ceeb')
left outer join [dataset.row] hs on (hs.[dataset] = 'B1818A40-245E-407D-9C7A-7326A232F56D') and (hs.[key] = hs_f.[index])
--left outer join [activity] acd on (acd.[record] = a.[id]) and (acd.[code] = 'PAYMENT') and (acd.[body] = 'Enrollment Deposit') and (acd.[summary] like 'Payment Due: %')
left outer join [activity] acdp on (acdp.[record] = a.[id]) and (acdp.[code] = 'PAYMENT') and (acdp.[body] = 'Enrollment Deposit') and (acdp.[summary] like 'Payment Received: %')

left outer join [school] s1 on (s1.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '1'))) order by [rank])) 
left outer join [field] f1 on (f1.[record] = s1.[id]) and (f1.[field] = 'school_verified') and (f1.[value] = '1') 

left outer join [school] s2 on (s2.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] not in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '0'))) and ([id] not in (s1.[id])) order by [rank])) 
left outer join [field] f2 on (f2.[record] = s2.[id]) and (f2.[field] = 'school_verified') and (f2.[value] = '1') 

left outer join [school] s3 on (s3.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] not in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '0'))) and ([id] not in (s1.[id], s2.[id])) order by [rank])) 
left outer join [field] f3 on (f3.[record] = s3.[id]) and (f3.[field] = 'school_verified') and (f3.[value] = '1') 

left outer join [school] s4 on (s4.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] not in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '0'))) and ([id] not in (s1.[id], s2.[id], s3.[id])) order by [rank])) 
left outer join [field] f4 on (f4.[record] = s4.[id]) and (f4.[field] = 'school_verified') and (f4.[value] = '1') 

left outer join [school] s5 on (s5.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] not in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '0'))) and ([id] not in (s1.[id], s2.[id], s3.[id], s4.[id])) order by [rank])) 
left outer join [field] f5 on (f5.[record] = s5.[id]) and (f5.[field] = 'school_verified') and (f5.[value] = '1') 

left outer join [school] s6 on (s6.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] not in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '0'))) and ([id] not in (s1.[id], s2.[id], s3.[id], s4.[id], s5.[id])) order by [rank])) 
left outer join [field] f6 on (f6.[record] = s6.[id]) and (f6.[field] = 'school_verified') and (f6.[value] = '1') 

left outer join [school] s7 on (s7.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] not in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '0'))) and ([id] not in (s1.[id], s2.[id], s3.[id], s4.[id], s5.[id], s6.[id])) order by [rank])) 
left outer join [field] f7 on (f7.[record] = s7.[id]) and (f7.[field] = 'school_verified') and (f7.[value] = '1') 

left outer join [school] s8 on (s8.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] not in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '0'))) and ([id] not in (s1.[id], s2.[id], s3.[id], s4.[id], s5.[id], s6.[id], s7.[id])) order by [rank])) 
left outer join [field] f8 on (f8.[record] = s8.[id]) and (f8.[field] = 'school_verified') and (f8.[value] = '1') 

left outer join [school] s9 on (s9.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] not in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '0'))) and ([id] not in (s1.[id], s2.[id], s3.[id], s4.[id], s5.[id], s6.[id], s7.[id], s8.[id])) order by [rank])) 
left outer join [field] f9 on (f9.[record] = s9.[id]) and (f9.[field] = 'school_verified') and (f9.[value] = '1') 

left outer join [school] s10 on (s10.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and (isnull([key],0) not in ('0','1832')) and ([id] not in (select [record] from [field] where ([field] = 'feed_school') and ([value] = '0'))) and ([id] not in (s1.[id], s2.[id], s3.[id], s4.[id], s5.[id], s6.[id], s7.[id], s8.[id], s9.[id])) order by [rank])) 
left outer join [field] f10 on (f10.[record] = s10.[id]) and (f10.[field] = 'school_verified') and (f10.[value] = '1') 

left outer join [school] s11 on (s11.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and ([type] = 'U') and ([conferred] is not null) order by [conferred] desc)) 

left outer join [school] s12 on (s12.[id] = (select top 1 [id] from [school] where ([record] = p.[id]) and ([type] = 'M') and ([conferred] is not null) order by [conferred] desc)) 

where 
(a.[submitted] is not null) 
and not exists(select * from [tag] where ([record] = p.[id]) and ([tag] = 'testrec')) 
--and (d.[code] in ('AM','AW','AR','GP','GA','GD','AT','AD','AN','GU')) 
--(lp.[year] = '2015')
--(rp.[active] = 1) 
--and exists ((select * from [field] _f inner join [lookup.prompt] _p on (_p.[id] =_f.[prompt]) where (_p.[xml].value('(p[k = "gargoyle"]/v)[1]', 'varchar(max)') is not null) and (_f.[record] = a.[id]) and (_f.[field] in ('program_type','program_type_area','program'))))
