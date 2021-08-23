---------------------
-- ACH04 - Liste DA
---------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select da.t_rdat as DateDemandeAchat, 
lda.t_rqno as DemandeAchat, 
lda.t_pono as LigneDemandeAchat, 
dbo.convertenum('td','B61C','a9','bull','pur.rqst',da.t_rqst,'4') as StatutDemandeAchat, 
da.t_remn as Demandeur, 
empd.t_nama as NomDemandeur, 
da.t_rdep as DepartementDemandeur, 
dept.t_dsca as NomDepartementDemandeur, 
da.t_aemn as Approbateur, 
empa.t_nama as NomApprobateur, 
lda.t_dldt as DateDemandeeLDA, 
left(lda.t_item, 9) as ProjetLDA, 
substring(lda.t_item, 10, len(lda.t_item)) as ArticleLDA, 
lda.t_nids as DesignationArticleLDA, 
lda.t_qoor as QuantiteLDA, 
lda.t_pric as PrixLDA, 
lda.t_cuqp as UnitePrixLDA, 
lda.t_oamt as MontantLDA, 
lda.t_cwar as MagasinLDA, 
dlda.t_prno as OrdreAchat, 
dbo.convertenum('td','B61C','a9','bull','pur.hdst',cde.t_hdst,'4') as StatutOA, 
dlda.t_ppon as LigneOA, 
lcde.t_odat as DateCommandeOA, 
lcde.t_otbp as TiersVendeurOA, 
tiers.t_nama as NomTiersVendeurOA, 
left(lcde.t_item, 9) as ProjetOA, 
substring(lcde.t_item, 10, len(lcde.t_item)) as ArticleOA, 
art.t_dsca as DescriptionArticleOA, 
lcde.t_ddta as DateSouhaiteeOA, 
lcde.t_ddtc as DateReceptionPlanifieeOA, 
lcde.t_ddtd as DateReceptionConfirmeeOA, 
lcde.t_cwar as MagasinOA, 
lcde.t_qoor as QuantiteOA, 
lcde.t_cuqp as UnitePrixAchatOA, 
lcde.t_cvqp as FacteurPrixAchatOA, 
lcde.t_pric as PrixOA, 
lcde.t_oamt as MontantOA, 
lcde.t_ddte as DateReelleReceptionOA, 
lcde.t_dino as BonLivraisonOA, 
lcde.t_qidl as QuantiteRecueOA, 
dbo.convertenum('tc','B61C','a9','bull','yesno',rec.t_conf,'4') as ConfirmationOA, 
dlda.t_pdno as OrdreFabrication, 
dlda.t_opno as OperationOrdreFabrication, 
left(dlda.t_mnit, 9) as ProjetArticleFabrique, 
substring(dlda.t_mnit, 10, len(dlda.t_mnit)) as ArticleFabrique, 
lda.t_glco as CodeCG, 
cg.t_dim2 as CentreCout, 
dim.t_desc as DescriptionCentreCout 
from ttdpur201500 lda --Lignes de Demandes d'Achats
left outer join ttdpur200500 da on da.t_rqno = lda.t_rqno --Demandes d'Achats
left outer join ttdpur202500 dlda on dlda.t_rqno = lda.t_rqno and dlda.t_pono = lda.t_pono --Données de Lignes de Demandes d'Achats
left outer join ttccom001500 empd on empd.t_emno = da.t_remn --Employés - Demandeur
left outer join ttcmcs065500 dept on dept.t_cwoc = da.t_rdep --Départements
left outer join ttccom001500 empa on empa.t_emno = da.t_aemn --Employés - Approbateur
left outer join ttdpur400500 cde on cde.t_orno = dlda.t_prno and cde.t_hdst between @hdst_f and @hdst_t --Commandes Fournisseurs --Bornage sur le Statut de la Commande Fournisseur
left outer join ttdpur401500 lcde on lcde.t_orno = dlda.t_prno and lcde.t_pono = dlda.t_ppon and lcde.t_sqnb = dlda.t_sqnb --Lignes de Commandes Fournisseurs
left outer join ttdpur406500 rec on rec.t_orno = dlda.t_prno and rec.t_pono = dlda.t_ppon and rec.t_sqnb = dlda.t_sqnb --Réceptions Réelles des Commandes Fournisseurs
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttccom100500 tiers on tiers.t_bpid = lcde.t_otbp --Tiers
left outer join ttfgld475500 cg on cg.t_glcd = lda.t_glco and cg.t_fcmp = (select ue.t_fcmp from ttcemm030500 ue where ue.t_eunt = left(lda.t_rqno, 2)) --Code Compte Général, on retrouve la société financière grâce à l'UE
left outer join ttfgld010500 dim on dim.t_dimx = cg.t_dim2 and dim.t_dtyp = 2 --Dimensions - Code dimension 2 = Centre de Coût
where da.t_remn in (@remn) --Bornage sur le Demandeur
and da.t_aemn in (@aemn) --Bornage sur l'Approbateur
and da.t_rqst between @rqst_f and @rqst_t --Bornage sur le Statut de la DA
and left(lda.t_rqno, 2) between @ue_f and @ue_t --Bornage sur l'UE à partir du numéro de DA
order by lda.t_rqno