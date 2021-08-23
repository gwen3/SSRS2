--------------------------------
-- PRJ03 - Transactions Projet
--------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select cout.t_entu as UniteEntreprise, 
cout.t_cprj as Projet, 
prj.t_dsca as DescriptionProjet, 
dbo.convertenum('tp','B61C','a9','bull','pdm.psts',prj.t_psts,'4') as StatutProjet, 
prj.t_ccam as MethodeAcquisition, 
prj.t_cfac as ModeFinancement, 
prj.t_csec as SecteurActivite, 
prj.t_ccat as Categorie, 
prj.t_ccot as Groupe, 
cout.t_cact as Activite, 
act.t_desc as DescriptionActivite, 
dbo.convertenum('tp','B61C','a9','bull','pdm.cotp',cout.t_cotp,'4') as TypeCoutRevenu, 
cout.t_ccco as EPR, 
cout.t_coob as ObjetDeCout, 
cout.t_desc as DesignationObjetDeCout, 
cout.t_quan as Quantite, 
cout.t_cuni as Unite, 
cout.t_cohc_1 as Montant, 
cout.t_rgdt as DateEnregistrement, 
cout.t_ltdt as DateTransaction, 
prj.t_stdt as HeureDebut, 
prj.t_dldt as DateFin, 
cout.t_ptyc as CodeTypeImputation, 
dbo.convertenum('tp','B61C','a9','bull','ppc.ptyc',cout.t_ptyc,'4') as TypeImputation 
from ttpppc200500 cout --Transactions de Coûts
left outer join ttppdm600500 prj on prj.t_cprj = cout.t_cprj --Projets
left outer join ttppss200500 act on act.t_cprj = cout.t_cprj and act.t_cpla = prj.t_cpla --Activités
where cout.t_entu between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise
and cout.t_cact = act.t_cact --On ne prend que les mêmes activités
and cout.t_cprj between @cprj_f and @cprj_t 
/*Potentiellement bornage non utilisés
and cout.t_cact between @cact_f and @cact_t --Bornage sur les Activités
and prj.t_psts >= @stat_f and prj.t_psts <= @stat_t
and prj.t_stdt >= @stdtutc_f and prj.t_stdt <= @stdtutc_t
and prj.t_dldt >= @dldtutc_f and prj.t_dldt <= @dldtutc_t
and cout.t_rgdt >= @rgdtutc_f and cout.t_rgdt <= @rgdtutc_t
and prj.t_ccam >= @ccam_f and prj.t_ccam <= @ccam_t
and prj.t_cfac >= @cfac_f and prj.t_cfac <= @cfac_t
and prj.t_csec >= @csec_f and prj.t_csec <= @csec_t
and prj.t_ccat >= @ccat_f and prj.t_ccat <= @ccat_t
and prj.t_ccot >= @ccot_f and prj.t_ccot <= @ccot_t*/

and ((cout.t_cotp between @cotp_f and @cotp_t and @engagement = 1) 
 or (cout.t_cotp between @cotp_f and @cotp_t and @engagement = 0 and cout.t_ptyc <> 60)) --Bornage sur le Type de Coût

union all
select cout.t_entu as UniteEntreprise, 
cout.t_cprj as Projet, 
prj.t_dsca as DescriptionProjet, 
dbo.convertenum('tp','B61C','a9','bull','pdm.psts',prj.t_psts,'4') as StatutProjet, 
prj.t_ccam as MethodeAcquisition, 
prj.t_cfac as ModeFinancement, 
prj.t_csec as SecteurActivite, 
prj.t_ccat as Categorie, 
prj.t_ccot as Groupe, 
cout.t_cact as Activite, 
act.t_desc as DescriptionActivite, 
'Revenu' as TypeCoutRevenu, 
cout.t_ccco as EPR, 
cout.t_coob as ObjetDeCout, 
cout.t_desc as DesignationObjetDeCout, 
'1' as Quantite, 
'' as Unite, 
cout.t_cohc_1 as Montant, 
cout.t_rgdt as DateEnregistrement, 
cout.t_ltdt as DateTransaction, 
prj.t_stdt as HeureDebut, 
prj.t_dldt as DateFin, 
0 as CodeTypeImputation, 
'' as TypeImputation
from ttpppc200500 cout --Transactions de Coûts
left outer join ttppdm600500 prj on prj.t_cprj = cout.t_cprj --Projets
left outer join ttppss200500 act on act.t_cprj = cout.t_cprj and act.t_cpla = prj.t_cpla --Activités
where cout.t_entu between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise
and cout.t_cact = act.t_cact --On ne prend que les mêmes activités
and cout.t_cprj between @cprj_f and @cprj_t 
/*Potentiellement bornage non utilisés
and cout.t_cact between @cact_f and @cact_t --Bornage sur les Activités
and prj.t_psts >= @stat_f and prj.t_psts <= @stat_t
and prj.t_stdt >= @stdtutc_f and prj.t_stdt <= @stdtutc_t
and prj.t_dldt >= @dldtutc_f and prj.t_dldt <= @dldtutc_t
and cout.t_rgdt >= @rgdtutc_f and cout.t_rgdt <= @rgdtutc_t
and prj.t_ccam >= @ccam_f and prj.t_ccam <= @ccam_t
and prj.t_cfac >= @cfac_f and prj.t_cfac <= @cfac_t
and prj.t_csec >= @csec_f and prj.t_csec <= @csec_t
and prj.t_ccat >= @ccat_f and prj.t_ccat <= @ccat_t
and prj.t_ccot >= @ccot_f and prj.t_ccot <= @ccot_t*/

and ((cout.t_cotp between @cotp_f and @cotp_t and @engagement = 1) 
 or (cout.t_cotp between @cotp_f and @cotp_t and @engagement = 0 and cout.t_ptyc <> 60)) --Bornage sur le Type de Coût
