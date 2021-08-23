----------------------------
-- FAB06 - OTD Fabrication
----------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select cde.t_cofc as ServiceVente, 
cde.t_odat as DateOrdre, 
lcde.t_orno as Ordre, 
lcde.t_pono as Position, 
lcde.t_sqnb as Incrément, 
cde.t_sotp as TypeOrdre, 
left(lcde.t_item, 9) as Projet, 
substring(lcde.t_item, 10, len(lcde.t_item)) as Article, 
art.t_dsca as Designation, 
art.t_kitm as CodeTypeArticle, 
dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle, 
lcde.t_serl as VIN, 
ligart.t_citg as GroupeArticle, 
ligart.t_csgs as StatistiqueVente, 
ligart.t_cpcl as MarqueModele, 
cde.t_ofbp as Client, 
lcde.t_qoor as QuantiteCommande, 
expe.t_qidl as QuantiteLivree, 
lcde.t_ddta as DateProduction, 
lcde.t_dmad as DateMADCConfirmee, 
numser.t_rdat as DateMiseEnStockProduitSerialise,
expe.t_dldt as DateLivraisonReelle, 
dbo.convertlistcdf('td','B61C','a9','grup','cre',lcde.t_cdf_cret,'4') as CauseRetard, 
dbo.textnumtotext(lcde.t_txtb,'4') as Commentaire, 
lcde.t_dlsc as DateLivraisonSouhaiteeClient 
--Rajout par rbesnier le 30/08/2018 suite à la demande de Cédric Fazilleau pour faire une analyse de leur retard. A ne pas mettre en prod, seulement du one shot
--cde.t_dlsc as DateLivraisonSouhaiteeClientGenerale, 
--cde.t_cdf_prdt as DateDebutPenaliteRetard 
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join ttdsls406500 expe on expe.t_orno = lcde.t_orno and expe.t_pono = lcde.t_pono and expe.t_sqnb = lcde.t_sqnb --Lignes de Livraisons de Commandes Clients Réelles
inner join ttdsls411500 ligart on ligart.t_orno = lcde.t_orno and ligart.t_pono = lcde.t_pono and ligart.t_sqnb = 0 --Données Articles de la Ligne de Commande Client
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join twhltc500500 numser on numser.t_item = lcde.t_item and numser.t_serl = lcde.t_serl --Numéro de Série par Magasin
where lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and expe.t_dldt between @date_f and @date_t --Bornage sur la Date de Livraison Réelle
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par l'Ordre de Vente