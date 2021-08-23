--Travail sur les vérifications TVA

--On récupère les tiers dont le pays du code adresse est différent du pays de TVA
(select 'Pays Adresse TVA Différent' as Source, 
tiers.t_bpid as Tiers, 
tiers.t_nama as NomTiers, 
tiers.t_fovn as NumTVATiers, 
tva.t_fovn as NumTVA, 
adr.t_ccty as PaysAdresse, 
tva.t_ccty as PaysTVA  
from ttccom100500 tiers 
inner join ttccom130500 adr on adr.t_cadr = tiers.t_cadr 
inner join ttctax400500 tva on tva.t_bpid = tiers.t_bpid
where tva.t_ccty != adr.t_ccty 
) union all 
--On récupère les tiers dont le pays du code TVA est différent de FRA
(select 'Pays TVA Etranger' as Source, 
tiers.t_bpid as Tiers, 
tiers.t_nama as NomTiers, 
tiers.t_fovn as NumTVATiers, 
tva.t_fovn as NumTVA, 
'' as PaysAdresse, 
tva.t_ccty as PaysTVA  
from ttccom100500 tiers 
inner join ttctax400500 tva on tva.t_bpid = tiers.t_bpid
where tva.t_ccty != 'FRA' 
) union all 
--On récupère les tiers dont le pays du code Adresse est différent de FRA
(select 'Pays Adresse Etranger' as Source, 
tiers.t_bpid as Tiers, 
tiers.t_nama as NomTiers, 
tiers.t_fovn as NumTVATiers, 
'' as NumTVA, 
adr.t_ccty as PaysAdresse, 
'' as PaysTVA  
from ttccom100500 tiers 
inner join ttccom130500 adr on adr.t_cadr = tiers.t_cadr 
where adr.t_ccty != 'FRA' 
) union all 
--On récupère les tiers dont le pays du code TVA est différent de FRA
(select 'Numero TVA Tiers et TVA Différent' as Source, 
tiers.t_bpid as Tiers, 
tiers.t_nama as NomTiers, 
tiers.t_fovn as NumTVATiers, 
tva.t_fovn as NumTVA, 
'' as PaysAdresse, 
tva.t_ccty as PaysTVA  
from ttccom100500 tiers 
inner join ttctax400500 tva on tva.t_bpid = tiers.t_bpid
where tva.t_fovn != tiers.t_fovn 
);