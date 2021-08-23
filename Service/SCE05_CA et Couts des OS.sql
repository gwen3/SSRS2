-------------------------------
-- SCE05 - CA et Couts des OS
-------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
/*
declare @datetrans_f as Date;
declare @datetrans_t as Date;
declare @datefact_f as Date;
declare @datefact_t as Date;
declare @ue_f as varchar(30);
declare @ue_t as varchar(30);
declare @os_f as varchar(30);
declare @os_t as varchar(30);
declare @typeserv_f as varchar(30);
declare @typeserv_t as varchar(30);
declare @statos_f as varchar(30);
declare @statos_t as varchar(30);

set @datetrans_f = '01/01/2018';
set @datetrans_t = '31/12/2019';
set @datefact_f = '01/01/1970';
set @datefact_t = '31/12/2019';
set @ue_f = 'LV';
set @ue_t = 'LV';
set @os_f = 'LVS004057';
set @os_t = 'LVS004057';
set @typeserv_f = ' ';
set @typeserv_t = 'ZZZ';
set @statos_f = '1';
set @statos_t = '999';
*/
(select 'Matiere' as Source
,cmat.t_orno as OrdreService
,cmat.t_lino as LigneOrdreService
,cmat.t_acln as LignePrestation
,lpresta.t_desc as DescriptionPrestation
,lpresta.t_cstp as TypeService
,dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS
,apl.t_rpct as SignaleA
,(case 
when gargen.t_peru = 25 --Année
	then dateadd(day, (gargen.t_nrpe * 365), gar.t_optm) --On multiplie par 365
when gargen.t_peru = 20 --Trimestre
	then dateadd(day, (gargen.t_nrpe * 90), gar.t_optm) --On multiplie par 90
when gargen.t_peru = 15 --Mois
	then dateadd(day, (gargen.t_nrpe * 30), gar.t_optm) --On multiplie par 30
when gargen.t_peru = 10 --Semaine
	then dateadd(day, (gargen.t_nrpe * 7), gar.t_optm) --On multiplie par 7
when gargen.t_peru = 5 --Mois
	then dateadd(day, (gargen.t_nrpe * 1), gar.t_optm) --On multiplie par 1
end) as ExpirationConditionLe
,'' as VehiculeSousGarantie --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
,cmat.t_item as Article
,art.t_dsca as Description
,cmat.t_amnt_1 as Cout --Cout : Mat MO Autre
--cmat.t_adtm as DateTransaction, 
,(case cmat.t_dltp 
when 28 
	then cmat.t_artm --Cas des livraisons directes
else cmat.t_adtm --Cas autre que les livraisons directes
end) as DateTransaction
,dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation
,tiers.t_nama as NomTiersAcheteur
,pays.t_dsca as PaysLivraison
,lpresta.t_sern as NumeroSerie
,lpresta.t_cctp as TypeCouverture
,gar.t_gwte as GarantieGenerique
,gargen.t_desc as DescriptionGarantie
,os.t_aftm as DateFinOS
,os.t_cbrn as SecteurActivite
,left(lpresta.t_crac, 2) as Activite
,dim.t_desc as DescriptionActivite
,os.t_logn as CreateurOS
,lpresta.t_crac as PrestationReference
,os.t_cwoc as DepartementService
,dep.t_dsca as DesignationDepartementService
,lpresta.t_pstm as DateDebutPlanifiee
,lpresta.t_pftm as DateFinPlanifiee
,dbo.convertenum('ts','B61C','a9','bull','mdm.pmtd',lpresta.t_pmtd,'4') as ModeTarification
,cmat.t_inam as Montant
,os.t_ccur as Monnaie
,cmat.t_invd as DateFacturation
,cmat.t_idoc as NumeroFacture
,dbo.convertenum('ts','B61C','a9','bull','soc.clst',cmat.t_clst,'4') as StatutLigne
,left(os.t_cwoc, 2) as Site
,0 as NbHeures
,cmat.t_amnt_1 as CoutMatiere
,(case cmat.t_dltp 
when 4 --Magasin De
	then cmat.t_adqt
when 25 --Magasin A
	then -cmat.t_adqt
else 
	cmat.t_adqt 
end) as QuantiteReelle 
,gar.t_optm as DateInstallation
,cmat.t_psdt as DateImputation
--On ne fait pas les calculs en SQL car la date de transaction est un champ calculé, on le fait sur SSRS
,'' as MoisFacture
,'' as AnneeFacture
,'' as MoisTransaction
,'' as AnneeTransaction
,0 as Prestation
,'Réel' as 'Réel Budget'
,nc.t_rsbp as TiersResponsableImpute
,tiernc.t_nama as NomTiersResponsableImpute
,nc.t_resp as ResponsableActiviteImputee
,resp.t_dsca as NomResponsableActiviteImputee
,'' as HeurePeriode
,dbo.convertenum('ts','B61C','a9','bull','soc.osta',lpresta.t_asta,'4') as StatutLignePrestation
,isnull(lpresta.t_ccll,'') as NumAppel
-- Détermination Prix de ventes estimés : Prix de ventes - % Remise * qté estimée
,(cmat.t_espr * (1-(cmat.t_reme/100)) * cmat.t_eqan) as PxVtesEst
--
from ttssoc220500 cmat --Coûts Matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = cmat.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = cmat.t_orno and lpresta.t_acln = cmat.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = cmat.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttfgld010500 dim on dim.t_dtyp = 3 and dim.t_dimx = left(lpresta.t_crac, 2) --Dimensions
left outer join ttcmcs065500 dep on dep.t_cwoc = os.t_cwoc --Departement de Service
left outer join tqmncm100500 nc on nc.t_ncmr = left(lpresta.t_desc, 9) --Non Conformes
left outer join ttccom100500 tiernc on tiernc.t_bpid = nc.t_rsbp --Tiers Responsable Imputé
left outer join tqmncm003500 resp on resp.t_mrbc = nc.t_resp --Responsable Activité Imputée
left outer join ttccom130500 adr on adr.t_cadr = os.t_lcad --Adresse de Livraison
left outer join ttcmcs010500 pays on pays.t_ccty = adr.t_ccty --Pays de Livraison
left outer join ttcibd001500 art on art.t_item = cmat.t_item --Articles
where left(os.t_cwoc, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and --Bornage sur la Date de Livraison Reelle
((cmat.t_dltp = 28 and cmat.t_artm between @datetrans_f and @datetrans_t) --Cas des livraisons directes
or (cmat.t_dltp != 28 and cmat.t_adtm between @datetrans_f and @datetrans_t)) --Cas autre que les livraisons directes
and --Bornage sur la Date de Facture
(cmat.t_invd between @datefact_f and @datefact_t or cmat.t_invd < '01/01/1970')
and cmat.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and lpresta.t_cstp between @typeserv_f and @typeserv_t --Bornage sur le Type de Service
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
) union all
(select 'Main Oeuvre' as Source
,cma.t_orno as OrdreService
,cma.t_lino as LigneOrdreService
,cma.t_acln as LignePrestation
,lpresta.t_desc as DescriptionPrestation
,lpresta.t_cstp as TypeService
,dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS
,apl.t_rpct as SignaleA
,(case 
when gargen.t_peru = 25 --Année
	then dateadd(day, (gargen.t_nrpe * 365), gar.t_optm) --On multiplie par 365
when gargen.t_peru = 20 --Trimestre
	then dateadd(day, (gargen.t_nrpe * 90), gar.t_optm) --On multiplie par 90
when gargen.t_peru = 15 --Mois
	then dateadd(day, (gargen.t_nrpe * 30), gar.t_optm) --On multiplie par 30
when gargen.t_peru = 10 --Semaine
	then dateadd(day, (gargen.t_nrpe * 7), gar.t_optm) --On multiplie par 7
when gargen.t_peru = 5 --Mois
	then dateadd(day, (gargen.t_nrpe * 1), gar.t_optm) --On multiplie par 1
end) as ExpirationConditionLe
,'' as VehiculeSousGarantie --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
,'' as Article
,'' as Description
,cma.t_amnt_1 as Cout --Cout : Mat MO Autre
,cma.t_lttm as DateTransaction
,dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation
,tiers.t_nama as NomTiersAcheteur
,pays.t_dsca as PaysLivraison
,lpresta.t_sern as NumeroSerie
,lpresta.t_cctp as TypeCouverture
,gar.t_gwte as GarantieGenerique
,gargen.t_desc as DescriptionGarantie
,os.t_aftm as DateFinOS
,os.t_cbrn as SecteurActivite
,left(lpresta.t_crac, 2) as Activite
,dim.t_desc as DescriptionActivite
,os.t_logn as CreateurOS
,lpresta.t_crac as PrestationReference
,os.t_cwoc as DepartementService
,dep.t_dsca as DesignationDepartementService
,lpresta.t_pstm as DateDebutPlanifiee
,lpresta.t_pftm as DateFinPlanifiee
,dbo.convertenum('ts','B61C','a9','bull','mdm.pmtd',lpresta.t_pmtd,'4') as ModeTarification
,cma.t_inam as Montant
,os.t_ccur as Monnaie
,cma.t_invd as DateFacturation
,cma.t_idoc as NumeroFacture
,dbo.convertenum('ts','B61C','a9','bull','soc.clst',cma.t_clst,'4') as StatutLigne
,left(os.t_cwoc, 2) as Site
,cma.t_acqt as NbHeures
,0 as CoutMatiere
,'' as QuantiteReelle 
,gar.t_optm as DateInstallation
,cma.t_psdt as DateImputation
--On ne fait pas les calculs en SQL car la date de transaction est un champ calculé, on le fait sur SSRS
,'' as MoisFacture
,'' as AnneeFacture
,'' as MoisTransaction
,'' as AnneeTransaction
,0 as Prestation
,'Réel' as 'Réel Budget'
,nc.t_rsbp as TiersResponsableImpute
,tiernc.t_nama as NomTiersResponsableImpute
,nc.t_resp as ResponsableActiviteImputee
,resp.t_dsca as NomResponsableActiviteImputee
,(select sum(hr.t_hrea) from tbptmm130500 hr where hr.t_orno = cma.t_orno and hr.t_lbln = cma.t_lino and hr.t_trdt between @datetrans_f and @datetrans_t) as HeurePeriode
,dbo.convertenum('ts','B61C','a9','bull','soc.osta',lpresta.t_asta,'4') as StatutLignePrestation
,isnull(lpresta.t_ccll,'') as NumAppel
-- Détermination Prix de ventes estimés : Px Ventes * Durée estimée
,(cma.t_espr * cma.t_eqtm) as PxVtesEst
--
from ttssoc230500 cma --Coûts de main d'oeuvre de l'ordre de service
inner join ttssoc200500 os on os.t_orno = cma.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = cma.t_orno and lpresta.t_acln = cma.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = cma.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttfgld010500 dim on dim.t_dtyp = 3 and dim.t_dimx = left(lpresta.t_crac, 2) --Dimensions
left outer join ttcmcs065500 dep on dep.t_cwoc = os.t_cwoc --Departement de Service
left outer join tqmncm100500 nc on nc.t_ncmr = left(lpresta.t_desc, 9) --Non Conformes
left outer join ttccom100500 tiernc on tiernc.t_bpid = nc.t_rsbp --Tiers Responsable Imputé
left outer join tqmncm003500 resp on resp.t_mrbc = nc.t_resp --Responsable Activité Imputée
left outer join ttccom130500 adr on adr.t_cadr = os.t_lcad --Adresse de Livraison
left outer join ttcmcs010500 pays on pays.t_ccty = adr.t_ccty --Pays de Livraison
where left(os.t_cwoc, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and cma.t_lttm between @datetrans_f and @datetrans_t --Bornage sur la Date de Livraison Reelle
and --Bornage sur la Date de Facture
(cma.t_invd between @datefact_f and @datefact_t or cma.t_invd < '01/01/1970')
and cma.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and lpresta.t_cstp between @typeserv_f and @typeserv_t --Bornage sur le Type de Service
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
) union all
(select 'Autre' as Source
,cmao.t_orno as OrdreService
,cmao.t_lino as LigneOrdreService
,cmao.t_acln as LignePrestation
,lpresta.t_desc as DescriptionPrestation
,lpresta.t_cstp as TypeService
,dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS
,apl.t_rpct as SignaleA
,(case 
when gargen.t_peru = 25 --Année
	then dateadd(day, (gargen.t_nrpe * 365), gar.t_optm) --On multiplie par 365
when gargen.t_peru = 20 --Trimestre
	then dateadd(day, (gargen.t_nrpe * 90), gar.t_optm) --On multiplie par 90
when gargen.t_peru = 15 --Mois
	then dateadd(day, (gargen.t_nrpe * 30), gar.t_optm) --On multiplie par 30
when gargen.t_peru = 10 --Semaine
	then dateadd(day, (gargen.t_nrpe * 7), gar.t_optm) --On multiplie par 7
when gargen.t_peru = 5 --Mois
	then dateadd(day, (gargen.t_nrpe * 1), gar.t_optm) --On multiplie par 1
end) as ExpirationConditionLe
,'' as VehiculeSousGarantie --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
,cmao.t_tltp as Article
,cmao.t_desc as Description
,cmao.t_amnt_1 as Cout --Cout : Mat MO Autre
,cmao.t_ltdt as DateTransaction
,dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation
,tiers.t_nama as NomTiersAcheteur
,pays.t_dsca as PaysLivraison
,lpresta.t_sern as NumeroSerie
,lpresta.t_cctp as TypeCouverture
,gar.t_gwte as GarantieGenerique
,gargen.t_desc as DescriptionGarantie
,os.t_aftm as DateFinOS
,os.t_cbrn as SecteurActivite
,left(lpresta.t_crac, 2) as Activite
,dim.t_desc as DescriptionActivite
,os.t_logn as CreateurOS
,lpresta.t_crac as PrestationReference
,os.t_cwoc as DepartementService
,dep.t_dsca as DesignationDepartementService
,lpresta.t_pstm as DateDebutPlanifiee
,lpresta.t_pftm as DateFinPlanifiee
,dbo.convertenum('ts','B61C','a9','bull','mdm.pmtd',lpresta.t_pmtd,'4') as ModeTarification
,cmao.t_inam as Montant
,os.t_ccur as Monnaie
,cmao.t_invd as DateFacturation
,cmao.t_idoc as NumeroFacture
,dbo.convertenum('ts','B61C','a9','bull','soc.clst',cmao.t_clst,'4') as StatutLigne
,left(os.t_cwoc, 2) as Site
,0 as NbHeures
,0 as CoutMatiere
,'' as QuantiteReelle 
,gar.t_optm as DateInstallation
,cmao.t_psdt as DateImputation
--On ne fait pas les calculs en SQL car la date de transaction est un champ calculé, on le fait sur SSRS
,'' as MoisFacture
,'' as AnneeFacture
,'' as MoisTransaction
,'' as AnneeTransaction
,cmao.t_amnt_1 as Prestation
,'Réel' as 'Réel Budget'
,nc.t_rsbp as TiersResponsableImpute
,tiernc.t_nama as NomTiersResponsableImpute
,nc.t_resp as ResponsableActiviteImputee
,resp.t_dsca as NomResponsableActiviteImputee
,'' as HeurePeriode
,dbo.convertenum('ts','B61C','a9','bull','soc.osta',lpresta.t_asta,'4') as StatutLignePrestation
,isnull(lpresta.t_ccll,'') as NumAppel
-- Détermination Prix de ventes estimés : Px Ventes estimé * qté estimée
,(cmao.t_espr * cmao.t_eqan) as PxVtesEst
--
from ttssoc240500 cmao --Coûts de main d'oeuvre de l'ordre de service
inner join ttssoc200500 os on os.t_orno = cmao.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = cmao.t_orno and lpresta.t_acln = cmao.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = cmao.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttfgld010500 dim on dim.t_dtyp = 3 and dim.t_dimx = left(lpresta.t_crac, 2) --Dimensions
left outer join ttcmcs065500 dep on dep.t_cwoc = os.t_cwoc --Departement de Service
left outer join tqmncm100500 nc on nc.t_ncmr = left(lpresta.t_desc, 9) --Non Conformes
left outer join ttccom100500 tiernc on tiernc.t_bpid = nc.t_rsbp --Tiers Responsable Imputé
left outer join tqmncm003500 resp on resp.t_mrbc = nc.t_resp --Responsable Activité Imputée
left outer join ttccom130500 adr on adr.t_cadr = os.t_lcad --Adresse de Livraison
left outer join ttcmcs010500 pays on pays.t_ccty = adr.t_ccty --Pays de Livraison
where left(os.t_cwoc, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and cmao.t_ltdt between @datetrans_f and @datetrans_t --Bornage sur la Date de Livraison Reelle
and --Bornage sur la Date de Facture
(cmao.t_invd between @datefact_f and @datefact_t or cmao.t_invd < '01/01/1970')
and cmao.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and lpresta.t_cstp between @typeserv_f and @typeserv_t --Bornage sur le Type de Service
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
--and lpresta.t_pmtd = 15 --On prend les modes de tarifications qui sont en temps et matières
) union all
(select 'Prix Fixe' as Source
,ospf.t_orno as OrdreService
,'' as LigneOrdreService
,ospf.t_acln as LignePrestation
,lpresta.t_desc as DescriptionPrestation
,lpresta.t_cstp as TypeService
,dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS
,apl.t_rpct as SignaleA
,(case 
when gargen.t_peru = 25 --Année
	then dateadd(day, (gargen.t_nrpe * 365), gar.t_optm) --On multiplie par 365
when gargen.t_peru = 20 --Trimestre
	then dateadd(day, (gargen.t_nrpe * 90), gar.t_optm) --On multiplie par 90
when gargen.t_peru = 15 --Mois
	then dateadd(day, (gargen.t_nrpe * 30), gar.t_optm) --On multiplie par 30
when gargen.t_peru = 10 --Semaine
	then dateadd(day, (gargen.t_nrpe * 7), gar.t_optm) --On multiplie par 7
when gargen.t_peru = 5 --Mois
	then dateadd(day, (gargen.t_nrpe * 1), gar.t_optm) --On multiplie par 1
end) as ExpirationConditionLe
,'' as VehiculeSousGarantie --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
,'' as Article
,'' as Description
,'' as Cout --Cout : Mat MO Autre
,ospf.t_crtm as DateTransaction
,dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation
,tiers.t_nama as NomTiersAcheteur
,pays.t_dsca as PaysLivraison
,lpresta.t_sern as NumeroSerie
,lpresta.t_cctp as TypeCouverture
,gar.t_gwte as GarantieGenerique
,gargen.t_desc as DescriptionGarantie
,os.t_aftm as DateFinOS
,os.t_cbrn as SecteurActivite
,left(lpresta.t_crac, 2) as Activite
,dim.t_desc as DescriptionActivite
,os.t_logn as CreateurOS
,lpresta.t_crac as PrestationReference
,os.t_cwoc as DepartementService
,dep.t_dsca as DesignationDepartementService
,lpresta.t_pstm as DateDebutPlanifiee
,lpresta.t_pftm as DateFinPlanifiee
,dbo.convertenum('ts','B61C','a9','bull','mdm.pmtd',lpresta.t_pmtd,'4') as ModeTarification
,tarif.t_pris as Montant
,os.t_ccur as Monnaie
,ospf.t_invd as DateFacturation
,ospf.t_idoc as NumeroFacture
,dbo.convertenum('ts','B61C','a9','bull','soc.ivst',ospf.t_stat,'4') as StatutLigne
,left(os.t_cwoc, 2) as Site
,0 as NbHeures
,0 as CoutMatiere
,'' as QuantiteReelle
,gar.t_optm as DateInstallation
,ospf.t_psdt as DateImputation
--On ne fait pas les calculs en SQL car la date de transaction est un champ calculé, on le fait sur SSRS
,'' as MoisFacture
,'' as AnneeFacture
,'' as MoisTransaction
,'' as AnneeTransaction
,0 as Prestation
,'Réel' as 'Réel Budget'
,nc.t_rsbp as TiersResponsableImpute
,tiernc.t_nama as NomTiersResponsableImpute
,nc.t_resp as ResponsableActiviteImputee
,resp.t_dsca as NomResponsableActiviteImputee
,'' as HeurePeriode
,dbo.convertenum('ts','B61C','a9','bull','soc.osta',lpresta.t_asta,'4') as StatutLignePrestation
,isnull(lpresta.t_ccll,'') as NumAppel
-- Détermination Prix de ventes estimés : Prix fixes
,tarif.t_pris as PxVtesEst
--
from ttssoc215500 ospf --Coûts de main d'oeuvre de l'ordre de service
inner join ttssoc200500 os on os.t_orno = ospf.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = ospf.t_orno and lpresta.t_acln = ospf.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = ospf.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttfgld010500 dim on dim.t_dtyp = 3 and dim.t_dimx = left(lpresta.t_crac, 2) --Dimensions
left outer join ttcmcs065500 dep on dep.t_cwoc = os.t_cwoc --Departement de Service
left outer join ttstdm100500 tarif on tarif.t_prid = ospf.t_prid --Informations sur les tarifs
left outer join tqmncm100500 nc on nc.t_ncmr = left(lpresta.t_desc, 9) --Non Conformes
left outer join ttccom100500 tiernc on tiernc.t_bpid = nc.t_rsbp --Tiers Responsable Imputé
left outer join tqmncm003500 resp on resp.t_mrbc = nc.t_resp --Responsable Activité Imputée
left outer join ttccom130500 adr on adr.t_cadr = os.t_lcad --Adresse de Livraison
left outer join ttcmcs010500 pays on pays.t_ccty = adr.t_ccty --Pays de Livraison
where left(os.t_cwoc, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and ospf.t_crtm between @datetrans_f and @datetrans_t --Bornage sur la Date de Transaction
and --Bornage sur la Date de Facture
(ospf.t_invd between @datefact_f and @datefact_t or ospf.t_invd < '01/01/1970')
and ospf.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and lpresta.t_cstp between @typeserv_f and @typeserv_t --Bornage sur le Type de Service
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
and (lpresta.t_pmtd = 10 or lpresta.t_pmtd = 12) --On prend les modes de tarifications qui sont en temps et matières
)