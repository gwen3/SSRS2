--------------------------
-- COM14 - Prix de Vente
--------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

with nomenclature (Niveau, Position, ArticlePere, DescriptionArticlePere, ArticleFils, DescriptionArticleFils, Fantome, SignalArticle, GroupeArticle, DateApplication, DateExpiration, TypeArticleFils, SousTraite, Quantite, UniteStock, Magasin, chemin, tri, tripere) as (
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
,cast(cast(nome.t_mitm as nvarchar(30)) + '/' + cast(nome.t_sitm as nvarchar(30)) as nvarchar(1000))
--Rajout de l'article père au début de la chaine le 24/05/2017
--cast(concat(0, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(30)) 
,cast(concat(nome.t_mitm, '_', 0, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))
,cast(concat(nome.t_mitm, '_', 0, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000)) 
from ttibom010500 nome --Nomenclatures
inner join ttcibd001500 fils on nome.t_sitm = fils.t_item
inner join ttcibd001500 pere on nome.t_mitm = pere.t_item
where nome.t_indt <= @dateapplic --Date d'application de la nomenclature inférieure ou égale à la date du jour
and nome.t_exdt > @dateapplic --Date d'expiration de la nomenclature n'est pas encore arrivée à la date du jour
and left(nome.t_mitm, 9) between @prj_f and @prj_t --Bornage sur le Projet de l'Article Fabriqué
and substring(nome.t_mitm, 10, len(nome.t_mitm)) between @art_f and @art_t --Bornage sur le Projet de l'Article Fabriqué
and ((left(nome.t_mitm, 2) between @ue_f and @ue_t) or left(nome.t_mitm, 2) = '') --Bornage sur l'UE à partir du projet de l'Article, on prend également lorsqu'il n'y en a pas
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
,cast((chemin + '/' + cast(nome.t_sitm as nvarchar(30))) as nvarchar(1000))
,cast(concat(tri, '/', Niveau + 1, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))
,cast(concat(tri, '/', Niveau + 1, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))  
from ttibom010500 nome --Nomenclatures
inner join nomenclature on nome.t_mitm = nomenclature.ArticleFils --On fait appel à la table nomenclature définie en tout début
inner join ttcibd001500 pere on nome.t_mitm = pere.t_item --On va chercher l'article père
inner join ttcibd001500 fils on nome.t_sitm = fils.t_item --On va chercher l'article fils
where nome.t_indt <= @dateapplic --Date d'application de la nomenclature inférieure ou égale à la date du jour
and nome.t_exdt > @dateapplic --Date d'expiration de la nomenclature n'est pas encore arrivée à la date du jour
and Niveau < 2
)
select nomenclature.Niveau
,nomenclature.Position
,nomenclature.ArticlePere
,nomenclature.DescriptionArticlePere
,nomenclature.ArticleFils
,nomenclature.DescriptionArticleFils
,nomenclature.Fantome
,nomenclature.SignalArticle
,nomenclature.GroupeArticle
,nomenclature.DateApplication
,nomenclature.DateExpiration
,pr.t_ltcp as DateCalculPrixRevient
,nomenclature.TypeArticleFils
,nomenclature.SousTraite
,pr.t_ecpr_1 as PrixRevientEstime
,pr.t_emtc_1 as CoutMatiereEstime
,(case gam.t_stor
when 1 --Gamme Standard
	then (select sum(opgam.t_sutm) from ttirou102500 opgam where opgam.t_mitm = ' ' and opgam.t_opro = gam.t_strc)
when 2 --Gamme non Standard
	then (select sum(opgam.t_sutm) from ttirou102500 opgam where opgam.t_mitm = nomenclature.ArticleFils and opgam.t_opro = '     0')
end) as ComposantTempsPrepa --Sommes des temps de Préparation dans les Opérations de Gammes en MINUTES
,(case gam.t_stor
when 1 --Gamme Standard
	then (select sum(opgam.t_rutm) from ttirou102500 opgam where opgam.t_mitm = ' ' and opgam.t_opro = gam.t_strc)
when 2 --Gamme non Standard
	then (select sum(opgam.t_rutm) from ttirou102500 opgam where opgam.t_mitm = nomenclature.ArticleFils and opgam.t_opro = '     0')
end) as ComposantTempsExecution --Sommes des temps d'Exécution dans les Opérations de Gammes en MINUTES
,nomenclature.Quantite
,nomenclature.UniteStock
,nomenclature.Magasin
,(case nomenclature.TypeArticleFils
when 'Acheté'
	then artacht.t_qiec
when 'Fabriqué'
	then artcom.t_ecoq
end) as SerieEconomique
,prreel.t_avpr as PrixAchatMoyen
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = nomenclature.ArticleFils and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(nomenclature.Magasin, 2)) and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PUMPActuel
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = nomenclature.ArticleFils and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(nomenclature.Magasin, 2)) and pmp.t_trdt <= @datepmp order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PUMPADate
,(case (select top 1 lb.t_brty from ttdpcg031500 lb where lb.t_item = nomenclature.ArticleFils and lb.t_prbk = 'MAS000005' and lb.t_efdt <= @dateapplic and (lb.t_exdt > @dateapplic or lb.t_exdt < '01/01/1980') and lb.t_miqt >= artacht.t_qiec order by lb.t_miqt desc) 
when 1
	then (select top 1 lb.t_bapr from ttdpcg031500 lb where lb.t_item = nomenclature.ArticleFils and lb.t_prbk = 'MAS000005' and lb.t_efdt <= @dateapplic and (lb.t_exdt > @dateapplic or lb.t_exdt < '01/01/1980') and lb.t_miqt >= artacht.t_qiec order by lb.t_miqt desc)
when 2
	then (select top 1 lb.t_bapr from ttdpcg031500 lb where lb.t_item = nomenclature.ArticleFils and lb.t_prbk = 'MAS000005' and lb.t_efdt <= @dateapplic and (lb.t_exdt > @dateapplic or lb.t_exdt < '01/01/1980') and lb.t_miqt >= artacht.t_qiec order by lb.t_miqt desc)
end) as BaremePrixContratAchatFiliale
,'' as PrixNonBareme 
from nomenclature 
left outer join ttdipu010500 artacht on artacht.t_item = nomenclature.ArticleFils and artacht.t_otbp = (select top 1 a.t_otbp from ttdipu010500 a where a.t_item = nomenclature.ArticleFils order by a.t_pref desc) --Articles Achats Tiers
left outer join tticpr007500 pr on pr.t_item = nomenclature.ArticleFils --Données Etablissements des Prix de Revients
left outer join ttdipu100500 prreel on prreel.t_item = nomenclature.ArticleFils --Prix d'Achats Réels de l'Article
left outer join ttcibd200500 artcom on artcom.t_item = nomenclature.ArticleFils --Articles Commandes
left outer join ttirou101500 gam on gam.t_mitm = nomenclature.ArticleFils and gam.t_opro = '     0' --Gammes par Article
where Niveau = 1
order by nomenclature.tri asc