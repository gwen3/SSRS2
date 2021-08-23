------------------------------
-- FAB12 - Coûts Fab par EPR
------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select cout.t_pdno as OrdreFabrication
,(select ofab2.t_qdlv from ttisfc001500 ofab2 where ofab2.t_pdno = cout.t_pdno and cout.t_cpcp = 'MATIER') as QuantiteLivreeOF
,(select ofab3.t_qrdr from ttisfc001500 ofab3 where ofab3.t_pdno = cout.t_pdno and cout.t_cpcp = 'MATIER') as QuantiteOrdreOF
,left(ofab.t_mitm, 9) as ProjetArticle
,substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article
,concat(art.t_citg, ' - ', grpart.t_dsca) as GroupeArticle
,art.t_dsca as DescriptionArticle
,cout.t_cwoc as CentreCharge
,cout.t_cpcp as ElementPrixRevient 
,epr.t_dsca as DescriptionElementPrixRevient
,cout.t_nune as NombreEstimeUnite
,cout.t_eamt_1 as MontantEstimeUnite
,cout.t_nuna as NombreReelUnite
,cout.t_aamt_1 as MontantReelUnite
,ofab.t_qdlv as QuantiteLivree
,(select ofab3.t_qrdr from ttisfc001500 ofab3 where ofab3.t_pdno = cout.t_pdno) as QuantiteOrdre
,(cout.t_nune * ofab.t_qdlv) as NombreEstimeTotal
,(cout.t_eamt_1 * ofab.t_qdlv) as MontantEstimeTotal
,(cout.t_nuna * ofab.t_qdlv) as NombreReelTotal
,(cout.t_aamt_1 * ofab.t_qdlv) as MontantReelTotal
,cout.t_ccur as Devise
,ofab.t_cada as DateCalcul
,ofab.t_prdt as DateFabricationPlanifiee
,ofab.t_adld as DateLivraisonReelle
,ofab.t_cldt as DateClotureReelle
,ofab.t_cmdt as DateAchevement
,concat(ofab.t_plid, ' - ', emppla.t_nama) as Planificateur
from tticst010500 cout --Couts unitaires des produits finis
inner join ttisfc001500 ofab on ofab.t_pdno = cout.t_pdno --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttcmcs048500 epr on epr.t_cpcp = cout.t_cpcp --Elements de Prix de Revients
left outer join ttccom001500 emppla on emppla.t_emno = ofab.t_plid --Employés - Planificateur
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Article
where cout.t_cstv = 1 --On prend les coûts selon articles
and left(cout.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par l'OF
and left(ofab.t_mitm, 9) between @prj_f and @prj_t --Bornage sur le Projet
and substring(ofab.t_mitm, 10, len(ofab.t_mitm)) between @art_f and @art_t --Bornage sur l'Article
and cout.t_pdno between @ofab_f and @ofab_t --Bornage sur l'OF
and ofab.t_prdt between @datefab_f and @datefab_t --Bornage sur la Date de Fabrication Planifiée
and ofab.t_adld between @dateliv_f and @dateliv_t --Bornage sur la Date de Livraison Réelle
and ofab.t_cldt between @dateclo_f and @dateclo_t --Bornage sur la Date de Cloture Réelle
and ofab.t_cmdt between @dateachev_f and @dateachev_t --Bornage sur la Date d'Achevement
and ofab.t_plid between @planif_f and @planif_t --Bornage sur le Planificateur
and art.t_citg between @grpart_f and @grpart_t --Bornage sur le Groupe Article