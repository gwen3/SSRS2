-------------------------------------------------------------------------
-- VER24 - Attributs Tiers
-------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select
tiers.t_bpid as Tiers
,tiers.t_nama as Nom_Tiers
,tiers.t_lgid as RegistreCommerce
,dbo.convertenum('tc','B61U','a','stnd','bprl',tiers.t_bprl,'4') as Role_Tiers
,dbo.convertenum('tc','B61','a','','com.prst',tiers.t_prst,'4') as Statut_Tiers
,attrt.t_cfea as Attribut
,attr.t_labl as Description_Attribut
,attrt.t_dats as Donnees
,attrt.t_datd as Donnees_Numériques
,dbo.convertenum('td','B61','a','','smi.role',attrt.t_role,'4') as Role_Tiers_Attribut
from 
ttccom100500 tiers  --Tiers
inner join ttdsmi101500 attrt on attrt.t_bpid = tiers.t_bpid -- Attribut tiers
inner join ttdsmi050500 attr on attr.t_cfea = attrt.t_cfea -- Attributs
where 
tiers.t_bprl in (@bprl) -- Bornage Role tiers
and tiers.t_prst in (@prst) --Statut_Tiers
and attrt.t_cfea in (@cfea) --Bornage sur Attribut du tiers
and attrt.t_role in (@role) -- Bornage sur Role tiers pour attribut