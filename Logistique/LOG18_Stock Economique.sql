-----------------------------
-- LOG18 - Stock Economique
-----------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select stk.t_cwar as Magasin, 
art.t_citg as GroupeArticle, 
left(stk.t_item, 9) as Projet, 
substring(stk.t_item, 10, len(stk.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
rpd.t_plid as Planificateur, 
emp.t_nama as NomPlanificateur, 
art.t_cuni as UniteStock, 
stk.t_qhnd as StockPhysique, 
stk.t_qord as StockEnCommande, 
stk.t_qall as StockReserve, 
(stk.t_qhnd + stk.t_qord - stk.t_qall) as StockEconomique, 
stk.t_qblk as StockBloque, 
mag.t_oqmf as IncrementQuantiteOrdre, 
mag.t_mioq as QuantiteMinimumOrdre, 
mag.t_ecoq as QuantiteCommandeEconomique, 
mag.t_oint as IntervalleOrdre, 
mag.t_sfst as StockSecurite, 
mag.t_reop as SeuilReapprovisionnement 
from twhwmd215500 stk --Stock des Articles par Magasin
inner join twhwmd210500 mag on mag.t_cwar = stk.t_cwar and mag.t_item = stk.t_item --Magasin - Données Articles
inner join ttcibd001500 art on art.t_item = stk.t_item --Articles 
inner join ttcemm112500 mag2 on mag2.t_waid = stk.t_cwar --Magasins
inner join tcprpd100500 rpd on rpd.t_clus = mag2.t_dicl and rpd.t_item = stk.t_item --Articles - Planification
left outer join ttccom001500 emp on emp.t_emno = rpd.t_plid --Employés
where left(stk.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le Magasin
and stk.t_cwar between @cwar_f and @cwar_t --Bornage sur le Magasin
and left(stk.t_item, 9) between @prj_f and @prj_t --Bornage sur le Projet de l'Article
and substring(stk.t_item, 10, len(stk.t_item)) between @art_f and @art_t --Bornage sur l'Article
and art.t_citg between @citg_f and @citg_t --Bornage sur le Groupe Article
and mag2.t_dicl between @cluster_f and @cluster_t --Bornage sur le cluster
and rpd.t_plid between @plid_f and @plid_t --Bornage sur le Planificateur
and (stk.t_qhnd <> 0 or stk.t_qord <> 0 or stk.t_qall <> 0 or stk.t_qblk <> 0) 
order by rpd.t_plid, stk.t_cwar, art.t_citg, stk.t_item