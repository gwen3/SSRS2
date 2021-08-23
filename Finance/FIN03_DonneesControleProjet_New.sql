-------------------------------------
-- FIN03 - Donnees Controle Projets
-------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select prj.t_entu as UniteEntreprise, 
cntprj.t_cprj as Projet, 
prj.t_dsca as DescriptionProjet, 
dbo.convertenum('tp','B61C','a9','bull','pdm.psts',prj.t_psts,'4') as StatutProjet, 
prj.t_stdt as DateDebut, 
prj.t_dldt as DateFin, 
--(select top 1 t_srid from tdmcom010500 where t_trid like concat('{"%', cntprj.t_cprj, '%"}')) as PieceJointe, --On fait ensuite une condition, s'il y a quelque chose on affiche Oui sinon Non.
'' as PieceJointe, --La pièce jointe est bien trop compliqué à faire tourner, on ne la ramène pas du coup.
prj.t_ccam as MethodeAcquisition, 
prj.t_cfac as ModeFinancement, 
modfin.t_desc as DescriptionModeFinancement, 
prj.t_csec as SecteurActivite, 
secact.t_desc as DescriptionSecteurActivite, 
prj.t_ccat as Categorie, 
cat.t_desc as DescriptionCategorie, 
prj.t_ccot as Groupe, 
cntprj.t_cact as Activite, 
act.t_desc as DescriptionActivite, 
(select actcpt.t_afdt from ttppss200500 actcpt where actcpt.t_cprj = cntprj.t_cprj and actcpt.t_cact = 'CONCEPT') as DateReelleJalonConception, 
(select actcon.t_afdt from ttppss200500 actcon where actcon.t_cprj = cntprj.t_cprj and actcon.t_cact = 'CONTRAT') as DateReelleJalonContrat, 
(select actdef.t_afdt from ttppss200500 actdef where actdef.t_cprj = cntprj.t_cprj and actdef.t_cact = 'DEFINIT') as DateReelleJalonDefinition, 
(select actind.t_afdt from ttppss200500 actind where actind.t_cprj = cntprj.t_cprj and actind.t_cact = 'INDUS') as DateReelleJalonIndustrialisation, 
(select actqua.t_afdt from ttppss200500 actqua where actqua.t_cprj = cntprj.t_cprj and actqua.t_cact = 'QUALIF') as DateReelleJalonQualification, 
dbo.convertenum('tp','B61C','a9','bull','pdm.cotp',cntprj.t_cotp,'4') as TypeCout, 
cntprj.t_qubg as QuantiteBudget, 
cntprj.t_ambg_1 as BudgetTotal, 
cntprj.t_qupm as QuantiteValeurAcquise, 
cntprj.t_ampm_1 as ValeurAcquise, 
(cntprj.t_ambg_1 - cntprj.t_ampm_1) as EcartBudgetValeurAcquise, 
(cntprj.t_quac + cntprj.t_quex) as QuantiteReelleAvecEngagements, 
(cntprj.t_amac_1 + cntprj.t_amex_1) as CoutsReelsAvecEngagements, 
((cntprj.t_quac + cntprj.t_quex) - cntprj.t_qubg) as EcartQuantiteReelleAvecEngagementQuantiteBudget, --QuantiteReelleAvecEngagements - QuantiteBudget
((cntprj.t_amac_1 + cntprj.t_amex_1) - cntprj.t_ambg_1) as EcartCoutsReelsAvecEngagementCoutBudget, --CoutsReelsAvecEngagements - BudgetTotal
cntprj.t_quac as QuantiteReelleHorsEngagement, 
cntprj.t_amac_1 as CoutsReelsHorsEngagement, 
(cntprj.t_quac - cntprj.t_qubg) as EcartQuantiteReelleHorsEngagementQuantiteBudget, --QuantiteReelleHorsEngagement - QuantiteBudget
(cntprj.t_amac_1 - cntprj.t_ambg_1) as EcartCoutReelHorsEngagementCoutBudget, --CoutsReelsHorsEngagement - BudgetTotal
cntprj.t_qupe as QuantitePrevisionnelle, 
cntprj.t_ampe_1 as CoutsPrevisionnels, 
(cntprj.t_ambg_1 - cntprj.t_ampe_1) as EcartBudgetPrevisionnel, 
left(act.t_litm, 9) as ProjetArticleSpecifique, 
substring(act.t_litm, 10, len(act.t_litm)) as ArticleSpecifique, 
art.t_dsca as DescriptionArticle, 
(select sum(cont.t_copr) from ttpctm110500 cont where cont.t_cprj = cntprj.t_cprj and cntprj.t_cact = '0100' and cntprj.t_cotp = '2') as MontantLigneContrat, 
(select sum(cont.t_itod) from ttpctm110500 cont where cont.t_cprj = cntprj.t_cprj and cntprj.t_cact = '0100' and cntprj.t_cotp = '2') as MontantFacture, 
(select top 1 cont.t_ccur from ttpctm110500 cont where cont.t_cprj = cntprj.t_cprj) as Devise 
from ttpppc441500 cntprj --Controle des Couts par Projet/Activite/Type de Couts
inner join ttppdm600500 prj on prj.t_cprj = cntprj.t_cprj --Gestion de Projets
left outer join ttppss200500 act on act.t_cprj = cntprj.t_cprj and act.t_cpla = prj.t_cpla --Activités
left outer join ttppdm059500 modfin on modfin.t_cfac = prj.t_cfac --Modes de Financement
left outer join ttppdm055500 secact on secact.t_csec = prj.t_csec --Secteur d'Activité
left outer join ttppdm075500 cat on cat.t_ccat = prj.t_ccat --Catégories
left outer join ttcibd001500 art on art.t_item = act.t_litm --Article
where cntprj.t_cact = act.t_cact --On ne prend que les Activités Communes
and (cntprj.t_cact = '0100' or cntprj.t_cact = '0200' or cntprj.t_cact = '0300' or cntprj.t_cact = '0400' or cntprj.t_cact = '0500' or cntprj.t_cact = '0600') --On ne prend que certaines activités
and prj.t_entu between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise
and cntprj.t_cprj between @cprj_f and @cprj_t --Bornage sur le Projet