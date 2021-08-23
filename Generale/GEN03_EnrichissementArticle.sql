-----------------------------------
-- GEN03 - Enrichissement Article
-----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select clus.t_clus as ClusterArticle, 
left(art.t_item, 9) as Projet, 
substring(art.t_item, 10, len(art.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
art.t_kitm as CodeTypeArticle, 
dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle, 
art.t_citg as GroupeArticle, 
art.t_csig as CodeSignal, 
dbo.textnumtotext(art.t_txta,'4') as Texte, 
etude.t_revi as Revision, 
etude.t_plan as PlanEtude, 
etude.t_indt as DateApplication, 
art.t_dcre as DateCreationArticle, 
art.t_lmdt as DateModificationArticle, 
art.t_cood as CoordinateurTechnique, 
empcoor.t_nama as NomCoordinateurTechnique, 
artach.t_otbp as TiersVendeurArticleAchat, 
tierartach.t_nama as NomTiersVendeurArticleAchat, 
artachtier.t_pref as Preference, 
artachtier.t_otbp as TiersVendeurArticleAchatTiers, 
tierartachtier.t_nama as NomTiersVendeurArticleAchatTiers, 
ordreplan.t_prdt as DateBesoin, 
ordreplan.t_dwar as MagasinCluster, 
(select sum(ordrep.t_quan) from tcprrp100500 ordrep where substring(ordrep.t_item, 4, len(ordrep.t_item)) = art.t_item) as QteCumuleeProposee, 
ordreplan.t_cplb as Planificateur, 
empplan.t_nama as NomPlanificateur, 
ordreplan.t_suno as Tiers, 
tierven.t_nama as NomTiers, 
'' as ConsultationEnvoyee, 
'' as FamilleFournisseur, 
'' as PrixValide 
from ttcibd001500 art --Articles
left outer join ttiedm100500 etude on etude.t_eitm = art.t_item and etude.t_exdt < '01/01/1980' --Reference d'Etude - Revision ; On prend la révision qui n'a pas de date d'expiration
left outer join ttdipu001500 artach on artach.t_item = art.t_item --Donnees d'Achat Article
left outer join ttccom100500 tierartach on tierartach.t_bpid = artach.t_otbp --Tiers Vendeur de l'Article Achat
left outer join ttdipu010500 artachtier on artachtier.t_item = art.t_item and artachtier.t_exdt > '01/01/2035' and artachtier.t_efdt = 
(select top 1 aat.t_efdt from ttdipu010500 aat where aat.t_item = art.t_item and aat.t_exdt > '01/01/2035' order by aat.t_efdt desc) --Donnees d'Achat Article ; On ne Prend que ceux encore actif
left outer join ttccom100500 tierartachtier on tierartachtier.t_bpid = artachtier.t_otbp --Tiers Vendeur de l'Article Achat Tiers
left outer join tcprrp100500 ordreplan on substring(ordreplan.t_item, 4, len(ordreplan.t_item)) = art.t_item and ordreplan.t_prdt = 
(select top 1 op.t_prdt from tcprrp100500 op where substring(op.t_item, 4, len(op.t_item)) = art.t_item order by op.t_prdt desc) --Ordres Planifies
left outer join ttccom100500 tierven on tierven.t_bpid = ordreplan.t_suno --Tiers Vendeur Retrouve sur l'Ordre Planifie
left outer join tcprpd100500 clus on clus.t_item = art.t_item --Article Planification
left outer join ttccom001500 empplan on empplan.t_emno = ordreplan.t_cplb --Employé Planificateur
left outer join ttccom001500 empcoor on empcoor.t_emno = art.t_cood --Employé Coordinateur Technique
where left(art.t_cood, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par 
--and art.t_csig between @sig_f and @sig_t --Bornage sur le Code Signal
and art.t_dcre between @dcrea_f and @dcrea_t --Bornage sur la Date de Creation
and art.t_lmdt between @dmodi_f and @dmodi_t --Bornage sur la Date de Modification
--rajout par rbesnier le 15/04/2019
--On ne veut pas la règle des articles en X
and ((art.t_csig between @sig_f and @sig_t) --Bornage sur le Code Signal
or (@sigx = 1 and art.t_csig like '%X%' and (select sum(ordrep.t_quan) from tcprrp100500 ordrep where substring(ordrep.t_item, 4, len(ordrep.t_item)) = art.t_item) != 0))