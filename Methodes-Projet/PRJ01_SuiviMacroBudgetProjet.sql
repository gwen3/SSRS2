--------------------------------------
-- PRJ01 - Suivi Macro Budget Projet
--------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Lancer les projets 360 et cliquer sur Controle des couts. Controle par projet/activité/type de couts et récupérer l'engagement réel. Projet type : LVD000069
select distinct cout.t_cprj as Projet, 
prj.t_dsca as DescriptionProjet, 
prj.t_year as PeriodeCourante, 
prj.t_entu as UniteEntreprise, 
prj.t_psts as CodeStatutProjet, 
dbo.convertenum('tp','B61C','a9','bull','pdm.psts',prj.t_psts,'4') as StatutProjet, 
prj.t_stdt as DateDebutProjet, 
prj.t_dldt as DateFinProjet, 
controle.t_cact as Activite, 
acti.t_desc as DescriptionActivite, 
acti.t_wast as CodeStatutAutorTravailActi, 
dbo.convertenum('tp','B61C','a9','bull','pdm.wast',acti.t_wast,'4') as StatutAutorTravailActi, 
(select copat.t_amac_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 1) as CoutReelMOActivite, 
(select copat.t_amac_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 2) as CoutReelMatiereActivite, 
(select copat.t_amac_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 3) as CoutReelEquipementActivite, 
(select copat.t_amac_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 4) as CoutReelSousTraitanceActivite, 
(select copat.t_amac_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 5) as CoutReelCoutDiversActivite, 
(select copat.t_amac_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 10) as CoutReelCoutIndirectActivite, 
(select copat.t_ambg_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 1) as BudgetTotalMOActivite, 
(select copat.t_ambg_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 2) as BudgetTotalMatiereActivite, 
(select copat.t_ambg_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 3) as BudgetTotalEquipementActivite, 
(select copat.t_ambg_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 4) as BudgetTotalSousTraitanceActivite, 
(select copat.t_ambg_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 5) as BudgetTotalCoutDiversActivite, 
(select copat.t_ambg_1 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 10) as BudgetTotalCoutIndirectActivite, 
(select copat.t_qubg 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 1) as QuantiteBudgetMOActivite, 
(select copat.t_qubg 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 2) as QuantiteBudgetMatiereActivite, 
(select copat.t_qubg 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 3) as QuantiteBudgetEquipementActivite, 
(select copat.t_qubg 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 4) as QuantiteBudgetSousTraitanceActivite, 
(select copat.t_qubg 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 5) as QuantiteBudgetCoutDiversActivite, 
(select copat.t_qubg 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 10) as QuantiteBudgetCoutIndirectActivite, 
(select copat.t_quac 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 1) as QuantiteReelleMOActivite, 
(select copat.t_quac 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 2) as QuantiteReelleMatiereActivite, 
(select copat.t_quac 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 3) as QuantiteReelleEquipementActivite, 
(select copat.t_quac 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 4) as QuantiteReelleSousTraitanceActivite, 
(select copat.t_quac 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 5) as QuantiteReelleCoutDiversActivite, 
(select copat.t_quac 
from ttpppc441500 copat
where copat.t_cprj = cout.t_cprj 
and copat.t_mpto = 2 
and copat.t_cpla = acti.t_cpla 
and copat.t_cact = acti.t_cact 
and copat.t_cotp = 10) as QuantiteReelleCoutIndirectActivite 
from ttpppc411500 cout --Controle des coûts par projet/code contrôle main d'oeuvre
inner join ttppdm600500 prj on prj.t_cprj = cout.t_cprj --Projet
inner join ttpppc440500 controle on controle.t_cprj = cout.t_cprj --Controle des coûts par projet/Activite
inner join ttppss200500 acti on acti.t_cprj = controle.t_cprj and acti.t_cpla = controle.t_cpla and acti.t_cact = controle.t_cact --Activités
where controle.t_cact like '%00' 
and controle.t_mpto = 2 -- Total par projet
and left(cout.t_cprj, 2) between @ue_f and @ue_t --Bornage sur l'UE donnée par le projet
and cout.t_cprj between @cprj_f and @cprj_t --Projet
and controle.t_cact between @acti_f and @acti_t --Activité
and prj.t_year between @year_f and @year_t --Période Annuelle de Contrôle des Coûts
and prj.t_psts between @stat_f and @stat_t --Bornage sur le Statut du Projet