-----------------------------------------------------------
-- VER15 - Vérification Mise à Jour du Prix Moyen d'Achat
-----------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(prach.t_item, 9) as ProjetArticle, 
substring(prach.t_item, 10, len(prach.t_item)) as Article, 
art.t_dsca as Designation, 
dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle, 
prach.t_avpr as PrixAchatMoyen, 
achart.t_ccur as Devise, 
prach.t_ltpr as DernierPrixAchat, 
achart.t_ccur as Devise2, 
prach.t_ltpp as DateDerniereTransactionAchat, 
prach.t_purc as ReceptionAchatsCumules, 
(((prach.t_avpr - prach.t_ltpr) / prach.t_avpr) * 100) as EcartPMADPA, 
(select sum(pmp.t_mauc_1) from twhina137500 pmp where pmp.t_item = prach.t_item and pmp.t_trdt = (select max(pmp2.t_trdt) from twhina137500 pmp2 where pmp2.t_item = pmp.t_item and pmp2.t_trdt <= prach.t_ltpp)) as PUMPAvantDateDerniereTransactionAchat, --Calcul du PMP par rapport à la date du jour
(select sum(pmp.t_mauc_1) from twhina137500 pmp where pmp.t_item = prach.t_item and pmp.t_trdt = (select max(pmp2.t_trdt) from twhina137500 pmp2 where pmp2.t_item = pmp.t_item and pmp2.t_trdt >= prach.t_ltpp)) as PUMPApresDateDerniereTransactionAchat --Calcul du PMP par rapport à la date en sélection
from ttdipu100500 prach --Prix d'achats réels de l'article
inner join ttcibd001500 art on art.t_item = prach.t_item --Articles
inner join ttdipu001500 achart on achart.t_item = prach.t_item --Données d'achats articles
where prach.t_avpr != 0 --On ne prend pas les prix d'achats à 0
and prach.t_ltpp between @datetrans_f and @datetrans_t --Bornage sur la dernière date de transaction
--and ((((prach.t_avpr - prach.t_ltpr) / prach.t_avpr) * 100) <= @ecart_f or (((prach.t_avpr - prach.t_ltpr) / prach.t_avpr) * 100) >= @ecart_t)
and art.t_kitm in (@kitm) --Bornage sur le type article