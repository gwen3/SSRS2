--------------------------------------
-- FAB04 - OF Quantités à Livrer à 0
--------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select ofab.t_pdno as OrdreFabrication, 
ofab.t_cprj as ProjetOF, 
ofab.t_cmdt as DateAchevement, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
ofab.t_cwar as Magasin, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOrdre, 
ofab.t_qntl as QuantiteInitiale, 
ofab.t_qtdl as QuantiteALivrer, 
ofab.t_qdlv as QuantiteLivree, 
ofab.t_qrjc as QuantiteRejetee, 
ofab.t_pldt as DateLivraisonPlanif, 
--modif par rbesnier le 20/12/2018 suite à la demande de Gaëtan, ticket 41045
op.t_opno as DerniereOperationOF, 
op.t_qplo as QuantitePlanifieeEnSortieOP, 
op.t_qcmp as QuantiteAcheveeOP, 
op.t_qrjc as QuantiteRejeteeOP, 
(op.t_qplo - op.t_qcmp - (select sum(op2.t_qrjc) from ttisfc010500 op2 where op2.t_pdno = ofab.t_pdno and op2.t_opst != 7)) as QuantiteReliquat, 
'' as StatutOP, 
(select top 1 op3.t_cmdt from ttisfc010500 op3 where op3.t_pdno = ofab.t_pdno order by op3.t_cmdt desc) as DerniereDateAchevementOP 
from ttisfc001500 ofab --Ordre de Fabrication
inner join ttisfc010500 op on op.t_pdno = ofab.t_pdno --Opérations des Ordres de Fabrication
where (ofab.t_osta = 6 or ofab.t_osta = 7) --Bornage sur le Statut à Actif et à Déclarer achevé
and op.t_nopr = 0 --Bornage sur l'Opération Suivante qui est à 0 (pas d'opé suivante)
and op.t_qcmp <> 0 --Bornage sur la Quantité Achevée différente de 0
and ofab.t_pdno between @ofab_f and @ofab_t --Bornage sur l'OF
and left(ofab.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
