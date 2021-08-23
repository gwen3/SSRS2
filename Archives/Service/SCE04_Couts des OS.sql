-------------------------------------
-- SCE04 - Couts des OS par Periode
-------------------------------------

/*declare @datetrans_f as Date;
declare @datetrans_t as Date;
declare @ue_f as varchar(30);
declare @ue_t as varchar(30);
declare @os_f as varchar(30);
declare @os_t as varchar(30);
declare @appel_f as varchar(30);
declare @appel_t as varchar(30);
declare @datesig_f as Date;
declare @datesig_t as Date;
declare @statapl_f as varchar(30);
declare @statapl_t as varchar(30);
declare @couv_f as Date;
declare @couv_t as Date;
declare @statos_f as varchar(30);
declare @statos_t as varchar(30);
declare @tauxhoraire as varchar(30);

set @datetrans_f = '01/01/2017';
set @datetrans_t = '31/12/2017';
set @ue_f = 'LV';
set @ue_t = 'LV';
set @os_f = ' ';
set @os_t = 'ZZZZ';
set @appel_f = ' ';
set @appel_t = 'ZZZZZ';
set @datesig_f = '01/01/2017';
set @datesig_t = '31/12/2017';
set @statapl_f = '1';
set @statapl_t = '999';
set @couv_f = '01/01/2017';
set @couv_t = '31/12/2017';
set @statos_f = '1';
set @statos_t = '999';
set @tauxhoraire = '80';
*/

if (@appel_f != ' ') --Si on ne renseigne pas d'appel précis, on prend tout, sinon on regarde les bornages qui dépendent de l'appel
(select 'Matiere' as Source, 
cmat.t_orno as OrdreService, 
cmat.t_lino as LigneOrdreService, 
cmat.t_acln as LignePrestation, 
substring(cmat.t_orno, 3, 1) as TypeService, 
dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS, 
os.t_cprj as ProjetOS, 
apl.t_ccll as NumeroAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.cllo',apl.t_cllo,'4') as OrigineAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.stat',apl.t_stat,'4') as StatutAppel, 
left(apl.t_item, 9) as ProjetAppel, 
apl.t_shpd as DescriptionAppel, 
txt.t_ludt as DateCommentaire, 
dbo.textnumtotext(apl.t_txtk,'4') as DernierCommentaire, 
apl.t_rpct as SignaleA, 
gar.t_optm as DateInstallation, 
year(gar.t_optm) as AnneeInstallation, 
(case 
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
end) as ExpirationConditionLe, 
'' as VehiculeSousGarantie, --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
'' as TiersVendeur, 
'' as NomTiersVendeur, 
'0' as MontantFactureHA, 
cmat.t_amnt_1 as Cout, --Cout : Mat MO Autre
cmat.t_adtm as DateTransaction, 
dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation, 
tiers.t_nama as NomTiersAcheteur, 
lpresta.t_sern as NumeroSerie, 
lpresta.t_cctp as TypeCouverture, 
gar.t_gwte as GarantieGenerique, 
gargen.t_desc as DescriptionGarantie, 
os.t_aftm as DateFinOS, 
os.t_cbrn as SecteurActivite, 
(select round(sum(lfact.t_amti), 2) from tcisli310500 lfact inner join tcisli305500 fact on fact.t_sfcp = lfact.t_sfcp and fact.t_tran = lfact.t_tran and fact.t_idoc = lfact.t_idoc where lfact.t_orno = cmat.t_orno and lfact.t_srtp = 60 and fact.t_idat between @datetrans_f and @datetrans_t) as MontantHTFactures 
from ttssoc220500 cmat --Coûts Matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = cmat.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = cmat.t_orno and lpresta.t_acln = cmat.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = cmat.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttttxt002500 txt on txt.t_ctxt = apl.t_txtk --Textes du Dernier Commentaire
where left(cmat.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and cmat.t_dltp != 28 --Cas autre que les livraisons directes
and cmat.t_adtm between @datetrans_f and @datetrans_t --Bornage sur la Date de Livraison Réelle
and cmat.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and apl.t_ccll between @appel_f and @appel_t --Bornage sur le Numéro d'Appel
and apl.t_rpct between @datesig_f and @datesig_t --Bornage sur la Date de Signalisation
and apl.t_stat between @statapl_f and @statapl_t --Bornage sur le Statut de l'Appel
and apl.t_cvtm between @couv_f and @couv_t --Bornage sur la Durée de Couverture
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
) union all
(select 'Matiere' as Source, 
cmat.t_orno as OrdreService, 
cmat.t_lino as LigneOrdreService, 
cmat.t_acln as LignePrestation, 
substring(cmat.t_orno, 3, 1) as TypeService, 
dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS, 
os.t_cprj as ProjetOS, 
apl.t_ccll as NumeroAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.cllo',apl.t_cllo,'4') as OrigineAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.stat',apl.t_stat,'4') as StatutAppel, 
left(apl.t_item, 9) as ProjetAppel, 
apl.t_shpd as DescriptionAppel, 
txt.t_ludt as DateCommentaire, 
dbo.textnumtotext(apl.t_txtk,'4') as DernierCommentaire, 
apl.t_rpct as SignaleA, 
gar.t_optm as DateInstallation, 
year(gar.t_optm) as AnneeInstallation, 
(case 
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
end) as ExpirationConditionLe, 
'' as VehiculeSousGarantie, --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
'' as TiersVendeur, 
'' as NomTiersVendeur, 
'0' as MontantFactureHA, 
cmat.t_amnt_1 as Cout, --Cout : Mat MO Autre
cmat.t_adtm as DateTransaction, 
dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation, 
tiers.t_nama as NomTiersAcheteur, 
lpresta.t_sern as NumeroSerie, 
lpresta.t_cctp as TypeCouverture, 
gar.t_gwte as GarantieGenerique, 
gargen.t_desc as DescriptionGarantie, 
os.t_aftm as DateFinOS, 
os.t_cbrn as SecteurActivite, 
(select round(sum(lfact.t_amti), 2) from tcisli310500 lfact inner join tcisli305500 fact on fact.t_sfcp = lfact.t_sfcp and fact.t_tran = lfact.t_tran and fact.t_idoc = lfact.t_idoc where lfact.t_orno = cmat.t_orno and lfact.t_srtp = 60 and fact.t_idat between @datetrans_f and @datetrans_t) as MontantHTFactures 
from ttssoc220500 cmat --Coûts Matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = cmat.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = cmat.t_orno and lpresta.t_acln = cmat.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = cmat.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttttxt002500 txt on txt.t_ctxt = apl.t_txtk --Textes du Dernier Commentaire
where left(cmat.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and cmat.t_dltp = 28 --Cas des livraisons directes
and cmat.t_artm between @datetrans_f and @datetrans_t --Bornage sur la Date de Livraison Réelle
and cmat.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and apl.t_ccll between @appel_f and @appel_t --Bornage sur le Numéro d'Appel
and apl.t_rpct between @datesig_f and @datesig_t --Bornage sur la Date de Signalisation
and apl.t_stat between @statapl_f and @statapl_t --Bornage sur le Statut de l'Appel
and apl.t_cvtm between @couv_f and @couv_t --Bornage sur la Durée de Couverture
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
) union all
(select 'Main Oeuvre' as Source, 
donos.t_orno as OrdreService, 
donos.t_lbln as LigneOrdreService, 
donos.t_acln as LignePrestation, 
substring(donos.t_orno, 3, 1) as TypeService, 
dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS, 
os.t_cprj as ProjetOS, 
apl.t_ccll as NumeroAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.cllo',apl.t_cllo,'4') as OrigineAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.stat',apl.t_stat,'4') as StatutAppel, 
left(apl.t_item, 9) as ProjetAppel, 
apl.t_shpd as DescriptionAppel, 
txt.t_ludt as DateCommentaire, 
dbo.textnumtotext(apl.t_txtk,'4') as DernierCommentaire, 
apl.t_rpct as SignaleA, 
gar.t_optm as DateInstallation, 
year(gar.t_optm) as AnneeInstallation, 
(case 
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
end) as ExpirationConditionLe, 
'' as VehiculeSousGarantie, --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
'' as TiersVendeur, 
'' as NomTiersVendeur, 
'0' as MontantFactureHA, 
(donos.t_hrea * @tauxhoraire) as Cout, --Cout : Mat MO Autre
dateadd(day, donos.t_peri - 1, dateadd(year, donos.t_year - 1, cast('01/01/0001' as date))) as DateTransaction, 
dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation, 
tiers.t_nama as NomTiersAcheteur, 
lpresta.t_sern as NumeroSerie, 
lpresta.t_cctp as TypeCouverture, 
gar.t_gwte as GarantieGenerique, 
gargen.t_desc as DescriptionGarantie, 
os.t_aftm as DateFinOS, 
os.t_cbrn as SecteurActivite, 
(select round(sum(lfact.t_amti), 2) from tcisli310500 lfact inner join tcisli305500 fact on fact.t_sfcp = lfact.t_sfcp and fact.t_tran = lfact.t_tran and fact.t_idoc = lfact.t_idoc where lfact.t_orno = donos.t_orno and lfact.t_srtp = 60 and fact.t_idat between @datetrans_f and @datetrans_t) as MontantHTFactures 
from tbptmm130500 donos --Données des Ordres de Service
inner join ttssoc200500 os on os.t_orno = donos.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = donos.t_orno and lpresta.t_acln = donos.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = donos.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttttxt002500 txt on txt.t_ctxt = apl.t_txtk --Textes du Dernier Commentaire
where left(donos.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
--and donos.t_peri between datepart(dayofyear, @datetrans_f) and datepart(dayofyear, @datetrans_t) --Bornage sur le jour
--and donos.t_year between datepart(year, @datetrans_f) and datepart(year, @datetrans_t) --Bornage sur l'année
and donos.t_stdt between @datetrans_f and @datetrans_t --Bornage sur la date d'enregistrement
and donos.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and apl.t_ccll between @appel_f and @appel_t --Bornage sur le Numéro d'Appel
and apl.t_rpct between @datesig_f and @datesig_t --Bornage sur la Date de Signalisation
and apl.t_stat between @statapl_f and @statapl_t --Bornage sur le Statut de l'Appel
and apl.t_cvtm between @couv_f and @couv_t --Bornage sur la Durée de Couverture
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
) union all
(select 'Autre' as Source, 
cmao.t_orno as OrdreService, 
cmao.t_lino as LigneOrdreService, 
cmao.t_acln as LignePrestation, 
substring(cmao.t_orno, 3, 1) as TypeService, 
dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS, 
os.t_cprj as ProjetOS, 
apl.t_ccll as NumeroAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.cllo',apl.t_cllo,'4') as OrigineAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.stat',apl.t_stat,'4') as StatutAppel, 
left(apl.t_item, 9) as ProjetAppel, 
apl.t_shpd as DescriptionAppel, 
txt.t_ludt as DateCommentaire, 
dbo.textnumtotext(apl.t_txtk,'4') as DernierCommentaire, 
apl.t_rpct as SignaleA, 
gar.t_optm as DateInstallation, 
year(gar.t_optm) as AnneeInstallation, 
(case 
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
end) as ExpirationConditionLe, 
'' as VehiculeSousGarantie, --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
cde.t_otbp as TiersVendeur, 
tiersv.t_nama as NomTiersVendeur, 
--reca.t_iamt as MontantFactureHA, 
(select sum(reca2.t_iamt) from ttdpur430500 reca2 where reca2.t_orno = reca.t_orno and reca2.t_pono = reca.t_pono) as MontantFactureHA, 
--recr.t_damt as Cout, --Cout : Mat MO Autre
(select sum(recr2.t_damt) from ttdpur406500 recr2 where recr2.t_orno = recr.t_orno and recr2.t_pono = recr.t_pono and recr2.t_ddte between @datetrans_f and @datetrans_t) as Cout, 
recr.t_ddte as DateTransaction, 
dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation, 
tiers.t_nama as NomTiersAcheteur, 
lpresta.t_sern as NumeroSerie, 
lpresta.t_cctp as TypeCouverture, 
gar.t_gwte as GarantieGenerique, 
gargen.t_desc as DescriptionGarantie, 
os.t_aftm as DateFinOS, 
os.t_cbrn as SecteurActivite, 
(select round(sum(lfact.t_amti), 2) from tcisli310500 lfact inner join tcisli305500 fact on fact.t_sfcp = lfact.t_sfcp and fact.t_tran = lfact.t_tran and fact.t_idoc = lfact.t_idoc where lfact.t_orno = cmao.t_orno and lfact.t_srtp = 60 and fact.t_idat between @datetrans_f and @datetrans_t) as MontantHTFactures 
from ttssoc240500 cmao --Autres Coûts de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = cmao.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = cmao.t_orno and lpresta.t_acln = cmao.t_acln --Prestations d'Ordre de Service
--inner join ttsmdm400500 ordr on ordr.t_orno = cmao.t_orno and ordr.t_apln = cmao.t_acln and ordr.t_orig = 5 and ordr.t_cotp = 25 --Service - Relations de l'Ordre ; Origine de l'Ordre = Ordre de Service (5) ; Type de Couts = Autres (35)
--inner join ttdpur406500 recr on recr.t_orno = ordr.t_rono and recr.t_pono = ordr.t_reln --Réceptions Réelles de Commandes
--inner join ttdpur430500 reca on reca.t_orno = ordr.t_rono and reca.t_pono = ordr.t_reln --Réceptions d'Achats à Payer pour les Commandes
inner join ttsmdm400500 ordr on ordr.t_orno = cmao.t_orno and ordr.t_apln = cmao.t_acln and ordr.t_orig = 5 and (ordr.t_cotp = 35 or ordr.t_cotp = 25) --Service - Relations de l'Ordre ; Origine de l'Ordre = Ordre de Service (5) ; Type de Couts = Autres (35) ou Sous-Traitance (25)
left outer join ttdpur406500 recr on recr.t_orno = ordr.t_rono and recr.t_pono = ordr.t_reln and recr.t_ddte between @datetrans_f and @datetrans_t and recr.t_sqnb = (select top 1 recr2.t_sqnb from ttdpur406500 recr2 where recr2.t_orno = recr.t_orno and recr2.t_pono = recr.t_pono order by recr2.t_sqnb desc) --Réceptions Réelles de Commandes
left outer join ttdpur430500 reca on reca.t_orno = ordr.t_rono and reca.t_pono = ordr.t_reln and reca.t_sqnb = (select top 1 reca2.t_sqnb from ttdpur430500 reca2 where reca2.t_orno = reca.t_orno and reca2.t_pono = reca.t_pono order by reca2.t_sqnb desc) --Réceptions d'Achats à Payer pour les Commandes
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = cmao.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttttxt002500 txt on txt.t_ctxt = apl.t_txtk --Textes du Dernier Commentaire
left outer join ttdpur400500 cde on cde.t_orno = ordr.t_rono --Commandes Fournisseurs
left outer join ttccom100500 tiersv on tiersv.t_bpid = cde.t_otbp --Tiers Vendeur
where left(cmao.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and cmao.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and apl.t_ccll between @appel_f and @appel_t --Bornage sur le Numéro d'Appel
and apl.t_rpct between @datesig_f and @datesig_t --Bornage sur la Date de Signalisation
and apl.t_stat between @statapl_f and @statapl_t --Bornage sur le Statut de l'Appel
and apl.t_cvtm between @couv_f and @couv_t --Bornage sur la Durée de Couverture
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
)
else
(select 'Matiere' as Source, 
cmat.t_orno as OrdreService, 
cmat.t_lino as LigneOrdreService, 
cmat.t_acln as LignePrestation, 
substring(cmat.t_orno, 3, 1) as TypeService, 
dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS, 
os.t_cprj as ProjetOS, 
apl.t_ccll as NumeroAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.cllo',apl.t_cllo,'4') as OrigineAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.stat',apl.t_stat,'4') as StatutAppel, 
left(apl.t_item, 9) as ProjetAppel, 
apl.t_shpd as DescriptionAppel, 
txt.t_ludt as DateCommentaire, 
dbo.textnumtotext(apl.t_txtk,'4') as DernierCommentaire, 
apl.t_rpct as SignaleA, 
gar.t_optm as DateInstallation, 
year(gar.t_optm) as AnneeInstallation, 
(case 
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
end) as ExpirationConditionLe, 
'' as VehiculeSousGarantie, --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
'' as TiersVendeur, 
'' as NomTiersVendeur, 
'0' as MontantFactureHA, 
cmat.t_amnt_1 as Cout, --Cout : Mat MO Autre
cmat.t_adtm as DateTransaction, 
dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation, 
tiers.t_nama as NomTiersAcheteur, 
lpresta.t_sern as NumeroSerie, 
lpresta.t_cctp as TypeCouverture, 
gar.t_gwte as GarantieGenerique, 
gargen.t_desc as DescriptionGarantie, 
os.t_aftm as DateFinOS, 
os.t_cbrn as SecteurActivite, 
(select round(sum(lfact.t_amti), 2) from tcisli310500 lfact inner join tcisli305500 fact on fact.t_sfcp = lfact.t_sfcp and fact.t_tran = lfact.t_tran and fact.t_idoc = lfact.t_idoc where lfact.t_orno = cmat.t_orno and lfact.t_srtp = 60 and fact.t_idat between @datetrans_f and @datetrans_t) as MontantHTFactures 
from ttssoc220500 cmat --Coûts Matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = cmat.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = cmat.t_orno and lpresta.t_acln = cmat.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = cmat.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttttxt002500 txt on txt.t_ctxt = apl.t_txtk --Textes du Dernier Commentaire
where left(cmat.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and cmat.t_dltp != 28 --Cas des livraisons autre que directes
and cmat.t_adtm between @datetrans_f and @datetrans_t --Bornage sur la Date de Livraison Réelle
and cmat.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
) union all
(select 'Matiere' as Source, 
cmat.t_orno as OrdreService, 
cmat.t_lino as LigneOrdreService, 
cmat.t_acln as LignePrestation, 
substring(cmat.t_orno, 3, 1) as TypeService, 
dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS, 
os.t_cprj as ProjetOS, 
apl.t_ccll as NumeroAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.cllo',apl.t_cllo,'4') as OrigineAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.stat',apl.t_stat,'4') as StatutAppel, 
left(apl.t_item, 9) as ProjetAppel, 
apl.t_shpd as DescriptionAppel, 
txt.t_ludt as DateCommentaire, 
dbo.textnumtotext(apl.t_txtk,'4') as DernierCommentaire, 
apl.t_rpct as SignaleA, 
gar.t_optm as DateInstallation, 
year(gar.t_optm) as AnneeInstallation, 
(case 
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
end) as ExpirationConditionLe, 
'' as VehiculeSousGarantie, --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
'' as TiersVendeur, 
'' as NomTiersVendeur, 
'0' as MontantFactureHA, 
cmat.t_amnt_1 as Cout, --Cout : Mat MO Autre
cmat.t_adtm as DateTransaction, 
dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation, 
tiers.t_nama as NomTiersAcheteur, 
lpresta.t_sern as NumeroSerie, 
lpresta.t_cctp as TypeCouverture, 
gar.t_gwte as GarantieGenerique, 
gargen.t_desc as DescriptionGarantie, 
os.t_aftm as DateFinOS, 
os.t_cbrn as SecteurActivite, 
(select round(sum(lfact.t_amti), 2) from tcisli310500 lfact inner join tcisli305500 fact on fact.t_sfcp = lfact.t_sfcp and fact.t_tran = lfact.t_tran and fact.t_idoc = lfact.t_idoc where lfact.t_orno = cmat.t_orno and lfact.t_srtp = 60 and fact.t_idat between @datetrans_f and @datetrans_t) as MontantHTFactures 
from ttssoc220500 cmat --Coûts Matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = cmat.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = cmat.t_orno and lpresta.t_acln = cmat.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = cmat.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttttxt002500 txt on txt.t_ctxt = apl.t_txtk --Textes du Dernier Commentaire
where left(cmat.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and cmat.t_dltp = 28 --Cas des livraisons directes
and cmat.t_artm between @datetrans_f and @datetrans_t --Bornage sur la Date de Livraison Réelle
and cmat.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
) union all
(select 'Main Oeuvre' as Source, 
donos.t_orno as OrdreService, 
donos.t_lbln as LigneOrdreService, 
donos.t_acln as LignePrestation, 
substring(donos.t_orno, 3, 1) as TypeService, 
dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS, 
os.t_cprj as ProjetOS, 
apl.t_ccll as NumeroAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.cllo',apl.t_cllo,'4') as OrigineAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.stat',apl.t_stat,'4') as StatutAppel, 
left(apl.t_item, 9) as ProjetAppel, 
apl.t_shpd as DescriptionAppel, 
txt.t_ludt as DateCommentaire, 
dbo.textnumtotext(apl.t_txtk,'4') as DernierCommentaire, 
apl.t_rpct as SignaleA, 
gar.t_optm as DateInstallation, 
year(gar.t_optm) as AnneeInstallation, 
(case 
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
end) as ExpirationConditionLe, 
'' as VehiculeSousGarantie, --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
'' as TiersVendeur, 
'' as NomTiersVendeur, 
'0' as MontantFactureHA, 
(donos.t_hrea * @tauxhoraire) as Cout, --Cout : Mat MO Autre
dateadd(day, donos.t_peri - 1, dateadd(year, donos.t_year - 1, cast('01/01/0001' as date))) as DateTransaction, 
dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation, 
tiers.t_nama as NomTiersAcheteur, 
lpresta.t_sern as NumeroSerie, 
lpresta.t_cctp as TypeCouverture, 
gar.t_gwte as GarantieGenerique, 
gargen.t_desc as DescriptionGarantie, 
os.t_aftm as DateFinOS, 
os.t_cbrn as SecteurActivite, 
(select round(sum(lfact.t_amti), 2) from tcisli310500 lfact inner join tcisli305500 fact on fact.t_sfcp = lfact.t_sfcp and fact.t_tran = lfact.t_tran and fact.t_idoc = lfact.t_idoc where lfact.t_orno = donos.t_orno and lfact.t_srtp = 60 and fact.t_idat between @datetrans_f and @datetrans_t) as MontantHTFactures 
from tbptmm130500 donos --Données des Ordres de Service
inner join ttssoc200500 os on os.t_orno = donos.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = donos.t_orno and lpresta.t_acln = donos.t_acln --Prestations d'Ordre de Service
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = donos.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttttxt002500 txt on txt.t_ctxt = apl.t_txtk --Textes du Dernier Commentaire
where left(donos.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
--and donos.t_peri between datepart(dayofyear, @datetrans_f) and datepart(dayofyear, @datetrans_t) --Bornage sur le jour
--and donos.t_year between datepart(year, @datetrans_f) and datepart(year, @datetrans_t) --Bornage sur l'année
and donos.t_stdt between @datetrans_f and @datetrans_t --Bornage sur la date d'enregistrement
and donos.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
) union all
(select 'Autre' as Source, 
cmao.t_orno as OrdreService, 
cmao.t_lino as LigneOrdreService, 
cmao.t_acln as LignePrestation, 
substring(cmao.t_orno, 3, 1) as TypeService, 
dbo.convertenum('ts','B61C','a9','bull','soc.osta',os.t_osta,'4') as StatutOS, 
os.t_cprj as ProjetOS, 
apl.t_ccll as NumeroAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.cllo',apl.t_cllo,'4') as OrigineAppel, 
dbo.convertenum('ts','B61C','a9','bull','clm.stat',apl.t_stat,'4') as StatutAppel, 
left(apl.t_item, 9) as ProjetAppel, 
apl.t_shpd as DescriptionAppel, 
txt.t_ludt as DateCommentaire, 
dbo.textnumtotext(apl.t_txtk,'4') as DernierCommentaire, 
apl.t_rpct as SignaleA, 
gar.t_optm as DateInstallation, 
year(gar.t_optm) as AnneeInstallation, 
(case 
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
end) as ExpirationConditionLe, 
'' as VehiculeSousGarantie, --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
cde.t_otbp as TiersVendeur, 
tiersv.t_nama as NomTiersVendeur, 
--reca.t_iamt as MontantFactureHA, 
(select sum(reca2.t_iamt) from ttdpur430500 reca2 where reca2.t_orno = reca.t_orno and reca2.t_pono = reca.t_pono) as MontantFactureHA, 
--recr.t_damt as Cout, --Cout : Mat MO Autre
(select sum(recr2.t_damt) from ttdpur406500 recr2 where recr2.t_orno = recr.t_orno and recr2.t_pono = recr.t_pono and recr2.t_ddte between @datetrans_f and @datetrans_t) as Cout, 
recr.t_ddte as DateTransaction, 
dbo.convertenum('ts','B61C','a9','bull','tdm.wrtp',lpresta.t_wrtp,'4') as GarantiePrestation, 
tiers.t_nama as NomTiersAcheteur, 
lpresta.t_sern as NumeroSerie, 
lpresta.t_cctp as TypeCouverture, 
gar.t_gwte as GarantieGenerique, 
gargen.t_desc as DescriptionGarantie, 
os.t_aftm as DateFinOS, 
os.t_cbrn as SecteurActivite, 
(select round(sum(lfact.t_amti), 2) from tcisli310500 lfact inner join tcisli305500 fact on fact.t_sfcp = lfact.t_sfcp and fact.t_tran = lfact.t_tran and fact.t_idoc = lfact.t_idoc where lfact.t_orno = cmao.t_orno and lfact.t_srtp = 60 and fact.t_idat between @datetrans_f and @datetrans_t) as MontantHTFactures 
from ttssoc240500 cmao --Autres Coûts de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = cmao.t_orno --Ordres de Services
inner join ttssoc210500 lpresta on lpresta.t_orno = cmao.t_orno and lpresta.t_acln = cmao.t_acln --Prestations d'Ordre de Service
--inner join ttsmdm400500 ordr on ordr.t_orno = cmao.t_orno and ordr.t_apln = cmao.t_acln and ordr.t_orig = 5 and ordr.t_cotp = 25 --Service - Relations de l'Ordre ; Origine de l'Ordre = Ordre de Service (5) ; Type de Couts = Autres (35)
--inner join ttdpur406500 recr on recr.t_orno = ordr.t_rono and recr.t_pono = ordr.t_reln --Réceptions Réelles de Commandes
--inner join ttdpur430500 reca on reca.t_orno = ordr.t_rono and reca.t_pono = ordr.t_reln --Réceptions d'Achats à Payer pour les Commandes
inner join ttsmdm400500 ordr on ordr.t_orno = cmao.t_orno and ordr.t_apln = cmao.t_acln and ordr.t_orig = 5 and (ordr.t_cotp = 35 or ordr.t_cotp = 25) --Service - Relations de l'Ordre ; Origine de l'Ordre = Ordre de Service (5) ; Type de Couts = Autres (35) ou Sous-Traitance (25)
left outer join ttdpur406500 recr on recr.t_orno = ordr.t_rono and recr.t_pono = ordr.t_reln and recr.t_ddte between @datetrans_f and @datetrans_t and recr.t_sqnb = (select top 1 recr2.t_sqnb from ttdpur406500 recr2 where recr2.t_orno = recr.t_orno and recr2.t_pono = recr.t_pono order by recr2.t_sqnb desc) --Réceptions Réelles de Commandes
left outer join ttdpur430500 reca on reca.t_orno = ordr.t_rono and reca.t_pono = ordr.t_reln and reca.t_sqnb = (select top 1 reca2.t_sqnb from ttdpur430500 reca2 where reca2.t_orno = reca.t_orno and reca2.t_pono = reca.t_pono order by reca2.t_sqnb desc) --Réceptions d'Achats à Payer pour les Commandes
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers
left outer join ttsclm100500 apl on apl.t_rsvo = cmao.t_orno --Table des Appels ; Bornage sur le numéro d'Appel, la date d'appel, le statut et la durée de couverture
left outer join ttscfg200500 gar on gar.t_item = lpresta.t_item and gar.t_sern = lpresta.t_sern --Articles Sérialisés
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttttxt002500 txt on txt.t_ctxt = apl.t_txtk --Textes du Dernier Commentaire
left outer join ttdpur400500 cde on cde.t_orno = ordr.t_rono --Commandes Fournisseurs
left outer join ttccom100500 tiersv on tiersv.t_bpid = cde.t_otbp --Tiers Vendeur
where left(cmao.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Service
and cmao.t_orno between @os_f and @os_t --Bornage sur le Numéro d'OS
and os.t_osta between @statos_f and @statos_t --Bornage sur le Statut de l'OS
)