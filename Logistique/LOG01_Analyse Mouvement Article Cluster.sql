----------------------------------------------
-- LOG01 - Analyse Mouvement Article Cluster
----------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(artplan.t_plni, 3) as Cluster, 
left(artplan.t_item, 9) as Projet, 
substring(artplan.t_item, 10, len(artplan.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
artplan.t_cwar as MagasinCluster, 
stkartmag.t_cwar as MagasinTransit, 
artplan.t_plid as Planificateur, 
emp.t_nama as NomPlanificateur, 
stkartmag.t_qhnd as StockPhysiqueMag, 
stkartmag.t_qcis as SortieCumuleeMag, 
stkartmag.t_ltdt as DateDerniereTransactionStockMag, 
stkart.t_stoc as StockPhysique, 
stkart.t_ltdt as DateDerniereTransactionStock, 
stkart.t_uscu as SortieCumulee, 
art.t_csig as CodeSignal, 
art.t_dcre as DateCreationArticle 
from tcprpd100500 artplan 
inner join twhwmd215500 stkartmag on artplan.t_item = stkartmag.t_item --Stock Articles par Magasin
inner join ttcibd100500 stkart on stkart.t_item = artplan.t_item --Stock Articles
inner join ttcibd001500 art on art.t_item = artplan.t_item --Articles
left outer join ttccom001500 emp on emp.t_emno = artplan.t_plid
where artplan.t_cwar between @mag_f and @mag_t --Bornage sur le Magasin
and artplan.t_plid between @planif_f and @planif_t --Bornage sur le planificateur
and left(artplan.t_plni, 3) between @clus_f and @clus_t --Bornage sur le cluster
and stkartmag.t_cwar != 'ZZZZZZ' --On enlève les magasins où il n'y a pas eu de mouvements
and left(artplan.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le magasin