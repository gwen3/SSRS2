--------------------------------------
-- ACH07 - Controle Extinction Tiers
--------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select artachtier.t_otbp as TiersVendeur, 
tiersv.t_nama as NomTiersVendeur, 
artachtier.t_sfbp as TiersExpediteur, 
tierse.t_nama as NomTiersExpediteur, 
artachtier.t_efdt as DateApplication, 
artachtier.t_exdt as DateExpiration, 
left(artachtier.t_item, 9) as Projet, 
substring(artachtier.t_item, 10, len(artachtier.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
art.t_csig as SignalArticle, 
(select top 1 lcde.t_odat from ttdpur401500 lcde where lcde.t_item = artachtier.t_item and lcde.t_otbp = artachtier.t_otbp order by t_odat desc) as DateDerniereCommande 
from ttdipu010500 artachtier 
inner join ttccom100500 tiersv on tiersv.t_bpid = artachtier.t_otbp --Tiers Vendeur
inner join ttccom100500 tierse on tierse.t_bpid = artachtier.t_sfbp --Tiers Expéditeur
inner join ttcibd001500 art on art.t_item = artachtier.t_item --Articles
where artachtier.t_otbp between @tiers_f and @tiers_t --Bornage sur le Tiers Vendeur
--where artachtier.t_otbp between '100000419' and '100000419' --Bornage sur le Tiers