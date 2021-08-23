-------------------------------------
-- PRJ04 - Donnees Controle Projets
-------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select prj.t_entu as UniteEntreprise, 
cntprj.t_cprj as Projet, 
prj.t_dsca as DescriptionProjet, 
dbo.convertenum('tp','B61C','a9','bull','pdm.psts',prj.t_psts,'4') as StatutProjet, 
prj.t_ccam as MethodeAcquisition, 
prj.t_cfac as ModeFinancement, 
prj.t_csec as SecteurActivite, 
prj.t_ccat as Categorie, 
prj.t_ccot as Groupe, 
cntprj.t_cact as Activite, 
--act.t_cact as Activite, 
act.t_desc as DescriptionActivite, 
dbo.convertenum('tp','B61C','a9','bull','pdm.cotp',cntprj.t_cotp,'4') as TypeCout, 
cntprj.t_qubg as QuantiteBudget, 
cntprj.t_ambg_1 as BudgetTotal, 
cntprj.t_qupm as QuantiteValeurAcquise, 
cntprj.t_ampm_1 as ValeurAcquise, 
(cntprj.t_ambg_1 - cntprj.t_ampm_1) as EcartBudgetValeurAcquise, 
(cntprj.t_quac + cntprj.t_quex) as QuantiteReelleAvecEngagements, 
(cntprj.t_amac_1 + cntprj.t_amex_1) as CoutsReelsAvecEngagements, 
--(cntprj.t_qupm - cntprj.t_quac - cntprj.t_quex) as EcartQuantiteReelleAvecEngagement, 
((cntprj.t_quac + cntprj.t_quex) - cntprj.t_qubg) as EcartQuantiteReelleAvecEngagementQuantiteBudget, --QuantiteReelleAvecEngagements - QuantiteBudget
--(cntprj.t_ampm_1 - cntprj.t_amac_1 - cntprj.t_amex_1) as EcartCoutsReelsAvecEngagement, 
((cntprj.t_amac_1 + cntprj.t_amex_1) - cntprj.t_ambg_1) as EcartCoutsReelsAvecEngagementCoutBudget, --CoutsReelsAvecEngagements - BudgetTotal
cntprj.t_quac as QuantiteReelleHorsEngagement, 
cntprj.t_amac_1 as CoutsReelsHorsEngagement, 
--(cntprj.t_qupm - cntprj.t_quac) as EcartQuantiteReelleHorsEngagement, 
(cntprj.t_quac - cntprj.t_qubg) as EcartQuantiteReelleHorsEngagementQuantiteBudget, --QuantiteReelleHorsEngagement - QuantiteBudget
--(cntprj.t_ampm_1 - cntprj.t_amac_1) as EcartCoutReelHorsEngagement, 
(cntprj.t_amac_1 - cntprj.t_ambg_1) as EcartCoutReelHorsEngagementCoutBudget, --CoutsReelsHorsEngagement - BudgetTotal
cntprj.t_qupe as QuantitePrevisionnelle, 
cntprj.t_ampe_1 as CoutsPrevisionnels, 
(cntprj.t_ambg_1 - cntprj.t_ampe_1) as EcartBudgetPrevisionnel 
--prj.t_stdt as HeureDebut, 
--prj.t_dldt as DateFin, 
--cntprj.t_quex as EngagementSurQuantite, 
--cntprj.t_amex_1 as Engagement, 
from ttpppc441500 cntprj --Controle des Couts par Projet/Activite/Type de Couts
left outer join ttppdm600500 prj on prj.t_cprj = cntprj.t_cprj --Gestion de Projets
left outer join ttppss200500 act on act.t_cprj = cntprj.t_cprj and act.t_cpla = prj.t_cpla --Activités
left outer join ttpppc200500 cout on cout.t_cprj = cntprj.t_cprj and cout.t_cotp = cntprj.t_cotp --Transactions de Couts
where cntprj.t_cact = act.t_cact --On ne prend que les Activités Communes
and prj.t_entu between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise
and cntprj.t_cprj between @cprj_f and @cprj_t --Bornage sur le Projet
--and 
--and prj.t_psts between @stat_f and @stat_t --Bornage sur le Statut du Projet
--and prj.t_stdt between @stdt_f and @stdt_t --Bornage sur la Date de Début du Projet
--and prj.t_dldt between @dldt_f and @dldt_t --Bornage sur la Date de Fin du Projet
--and prj.t_ccam between @ccam_f and @ccam_t --Bornage sur la Méthode d'Acquisition
--and prj.t_cfac between @cfac_f and @cfac_t --Bornage sur le Mode de Financement
--and prj.t_csec between @csec_f and @csec_t --Bornage sur le Secteur d'Activité
--and prj.t_ccat between @ccat_f and @ccat_t --Bornage sur la Catégorie
--and prj.t_ccot between @ccot_f and @ccot_t --Bornage sur le Groupe
--and act.t_cact between @cact_f and @cact_t --Bornage sur l'Activité