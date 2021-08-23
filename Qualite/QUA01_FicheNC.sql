------------------------------------
-- QUA01 - Fiche de Non Conformité
------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select qua.t_ncmr as RapportNC, 
qua.t_dsca as DescriptionRapportNC, 
qua.t_pilo as PiloteAnalyseImputation, 
emp.t_nama as NomEmploye, 
qua.t_lflu as LieuFluxDetectant, 
qua.t_grid as SiteGruauTraitant, 
ue.t_dsca as NomSite, 
qua.t_prji as ChampProjetArticleImpute, 
left(qua.t_itmi, 9) as ProjetArticleImpute, 
substring(qua.t_itmi, 10, len(qua.t_itmi)) as ArticleImpute, 
art.t_dsca as DescriptionArticleImpute, 
qua.t_qani as QuantiteImputee, 
qua.t_resp as ResponsableActiviteImputee, 
exa.t_dsca as DescriptionResponsable, 
qua.t_rsbp as Fournisseur, 
fourn.t_nama as NomFournisseur, 
dbo.textnumtotext(qua.t_trac,4) as TracabiliteProduit2, 
dbo.textnumtotext(qua.t_nctx,4) as DescriptionDeNonConformite, 
dbo.textnumtotext(qua.t_dsnc,4) as DescriptionNC, 
qua.t_epjc as Lien, 
achart.t_buyr as Acheteur, 
emp2.t_nama as NomAcheteur, 
qua.t_ccur as DeviseRefacturation, 
qua.t_rpdt as DateCreation, 
qua.t_rptr as Createur, 
utilisateur.t_name as NomCreateur, 
qua.t_acta as ActiviteAlertante, 
qua.t_vehi as VehiculeDeBase, 
vehi.t_dsca as DescriptionVehicule, 
qua.t_serl as NumeroSerie, 
left(qua.t_item, 9) as ProjetArticle, 
substring(qua.t_item, 10, len(qua.t_itmi)) as Article, 
art2.t_dsca as DescriptionArticle, 
qua.t_nqua as Quantite, 
qua.t_nuom as UniteQuantite, 
ute.t_dsca as DescriptionUnite, 
dbo.textnumtotext(qua.t_txtt,4) as TracabiliteProduit, 
qua.t_ownr as ProprietairePilote, 
emp3.t_nama as NomProprietairePilote, 
qua.t_disp as CodeCorrection, 
dbo.convertenum('qm','B61C','a9','bull','ncm.disp',qua.t_disp,'4') as Correction, 
cexam.t_dsca as NomActiviteAlertante, 
qua.t_srni as NumeroSerieArticleImpute, 
qua.t_nctp as TypeFamilleProduit, 
typ.t_dsca as DescriptionTypeFamilleProduit, 
artfourn.t_aitc as ReferenceFournisseur, 
--Rajout pour la NC de Laval par rbesnier le 04/10/2017
qua.t_tdft as TypeDefaut, 
qua.t_flux as Impute, 
lieuflu.t_dsca as DescriptionLieuFluxDetectant, 
lieuimp.t_dsca as DescriptionImpute 
from tqmncm100500 qua --Rapport de non-conformité (NCMR)
left outer join ttccom001500 emp on emp.t_emno = qua.t_pilo --Employés
left outer join ttcibd001500 art on art.t_item = qua.t_itmi --Articles
left outer join ttcibd001500 art2 on art2.t_item = qua.t_item --Articles
left outer join tqmncm003500 exa on exa.t_mrbc = qua.t_resp --Comite d'examen des produits
left outer join ttccom100500 fourn on fourn.t_bpid = qua.t_rsbp --Table des tiers
left outer join ttdipu001500 achart on achart.t_item = qua.t_itmi --Articles Achats
left outer join ttccom001500 emp2 on emp2.t_emno = achart.t_buyr --Employés Acheteur
left outer join ttcemm030500 ue on ue.t_eunt = qua.t_grid --Unités d'Entreprise
left outer join ttgbrg835500 utilisateur on utilisateur.t_user = qua.t_rptr --Gestion des Employés
left outer join tzgncm003500 vehi on vehi.t_vehi = qua.t_vehi --Véhicule
left outer join ttcmcs001500 ute on ute.t_cuni = qua.t_nuom --Unité
left outer join ttccom001500 emp3 on emp3.t_emno = qua.t_ownr --Employés Pilote
left outer join tqmncm003500 cexam on cexam.t_mrbc = qua.t_acta --Comité d'Examen des Produits
left outer join tqmncm001500 typ on typ.t_nctp = qua.t_nctp --Type de Produits Non Conformes
left outer join ttcibd004500 artfourn on artfourn.t_citt = 2 and artfourn.t_item = qua.t_item and artfourn.t_bpid = qua.t_rsbp --Code Article par Système de Codage ; citt = 2 signifie fournisseur
left outer join tzgncm001500 lieuflu on lieuflu.t_cflu = qua.t_lflu --Lieux du Flux Détectant
left outer join tzgncm001500 lieuimp on lieuimp.t_cflu = qua.t_flux --Lieux du Flux Détectant
where qua.t_ncmr = @ficheNC --Bornage sur la fiche de non conformité
and left(qua.t_ncmr, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par la fiche de non conformité