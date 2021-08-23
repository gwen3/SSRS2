---------------------------------------------------
-- FAB14 - Coûts de Fabrication Détaillés par EPR
---------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select trstk.t_orno as Ordre
,trstk.t_opno as OperationOrdre
,trstk.t_pono as Position
,dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOrdreFabrication
,dbo.convertenum('tc','B61C','a9','bull','fitr',trstk.t_fitr,'4') as EcritureFinanciere
,trstk.t_trdt as DateTransaction
,left(trstk.t_item, 9) as ProjetArticle
,substring(trstk.t_item, 10, len(trstk.t_item)) as Article
,art.t_dsca as DescriptionArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,art.t_citg as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,trstk.t_cpcp_f as ElementPrixRevient
,epr.t_dsca as DescriptionElementPrixRevient
,trstk.t_cprj as ProjetPCS
,prjpcs.t_dsca as DescriptionProjetPCS
,trstk.t_amnt_f_1 as MontantDe
,trstk.t_ccur_f as Devise
,trstk.t_nuni as NombreUnite
,trstk.t_cuni as Unite
,trstk.t_entc_f as EntiteDe
,ofab.t_adld as DateLivraisonOrdreFabrication
,left(ofab.t_mitm, 9) as ProjetArticleOrdreFabrication
,substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as ArticleOrdreFabrication
,artofab.t_dsca as DescriptionArticleOrdreFabrication
,dbo.convertenum('tc','B61C','a9','bull','kitm',artofab.t_kitm,'4') as TypeArticleOrdreFabrication
,artofab.t_citg as GroupeArticleOrdreFabrication
,grpartofab.t_dsca as DescriptionGroupeArticleOrdreFabrication
,ofab.t_qrdr as QuantiteOrdre
,ofab.t_qrdr as QuantiteOrdreParEpr
,ofab.t_qrdr as QuantiteOrdreParEprEtParArticle
,'=SI(A2<>A1;AC2;SI(H2<>H1;AC2;0))' as QuantiteOrdreParOrdreEtParArticle
,ofab.t_qdlv as QuantiteLivreeOrdre
,ofab.t_qdlv as QuantiteLivreeOrdreParEpr
,ofab.t_qdlv as QuantiteLivreeOrdreParEprEtParArticle
,'=SI(A2<>A1;AH2;SI(H2<>H1;AH2;0))' as QuantiteLivreeOrdreParOrdreEtParArticle
,artofab.t_cuni as UniteStockArticleOF
from tticst300500 trstk --Gestion des en-cours et transactions de stocks
inner join ttcibd001500 art on art.t_item = trstk.t_item --Articles
left outer join ttcmcs048500 epr on epr.t_cpcp = trstk.t_cpcp_f --Elements de Prix de Revients
inner join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Article
inner join ttisfc001500 ofab on ofab.t_pdno = trstk.t_orno --Ordre de Fabrication
inner join ttcibd001500 artofab on artofab.t_item = ofab.t_mitm --Articles - OF
left outer join ttcmcs023500 grpartofab on grpartofab.t_citg = artofab.t_citg --Groupe Article
left outer join ttcmcs052500 prjpcs on prjpcs.t_cprj = trstk.t_cprj --Projets PCS
where left(trstk.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par l'OF
and ofab.t_adld between @adld_f and @adld_t --Bornage sur la Date de Livraison de l'OF
and trstk.t_cprj between @prj_f and @prj_t --Bornage sur le Projet PCS
and substring(ofab.t_mitm, 10, len(ofab.t_mitm)) between @art_f and @art_t --Bornage sur l'Article
and trstk.t_orno between @of_f and @of_t --Bornage sur l'OF
and artofab.t_citg between @grpart_f and @grpart_t --Bornage sur le Groupe Article
and trstk.t_cpcp_f between @epr_f and @epr_t --Bornage sur l'EPR
and trstk.t_fitr in (@ecri)
--and (trstk.t_fitr = 52 or trstk.t_fitr = 61 or trstk.t_fitr = 74) --Ecriture Financière = Sortie ou Couts Opératoires ou Réception
order by trstk.t_orno, trstk.t_cpcp_f, trstk.t_item, trstk.t_fitr
