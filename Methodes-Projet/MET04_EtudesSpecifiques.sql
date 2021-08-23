-------------------------------
-- MET04 - Etudes Spécifiques OF LV
-------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/*
declare @date_f date = DATEADD(DD, -360, CAST(CURRENT_TIMESTAMP AS DATE));
declare @date_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @datevar_f date = DATEADD(DD, -360, CAST(CURRENT_TIMESTAMP AS DATE));
declare @datevar_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @cprj_f nvarchar(9) = ' '
declare @cprj_t nvarchar(9) = 'ZZZZZZZZZ'
declare @phase_f nvarchar(9) = '1'
declare @phase_t nvarchar(9) = '3'
declare @stat_f integer = '1'
declare @stat_t integer = '3'
declare @ue_f nvarchar(2) = 'LV'
declare @ue_t nvarchar(2) = 'SM'
*/

(select art.t_citg as FamilleProduit, 
ga.t_dsca as DescriptionFamilleProduit, 
art.t_cpcl as ClasseProduit, 
clp.t_dsca as DescriptionClasseProduit, 
prj.t_cprj as Projet, 
projet.t_dsca as DescriptionProjet, 
dbo.convertenum('tc','B61C','a9','bull','psts',prj.t_psts,'4') as StatutProjet, 
prj.t_psta as PhaseProjet, 
pprj.t_dsca as DescriptionPhaseProjet, 
--correction par rbesnier le 05/06/2018, l'article ETUDESPE est le plus souvent en 3ème niveau dans les nomenclatures, il y a souvent un article V.... qui contient l'article ETUDESPE, il n'est pas présent dans l'article de tête
-- dboivin 11/06/2018 on compte le nombre d'articles etudespe avec ce projet et une quantité supérieure à 0, le champ projet étant absent de la nomenclature, on va le chercher sur l'article
--(select sum(nom.t_qana) from ttibom010500 nom where nom.t_mitm = lcde.t_item and nom.t_sitm like '%ETUDESPE%') as QuantiteArticleEtudeSpe, 
--(select sum(nom.t_qana) from ttibom010500 nom where left(nom.t_mitm, 9) = prj.t_cprj and nom.t_sitm like '%ETUDESPE%') as QuantiteArticleEtudeSpe, 
(select count(nom.t_sitm) from ttibom010500 nom inner join ttcibd001500 artn on nom.t_mitm=artn.t_item where artn.t_cprj = prj.t_cprj and nom.t_sitm like '%ETUDESPE%' and nom.t_qana > 0) as QuantiteArticleEtudeSpe, 
--'' as QuantiteArticleEtudeSpe, 
--Formule SSRS pour ce champ : =IIf(IsNothing(Fields!QuantiteArticleEtudeSpe.Value),"Non Présent",Fields!QuantiteArticleEtudeSpe.Value)
--(select top 1 t_pdno from ttisfc001500 orfab where orfab.t_mitm = concat(prj.t_cprj, 'ETUDESPELV')) as OFArticleEtudeSpe, 
(select top 1 t_pdno from ttisfc001500 orfab inner join ttcibd001500 artn on orfab.t_mitm=artn.t_item where artn.t_cprj = prj.t_cprj and orfab.t_mitm = concat(prj.t_cprj, 'ETUDESPELV')) as OFArticleEtudeSpe, 
--'' as OFArticleEtudeSpe, 
--isnull((select sum(nom.t_qana) from ttibom010500 nom where left(nom.t_mitm, 9) = prj.t_cprj and nom.t_sitm like '%ETUDESPE%'), 0) - isnull((select sum(nom.t_qana) from ttibom010500 nom where left(nom.t_mitm, 9) = prj.t_cprj and nom.t_sitm = concat(prj.t_cprj, 'ETUDESPE', left(prj.t_cprj, 2))), 0) as SiteEtudeSpe, 
--(select top 1 right(nom.t_sitm, 2) from ttibom010500 nom where left(nom.t_mitm, 9) = prj.t_cprj and nom.t_sitm like '%ETUDESPE%' and nom.t_sitm not like concat('%ETUDESPE', left(prj.t_cprj, 2))) as SiteEtudeSpe, 
(select top 1 right(nom.t_sitm, 2) from ttibom010500 nom inner join ttcibd001500 artn on nom.t_mitm=artn.t_item where artn.t_cprj = prj.t_cprj and nom.t_sitm like '%ETUDESPE%' and nom.t_sitm not like concat('%ETUDESPE', left(prj.t_cprj, 2))) as SiteEtudeSpe, 
--'' as SiteEtudeSpe, 
isnull((select sum(stkartspe.t_stoc) from ttcibd100500 stkartspe where stkartspe.t_item = concat(prj.t_cprj, 'ETUDESPELV')), 0) as StockArticleEtudeSpe, 
--'' as StockArticleEtudeSpe, 
cde.t_cdf_bcdt as DateSignatureBonCommande, 
lcde.t_odat as DateSaisieOV, 
dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo,'4') as SousTraitantTransformation, 
cde.t_crep as Interlocuteur, 
emp.t_nama as NomInterlocuteur, 
lcde.t_orno as NumeroCommande, 
lcde.t_pono as PositionCommande, 
lcde.t_sqnb as SequenceCommande, 
left(lcde.t_item, 9) as ProjetArticle, 
substring(lcde.t_item, 10, len(lcde.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
ofab.t_pdno as OrdreFabrication, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
lcde.t_ofbp as TiersAcheteur, 
tier.t_nama as NomTiersAcheteur, 
lcde.t_cpva as Variante, 
vari.t_pcfd as DateVariante, 
dbo.convertenum('tc','B61C','a9','bull','yesno',vari.t_vali,'4') as VarianteProduitCorrecte,
dbo.textnumtotext(lcde.t_txta,'4') as TexteLigneOV, 
lcde.t_dlsc as DateLivraisonSouhaiteeClient, 
cde.t_cdf_redt as DateRecettePlanifiee, 
cde.t_cdf_prdt as DateDemarragePenaliteRetard, 
lcde.t_dapc as DateArriveePrevueChassis, 
(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) as DateArriveeChassis, --On prend la date la plus récente
lcde.t_dmad as DateMADCConfirmee, 
cde.t_ddat as DateProductionGruau, 
lcde.t_prdt as DateMADCPrevue, 
lcde.t_dcde as DelaiReceptionCommande, 
lcde.t_drch as DelaiReceptionChassis, 
cde.t_refa as ParcOuBesoin, 
cde.t_corn as InfoCommandeClient, 
prj.t_cdf_drdf as DossierDateReceptionDescriptif, 
dbo.convertlistcdf('ti','B61C','a9','grup','dca',prj.t_cdf_dca1,'4') as DossierChargeAffaire1, 
dbo.convertlistcdf('ti','B61C','a9','grup','dca',prj.t_cdf_dca2,'4') as DossierChargeAffaire2, 
dbo.convertlistcdf('ti','B61C','a9','grup','dca',prj.t_cdf_dca3,'4') as DossierChargeAffaire3, 
prj.t_cdf_ddtd as DateDebutTraitementDossier, 
prj.t_cdf_dbfc as DateBonAFabriquerClient, 
prj.t_cdf_dnok as DateNomenclatureOK, 
prj.t_cdf_ddpd as Date100DossierProd, 
prj.t_cdf_dfpe as DateFinPrevisionnelle, 
prj.t_cdf_tatt as TempsAlloueTraitement, 
prj.t_cdf_txtp as TexteProjet, 
prj.t_cdf_avca as AvenantCodeAvenant, 
dbo.convertlistcdf('ti','B61C','a9','grup','dca',prj.t_cdf_avcf,'4') as AvenantChargeAffaire, 
prj.t_cdf_avdt as AvenantDateDebutTraitement, 
prj.t_cdf_avdp as AvenantDate100DossierProd 
from ttipcs030500 prj --Détails du Projet
inner join ttdsls401500 lcde on lcde.t_cprj = prj.t_cprj --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
-- piste pour améliorer les perfs, ajouter le projet et l'article pour la recherche sur les OF
--Modification suite au ticket 40940
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --Ordres de Fabrication
left outer join ttccom100500 tier on tier.t_bpid = lcde.t_ofbp --Tiers
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employés
left outer join ttcmcs023500 ga on ga.t_citg = art.t_citg --Groupes Articles (Famille de Produit)
left outer join ttipcs024500 pprj on pprj.t_psta = prj.t_psta --Phases de Projet
left outer join ttipcf500500 vari on vari.t_cpva = lcde.t_cpva --Variante de Produit
left outer join ttcmcs062500 clp on clp.t_cpcl = art.t_cpcl --Classe de Produit
left outer join ttcmcs052500 projet on projet.t_cprj = prj.t_cprj --Projets
where left(prj.t_cprj, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le projet
and prj.t_cprj between @cprj_f and @cprj_t --Bornage sur le Projet
and prj.t_psts between @stat_f and @stat_t --Bornage sur le Statut du Projet
and prj.t_psta between @phase_f and @phase_t --Bornage sur la Phase du Projet
and lcde.t_odat between @date_f and @date_t --Bornage sur la Date de Saisie de l'OV
and vari.t_pcfd between @datevar_f and @datevar_t --Bornage sur la Date de la Variante
)
union all --rajout par rbesnier le 02/04/2019 pour le ticket http://srvinfo2/glpi/front/ticket.form.php?id=42293
(select art.t_citg as FamilleProduit, 
ga.t_dsca as DescriptionFamilleProduit, 
art.t_cpcl as ClasseProduit, 
clp.t_dsca as DescriptionClasseProduit, 
prj.t_cprj as Projet, 
projet.t_dsca as DescriptionProjet, 
dbo.convertenum('tc','B61C','a9','bull','psts',prj.t_psts,'4') as StatutProjet, 
prj.t_psta as PhaseProjet, 
pprj.t_dsca as DescriptionPhaseProjet, 
(select count(nom.t_sitm) from ttibom010500 nom inner join ttcibd001500 artn on nom.t_mitm=artn.t_item where artn.t_cprj = prj.t_cprj and nom.t_sitm like '%ETUDESPE%' and nom.t_qana > 0) as QuantiteArticleEtudeSpe, 
(select top 1 t_pdno from ttisfc001500 orfab inner join ttcibd001500 artn on orfab.t_mitm=artn.t_item where artn.t_cprj = prj.t_cprj and orfab.t_mitm = concat(prj.t_cprj, 'ETUDESPELV')) as OFArticleEtudeSpe, 
(select top 1 right(nom.t_sitm, 2) from ttibom010500 nom inner join ttcibd001500 artn on nom.t_mitm=artn.t_item where artn.t_cprj = prj.t_cprj and nom.t_sitm like '%ETUDESPE%' and nom.t_sitm not like concat('%ETUDESPE', left(prj.t_cprj, 2))) as SiteEtudeSpe, 
isnull((select sum(stkartspe.t_stoc) from ttcibd100500 stkartspe where stkartspe.t_item = concat(prj.t_cprj, 'ETUDESPELV')), 0) as StockArticleEtudeSpe, 
cde.t_cdf_bcdt as DateSignatureBonCommande, 
lcde.t_odat as DateSaisieOV, 
dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo,'4') as SousTraitantTransformation, 
cde.t_crep as Interlocuteur, 
emp.t_nama as NomInterlocuteur, 
lcde.t_orno as NumeroCommande, 
lcde.t_pono as PositionCommande, 
lcde.t_sqnb as SequenceCommande, 
left(lcde.t_item, 9) as ProjetArticle, 
substring(lcde.t_item, 10, len(lcde.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
ofab.t_pdno as OrdreFabrication, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
lcde.t_ofbp as TiersAcheteur, 
tier.t_nama as NomTiersAcheteur, 
lcde.t_cpva as Variante, 
'' as DateVariante, 
'' as VarianteProduitCorrecte,
dbo.textnumtotext(lcde.t_txta,'4') as TexteLigneOV, 
lcde.t_dlsc as DateLivraisonSouhaiteeClient, 
cde.t_cdf_redt as DateRecettePlanifiee, 
cde.t_cdf_prdt as DateDemarragePenaliteRetard, 
lcde.t_dapc as DateArriveePrevueChassis, 
(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) as DateArriveeChassis, --On prend la date la plus récente
lcde.t_dmad as DateMADCConfirmee, 
cde.t_ddat as DateProductionGruau, 
lcde.t_prdt as DateMADCPrevue, 
lcde.t_dcde as DelaiReceptionCommande, 
lcde.t_drch as DelaiReceptionChassis, 
cde.t_refa as ParcOuBesoin, 
cde.t_corn as InfoCommandeClient, 
prj.t_cdf_drdf as DossierDateReceptionDescriptif, 
dbo.convertlistcdf('ti','B61C','a9','grup','dca',prj.t_cdf_dca1,'4') as DossierChargeAffaire1, 
dbo.convertlistcdf('ti','B61C','a9','grup','dca',prj.t_cdf_dca2,'4') as DossierChargeAffaire2, 
dbo.convertlistcdf('ti','B61C','a9','grup','dca',prj.t_cdf_dca3,'4') as DossierChargeAffaire3, 
prj.t_cdf_ddtd as DateDebutTraitementDossier, 
prj.t_cdf_dbfc as DateBonAFabriquerClient, 
prj.t_cdf_dnok as DateNomenclatureOK, 
prj.t_cdf_ddpd as Date100DossierProd, 
prj.t_cdf_dfpe as DateFinPrevisionnelle, 
prj.t_cdf_tatt as TempsAlloueTraitement, 
prj.t_cdf_txtp as TexteProjet, 
prj.t_cdf_avca as AvenantCodeAvenant, 
dbo.convertlistcdf('ti','B61C','a9','grup','dca',prj.t_cdf_avcf,'4') as AvenantChargeAffaire, 
prj.t_cdf_avdt as AvenantDateDebutTraitement, 
prj.t_cdf_avdp as AvenantDate100DossierProd 
from ttipcs030500 prj --Détails du Projet
inner join ttdsls401500 lcde on lcde.t_cprj = prj.t_cprj --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --Ordres de Fabrication
left outer join ttccom100500 tier on tier.t_bpid = lcde.t_ofbp --Tiers
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employés
left outer join ttcmcs023500 ga on ga.t_citg = art.t_citg --Groupes Articles (Famille de Produit)
left outer join ttipcs024500 pprj on pprj.t_psta = prj.t_psta --Phases de Projet
left outer join ttcmcs062500 clp on clp.t_cpcl = art.t_cpcl --Classe de Produit
left outer join ttcmcs052500 projet on projet.t_cprj = prj.t_cprj --Projets
where left(prj.t_cprj, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le projet
and prj.t_cprj between @cprj_f and @cprj_t --Bornage sur le Projet
and prj.t_psts between @stat_f and @stat_t --Bornage sur le Statut du Projet
and prj.t_psta between @phase_f and @phase_t --Bornage sur la Phase du Projet
and lcde.t_odat between @date_f and @date_t --Bornage sur la Date de Saisie de l'OV
and lcde.t_cpva = '' --On ne prend que les enregistrements sans variantes
)