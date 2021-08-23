----------------------------------
-- SCE02 - Prestation de Service
----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select presta.t_orno as OrdreService, 
presta.t_acln as LignePrestation, 
presta.t_crac as PrestationRef, 
presta.t_desc as DescriptionPrestation,
presta.t_pftm as DateDebPlanif,
dbo.convertenum('ts','B61C','a9','bull','soc.osta',presta.t_asta,'4') as StatutPrestation,
dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOs,
os.t_emno as Technicien,
empp.t_nama as NomTechnicien
from ttssoc210500 presta --Prestation d'Ordre de Service
inner join ttssoc200500 os on os.t_orno = presta.t_orno
--inner join tbpmdm001500 edpp on edpp.t_emno = ncmr.t_ownr --Données Employés (du personnel)
inner join ttccom001500 empp on empp.t_emno = os.t_emno --Employés
where left(presta.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE à partir de l'OS
and presta.t_orno between @os_f and @os_t --Bornage sur l'OS voulu
and presta.t_crac between @crac_f and @crac_t -- Bornage sur la Référence de la prestation
and os.t_osta in (@osta) --Bornage sur le statut de l'Ordre de Service