-------------------------------------------------------
-- LOG04 - Consommation Pièces Mensuelles Par Magasin
-------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select sortie.t_cwar as Magasin,
left(sortie.t_item, 9) as Projet, 
substring(sortie.t_item, 10, len(sortie.t_item)) as Article, 
sortie.t_year as Annee, 
sortie.t_peri as Periode, 
sortie.t_acip as SortieReellesParPeriode, 
sortie.t_decl as AppelDemande, 
sortie.t_deqt as QteDemande, 
sortie.t_qdeq as QteDemandeQual, 
sortie.t_lsts as VentePerdue, 
sortie.t_dmfp as PrevisionDemande, 
sortie.t_rets as QteRetournee, 
artplan.t_plni as ArticlePlan, 
artplan.t_clus as Cluste,
artplan.t_cwar as MagDefaut, 
artplan.t_plid as Planificateur, 
art.t_citg as GroupeArticle, 
grpart.t_dsca as DescriptionGroupeArticle,
art.t_dsca as DescriptionArticle,
art.t_cuni as UnitStock,
artmag.t_risk as ClasseRisque
from twhinr130500 sortie --Sortie par Période et par Magasin
inner join tcprpd100500 artplan on substring(artplan.t_plni, 4, len(artplan.t_plni)) = sortie.t_item --Articles Plan
inner join ttcibd001500 art on art.t_item = sortie.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Article
left outer join twhwmd400500 artmag on artmag.t_item = art.t_item --Article Magasin
where left(artplan.t_clus, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le Cluster
and sortie.t_cwar between @mag_f and @mag_t --Bornage sur le Magasin
and substring(sortie.t_item, 10, len(sortie.t_item)) between @art_f and @art_t --Bornage sur l'Article sans le code projet
and art.t_citg between @grpart_f and @grpart_t --Bornage sur le Groupe Article
and sortie.t_year between @an_f and @an_t --Bornage sur l'Année
and sortie.t_peri between @peri_f and @peri_t --Bornage sur la Période
and artplan.t_plid between @planif_f and @planif_t --Bornage sur le Planificateur
and left(artplan.t_plni, 3) between @clus_f and @clus_t --Bornage sur le Cluster
and artmag.t_risk between @risk_f and @risk_t --Bornage sur la classe de risque