-------------------------------
-- FAB09 - Plan de Production
-------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
/*
declare @opt1 varchar(20) = 'decorati';
declare @opt2 varchar(20) = 'decofour';
declare @opt3 varchar(20) = 'typedeco';
declare @ue_f varchar(20) = 'LB';
declare @ue_t varchar(20) = 'LB';
declare @date_f date = '01/01/1980'; -- ofab, tester 2018-12-19 sinon
declare @date_t date = '16/04/2019';
declare @dateachop_f date = '01/01/1980'; -- opof
declare @dateachop_t date = '16/04/2019';
declare @ofab_f varchar(20) = 'LB'; -- 
declare @ofab_t varchar(20) = 'LBZ';
declare @emp_f varchar(20) = '';
declare @emp_t varchar(20) = 'zzz';
declare @stat_f varchar(20) = '1';
declare @stat_t varchar(20) = '8';
*/
select ofab.t_orno as CommandeClient
,ofab.t_cprj as Projet
,(case
when exists (select lcde.t_item from ttdsls401500 lcde where lcde.t_item = concat(ofab.t_cprj,'V00000780'))
	then 'OUI'
else 'NON'
end) as Modification
,ofab.t_pdno as OrdreFabrication
,opof.t_opno as OperationOrdreFabrication
,left(ofab.t_mitm, 9) as ProjetArticleOperationOF
,substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as ArticleOF
,art.t_dsca as DescriptionArticle
,art.t_citg as GroupeArticleOF
,ofab.t_cwar as Magasin
,dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF
,ofab.t_prdt as DateDebutFabrication
,ofab.t_apdt as DateReelleDebutFab
,ofab.t_cmdt as DateAchevementOF
,ofab.t_qrdr as QuantiteOrdre
,ofab.t_qdlv as QuantiteLivree
,dbo.textnumtotext(ofab.t_txta,'4') as TexteAssocieOF
,dbo.textnumtotext(opof.t_txta,'4') as TexteAssocieOperationOF
,opof.t_tano as Tache
,tache.t_dsca as DescriptionTache
,dbo.convertenum('ti','B61C','a9','bull','sfc.opst',opof.t_opst,'4') as StatutOperation
,opof.t_cmdt as DateAchevementTache
,lov.t_dmad as DateMADCConfirmee
,lov.t_ddta as DateProductionGruau
,ofab.t_pldt as DateLivraisonPlanifiee
,ofab.t_rdld as DateLivraisonRequise
,ofab.t_sfpl as PiloteAtelier
,emp.t_nama as NomPiloteAtelier
,dbo.textnumtotext(optvar1.t_txta,'4') as TexteOptionVariante1
,dbo.textnumtotext(optvar2.t_txta,'4') as TexteOptionVariante2
,dbo.textnumtotext(optvar3.t_txta,'4') as TexteOptionVariante3
,left(cmat.t_sitm, 9) as ProjetCellule
,substring(cmat.t_sitm, 10, len(cmat.t_sitm)) as ArticleCellule
from ttisfc001500 ofab --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttisfc010500 opof on opof.t_pdno = ofab.t_pdno --Opérations Ordres de Fabrication
left outer join ttirou003500 tache on tache.t_tano = opof.t_tano --Tâches
left outer join ttdsls401500 lov on lov.t_orno = ofab.t_orno and lov.t_pono = ofab.t_pono --Ligne de Commande Client
left outer join ttccom001500 emp on emp.t_emno = ofab.t_sfpl --Employé
left outer join ttipcf500500 var on var.t_refo = ofab.t_cprj and ofab.t_cprj != '' and var.t_reft = 4 --Variantes de Produits ; On ne prend que les variantes de type Projet (PCS)
left outer join ttipcf520500 optvar1 on optvar1.t_cpva = var.t_cpva and optvar1.t_cpft = @opt1 --Options par Variantes de Produits
left outer join ttipcf520500 optvar2 on optvar2.t_cpva = var.t_cpva and optvar2.t_cpft = @opt2 --Options par Variantes de Produits
left outer join ttipcf520500 optvar3 on optvar3.t_cpva = var.t_cpva and optvar3.t_cpft = @opt3 --Options par Variantes de Produits
left outer join tticst001500 cmat on cmat.t_pdno = ofab.t_pdno and cmat.t_sitm = (select top 1 cmat2.t_sitm from tticst001500 cmat2 inner join ttcibd001500 artcomp on artcomp.t_item = cmat2.t_sitm and artcomp.t_citg like 'BAK%' where cmat2.t_pdno = ofab.t_pdno)
where
left(ofab.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
and ofab.t_cmdt between @date_f and @date_t --Bornage sur la Date d'Achèvement de l'OF
and opof.t_cmdt between @dateachop_f and @dateachop_t --Bornage sur la Date d'Achevement de la Tache
and ofab.t_pdno between @ofab_f and @ofab_t --Bornage sur l'Ordre de Fabrication
and ofab.t_sfpl between @emp_f and @emp_t --Bornage sur le Pilote de l'Atelier
and ofab.t_osta between @stat_f and @stat_t --Bornage sur le Statut de l'OF