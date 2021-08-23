---------------------------
-- FAB02 - Charge Semaine
---------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select uti.t_cwoc as CentreCharge, 
rou.t_dsca as DescriptionCentreCharge, 
uti.t_mcho as HeuresMachines, 
uti.t_pryr as AnneeFabrication, 
uti.t_prwk as SemaineFabrication, 
uti.t_prdt as DateDebutPreparationExecution, 
uti.t_pdno as OrdreFabrication, 
uti.t_opno as OperationOF, 
opt.t_opst as CodeStatutOperation, 
dbo.convertenum('ti','B61C','a9','bull','sfc.opst',opt.t_opst,'4') as StatutOperation, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DescriptionArticle, 
ofab.t_plid as Planificateur, 
ofab.t_prcd as Priorite, 
uti.t_mcno as Machine, 
uti.t_maho as HeureMainOeuvre, 
uti.t_qpln as QuantitePlanifiee, 
ofab.t_grid as GroupeOrdreSFC, 
opt.t_sutm as TempsPreparationMoyen, 
ofab.t_qdlv as QuantiteLivree, 
(uti.t_qpln - ofab.t_qdlv) as QuantiteResteALivrer 
from ttisfc011500 uti --Taux d'Utilisation par Semaine
inner join ttisfc001500 ofab on ofab.t_pdno = uti.t_pdno --Ordre de Fabrication
inner join ttisfc010500 opt on opt.t_pdno = uti.t_pdno and opt.t_opno = uti.t_opno --Opération des Ordres de Fabrication
left outer join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttirou001500 rou on rou.t_cwoc = uti.t_cwoc --Centre de Charge
where left(uti.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
and uti.t_cwoc between @cwoc_f and @cwoc_t --Bornage sur le Centre de Charge
and uti.t_prdt >= @date --Bornage sur la Date Début de Préparation Exécution