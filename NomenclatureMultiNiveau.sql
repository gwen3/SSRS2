--------------------------------------
-- Nomenclatures Multiniveau
--------------------------------------

--1ère requête de sélection sur l'article père
select left(nome.t_sitm, 9) as ProjetArticleFabrique, 
substring(nome.t_sitm, 10, len(nome.t_sitm)) as ArticleFabrique, 
artfab.t_dsca as DescriptionArticleFabrique, 
dbo.convertenum('tc','B61C','a9','bull','kitm',artfab.t_kitm,'4') as TypeArticleFabrique, 
(select top 1 rev.t_revi from ttiedm100500 rev where rev.t_eitm = nome.t_mitm and rev.t_indt <= @dateapplic and (rev.t_exdt > @dateapplic or rev.t_exdt < '01/01/1980') order by rev.t_revi desc) as Revision, 
artfab.t_cuni as UniteStock, 
prodart.t_oltm as DelaiFabrication, 
dbo.convertenum('tc','B61C','a9','bull','tope',prodart.t_oltu,'4') as UniteDelaiFabrication, 
prodart.t_unom as QuantiteNomenclature, 
'' as UniteNomenclature, 
dbo.textnumtotext(artfab.t_txta,'4') as TexteArticle 
from ttibom010500 nome 
left outer join ttcibd001500 artfab on artfab.t_item = nome.t_mitm
left outer join ttiipd001500 prodart on prodart.t_item = nome.t_mitm 
where left(nome.t_mitm, 9) = @prj --Bornage sur le Projet de l'Article voulu
and substring(nome.t_mitm, 10, len(nome.t_mitm)) = @art --Bornage sur l'Article voulu



--Requête pour récupérer les options de la variante :
select substring(svar.t_item, 10, len(svar.t_item)) as OptionVarianteProduit, 
art.t_dsca as DescriptionOptionVarianteProduit, 
var.t_cpva as VarianteProduit, 
optvar.t_opts as GroupeOption, 
optvar.t_cpft as CaracteristiqueProduit, 
optvar.t_dsca as DescriptionCaracteristiqueProduit, 
optvar.t_copt as Options, 
opt.t_dsca as DescriptionOptions, 
dbo.textnumtotext(optvar.t_txta,'4') as TexteOptionVariante 
from ttipcf500500 var --Variantes de Produits
left outer join ttipcf510500 svar on svar.t_cpva = var.t_cpva --Structure Variante de Produit
left outer join ttipcf520500 optvar on optvar.t_cpva = var.t_cpva and optvar.t_opts = svar.t_opts --Options par Variantes de Produits
left outer join ttipcf110500 opt on opt.t_item = svar.t_item and opt.t_cpft = optvar.t_cpft and opt.t_copt = optvar.t_copt --Options par Caractéristique de Produit et Article
inner join ttcibd001500 art on art.t_item = svar.t_item --Articles
where var.t_refo = @prjartpere --On prend la Commande Client comme Référence




--Requête pour les gammes
select 

from ttirou101500 gam --Gamme par Article
where gam.t_mitm = @art 


--Récursivité pour avoir tous les niveaux de la nomenclature
with nomenclature (Niveau, ArticlePere, ArticleFils, Position, Operation, Magasin, DateApplication, DateExpiration, Fantome, PostConsoMatiere, /*Revision, PieceJointe,*/ Quantite) as (
-- article tete
select 0 as Niveau, 
nome.t_mitm, 
nome.t_sitm, 
nome.t_pono, 
nome.t_opno,
nome.t_cwar, 
nome.t_indt, 
nome.t_exdt, 
dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_cpha,'4'), 
dbo.convertenum('tc','B61C','a9','bull','yesno',prodartfils.t_bfcp,'4'), 
--(select rev.t_revi from ttiedm100500 rev where rev.t_eitm = nome.t_sitm and rev.t_indt <= @dateapplicnom and (rev.t_exdt > @dateapplicnom or rev.t_exdt < '01/01/1980')), 
--'ef' as PieceJointe, 
nome.t_qana 
from ttibom010500 nome --Nomenclatures
inner join ttcibd001500 fils on nome.t_sitm = fils.t_item
inner join ttiipd001500 prodartfils on prodartfils.t_item = nome.t_sitm 
where nome.t_indt <= @dateapplicnom --Date d'application de la nomenclature inférieure ou égale à la date du jour
and nome.t_exdt > @dateapplicnom --Date d'expiration de la nomenclature n'est pas encore arrivée à la date du jour
and left(nome.t_mitm, 9) = @prjartpere --Bornage sur le Projet de l'Article Fabriqué
and substring(nome.t_mitm, 10, len(nome.t_mitm)) = @artpere --Bornage sur le Projet de l'Article Fabriqué
--and ((left(nome.t_mitm, 2) between @ue_f and @ue_t) or left(nome.t_mitm, 2) = '') --Bornage sur l'UE à partir du projet de l'Article, on prend également lorsqu'il n'y en a pas
union all 
-- récursivité
select Niveau + 1, 
nome.t_mitm, 
nome.t_sitm, 
fils.t_dsca, 
nome.t_pono, 
nome.t_opno,
nome.t_cwar, 
nome.t_indt, 
nome.t_exdt, 
dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_cpha,'4'), 
fils.t_csig, 
dbo.convertenum('tc','B61C','a9','bull','yesno',prodartfils.t_bfcp,'4'), 
--(select rev.t_revi from ttiedm100500 rev where rev.t_eitm = nome.t_sitm and rev.t_indt <= @dateapplicnom and (rev.t_exdt > @dateapplicnom or rev.t_exdt < '01/01/1980')), 
--'ezf' as PieceJointe, 
fils.t_wght, 
fils.t_cwun, 
nome.t_qana, 
fils.t_cuni 
from ttibom010500 nome --Nomenclatures
inner join nomenclature on nome.t_mitm = nomenclature.ArticleFils --On fait appel à la table nomenclature définie en tout début
inner join ttcibd001500 fils on nome.t_sitm = fils.t_item --On va chercher l'article fils
inner join ttiipd001500 prodartfils on prodartfils.t_item = nome.t_sitm 
where nome.t_indt <= @dateapplicnom --Date d'application de la nomenclature inférieure ou égale à la date du jour
and nome.t_exdt > @dateapplicnom --Date d'expiration de la nomenclature n'est pas encore arrivée à la date du jour
)
--Requête utilisant la récursivité
select nomenclature.Niveau, 
nomenclature.ArticlePere, 
left(nomenclature.ArticleFils, 9) as ProjetArticleFils, 
substring(nomenclature.ArticleFils, 10, len(nomenclature.ArticleFils)) as ArticleFils, 
nomenclature.DescriptionArticleFils, 
nomenclature.Position, 
nomenclature.Operation, 
nomenclature.Magasin, 
nomenclature.DateApplication, 
nomenclature.DateExpiration, 
nomenclature.Fantome, 
nomenclature.SignalArticle, 
nomenclature.PostConsoMatiere, 
--nomenclature.Revision, 
--nomenclature.PieceJointe, 
nomenclature.Poids, 
nomenclature.UnitePoids, 
nomenclature.Quantite, 
nomenclature.UniteQuantite 
from nomenclature 
inner join ttcibd001500 art on art.t_item = nomenclature.ArticleFils --Articles
--where left(nomenclature.ArticlePere, 9) = 'LV6000121'  
--and substring(nomenclature.ArticlePere, 10, len(nomenclature.ArticlePere)) = 'CABINES-LV'
