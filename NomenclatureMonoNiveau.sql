--------------------------------------
-- Nomenclatures MonoNiveau
--------------------------------------

--1ère requête, sélection de l'article voulu
select left(nome.t_mitm, 9) as ProjetArticleFabrique, 
substring(nome.t_mitm, 10, len(nome.t_mitm)) as ArticleFabrique, 
artfab.t_dsca as DescriptionArticleFabrique, 
dbo.convertenum('tc','B61C','a9','bull','kitm',artfab.t_kitm,'4') as TypeArticleFabrique, 
(select top 1 rev.t_revi from ttiedm100500 rev where rev.t_eitm = nome.t_mitm and rev.t_indt <= @dateapplic and (rev.t_exdt > @dateapplic or rev.t_exdt < '01/01/1980') order by rev.t_revi desc) as Revision, 
artfab.t_cuni as UniteStock, 
prodart.t_oltm as DelaiFabrication, 
dbo.convertenum('tc','B61C','a9','bull','tope',prodart.t_oltu,'4') as UniteDelaiFabrication, 
prodart.t_unom as QuantiteNomenclature, 
'' as UniteNomenclature, 
dbo.textnumtotext(artfab.t_txta,'4') as TexteArticle 
from ttibom010500 nome --Nomenclatures
left outer join ttcibd001500 artfab on artfab.t_item = nome.t_mitm --Article
left outer join ttiipd001500 prodart on prodart.t_item = nome.t_mitm --Données de Production des Articles
where left(nome.t_mitm, 9) = @prjartpere --Bornage sur le Projet de l'Article voulu
and substring(nome.t_mitm, 10, len(nome.t_mitm)) = @artpere --Bornage sur l'Article voulu


--Sélection de la Variante
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
where var.t_refo = @prj --On prend la Commande Client comme Référence


--Requête pour les gammes
select left(gam.t_mitm, 9) as ProjetArticleGamme, 
substring(gam.t_mitm, 10, len(gam.t_mitm)) as ArticleGamme, 
art.t_dsca as DescriptionArticleGamme, 
gam.t_opro as Gamme, 
dbo.convertenum('tc','B61C','a9','bull','yesno',gam.t_stor,'4') as GammeStandard, 
gam.t_runi as UniteGamme, 
opgam.t_opno as OperationGamme, 
opgam.t_tano as Tache, 
tache.t_dsca as DescriptionTache, 
opgam.t_cwoc as CentreCharge, 
cc.t_dsca as DescriptionCentreCharge, 
opgam.t_mcno as Machine, 
mach.t_dsca as DescriptionMachine, 
opgam.t_qutm as TempsFileAttente, 
opgam.t_trdl as TempsAttente, 
opgam.t_mvtm as TempsDeplacement, 
dbo.textnumtotext(opgam.t_txta,'4') as TexteOperationGamme, 
dbo.convertenum('tc','B61C','a9','bull','tope',opgam.t_tuni,'4') as UniteTemps, 
opgam.t_sutm as TempsPreparation, 
opgam.t_rutm as TempsCycle 
from ttirou101500 gam --Gamme par Article
inner join ttcibd001500 art on art.t_item = gam.t_mitm --Article
left outer join ttirou102500 opgam on ((opgam.t_opro = gam.t_opro and gam.t_stor = 1) or (opgam.t_opro = gam.t_opro and opgam.t_mitm = gam.t_mitm)) --Opérations de Gammes - Standard ou non
left outer join ttirou003500 tache on tache.t_tano = opgam.t_tano --Tâches
left outer join ttcmcs065500 cc on cc.t_cwoc = opgam.t_cwoc --Départements - Centre de Charges
left outer join ttirou002500 mach on mach.t_mcno = opgam.t_mcno --Machines
where left(gam.t_mitm, 9) = @prj --Bornage sur le Projet de l'Article Fabriqué
and substring(gam.t_mitm, 10, len(gam.t_mitm)) = @art --Bornage sur le Projet de l'Article Fabriqué


--Nomenclature
select '' as Niveau, 
nome.t_mitm as ArticlePere, 
left(nome.t_sitm, 9) as ProjetArticleFils, 
substring(nome.t_sitm, 10, len(nome.t_sitm)) as ArticleFils, 
art.t_dsca as DescriptionArticleFils, 
nome.t_pono as Position, 
nome.t_opno as Operation,
nome.t_cwar as Magasin, 
nome.t_indt as DateApplication, 
nome.t_exdt as DateExpiration, 
dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_cpha,'4') as ArticleFantome, 
art.t_csig as SignalArticle, 
dbo.convertenum('tc','B61C','a9','bull','yesno',prodart.t_bfcp,'4') as PostConsoSiMatiere, 
(select rev.t_revi from ttiedm100500 rev where rev.t_eitm = nome.t_sitm and rev.t_indt <= @dateapplicnom and (rev.t_exdt > @dateapplicnom or rev.t_exdt < '01/01/1980')) as Revision, 
(select t_srid from tdmcom010500 where t_trid like concat('{"%', nome.t_sitm, '%"}')) as PieceJointe, 
art.t_wght as Poids, 
art.t_cwun as UnitePoids, 
nome.t_qana as QuantiteNette, 
art.t_cuni as UniteQuantite, 
dbo.textnumtotext(art.t_txta,'4') as TexteArticle 
from ttibom010500 nome 
inner join ttcibd001500 art on art.t_item = nome.t_sitm --Articles
left outer join ttiipd001500 prodart on prodart.t_item = nome.t_sitm --Données de Production des Articles
where left(nome.t_mitm, 9) = @prj --Bornage sur le Projet de l'Article Fabriqué
and substring(nome.t_mitm, 10, len(nome.t_mitm)) = @art --Bornage sur le Projet de l'Article Fabriqué
order by ArticlePere, Position