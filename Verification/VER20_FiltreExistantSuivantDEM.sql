------------------------------------------
-- VER20 - Filtres existants pour DEM
------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select acti.t_proc as Dem
,role.t_desc as DescriptionRole
,acti.t_acco as Session
,rolemp.t_user as Utilisateur
,empl.t_name as NomUtilisateur
,dbo.convertenum('tc','B61C','a9','bull','yesno',perso.t_filt,'4') as Filtre
from ttgbrg520500 acti --Gestion de activités des processus
inner join ttgbrg820500 rolemp on rolemp.t_role = acti.t_proc --Roles par employés
inner join ttgbrg810500 role on role.t_role = rolemp.t_role --Roles
inner join ttgbrg835500 empl on empl.t_user = rolemp.t_user --Employés 
inner join tttadv950000 perso on perso.t_udrc = rolemp.t_user and concat(perso.t_cpac, perso.t_cmod, perso.t_cses) = acti.t_acco --Personnalisation
where acti.t_acco between @acco_f and @acco_t --Bornage sur l'application (session)
and acti.t_proc between @proc_f and @proc_t --Bornage sur DEM
and perso.t_filt in (@filt) --Bornage sur Filtre (Oui/Non)
and	rolemp.t_user between @user_f and @user_t --Bornage sur l'utilisateur