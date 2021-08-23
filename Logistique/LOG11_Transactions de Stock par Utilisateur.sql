----------------------------------------------------
-- LOG11 - transactions de Stock par Utilisateur
----------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(trstk.t_item, 9) as Projet
,substring(trstk.t_item, 10, len(trstk.t_item)) as Article
,art.t_dsca as DescriptionArticle
,trstk.t_trdt as DateStockage
,trstk.t_cwar as Magasin
,trstk.t_loca as Emplacement
,dbo.convertenum('tc','B61C','a9','bull','koor',trstk.t_koor,'4') as TypeOrdre
,dbo.convertenum('tc','B61C','a9','bull','kost',trstk.t_kost,'4') as Journal
,trstk.t_orno as Ordre
,trstk.t_pono as Ligne
,trstk.t_inmv as MouvementInterne
,trstk.t_logn as Utilisateur
,trstk.t_qstk as Quantite
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = trstk.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn and pmpdet.t_cpcp = 'MATIER') as PMP from twhina136500 pmp where pmp.t_item = trstk.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(trstk.t_cwar, 2)) and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PMPMatiere
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = trstk.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = trstk.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(trstk.t_cwar, 2)) and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PMP
from twhinr100500 trstk --Transactions de Stock par Point de Stockage
inner join ttcibd001500 art on art.t_item = trstk.t_item --Articles, Rajout par rbesnier le 15/02/2017 suite à demande de Stéphane Johan
where trstk.t_cwar between @cwar_f and @cwar_t --Bornage sur le Magasin
and trstk.t_logn between @logn_f and @logn_t --Bornage sur l'Utilisateur
and trstk.t_koor in (@koor) --Bornage sur le Type d'Ordre
and trstk.t_kost in (@kost) --Bornage sur le Type de Transaction
and trstk.t_trdt between @trdt_f AND @trdt_t --Bornage sur la Date de trstknsaction = Date de Stockage
and trstk.t_loca between @loca_f and @loca_t --Bornage sur l'Emplacement
and left(trstk.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise définie par le Magasin
order by trstk.t_trdt desc