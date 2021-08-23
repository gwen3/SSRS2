---------------------------
-- ACH05 - Barème de Prix
---------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lbar.t_prbk as BaremePrix, 
bar.t_dsca as DescriptionBareme, 
left(lbar.t_item, 9) as ProjetArticle, 
substring(lbar.t_item, 10, len(lbar.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
lbar.t_otbp as TiersVendeur, 
tiers.t_nama as NomTiersVendeur, 
lbar.t_sfbp as TiersExpediteur, 
lbar.t_bapr as Prix, 
lbar.t_curn as DeviseLigneBareme, 
lbar.t_qtun as UniteQuantite, 
lbar.t_prun as UnitePrix, 
lbar.t_brty as TypeTranche, 
lbar.t_miqt as ValeurTranche, 
lbar.t_efdt as DateApplication, 
bar.t_modu as Typ, 
lbar.t_exdt as DateExpiration, 
art.t_cuni as UniteStock, 
fact.t_basu as UniteReference, 
fact.t_unit as UniteFacteurConversion, 
fact.t_conv as FacteurConversion, 
prix.t_ltpp as DateDerniereTransactionPrixAchat, 
prix.t_avpr as PrixAchatMoyen, 
achart.t_ccur as Devise, 
prix.t_ltpr as DernierPrixAchat, 
prix.t_purc as ReceptionAchatsCumules, 
achart.t_cupp as Unite 
from ttdpcg031500 lbar --Lignes de Barèmes de Prix
inner join ttdpcg011500 bar on bar.t_prbk = lbar.t_prbk --Barèmes de Prix
inner join ttcibd001500 art on art.t_item = lbar.t_item --Articles
inner join ttccom100500 tiers on tiers.t_bpid = lbar.t_otbp --Tiers
left outer join ttcibd003500 fact on fact.t_item = lbar.t_item and fact.t_basu = art.t_cuni --Facteur de Conversion de l'Unité de Stock
left outer join ttdipu100500 prix on prix.t_item = lbar.t_item --Prix d'Achats Réels de l'Article
left outer join ttdipu001500 achart on achart.t_item = lbar.t_item --Données d'Achat Article
where lbar.t_prbk between @bar_f and @bar_t --Bornage sur le Barème
and left(lbar.t_item, 9) between @prj_f and @prj_t --Bornage sur le Projet
and substring(lbar.t_item, 10, len(lbar.t_item)) between @art_f and @art_t --Bornage sur l'Article
/*where lbar.t_prbk = 'LVM000001' --Bornage sur le Barème
and left(lbar.t_item, 9) between '' and '' --Bornage sur le Projet
and substring(lbar.t_item, 10, len(lbar.t_item)) between 'AD0000000000' and 'APZZZZZZZZZZ' --Bornage sur l'Article*/