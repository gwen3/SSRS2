--------------------------------------------------------
-- VER21 PROCESSUS_ROLES_SESSIONS
--------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
 processus.t_proc as Processus
,processus.t_desc as DescriptionProcessus
,dbo.convertenum('tc','B61C','a9','bull','yesno',processus.t_expi,'4') as ExpiProcessus
,processus.t_stat as StatutProcessus
,processus.t_cdat as DateMajProc
,processus.t_upus as UtilMajProc
,roles.t_role as NomRole
,roles.t_desc as DescriptionRole
,roles.t_cdat as DateMajRole
,roles.t_cusr as UtilMajRole
,dbo.convertenum('tc','B61C','a9','bull','yesno',roles.t_expi,'4') as ExpiRole
,activites.t_extc as CodeExterneActivite
,activites.t_pono as PosActivite
,activites.t_desc as DescriptionActivite
,activites.t_acco as ApplicationActivites
,activites.t_argu as ArgumentActivites
,activites.t_cotp as TypeCtrlActivites
,activites.t_cmpt as ComposantActivites
,activites.t_rele as VersionComposantActivites
,activites.t_cuti as AppliAuxActivites
,ssappactiv.t_sacc as SsApplication
,descrapplications.t_desc as DescriptionApplication
,ssappactiv.t_sequ as SeqSsApplication
,dbo.convertenum('tg','B61','a','','brg.auth',ssappactiv.t_auth,'4') as AutorisationsApplication
from ttgbrg500500 processus
inner join ttgbrg506500 roleproc on roleproc.t_proc = processus.t_proc and roleproc.t_vers = processus.t_vers
inner join ttgbrg810500 roles on roles.t_role = roleproc.t_role
left outer join ttgbrg520500 activites on activites.t_proc = processus.t_proc and activites.t_prov = processus.t_vers
left outer join ttgbrg523500 ssappactiv on ssappactiv.t_proc = activites.t_proc and ssappactiv.t_prov = activites.t_prov and ssappactiv.t_pono = activites.t_pono
left outer join ttgbrg565500 descrapplications on descrapplications.t_cmpt = activites.t_cmpt and descrapplications.t_rele = activites.t_rele  and descrapplications.t_acco = ssappactiv.t_sacc and descrapplications.t_clan = '4'
where (processus.t_proc in (@proc_f) and (@prodesc_f is null or processus.t_desc like concat('%', @prodesc_f, '%')))
and roles.t_role in (@role_f)
and (activites.t_acco like  concat('%', @acco_f, '%') or @acco_f is null)
order by 
processus.t_proc,
roles.t_role,
activites.t_extc,
ssappactiv.t_sequ