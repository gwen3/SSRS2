-------------------------------
-- COM04 - Carnet de Commande
-------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select ligcde.t_odat as DateCommande, 
ligcde.t_orno as NumeroCommande, 
ligcde.t_ddta as DateLivraisonPlanifiee, 
ligcde.t_pono as NumeroLigne, 
ligcde.t_sqnb as Sequence,
ligcde.t_qoor as Quantite, 
ligcde.t_oamt as Montant, 
dbo.convertenum('tc','B61C','a9','bull','yesno',ligcde.t_clyn,'4') as Annule, 
ligcdeart.t_citg as GroupeArticle, 
left(ligcde.t_item, 9) as Projet, 
substring(ligcde.t_item, 10, len(ligcde.t_item)) as Article, 
art.t_dsca as DesignationArticle 
from ttdsls401500 ligcde --Lignes de Commandes Clients
inner join ttdsls411500 ligcdeart on ligcdeart.t_orno = ligcde.t_orno and ligcdeart.t_pono = ligcde.t_pono and ligcdeart.t_sqnb = ligcde.t_sqnb --Données Articles de la Ligne de Commande Client
inner join ttcibd001500 art on art.t_item = ligcde.t_item --Articles
where ligcde.t_sqnb = 0 --Bornage sur le Numéro de Séquence qui doit être à 0
and ligcde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and ligcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre
and left(ligcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre