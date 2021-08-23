-----------------------------------------------------
-- LOG37 - Ctrl Stocks Morts/Dormants
-----------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select art.t_cwar as Magasin
,left(art.t_item, 9) as Projet_Article
,substring(art.t_item, 10, len(art.t_item)) as Article
,artgen.t_dsca as DescriptionArticle
,artgen.t_dcre as DateCreationArt
,artgen.t_citg as GroupeArticle
,artgen.t_csig as CodeSignal
,artgen.t_cuni as UniteStock
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
--,artplan.t_cwar as MagasinArticlePlan
,artplan.t_plid as Planificateur
,nomemp.t_nama as NomPlanificateur
--,artplan.t_plni as ArticlePlan
,magstock.t_qcis as SortieCumulee
,magstock.t_qhnd as StockPhysique
,(select sum(tqtstk.t_qhnd) from twhwmd215500 tqtstk where tqtstk.t_item = art.t_item) as StockPhysiqueTotal 
,magstock.t_qall as StockReserve
,(select sum(tqtstk.t_qall) from twhwmd215500 tqtstk where tqtstk.t_item = art.t_item) as StockReserveTotal 
,magstock.t_qord as EnCommande
,(select sum(tqtstk.t_qord) from twhwmd215500 tqtstk where tqtstk.t_item = art.t_item) as EnCdeTotal 
,(select sum(ordpla.t_quan) from tcprrp100500 ordpla where ordpla.t_plnc = '001' and ordpla.t_item = concat(mag.t_dicl,art.t_item)) as PlanifMag 
,(select sum(ordpla.t_quan) from tcprrp100500 ordpla where ordpla.t_plnc = '001' and substring(ordpla.t_item, 4, len(ordpla.t_item)) = art.t_item) as PlanifTotal  
,art.t_sftm as DelaiDeSecurite
,dbo.convertenum('tc','B61C','a9','bull','tope',art.t_sftu,'4') as UniteDelaiSecurite
--
--Date dernière transaction
----- Magasin
,magstock.t_ltdt as DateDerniereTransactionMag
----- Tous magasins
,(select top 1 tousmagstk.t_ltdt from twhwmd215500 tousmagstk where tousmagstk.t_item = art.t_item order by tousmagstk.t_ltdt desc) as DateDerTransTousMag
,(select top 1 tousmagstk.t_cwar from twhwmd215500 tousmagstk where tousmagstk.t_item = art.t_item order by tousmagstk.t_ltdt desc) as MagDateDerTransTousMag
--
-- Dernière entrée en stock 
-- Magasin
,(select top 1 mvtstock.t_trdt from twhinr110500 mvtstock where mvtstock.t_item = art.t_item and mvtstock.t_cwar = art.t_cwar and mvtstock.t_kost = '3' order by mvtstock.t_trdt desc) as DateDerniereEntreeMag
-- Tous Magasins
,(select top 1 mvtstock.t_trdt from twhinr110500 mvtstock where mvtstock.t_item = art.t_item  and mvtstock.t_kost = '3' order by mvtstock.t_trdt desc) as DateDerniereEntreeTousMag
,(select top 1 mvtstock.t_cwar from twhinr110500 mvtstock where mvtstock.t_item = art.t_item  and mvtstock.t_kost = '3' order by mvtstock.t_trdt desc) as MagDateDerniereEntree
--
--
-- Conso totale des 24 derniers mois
,(case 
when month(getdate()) < 12
	then (select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and ((sortie.t_year = year(getdate()))
														or (sortie.t_year = year(getdate()) - 1)
														or (sortie.t_year = year(getdate()) - 2 and sortie.t_peri >= month(getdate()) + 1)))
	else (select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and sortie.t_year >= year(getdate()) - 1)
end) as Conso_24_Total
--
-- Conso totale des 12 derniers mois
,(select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and 
							((sortie.t_year = year(getdate()) and sortie.t_peri <= month(getdate())) or (sortie.t_year = year(getdate()) - 1 and sortie.t_peri > month(getdate())))) as Conso_12_Total
--
-- Conso totale des 6 derniers mois
,(case 
when month(getdate()) > 6
	then (select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri > month(getdate())- 6)
when month(getdate()) = 6
	then (select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri >= 1)
when month(getdate()) < 6
	then (select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and ((sortie.t_year = year(getdate()) and sortie.t_peri <= month(getdate())) or (sortie.t_year = year(getdate()) - 1 and sortie.t_peri >= month(getdate()+ 7))))
end) as Conso_6_Total
--
-- Conso totale des 3 derniers mois
,(case 
when month(getdate()) > 3
	then (select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri > month(getdate())-3)
when month(getdate()) = 3
	then (select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri >= 1)
when month(getdate()) < 3
	then (select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and ((sortie.t_year = year(getdate()) and sortie.t_peri <= month(getdate())) or (sortie.t_year = year(getdate()) - 1 and sortie.t_peri >= month(getdate()+ 10))))
end) as Conso_3_Total
--
-- Conso totale du mois
,(select sortie.t_acip from twhinr120500 sortie where sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri = month(getdate())) as Conso_1_Total
-- 
--
-- Conso du magasin des 24 derniers mois
,(case 
when month(getdate()) < 12
	then (select sum(sortie.t_acip) from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item and ((sortie.t_year = year(getdate()))
														or (sortie.t_year = year(getdate()) - 1)
														or (sortie.t_year = year(getdate()) - 2 and sortie.t_peri >= month(getdate()) + 1)))
	else (select sum(sortie.t_acip) from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item and sortie.t_year >= year(getdate()) - 1)
end) as Conso_24_Mag
--
-- Conso du magasin des 12 derniers mois
,(select sum(sortie.t_acip) from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item 
							and ((sortie.t_year = year(getdate()) and sortie.t_peri <= month(getdate())) or (sortie.t_year = year(getdate()) - 1 and sortie.t_peri > month(getdate())))) as Conso_12_Mag
--
-- Conso du magasin des 6 derniers mois
,(case 
when month(getdate()) > 6
	then (select sum(sortie.t_acip) from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri > month(getdate())- 6)
when month(getdate()) = 6
	then (select sum(sortie.t_acip) from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri >= 1)
when month(getdate()) < 6
	then (select sum(sortie.t_acip) from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item and ((sortie.t_year = year(getdate()) and sortie.t_peri <= month(getdate())) or (sortie.t_year = year(getdate()) - 1 and sortie.t_peri >= month(getdate()+ 7))))
end) as Conso_6_Mag
--
-- Conso du magasin des 3 derniers mois
,(case 
when month(getdate()) > 3
	then (select sum(sortie.t_acip) from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri > month(getdate())-3)
when month(getdate()) = 3
	then (select sum(sortie.t_acip) from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri >= 1)
when month(getdate()) < 3
	then (select sum(sortie.t_acip) from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item and ((sortie.t_year = year(getdate()) and sortie.t_peri <= month(getdate())) or (sortie.t_year = year(getdate()) - 1 and sortie.t_peri >= month(getdate()+ 10))))
end) as Conso_3_Mag
--
-- Conso du magasin du mois
,(select sortie.t_acip from twhinr130500 sortie where sortie.t_cwar = art.t_cwar and sortie.t_item = art.t_item and sortie.t_year = year(getdate()) and sortie.t_peri = month(getdate())) as Conso_1_Mag
--
,pr.t_ecpr_1 as PrixRevientEstime
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = art.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = art.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(art.t_cwar, 2)) and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PMP
--
-- Valorisation Stock
,(magstock.t_qhnd * 
	(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = art.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = art.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(art.t_cwar, 2)) and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc)) as ValoStkPMP
--
--
from twhwmd210500 art --Magasins - Données Articles
inner join ttcemm112500 mag on mag.t_waid = art.t_cwar --Magasins
left outer join tcprpd100500 artplan on artplan.t_plni = concat(mag.t_dicl,art.t_item) --Articles Planification
inner join twhwmd215500 magstock on magstock.t_cwar = art.t_cwar and magstock.t_item = art.t_item --Stock des Articles par magasin
left outer join ttccom001500 nomemp on artplan.t_plid = nomemp.t_emno --Employés
inner join ttcibd001500 artgen on art.t_item = artgen.t_item --Articles
left outer join tticpr007500 pr on pr.t_item = art.t_item --Données Etablissements des Prix de Revients
--
where
left(art.t_cwar, 2) between @ue_f and @ue_t --Bornage d'UE sur le Magasin
--art.t_cwar between @mag_f and @mag_t --Bornage sur le Magasin
and magstock.t_qhnd != 0--On ne prend pas les stocks à 0