---------------------------------
-- GEN02 - Temps Passé - Projet
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Heures Fabrication
(select 'Heures Fabrication' as Source, 
'' as CodeTypeTransaction, 
'' as TypeTransaction, 
donof.t_orno as DepartementOF, 
donof.t_cprj as ProjetPCSOS, 
prj.t_dsca as Description, -- Il n'y a pas de description pour les Projets PCS
donof.t_emno as CodeEmploye, 
emp.t_nama as NomEmploye, 
donof.t_year as Annee, 
donof.t_peri as Jour, 
concat(donof.t_peri, '/', donof.t_year) as Periode, 
donof.t_seqn as Sequence, 
donof.t_cact as Activite, 
acti.t_desc as DescriptionActivite, 
donof.t_tano as Tache, 
tache.t_dsca as DescriptionTache, 
donof.t_cwoc as CentreCharge, 
cc.t_dsca as DescriptionCentreCharge, 
donof.t_opno as Operation, 
'' as ElementPrixRevient, 
'' as DescriptionElementPrixRevient, 
'' as DateEnregistrement, 
donof.t_hrea as TempsMainOeuvre, 
donof.t_htst as CodeStatutTransaction, 
dbo.convertenum('tc','B61C','a9','bull','htst',donof.t_htst,'4') as StatutTransaction, 
donof.t_orig as CodeOrigineLigne, 
dbo.convertenum('bp','B61C','a9','bull','tmm.orig',donof.t_orig,'4') as OrigineLigne, 
donof.t_chlt as TypeMainOeuvre, 
typmo.t_dsca as DescriptionTypeMainOeuvre, 
donof.t_logn as CodeAcces, 
donof.t_trdt as DateTransaction, 
donof.t_proc as CodeTraite, 
dbo.convertenum('tc','B61C','a9','bull','yesno',donof.t_proc,'4') as Traite 
from tbptmm120500 donof --Données Ordre Fabrication
left outer join ttccom001500 emp on emp.t_emno = donof.t_emno --Employés
left outer join ttcppl030500 typmo on typmo.t_ckow = donof.t_chlt --Type de Main d'Oeuvre 
left outer join ttppss200500 acti on acti.t_cprj = donof.t_cprj and acti.t_cact = donof.t_cact --Activités 
left outer join ttirou003500 tache on tache.t_tano = donof.t_tano --Tache
left outer join ttcmcs065500 cc on cc.t_cwoc = donof.t_cwoc --Centre de Charge
left outer join ttcmcs052500 prj on prj.t_cprj = donof.t_cprj --Projet
where left(donof.t_cprj, 2) between @ue_f and @ue_t --Bornage sur l'UE
and donof.t_cprj between @cprj_f and @cprj_t --Bornage sur le Projet
) union all 
--Heures Projet
(select 'Heures Projet' as Source, 
'' as CodeTypeTransaction, 
'' as TypeTransaction, 
'' as DepartementOF, 
hdprj.t_cprj as ProjetPCSOS, 
prj.t_dsca as Description, 
hdprj.t_emno as CodeEmploye, 
emp.t_nama as NomEmploye, 
hdprj.t_year as Annee, 
hdprj.t_peri as Jour, 
concat(hdprj.t_peri, '/', hdprj.t_year) as Periode, 
hdprj.t_seqn as Sequence, 
hdprj.t_cact as Activite, 
acti.t_desc as DescriptionActivite, 
hdprj.t_ccun as Tache, -- Il existe un champ tache générale (gtsk)
hdprj.t_dsca as DescriptionTache, -- Description présente dans la table générale
'' as CentreCharge, 
'' as DescriptionCentreCharge, 
'' as Operation, 
hdprj.t_cpcp as ElementPrixRevient, 
prev.t_dsca as DescriptionElementPrixRevient, 
'' as DateEnregistrement, 
hdprj.t_hrea_8 as TempsMainOeuvre, 
'' as CodeStatutTransaction, 
'' as StatutTransaction, 
hdprj.t_orig as CodeOrigineLigne, 
dbo.convertenum('bp','B61C','a9','bull','tmm.orig',hdprj.t_orig,'4') as OrigineLigne, 
hdprj.t_chlt as TypeMainOeuvre, 
typmo.t_dsca as DescriptionTypeMainOeuvre, 
hdprj.t_logn as CodeAcces, 
hdprj.t_trdt as DateTransaction, 
hdprj.t_proc as CodeTraite, 
dbo.convertenum('tc','B61C','a9','bull','yesno',hdprj.t_proc,'4') as Traite 
from tbptmm111500 hdprj --Heures/Dépenses Projet et global
left outer join ttccom001500 emp on emp.t_emno = hdprj.t_emno --Employés
left outer join ttcppl030500 typmo on typmo.t_ckow = hdprj.t_chlt --Type de Main d'Oeuvre 
left outer join ttppss200500 acti on acti.t_cprj = hdprj.t_cprj and acti.t_cact = hdprj.t_cact --Activités 
left outer join ttppdm600500 prj on prj.t_cprj = hdprj.t_cprj --Projet
left outer join ttcmcs048500 prev on prev.t_cpcp = hdprj.t_cpcp --Element Prix de Revient
where left(hdprj.t_cprj, 2) between @ue_f and @ue_t --Bornage sur l'UE
and hdprj.t_cprj between @cprj_f and @cprj_t --Bornage sur le Projet
) union all 
--Heures PCS
(select 'Heures PCS' as Source, 
'' as CodeTypeTransaction, 
'' as TypeTransaction, 
'' as DepartementOF, 
donprj.t_cprj as ProjetPCSOS, 
prj.t_dsca as Description, -- Il n'y a pas de description pour les Projets PCS
donprj.t_emno as CodeEmploye, 
emp.t_nama as NomEmploye, 
donprj.t_year as Annee, 
donprj.t_peri as Jour, 
concat(donprj.t_peri, '/', donprj.t_year) as Periode, 
donprj.t_seqn as Sequence, 
donprj.t_cact as Activite, 
acti.t_desc as DescriptionActivite, 
donprj.t_tano as Tache, 
tache.t_dsca as DescriptionTache, 
donprj.t_cwoc as CentreCharge, 
cc.t_dsca as DescriptionCentreCharge, 
donprj.t_mcno as Operation, 
'' as ElementPrixRevient, 
'' as DescriptionElementPrixRevient, 
'' as DateEnregistrement, 
donprj.t_hrea as TempsMainOeuvre, 
donprj.t_htst as CodeStatutTransaction, 
dbo.convertenum('tc','B61C','a9','bull','htst',donprj.t_htst,'4') as StatutTransaction, 
donprj.t_orig as CodeOrigineLigne, 
dbo.convertenum('bp','B61C','a9','bull','tmm.orig',donprj.t_orig,'4') as OrigineLigne, 
donprj.t_chlt as TypeMainOeuvre, 
typmo.t_dsca as DescriptionTypeMainOeuvre, 
donprj.t_logn as CodeAcces, 
donprj.t_trdt as DateTransaction, 
donprj.t_proc as CodeTraite, 
dbo.convertenum('tc','B61C','a9','bull','yesno',donprj.t_proc,'4') as Traite 
from tbptmm170500 donprj --Données Projet
left outer join ttccom001500 emp on emp.t_emno = donprj.t_emno --Employés
left outer join ttcppl030500 typmo on typmo.t_ckow = donprj.t_chlt --Type de Main d'Oeuvre 
left outer join ttppss200500 acti on acti.t_cprj = donprj.t_cprj and acti.t_cact = donprj.t_cact --Activités 
left outer join ttirou003500 tache on tache.t_tano = donprj.t_tano --Tache
left outer join ttcmcs065500 cc on cc.t_cwoc = donprj.t_cwoc --Centre de Charge
left outer join ttcmcs052500 prj on prj.t_cprj = donprj.t_cprj --Projet
where left(donprj.t_cprj, 2) between @ue_f and @ue_t --Bornage sur l'UE
and donprj.t_cprj between @cprj_f and @cprj_t --Bornage sur le Projet
) union all 
--Heures Service
(select 'Heures Service' as Source, 
'' as CodeTypeTransaction, 
'' as TypeTransaction, 
'' as DepartementOF, 
donos.t_orno as ProjetPCSOS, 
'' as Description, --On ne récupère pas la description pour l'instant car il faudrait récupérer le tiers de l'OS
donos.t_emno as CodeEmploye, 
emp.t_nama as NomEmploye, 
donos.t_year as Annee, 
donos.t_peri as Jour, 
concat(donos.t_peri, '/', donos.t_year) as Periode, 
donos.t_seqn as Sequence, 
donos.t_acln as Activite, 
'' as DescriptionActivite, 
donos.t_stsk as Tache, 
'' as DescriptionTache, 
donos.t_cwoc as CentreCharge, 
cc.t_dsca as DescriptionCentreCharge, 
'' as Operation, 
donos.t_cpcp as ElementPrixRevient, 
prev.t_dsca as DescriptionElementPrixRevient, 
'' as DateEnregistrement, 
donos.t_hrea as TempsMainOeuvre, 
'' as CodeStatutTransaction, 
'' as StatutTransaction, 
donos.t_orig as CodeOrigineLigne, 
dbo.convertenum('bp','B61C','a9','bull','tmm.orig',donos.t_orig,'4') as OrigineLigne, 
donos.t_chlt as TypeMainOeuvre, 
typmo.t_dsca as DescriptionTypeMainOeuvre, 
donos.t_logn as CodeAcces, 
donos.t_trdt as DateTransaction, 
donos.t_proc as CodeTraite, 
dbo.convertenum('tc','B61C','a9','bull','yesno',donos.t_proc,'4') as Traite 
from tbptmm130500 donos --Données Ordre Service
left outer join ttccom001500 emp on emp.t_emno = donos.t_emno --Employés
left outer join ttcppl030500 typmo on typmo.t_ckow = donos.t_chlt --Type de Main d'Oeuvre 
left outer join ttcmcs065500 cc on cc.t_cwoc = donos.t_cwoc --Centre de Charge 
left outer join ttcmcs048500 prev on prev.t_cpcp = donos.t_cpcp --Element Prix de Revient
where left(donos.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE
and donos.t_orno between @cprj_f and @cprj_t --Bornage sur le Projet
)