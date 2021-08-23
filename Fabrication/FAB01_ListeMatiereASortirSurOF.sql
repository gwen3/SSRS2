-----------------------------------------------
-- FAB01 - Liste des Matières à Sortir sur OF
-----------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select cout.t_pdno as OrdreFab, 
ordrefab.t_cprj as Projet, 
ordrefab.t_cmdt as DateAchevementOF, 
left(cout.t_sitm, 9) as ProjetArticle, 
substring(cout.t_sitm, 10, len(cout.t_sitm)) as Article, 
art.t_dsca as DescriptionArticle, 
cout.t_cwar as Magasin, 
cout.t_pono as Position, 
cout.t_opno as Operation, 
ope.t_cmdt as DateAchevementOperation, 
ope.t_cwoc as CentreCharge, 
ordrefab.t_osta as CodeStatutOrdre, 
dbo.convertenum('tc','B61C','a9','bull','osta',ordrefab.t_osta,'4')	as StatutOrdre, 
ope.t_opst as CodeStatutOperation, 
dbo.convertenum('ti','B61C','a9','bull','sfc.opst',ope.t_opst,'4') as StatutOperation, 
cout.t_qune as QuantiteNette, 
cout.t_iswh as ASortirParMag, 
cout.t_issu as ASortir, 
cout.t_subd as LivraisonSuivante, 
--Ce champ n'est pas utilisé, on fait un calcul sur SSRS à la place, suppression le 30/06/2017
--cout.t_aamt_1 as MontantReel1, 
'' as MontantReel1, 
(case 
when cout.t_cpes_1 != 0 
	then cout.t_cpes_1 
else 
	pr.t_ecpr_1 
end) as PrixRevientEstime, 
cout.t_ques as QuantiteEstimee, 
stk.t_qhnd as StockPhysique, 
--rajout par rbesnier le 01/02/2018 suite au ticket 41391
dbo.convertenum('tc','B61C','a9','bull','yesno',cout.t_bfls,'4') as PostConsommation 
from tticst001500 cout --Couts Matières Estimés et Réel
inner join ttisfc001500 ordrefab on ordrefab.t_pdno = cout.t_pdno --Ordres de Fabrication
left outer join ttisfc010500 ope on ope.t_pdno = cout.t_pdno and ope.t_opno = cout.t_opno --Opérations des Ordres de Fabrication
left outer join ttcibd001500 art on art.t_item = cout.t_sitm --Articles
left outer join twhwmd215500 stk on stk.t_cwar = cout.t_cwar and stk.t_item = cout.t_sitm --Stock Articles par Magasins
left outer join tticpr007500 pr on pr.t_item = cout.t_sitm --Données Etablissements des Prix de Revients
where (cout.t_subd <> 0 or cout.t_issu <> 0 or cout.t_iswh <> 0) --Bornage sur les Quantités différentes de 0
and ((ordrefab.t_osta = 6 and ope.t_opst = 7) or (ordrefab.t_osta = 8 and ope.t_opst = 7) or (ordrefab.t_osta = 8)) --Bornage sur les Statuts (combinaison de statut)
and cout.t_pdno between @ofab_f and @ofab_t --Bornage sur les Ordres de Fabrication
and left(cout.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE en fonction de l'Ordre de Fabrication