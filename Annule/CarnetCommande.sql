---------------------------------
-- Carnet de Commandes - Annulé
---------------------------------

--Problème : si on ne prend que la séquence 1, aucun groupe article n'est renseigné dessus
select ligcom.t_odat as DateCommande, 
ligcom.t_orno as OrdreVente, 
ligcom.t_pono as Position, 
ligcom.t_sqnb as Sequence, 
ligcom.t_qoor as Quantite, 
ligcom.t_oamt as Montant, 
dbo.convertenum('tc','B61C','a9','bull','yesno',ligcom.t_clyn,4) as Annule, 
artligcom.t_citg as GroupeArticle, 
left(ligcom.t_item, 9) as Projet, 
substring(ligcom.t_item, 10, len(ligcom.t_item)) as Article, 
art.t_dsca as DescriptionArticle 
from ttdsls401500 ligcom --Ligne de Commande
inner join ttdsls411500 artligcom on artligcom.t_orno = ligcom.t_orno and artligcom.t_pono = ligcom.t_pono and artligcom.t_sqnb = ligcom.t_sqnb --Donnees Article de la Ligne de Commande
inner join ttcibd001500 art on art.t_item = ligcom.t_item --Article 
where ligcom.t_sqnb = 1 --Sequence 1
and ligcom.t_odat between @date_f and @date_t --Date de la Commande 
and ligcom.t_orno between @ov_f and @ov_t --Ordre Vente

