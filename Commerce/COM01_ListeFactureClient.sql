---------------------------------
-- COM01 - Liste Facture Client
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lig.t_orno as CommandeClient, 
lig.t_ofbp as Tiers, 
cli.t_nama as NomTiers, 
fac.t_invn as NumeroFacture, 
fac.t_invd as DateFacture, 
left(lig.t_item, 9) as ProjetArticle, 
substring(lig.t_item, 10, len(lig.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
lig.t_serl as Chassis, 
--Modification par dmorin pour cohérence des prix
--lig.t_pric as Prix, 
--lig.t_qidl as Quantite, 
fac.t_pric as Prix, 
fac.t_qidl as Quantite, 
fac.t_damt as Montant 
from ttdsls406500 fac --Lignes de Livraison de Commandes Clients Réelles
inner join ttdsls401500 lig	on lig.t_orno = fac.t_orno and lig.t_pono = fac.t_pono and lig.t_sqnb = fac.t_sqnb and lig.t_ofbp = @tier --Lignes de Commandes Clients
inner join ttcibd001500 art on art.t_item = lig.t_item --Articles
inner join ttccom100500 cli on cli.t_bpid = lig.t_ofbp --Tiers
where fac.t_stat >= 20 --Bornage sur les Statuts Après Facturé
and fac.t_invd >= @date_f and fac.t_invd <= @date_t --Bornage sur la Date de Facture
and left(lig.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par la Commande Client