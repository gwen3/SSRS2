-----------------------------------------------------
-- LOG33 - Articles Stocks Magasin
-----------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select art.t_cwar as Magasin
,left(art.t_item, 9) as ProjetArticle
,substring(art.t_item, 10, len(art.t_item)) as Article
,artgen.t_dsca as DescriptionArticle
,artgen.t_citg as GroupeArticle
,artgen.t_csig as CodeSignal
,artgen.t_cuni as UniteStock
,artgen.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',artgen.t_kitm,'4') as TypeArticle
,art.t_supw as MagasinApprovisionnement
,art.t_oqmf as IncrementQuantiteOrdre
,art.t_mioq as QuantiteMinimum
,art.t_maoq as QuantiteMaximum
,art.t_fioq as QuantiteCommandeFixe
,art.t_ecoq as QuantiteCommandeEconomique
,art.t_maxs as StockMaximum
,art.t_reop as SeuilReapprovisionnement
,art.t_sfst as StockSecurite
,art.t_oint as IntervalleOrdre
,art.t_oivu as UniteIntervalleOrdre
,artplan.t_cwar as MagasinArticlePlan
,artplan.t_plid as Plannificateur
,nomemp.t_nama as NomPlannificateur
,artplan.t_plni as ArticlePlan
,magstok.t_ltdt as DateDerniereTransaction
,magstok.t_qcis as SortieCumulee
,magstok.t_qhnd as StockPhysique
,magstok.t_qall as StockReserve
,(magstok.t_qhnd - magstok.t_qall) as StockDisponible
,magstok.t_qord as StockEnCommande
,(magstok.t_qhnd + magstok.t_qord - magstok.t_qall) as StockEconomique
,art.t_sftm as DelaiDeSecurite
,dbo.convertenum('tc','B61C','a9','bull','tope',t_sftu,'4') as UniteDelaiSecurite
--,(select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and ((sortie.t_year = year(getdate()) and sortie.t_peri <= month(getdate())) or (sortie.t_year = year(getdate()) - 1 and sortie.t_peri > month(getdate())))) as SortieReelle12DerniersMois
from twhwmd210500 art --Magasins - Données Articles
inner join tcprpd100500 artplan on left(art.t_cwar, 2) = left(artplan.t_cwar, 2) and substring(artplan.t_plni, 4, len(artplan.t_plni)) = art.t_item --Articles Planification
inner join twhwmd215500 magstok on magstok.t_cwar = art.t_cwar and magstok.t_item = art.t_item --Stock des Articles par magasin
left outer join ttccom001500 nomemp on artplan.t_plid = nomemp.t_emno --Employés
inner join ttcibd001500 artgen on art.t_item = artgen.t_item --Articles
where 
(magstok.t_qhnd != 0 or magstok.t_qall != 0 or magstok.t_qord != 0 or (magstok.t_qhnd - magstok.t_qall) != 0) -- Stock physique ou reservé ou EnCde  ou Disponible <> 0
and substring(art.t_item, 10, len(art.t_item)) between @art_f and @art_t --Bornage sur le numéro d'article sans code projet
and art.t_cwar between @mag_f and @mag_t --Bornage sur le Magasin
and left(art.t_cwar, 2) between @ue_f and @ue_t --Bornage d'UE sur le Magasin
and magstok.t_ltdt between @date_f and @date_t --Bornage sur la date de dernière transaction de stock
and artgen.t_citg in (@citg_f) -- Groupes articles
and artplan.t_plid in (@plid_f) -- Planificateur