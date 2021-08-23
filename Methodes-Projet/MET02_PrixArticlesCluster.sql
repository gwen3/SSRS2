----------------------------------
-- MET02 - Prix Articles Cluster
----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select artplan.t_clus as Cluster
,left(artplan.t_item, 9) as ProjetArticlePlan
,substring(artplan.t_item, 10, len(artplan.t_item)) as ArticlePlan
,art.t_dsca as DescriptionArticlePlan
,dbo.convertenum('tc','B61C','a9','bull','yesno',prodart.t_cpha,'4') as Fantome
,pr.t_ltcp as DateCalculPrixRevient
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,art.t_citg as GroupeArticle
,artacht.t_otbp as TiersVendeur
,tiers.t_nama as NomTiersVendeur
,art.t_wght as Poids
,art.t_cwun as UnitePoids
,art.t_csig as CodeSignal
,dbo.convertenum('tc','B61C','a9','bull','yesno',art.t_subc,'4') as SousTraite
,pr.t_ecpr_1 as PrixRevientEstime
,pr.t_emtc_1 as CoutMatiereEstime
,pr.t_eopc_1 as CoutOperatoireEstime
,(case gam.t_stor
when 1 --Gamme Standard
	then (select sum(opgam.t_sutm) from ttirou102500 opgam where opgam.t_mitm = ' ' and opgam.t_opro = gam.t_strc and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic)
when 2 --Gamme non Standard
	then (select sum(opgam.t_sutm) from ttirou102500 opgam where opgam.t_mitm = artplan.t_item and opgam.t_opro = '     0' and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic)
end) as ComposantTempsPrepa --Sommes des temps de Préparation dans les Opérations de Gammes en MINUTES
,(case gam.t_stor
when 1 --Gamme Standard
	then (select sum(opgam.t_rutm) from ttirou102500 opgam where opgam.t_mitm = ' ' and opgam.t_opro = gam.t_strc and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic)
when 2 --Gamme non Standard
	then (select sum(opgam.t_rutm) from ttirou102500 opgam where opgam.t_mitm = artplan.t_item and opgam.t_opro = '     0' and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic)
end) as ComposantTempsExecution --Sommes des temps d'Exécution dans les Opérations de Gammes en MINUTES
,art.t_cuni as UniteStock
,priach.t_sipp as PrixSimule
,priach.t_cupp as Unite
,priach.t_ccur as Devise
,(case
when art.t_cuni = priach.t_cupp or priach.t_cupp is null
	then 1
else
	isnull(faconv.t_conv, (select faconvgen.t_conv from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_basu = art.t_cuni and faconvgen.t_unit = priach.t_cupp))
end) as FacteurConversion
,prreel.t_ltpr as DernierPrixAchat
,achart.t_ccur as DeviseAchat
,achart.t_cupp as UniteAchat
,(case
when art.t_cuni = achart.t_cupp or achart.t_cupp is null
	then 1
else
	isnull(faconv2.t_conv, (select faconvgen.t_conv from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_basu = art.t_cuni and faconvgen.t_unit = achart.t_cupp))
end) as FacteurConversion2
,prreel.t_ltpp as DateDerniereTransactionPrixAchat
,prreel.t_avpr as PrixAchatMoyen
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = artplan.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(artplan.t_cwar, 2)) and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PUMPActuel
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = artplan.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(artplan.t_cwar, 2)) and pmp.t_trdt <= @dateapplic order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PUMPADate
from tcprpd100500 artplan --Articles Planification
inner join ttcibd001500 art on art.t_item = artplan.t_item --Articles 
inner join ttiipd001500 prodart on prodart.t_item = artplan.t_item --Données de Production des Articles
left outer join ttdipu010500 artacht on artacht.t_item = artplan.t_item and (artacht.t_pref = 2 or (artacht.t_pref = 1 and artacht.t_otbp = (select top 1 a.t_otbp from ttdipu010500 a where a.t_item = artplan.t_item order by a.t_prio asc))) --Articles Achats Tiers
left outer join ttccom100500 tiers on tiers.t_bpid = artacht.t_otbp --Tiers
left outer join tticpr170500 priach on priach.t_item = artplan.t_item and priach.t_cpcc = '001' --Prix d'Achats Simulés
left outer join tticpr007500 pr on pr.t_item = artplan.t_item --Données Etablissements des Prix de Revients
left outer join ttdipu100500 prreel on prreel.t_item = artplan.t_item --Prix d'Achats Réels de l'Article
left outer join ttdipu001500 achart on achart.t_item = artplan.t_item --Données d'Achat Article
left outer join ttcibd003500 faconv on faconv.t_item = artplan.t_item and faconv.t_basu = art.t_cuni and faconv.t_unit = priach.t_cupp --Facteur de Conversion 
left outer join ttcibd003500 faconv2 on faconv2.t_item = artplan.t_item and faconv2.t_basu = art.t_cuni and faconv2.t_unit = achart.t_cupp --Facteur de Conversion 
left outer join ttcibd200500 artcom on artcom.t_item = artplan.t_item --Articles Commandes
left outer join ttirou101500 gam on gam.t_mitm = artplan.t_item and gam.t_opro = '     0' --Gammes par Article Fils
where left(artplan.t_clus, 2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise définie par le Cluster
and artplan.t_clus between @clus_f and @clus_t --Bornage sur le CLUSTER
and left(artplan.t_item, 9) = ' ' --On ne prend que les articles standards, on ne prend pas les spécifiques