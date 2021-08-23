---------------------
-- QUA03 - Cotation
---------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select cspe.t_datc as DateCreation, 
cspe.t_eunt as UniteEntreprise, 
ue.t_dsca as SiteGruauTraitant, 
cspe.t_cflu as CodeLieuFluxDetectant, 
flux.t_dsca as LieuFluxDetectant, 
cspe.t_crea as Createur, 
cspe.t_natp as CodeNatureProduit, 
nat.t_dsca as NatureProduit, 
cspe.t_nctp as CodeFamilleProduit, 
pnc.t_dsca as FamilleProduit, 
cspe.t_vehi as CodeVehiculeBase, 
vehi.t_dsca as VehiculeBase, 
--Nouvelle version dans une nouvelle table
--cspe.t_serl as NumeroSerieVehicule, 
cspelot.t_serl as NumeroSerieVehicule, 
cspe.t_dsca as DescriptionControleSpecifique, 
(case 
when (cspe.t_quna = 0) 
	then 'Pas de Défaut' 
when (cspe.t_quna != 0) 
	then (select concat('Sévérité : ', dbo.GROUP_CONCAT_D(rtrim(dbo.textnumtotext(nc.t_nctx,'4')), ', Sévérité : ')) from tqmncm100500 nc where nc.t_ctrl = cspe.t_cont and (nc.t_lflu = 'GR-000004' or nc.t_lflu = 'GR-000009') and nc.t_slvl in ('AVES-(V1)', 'AVES-V1', 'AVES-V1+', 'IQAIQF-A', 'IQAIQF-B', 'VOLVO-100', 'VOLVO-50', 'VOLVO-25'))
end) as SeveriteDefautV1, 
(case 
when (cspe.t_quna = 0) 
	then 'Pas de Défaut' 
when (cspe.t_quna != 0) 
	then (select concat('Sévérité : ', dbo.GROUP_CONCAT_D(rtrim(dbo.textnumtotext(nc.t_nctx,'4')), ', Sévérité : ')) from tqmncm100500 nc where nc.t_ctrl = cspe.t_cont and (nc.t_lflu = 'GR-000004' or nc.t_lflu = 'GR-000009') and nc.t_slvl in ('AVES-(V2)', 'AVES-V2', 'IQAIQF-C', 'IQAIQF-D', 'VOLVO-5'))
end) as SeveriteDefautV2, 
--Rajout des types de défaut le 18/09/2017 par rbesnier
(case 
when (cspe.t_quna = 0) 
	then 'Pas de Défaut' 
when (cspe.t_quna != 0) 
	then (select concat('Type Déf : ', dbo.GROUP_CONCAT_D(nc.t_tdft, ', Type Déf : ')) from tqmncm100500 nc where nc.t_ctrl = cspe.t_cont and (nc.t_lflu = 'GR-000004' or nc.t_lflu = 'GR-000009') and nc.t_slvl in ('AVES-(V1)', 'AVES-V1', 'AVES-V1+', 'IQAIQF-A', 'IQAIQF-B', 'VOLVO-100', 'VOLVO-50', 'VOLVO-25'))
end) as TypeDefautV1, 
(case 
when (cspe.t_quna = 0) 
	then 'Pas de Défaut' 
when (cspe.t_quna != 0) 
	then (select concat('Type Déf : ', dbo.GROUP_CONCAT_D(nc.t_tdft, ', Type Déf : ')) from tqmncm100500 nc where nc.t_ctrl = cspe.t_cont and (nc.t_lflu = 'GR-000004' or nc.t_lflu = 'GR-000009') and nc.t_slvl in ('AVES-(V2)', 'AVES-V2', 'IQAIQF-C', 'IQAIQF-D', 'VOLVO-5'))
end) as TypeDefautV2, 
left(cspe.t_item, 9) as ProjetArticle, 
substring(cspe.t_item, 10, len(cspe.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
cspe.t_cont as ControleSpecifique, 
cspe.t_quna as QuantiteNOK, 
(case 
when (cspe.t_quna = 0) 
	then '0' 
when (cspe.t_quna != 0) 
	then (select count(nc.t_nctx) from tqmncm100500 nc where nc.t_ctrl = cspe.t_cont and nc.t_slvl like '%V1%') 
end) as NombreV1, 
(case 
when (cspe.t_quna = 0) 
	then '0' 
when (cspe.t_quna != 0) 
	then (select count(nc.t_nctx) from tqmncm100500 nc where nc.t_ctrl = cspe.t_cont and nc.t_slvl like '%V2%') 
end) as NombreV2, 
cspe.t_empj as EmplacementPieceJointe, 
--Rajout par rbesnier le 19/09/2017
cspe.t_mpro as ModeDeProduction, 
modpro.t_dsca as NomModeDeProduction 
from tzgncm100500 cspe --Contrôles Spécifiques
left outer join ttcemm030500 ue on ue.t_eunt = cspe.t_eunt --Unite d'Entreprise
left outer join tzgncm001500 flux on flux.t_cflu = cspe.t_cflu --Lieu de Flux Détectant
left outer join tzgncm002500 nat on nat.t_natp = cspe.t_natp --Nature du Produit
left outer join tzgncm003500 vehi on vehi.t_vehi = cspe.t_vehi --Vehicule de Base
--Rajout par rbesnier le 19/09/2017
left outer join tzgncm004500 modpro on modpro.t_mpro = cspe.t_mpro --Modes de Production
left outer join tqmncm001500 pnc on pnc.t_nctp = cspe.t_nctp --Type de Produits Non Conformes
--Changement de table, on allait avant dans la 002, passage à la 003 ; le 18/09/2017 par rbesnier
left outer join ttcibd001500 art on art.t_item = cspe.t_item --Articles
--Rajout par rbesnier le 18/09/2017 pour ramener le numéro de série du véhicule
left outer join tzgncm110500 cspelot on cspelot.t_cont = cspe.t_cont and cspelot.t_seqn = (select top 1 csl.t_seqn from tzgncm110500 csl where csl.t_cont = cspe.t_cont order by csl.t_seqn desc) --Controle Spécifiques - lots et séries
where left(cspe.t_cont, 2) between @ue_f and @ue_t --Bornage sur l'Unite d'Entreprise à partir du Numéro de Contrôle Spécifiques
--On change le critère pour pouvoir borner sur un nombre de jour (pour faire un abonnement au mois ou au jour)
and cspe.t_datc between @date_f and @date_t --Bornage sur la Date de Création
and left(cspe.t_cont, 2) in (@site) --Bornage sur le Site
and cspe.t_nctp in (@fam) --Bornage sur la famille de Produit
order by flux.t_dsca, cspe.t_natp asc