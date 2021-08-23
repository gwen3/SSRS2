------------------------------------
-- QUA05 - Synthèse Non Conformité
------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select qua.t_grid as SiteGruauTraitant, 
qua.t_ncmr as EtatNonConforme, 
dbo.convertenum('qm','B61C','a9','bull','ncm.stat',qua.t_stat,'4') as Statut, 
qua.t_rpdt as RapporteLe, 
qua.t_rptr as RapportePar, 
utilisateur.t_name as Nom, 
--Modification le 18/09/2017 par rbesnier, nous ne ramenons pas le bon champ
--qua.t_dsca as DescriptionRapportNC, 
dbo.textnumtotext(qua.t_nctx,'4') as DescriptionRapportNC, 
qua.t_nctp as TypeFamilleProduit, 
typ.t_dsca as DescriptionTypeFamilleProduit, 
qua.t_slvl as CodeSeverite, 
sev.t_dsca as Severite, 
qua.t_qani as QuantiteImputee, 
qua.t_nuom as UniteQuantite, 
left(qua.t_itmi, 9) as ProjetArticleImpute, 
substring(qua.t_itmi, 10, len(qua.t_itmi)) as ArticleImpute, 
art.t_dsca as DescriptionArticleImpute, 
qua.t_dtim as DateImputation, 
qua.t_resp as ResponsableActiviteImputee, 
exa.t_dsca as DescriptionResponsable, 
qua.t_cldt as DateCloture, 
qua.t_tdft as TypeDefaut, 
qua.t_vehi as VehiculeDeBase, 
vehi.t_dsca as DescriptionVehicule, 
qua.t_rsbp as TiersResponsableImpute, 
fourn.t_nama as NomTiersResponsableImpute, 
--rajout par rbesnier le 18/09/2017 de tous les champs qui suivent :
qua.t_lflu as CodeLieuFluxDetectant, 
lfdet.t_dsca as LieuFluxDetectant, 
qua.t_otbd as CodeNatureProduit, 
npro.t_dsca as NatureProduit, 
qua.t_otbd as CodeTiersAlertant, 
taler.t_nama as TiersAlertant, 
qua.t_acta as ActiviteAlertante, 
cexam.t_dsca as NomActiviteAlertante, 
qua.t_ctrl as ControleSpecifique, 
dbo.textnumtotext(qua.t_txtt,4) as TracabiliteProduit, 
dbo.textnumtotext(qua.t_trac,4) as TracabiliteProduit2, 
--rajout par rbesnier le 13/10/2017
qua.t_serl as NumeroSerie, 
--rajout par rbesnier le 20/03/2018 suite demande dprince et nbarranger
qua.t_pilo as PiloteAnalyseImputation, 
empp.t_nama as NomPiloteAnalyseImputation, 
dbo.textnumtotext(qua.t_dsnc,4) as DescriptionNC 
from tqmncm100500 qua --Rapport de non-conformité (NCMR)
left outer join ttcibd001500 art on art.t_item = qua.t_itmi --Articles
left outer join ttccom100500 fourn on fourn.t_bpid = qua.t_rsbp --Table des tiers
left outer join ttgbrg835500 utilisateur on utilisateur.t_user = qua.t_rptr --Gestion des Employés
left outer join tqmncm001500 typ on typ.t_nctp = qua.t_nctp --Type de Produits Non Conformes
left outer join tqmncm002500 sev on sev.t_slvl = qua.t_slvl --Sévérités
left outer join tqmncm003500 exa on exa.t_mrbc = qua.t_resp --Comite d'examen des produits
left outer join tqmncm003500 cexam on cexam.t_mrbc = qua.t_acta --Comité d'Examen des Produits
left outer join tzgncm001500 lfdet on lfdet.t_cflu = qua.t_lflu --Lieux du Flux Détectant
left outer join tzgncm002500 npro on npro.t_natp = qua.t_otbd --Nature du Produit
left outer join tzgncm003500 vehi on vehi.t_vehi = qua.t_vehi --Véhicule
left outer join ttccom100500 taler on taler.t_bpid = qua.t_otbd --Tiers Alertant
left outer join ttccom001500 empp on empp.t_emno = qua.t_pilo --Employé - Pilote Analyse
where qua.t_rpdt between @rap_f and @rap_t --Bornage sur la Date de Rapport
--Modification par rbesnier le 18/09/2017, on mettra dans le bornage si on souhaite avoir du vide
--and ((qua.t_dtim between @impu_f and @impu_t) or qua.t_dtim < '01/01/1980') --Bornage sur la Date d'Imputation
and qua.t_dtim between @impu_f and @impu_t --Bornage sur la Date d'Imputation
and qua.t_ncmr between @nc_f and @nc_t --Bornage sur le Numéro de Non Conforme
--On met la sélection multiple au lieu du de à, par rbesnier le 18/09/2017
/*and qua.t_grid between @site_f and @site_t --Bornage sur le Site Traitant
and qua.t_nctp between @fapr_f and @fapr_t --Bornage sur la Famille de Produits
and qua.t_slvl between @sev_f and @sev_t --Bornage sur la Sévérité
and qua.t_resp between @resp_f and @resp_t --Bornage sur le Responsable d'Activité Imputée
and qua.t_rsbp between @rsbp_f and @rsbp_t --Bornage sur le Tiers Responsable Imputé*/
and qua.t_grid in (@site, ' ') --Bornage sur le Site Traitant
--Suppression des 3 bornages ci-dessous suite aux erreurs liées à des familles produits nouvellement créées qui n'étaient du coup pas dans le SSRS
--and qua.t_nctp in (@fapr, ' ') --Bornage sur la Famille de Produits
--and qua.t_slvl in (@sev, ' ') --Bornage sur la Sévérité
--and qua.t_resp in (@resp, ' ') --Bornage sur le Responsable d'Activité Imputée
and qua.t_rsbp between @rsbp_f and @rsbp_t --Bornage sur le Tiers Responsable Imputé
and left(qua.t_ncmr, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par la fiche de non conformité