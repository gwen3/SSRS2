--------------------------------------
-- MET08 - Ctrl Nomenclature Multi Niveau 
--------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

with nomenclature (Niveau, Position, ArticlePere, DescriptionArticlePere, ArticleFils, DescriptionArticleFils, Fantome, 
			SignalArticle, GroupeArticle, DateApplication, DateExpiration, TypeArticleFils, SousTraite, Quantite, UniteStock, Magasin, Heritage, chemin, tri, tripere) as (
-- article tete
select 0 as Niveau
,right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)
,nome.t_mitm
,pere.t_dsca
,nome.t_sitm
,fils.t_dsca
,dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_cpha,'4')
,fils.t_csig
,fils.t_citg
,nome.t_indt
,nome.t_exdt
,dbo.convertenum('tc','B61C','a9','bull','kitm',fils.t_kitm,'4')
,dbo.convertenum('tc','B61C','a9','bull','yesno',fils.t_subc,'4')
,nome.t_qana
,fils.t_cuni
,nome.t_cwar
,dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_iwip,'4')
,cast(cast(nome.t_mitm as nvarchar(30)) + '/' + cast(nome.t_sitm as nvarchar(30)) as nvarchar(1000))
,cast(concat(nome.t_mitm, '_', 0, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))
,cast(concat(nome.t_mitm, '_', 0, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))
from ttibom010500 nome --Nomenclatures
inner join ttcibd001500 fils on nome.t_sitm = fils.t_item
inner join ttcibd001500 pere on nome.t_mitm = pere.t_item
where nome.t_indt <= getdate() --Date d'application de la nomenclature inférieure ou égale à la date du jour
and nome.t_exdt > getdate() --Date d'expiration de la nomenclature n'est pas encore arrivée à la date du jour
and left(nome.t_mitm, 9) = @prj --Bornage sur le Projet de l'Article Fabriqué
and substring(nome.t_mitm, 10, len(nome.t_mitm)) = @mitm --Bornage sur l'Article Fabriqué
union all 
-- récursivité
select Niveau + 1
,right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)
,nome.t_mitm
,pere.t_dsca
,nome.t_sitm
,fils.t_dsca
,dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_cpha,'4')
,fils.t_csig
,fils.t_citg
,nome.t_indt
,nome.t_exdt
,dbo.convertenum('tc','B61C','a9','bull','kitm',fils.t_kitm,'4')
,dbo.convertenum('tc','B61C','a9','bull','yesno',fils.t_subc,'4')
,nome.t_qana
,fils.t_cuni
,nome.t_cwar
,dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_iwip,'4')
,cast((chemin + '/' + cast(nome.t_sitm as nvarchar(30))) as nvarchar(1000))
,cast(concat(tri, '/', Niveau + 1, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))
,cast(concat(tri, '/', Niveau + 1, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))  
from ttibom010500 nome --Nomenclatures
inner join nomenclature on nome.t_mitm = nomenclature.ArticleFils --On fait appel à la table nomenclature définie en tout début
inner join ttcibd001500 pere on nome.t_mitm = pere.t_item --On va chercher l'article père
inner join ttcibd001500 fils on nome.t_sitm = fils.t_item --On va chercher l'article fils
where nome.t_indt <= getdate() --Date d'application de la nomenclature inférieure ou égale à la date du jour
and nome.t_exdt > getdate()--Date d'expiration de la nomenclature n'est pas encore arrivée à la date du jour
)
select nomenclature.Niveau
,nomenclature.Position
,left(nomenclature.tripere, charindex('_', nomenclature.tripere) - 1) as ArticlePerePere
,nomenclature.ArticlePere
,nomenclature.DescriptionArticlePere
,nomenclature.ArticleFils
,nomenclature.DescriptionArticleFils
,nomenclature.Fantome
,nomenclature.Heritage
,nomenclature.SignalArticle
,nomenclature.GroupeArticle
,nomenclature.DateApplication
,nomenclature.DateExpiration
,nomenclature.TypeArticleFils
,nomenclature.SousTraite
,nomenclature.Quantite
,nomenclature.UniteStock
,nomenclature.Magasin
,nomenclature.chemin
,nomenclature.tri
,nomenclature.tripere
from nomenclature 