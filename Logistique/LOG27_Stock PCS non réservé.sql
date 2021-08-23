----------------------------------
-- LOG27 - Stock PCS non réservé
----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(artplan.t_plni, 2) as UE
,left(artplan.t_item, 9) as Projet
,substring(artplan.t_item, 10, len(artplan.t_item)) as Article
,art.t_dsca as DescriptionArticle
,stk.t_cwar as Magasin
,stk.t_qhnd as StockPhysiqueUE
,stk.t_qord as StockEnCommandeUE
,stk.t_qall as StockReserveUE
,(stk.t_qhnd + stk.t_qord - stk.t_qall) as StockEcoUE
,stk.t_ltdt as DateDerniereTransaction
,(select top 1 encours.t_trdt from ttipcs300500 encours where encours.t_tror = 2 and encours.t_fitr = 125 and encours.t_koor = 3 and encours.t_cprj_f = left(artplan.t_item, 9) and encours.t_cprj_t = left(artplan.t_item, 9) order by encours.t_trdt desc) as DateFacturationPCS
,month((select top 1 encours.t_trdt from ttipcs300500 encours where encours.t_tror = 2 and encours.t_fitr = 125 and encours.t_koor = 3 and encours.t_cprj_f = left(artplan.t_item, 9) and encours.t_cprj_t = left(artplan.t_item, 9) order by encours.t_trdt desc)) as MoisFacturationPCS
,(select count(*) from twhinp100500 tspacli where tspacli.t_koor = 3 and tspacli.t_cprj = left(artplan.t_item, 9) and tspacli.t_kotr = 2) as NombreCommandesClientsNonLivrees
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = artplan.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(stk.t_cwar, 2)) and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PMP
from tcprpd100500 artplan --Articles Planification
inner join ttcibd001500 art on art.t_item = artplan.t_item --Articles 
left outer join twhwmd215500 stk on stk.t_item = artplan.t_item and left(stk.t_cwar, 2) = left(artplan.t_plni, 2) --Stock des articles par magasin
where left(artplan.t_item, 9) != ' ' --On ne prend que les articles PCS, avec un code projet devant
and (stk.t_qhnd + stk.t_qord - stk.t_qall) != 0 --Stock Economique différent de 0
and left(artplan.t_plni, 2) between @ue_f and @ue_t --On borne sur l'UE définie par le CLUSTER
and left(artplan.t_plni, 2) between @clus_f and @clus_t --On permet de choisir le cluster voulu
and (select count(*) from twhinp100500 tspacli where tspacli.t_koor = 3 and tspacli.t_cprj = left(artplan.t_item, 9) and tspacli.t_kotr = 2) = 0 --On ne prend que les lignes à 0
order by left(artplan.t_item, 9) --Tri sur le Projet