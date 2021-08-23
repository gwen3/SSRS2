-------------------------------------------------
-- PRJ02 - Suivi Détaillé des coûts d'un projet
-------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select cout.t_cprj as Projet, 
prj.t_dsca as DescriptionProjet, 
--rajout par rbesnier le 15/02/2018
dbo.convertenum('tp','B61C','a9','bull','pdm.psts',prj.t_psts,'4') as StatutProjet, 
cout.t_cact as Activite, 
acti.t_desc as DescriptionActivite, 
cout.t_cotp as CodeTypeCout, 
dbo.convertenum('tp','B61C','a9','bull','pdm.cotp',cout.t_cotp,'4') as TypeCout, 
cout.t_desc as Description, 
cout.t_rgdt as DateEnregistrement, 
cout.t_emno as Employe, 
emp.t_nama as NomEmploye, 
cout.t_quan as Quantite, 
cout.t_cuni as Unite, 
cout.t_cohd_1 as CoutProjet, 
cout.t_koor as Origine, 
cout.t_orno as Document, 
cout.t_pono as Position, 
left(cout.t_oitm, 9) as ProjetArticle, 
substring(cout.t_oitm, 10, len(cout.t_oitm)) as Article, 
cout.t_otbp as TiersVendeur, 
tiers.t_nama as NomTiersVendeur 
from ttpppc200500 cout --Transaction de cout
inner join ttppdm600500 prj on prj.t_cprj = cout.t_cprj --Projet
inner join ttppss200500 acti on acti.t_cact = cout.t_cact and acti.t_cprj = cout.t_cprj --Activite
left outer join ttccom001500 emp on emp.t_emno = cout.t_emno --Employés
left outer join ttccom100500 tiers on tiers.t_bpid = cout.t_otbp --Tiers
where cout.t_cprj between @cprj_f and @cprj_t --Bornage sur le Projet
--rajout par rbesnier le 15/02/2018
and prj.t_psts between @stat_f and @stat_t --Bornage sur le statut du Projet
and left(cout.t_cprj, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le Projet