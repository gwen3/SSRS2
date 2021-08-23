----------------------------
-- LOG16 - Distribution EP
----------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select dbo.convertenum('wh','B61C','a9','bull','inh.oorg',tra.t_oorg,'4') as TypeOrdre, 
tra.t_orno as Ordre, 
tra.t_pono as Ligne, 
tra.t_seqn as Sequence, 
tra.t_cwar as Magasin, 
tra.t_pddt as DateLivraisonPlanifiee, 
left(tra.t_item, 9) as Projet, 
substring(tra.t_item, 10, len(tra.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
tra.t_qoro as Quantite, 
tra.t_sfbp as Origine
from twhinh220500 tra --Lignes d'ordres de sorties de stock
left outer join ttcibd001500 art on art.t_item = tra.t_item --Articles
left outer join twhinh200500 ordmag on ordmag.t_oorg = tra.t_oorg and ordmag.t_orno = tra.t_orno --Lignes d'expédition
where left(tra.t_orno, 2) between @ue_f and @ue_t --On récupère l'UE sur l'ordre
and tra.t_pddt between @date_f and @date_t --Bornage sur la Date de Livraison Planifiée
and tra.t_lsta < 30 --Statut non Expédié
and tra.t_oorg in ('71','72','90') --Origine Transfert, Transfert (manuel) ou Distribution EP
--Ramener le stock par Magasin, et également celui par UE (somme de gauche du magasin)