------------------------------------------------
-- INV03 - Inventaire - Recherche d'un Article
------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select ligordreinv.t_orno as OrdreInventaire, 
ligordreinv.t_cntn as NumeroInventaire, 
ligordreinv.t_cwar as Magasin, 
ligordreinv.t_loca as Emplacement, 
left(ligordreinv.t_item, 9) as Projet, 
substring(ligordreinv.t_item, 10, len(ligordreinv.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
ligordreinv.t_stun as Unite, 
ligordreinv.t_qstp as Quantite, 
ligordreinv.t_qcnt as StockInv 
from twhinh500500 ordreinv --Ordre d'Inventaire
inner join twhinh501500 ligordreinv on ordreinv.t_orno = ligordreinv.t_orno and ordreinv.t_cntn = ligordreinv.t_cntn --Lignes d'Ordre d'Inventaire
inner join ttcibd001500 art on ligordreinv.t_item = art.t_item --Articles
where left(ligordreinv.t_item, 9) between @proj_f and @proj_t --Bornage sur le Projet
and substring(ligordreinv.t_item, 10, len(ligordreinv.t_item)) between @art_f and @art_t --Bornage sur l'Article
and left(ligordreinv.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le Magasin
and ordreinv.t_odat between @date_f and @date_t --Bornage sur la Date de Commande