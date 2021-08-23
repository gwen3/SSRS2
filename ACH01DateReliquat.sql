--Test pour le ACH01 pour la bonne date de reliquat


with CommandeFourn (Niveau, Ordre, Position, Sequence, SequenceParent, DatePlanifiee, Chemin) as (
-- article tete
select 0 as Niveau, 
loa.t_orno, 
loa.t_pono, 
loa.t_sqnb, 
loa.t_pseq, 
loa.t_ddta, 
cast(concat(loa.t_sqnb, ' / ') as nvarchar(100))
from ttdpur401500 loa --Nomenclatures
where loa.t_orno = 'LV1051261' 
and loa.t_pono = '40'
and loa.t_lseq = 0 --On prend en premier les reliquats sans reliquats
and loa.t_oltp = 3 --On prend les reliquats
union all 
-- récursivité
select Niveau + 1, 
loa.t_orno, 
loa.t_pono, 
loa.t_sqnb, 
loa.t_pseq, 
loa.t_ddta, 
cast(concat(Chemin, loa.t_sqnb, ' / ') as nvarchar(100))
from ttdpur401500 loa --Nomenclatures
inner join CommandeFourn on loa.t_orno = CommandeFourn.Ordre and loa.t_pono = CommandeFourn.Position and loa.t_sqnb = CommandeFourn.SequenceParent --On fait appel à la table nomenclature définie en tout début
where loa.t_sqnb !=0
)
select CommandeFourn.Niveau, 
CommandeFourn.Ordre, 
CommandeFourn.Position, 
CommandeFourn.Sequence, 
RIGHT(REPLICATE('0',4) + CAST(CommandeFourn.Sequence as varchar(4)), 4) as Test2, 
CommandeFourn.SequenceParent, 
CommandeFourn.DatePlanifiee, 
left(CommandeFourn.Chemin, 2), 
(select top 1 cf.t_ddta from ttdpur401500 cf where cf.t_orno = CommandeFourn.Ordre and cf.t_pono = CommandeFourn.Position and cf.t_sqnb = left(CommandeFourn.Chemin, 2) order by CommandeFourn.Chemin desc) as DateOK, 
CommandeFourn.Chemin
from CommandeFourn 
order by CommandeFourn.Chemin desc

/*select CommandeFourn.Niveau, 
CommandeFourn.Ordre, 
CommandeFourn.Position, 
CommandeFourn.Sequence, 
(select cf.DatePlanifiee from CommandeFourn cf where cf.Ordre = CommandeFourn.Ordre and cf.Position = CommandeFourn.Position and cf.SequenceParent = 0 and CommandeFourn.Sequence in CommandeFourn.Chemin)
from CommandeFourn */