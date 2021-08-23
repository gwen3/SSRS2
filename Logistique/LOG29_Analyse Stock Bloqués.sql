----------------------------------
-- LOG29 - Analyse Stock Bloqués
----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select stk.t_cwar as Magasin
,mag.t_dsca as NomMagasin
,left(stk.t_item, 9) as Projet
,substring(stk.t_item, 10, len(stk.t_item)) as Article
,art.t_dsca as DescriptionArticle
,stk.t_loca as Emplacement
,emp.t_dsca as NomEmplacement
,stk.t_qhnd as StockPhysiqueParEmplacement
,stk.t_qblk as StockBloqueParEmplacement
,bloc.t_bloc as MotifBlocage
,motif.t_dsca as DescriptionBlocage
,bloc.t_seqn as SequenceBlocage
,bloc.t_qbls as QuantiteBloqueeUniteStockage
,bloc.t_blun as UniteStockage
,bloc.t_logn as CodeAcces
,uti.t_name as NomUtilisateur
,bloc.t_date as DateBlocage
,convert(varchar, bloc.t_date, 108) as HeureDateBlocage
,stocartmag.t_qhnd as StockPhysiqueParMagasin
,stocartmag.t_qblk as StockBloqueParMagasin
,stocartmag.t_qall as StockReserveParMagasin
,stocartmag.t_qord as StockCommandeParMagasin
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = stk.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(stk.t_cwar, 2)) and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PMP
from twhinr140500 stk --Gestion des Stocks
inner join ttcmcs003500 mag on mag.t_cwar = stk.t_cwar --Magasins
inner join twhwmd300500 emp on emp.t_cwar = stk.t_cwar and emp.t_loca = stk.t_loca --Emplacements
inner join ttcibd001500 art on art.t_item = stk.t_item --Articles
left outer join twhwmd630500 bloc on bloc.t_cwar = stk.t_cwar and bloc.t_loca = stk.t_loca and bloc.t_item = stk.t_item and bloc.t_clot = stk.t_clot and bloc.t_idat = stk.t_idat --Blocages par Point de Stockage
left outer join ttcmcs005500 motif on motif.t_cdis = bloc.t_bloc --Motifs
inner join twhwmd215500 stocartmag on stocartmag.t_cwar = stk.t_cwar and stocartmag.t_item = stk.t_item --Stock des Articles par Magasin
left outer join tttaad200000 uti on uti.t_user = bloc.t_logn --Utilisateur
where stk.t_qblk != 0 --On ne ramène que les stocks bloqués différents de 0
and left(stk.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le magasin
and stk.t_cwar between @mag_f and @mag_t --Bornage sur le magasin