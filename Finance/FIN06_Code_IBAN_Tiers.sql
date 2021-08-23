--------------------------------------
-- FIN06 - Code IBAN des tiers
--------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(
select
'Tiers Payé' as RoleTiers,
dbo.convertenum('tc','B61C','a9','bull','bprl',tiers.t_bprl,'4') as RoleGeneral,
dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as StatutTiers,
tiers.t_bpid as CodeTiers,
tiers.t_nama as NomTiers,
cbt.t_cban as CodeCpteBancaire,
cbt.t_bano as CpteBancaire,
cbt.t_iban as Iban,
cbt.t_toac as TypeCpte,
cbt.t_brch as CodeAgence,
agbank.t_bnam as NomBanque
from
ttccom100500 tiers --Tiers
inner join ttccom124500 tp on tp.t_ptbp = tiers.t_bpid --Tiers payés
inner join ttccom125500 cbt on cbt.t_ptbp = tiers.t_bpid and cbt.t_cban = tp.t_cban --Cptes bancaires par tiers payé
left outer join ttfcmg011500 agbank on agbank.t_bank = cbt.t_brch --Agences bancaires
where
'1' in (@RoleTiers) --Choix du role tiers payé dans la liste
and tiers.t_bpid between  @tiers_f and @tiers_t --Interval de code tiers
and tiers.t_prst in (@statut) --Choix du statut du tiers (actif/non actif)
)
union
(
select
'Tiers Payeur' as RoleTiers,
dbo.convertenum('tc','B61C','a9','bull','bprl',tiers.t_bprl,'4') as RoleGeneral,
dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as StatutTiers,
tiers.t_bpid as CodeTiers,
tiers.t_nama as NomTiers,
cbt.t_cban as CodeCpteBancaire,
cbt.t_bano as CpteBancaire,
cbt.t_iban as Iban,
cbt.t_toac as TypeCpte,
cbt.t_brch as CodeAgence,
agbank.t_bnam as NomBanque
from
ttccom100500 tiers --Tiers
inner join ttccom114500 tp on tp.t_pfbp = tiers.t_bpid --Tiers Payés
inner join ttccom115500 cbt on cbt.t_pfbp = tiers.t_bpid and cbt.t_cban = tp.t_cban --Cptes bancaires par tiers payeur
left outer join ttfcmg011500 agbank on agbank.t_bank = cbt.t_brch --Agences bancaires
where
'2' in (@RoleTiers) --Choix du role tiers payeur dans la liste
and tiers.t_bpid between  @tiers_f and @tiers_t --Interval de code tiers
and tiers.t_prst in (@statut) --Choix du statut du tiers (actif/non actif)
)
order by 4, 1
