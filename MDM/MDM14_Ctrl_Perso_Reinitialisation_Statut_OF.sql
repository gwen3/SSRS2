----------------------------------------------------------
-- MDM14 Ctrl personnalisation réinitialisation statut OF
----------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
dbo.convertenum('tt','7.6','a','','adv.culv',perso.t_culv,'4') as Niveau_Perso
,perso.t_udrc as Utilisateur
,emp.t_name as Nom_Utilisateur
,perses.t_type as CodeTypePerso
,dbo.convertenum('tt','7.6','a','','adv.cuty',perses.t_type,'4') as Type_Perso
,perses.t_name as Nom
,perses.t_valu as Valeur
from tttadv950000 perso
left outer join tttaad200000 emp on perso.t_udrc = emp.t_user
inner join tttadv900000 perses on perses.t_cpac = perso.t_cpac and perses.t_cmod = perso.t_cmod and perses.t_cses = perso.t_cses and perses.t_culv = perso.t_culv and perses.t_udrc = perso.t_udrc
where
perso.t_culv = '1' --Personnalisation au niveau utilisateur
and perso.t_cpac = 'ti'
and perso.t_cmod = 'cst'
and perso.t_cses = '0203m000'
--and ((perso.t_culv = '1' and not exists(select top 1 rolemp.t_role 
--			   from ttgbrg820500 rolemp 
--			   where rolemp.t_role = 'PRD102' and rolemp.t_user = perso.t_udrc)) or perso.t_culv <> '1')
and perses.t_type in ('1','20','21') -- 1 = Personnalisation du champ; 20 = Champ obligatoire/lecture seule; 21 = Paramètres de session