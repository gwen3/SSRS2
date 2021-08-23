--------------------------------------
-- VER19 - Filtres dans les sessions
--------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select perso.t_udrc as Utilisateur
,empl.t_name as NomUtilisateur
,perso.t_culv as Niveauperso
,(case perso.t_culv
	when 1 then 'Niveau Utilisateur'
	when 2 then 'Niveau Role'
	when 3 then 'Niveau Société'
	else ''
end) as LibNiveauPerso
,perso.t_cpac as CodeAppli
,perso.t_cmod as Module
,perso.t_cses as NomSession
,dbo.convertenum('tc','B61C','a9','bull','yesno',perso.t_filt,'4') as Filtre
from tttadv950000 perso
inner join ttgbrg835500 empl on empl.t_user = perso.t_udrc --Employés
where perso.t_culv in (@niveau) --On borne sur le niveau de personnalisation 
and perso.t_cpac between @cpac_f and @cpac_t --On borne sur l'application
and perso.t_cmod between @cmod_f and @cmod_t --On borne sur le module
and perso.t_cses between @cses_f and @cses_t --On borne sur la session
and perso.t_filt in (@filt) --Bornage sur le filtrage