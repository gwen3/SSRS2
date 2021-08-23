---------------------------------------
-- ACH01 - OTD Lead Time Productivité
---------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/*
declare @ue_f as char(10) = 'LV';
declare @ue_t as char(10) = 'LV';
declare @datecde_f date = DATEADD(DD, -360, CAST(CURRENT_TIMESTAMP AS DATE));
declare @datecde_t date = DATEADD(DD, 1, CAST(CURRENT_TIMESTAMP AS DATE));
declare @dated_f date = DATEADD(DD, -360, CAST(CURRENT_TIMESTAMP AS DATE));
declare @dated_t date = DATEADD(DD, 1, CAST(CURRENT_TIMESTAMP AS DATE));
declare @datercp_f date = DATEADD(DD, -360, CAST(CURRENT_TIMESTAMP AS DATE));
declare @datercp_t date = DATEADD(DD, 1, CAST(CURRENT_TIMESTAMP AS DATE));
declare @tier_f nvarchar(9) = ' ';
declare @tier_t nvarchar(9) = 'ZZZZZZZZZ';
declare @prj_f nvarchar(9) = ' ';
declare @prj_t nvarchar(9) = 'ZZZZZZZZZ';
declare @ordre_f nvarchar(9) = ' ';
declare @ordre_t nvarchar(9) = 'ZZZZZZZZZ';
declare @serv nvarchar(256) = 'LVA001';
declare @typ int = 1;
declare @artu nvarchar(256) = '1, 2, 3';
declare @soufam nvarchar(256) = '1, 2, 3';
declare @cal as char(10) = 'LV0000001';
declare @dispo as char(3) = '001';
*/

(select rec.t_cprj as Projet
,substring(rec.t_item, 10, len(rec.t_item)) as Article
,art.t_dsca as DescriptionArticle
,oa.t_cofc as ServiceAchat
,oa.t_otbp as Fournisseur
,tier.t_nama as NomFournisseur
,d.t_dats as FamilleAchat
,e.t_dats as SousFamille
,f.t_dats as Segment
,oa.t_plnr as CodeApprovisionneur
,rec.t_cdec as Incoterm
,oa.t_ccon as Acheteur
,emp.t_nama as NomAcheteur
,rec.t_corg as CodeOrigineCde
,dbo.convertenum('td','B61C','a9','bull','pur.corg',rec.t_corg,'4') as OrigineCde
,oa.t_orno as OrdreAchatProgramme
,rec.t_pono as Position
,rec.t_sqnb as Sequence
,recach.t_rsqn as SequenceReception
,rec.t_cono as NumContratAchat
,rec.t_cpon as PositionContrat
,art.t_dcre as DateCreationArticle
,appro.t_suti as DelaiApproContractuel
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,art.t_csig as CodeSignal
,sig.t_dsca as DescriptionSignal
,oa.t_odat as DateOrdre
,rec.t_ddta as DateRecCourantePlanifiee
,rec.t_ddtc as DateRecConfirmee
,rec.t_ddtd as DateRecModifiee
,rec.t_ddte as DateReelleReception
,rec.t_qoor as QuantiteCommandee
,rec.t_cuqp as UniteAchat
,rec.t_pric as PrixUnitaire
,(case
when (cdeappr.t_toma != 1) 
	then cdeappr.t_amth_1 
else '' 
end) as CACommande
,rec.t_qidl as QuantiteLivree
,art.t_cuni as Unite
,recach.t_qiiv as QuantiteFactureeUteAchat
,(case 
when art.t_cuni = rec.t_cuqp
	then 1
else
	isnull(faconv.t_conv, (select faconvgen.t_conv from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_basu = art.t_cuni and faconvgen.t_unit = rec.t_cuqp)) 
end) as FacteurConv
,recach.t_iamt as PrixFacturee
,(case
when (cdeappr.t_toma = 1)
	then (select sum(a.t_amth_1) from ttfacp251500 a where (a.t_otyp = cdeappr.t_otyp and a.t_orno = cdeappr.t_orno and a.t_pono = cdeappr.t_pono and a.t_sqnb = cdeappr.t_sqnb and a.t_loco = cdeappr.t_loco))
else (select top 1 '' from ttfacp251500 a where (cdeappr.t_otyp = a.t_otyp and cdeappr.t_orno = a.t_orno and cdeappr.t_pono = a.t_pono and cdeappr.t_sqnb = a.t_sqnb and cdeappr.t_loco = a.t_loco)) 
end) as CAPaye
,rec.t_revi as Indice
,year(rec.t_ddte) as AnneeReception
,month(rec.t_ddte) as MoisReception
,'' as CritereCAPaye
,priach.t_ltpr as DernierPrixAchat
,achart.t_ccur as DeviseDernierPrixAchat
,priach.t_ltpp as DateDernierPrixAchat
,dbo.convertenum('td','B61C','a9','bull','gen.oltp',rec.t_oltp,'4') as TypeLigne
,oa.t_cdec as ConditionLivraison
,cliv.t_dsca as DescriptionConditionLivraison
,(case 
--Cas où la date de réception confirmée n'est pas renseignée (01/01/1970), on prend alors la date de réception courante planifiée
when rec.t_ddtc < '01/01/1980'
	then (case 
	--Cas où la date de réception courante planifiée est inférieure à la date réelle de réception
	when rec.t_ddta < rec.t_ddte
		then (select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between rec.t_ddta and rec.t_ddte)
	--Lorsqu'elle est supérieure, ça veut dire que la livraison a été faite avant la date prévue. On prend alors le négatif des jours ouvrés entre les 2 dates.
	else - (select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between rec.t_ddte and rec.t_ddta)
	end)
else (case 
	when rec.t_ddtc < rec.t_ddte
		then (select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between rec.t_ddtc and rec.t_ddte)
	--Lorsqu'elle est supérieure, ça veut dire que la livraison a été faite avant la date prévue. On prend alors le négatif des jours ouvrés entre les 2 dates.
	else - (select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between rec.t_ddte and rec.t_ddtc)
	end)
end) as EcartEngagementFournisseur
,'' as OTDEngagementFournisseur --On ne le calcul pas en SQL car cela oblige à répéter tout le calcul précédent alors qu'il ne faut que 2 lignes en SSRS (Si EcartEngagementFournisseur <= 0 alors 1, sinon 0)
,(case 
--Cas où la date de réception courante planifiée est inférieure à la date réelle de réception
when rec.t_ddta < rec.t_ddte
	then (select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between rec.t_ddta and rec.t_ddte) 
--Lorsqu'elle est supérieure, ça veut dire que la livraison a été faite avant la date prévue. On prend alors le négatif des jours ouvrés entre les 2 dates.
else - (select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between rec.t_ddte and rec.t_ddta) 
end) as EcartDelaiDemande
,(case 
when (case 
	--Cas où la date de réception courante planifiée est inférieure à la date réelle de réception
	when rec.t_ddta < rec.t_ddte 
		then (select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between rec.t_ddta and rec.t_ddte) 
	--Lorsqu'elle est supérieure, ça veut dire que la livraison a été faite avant la date prévue. On prend alors le négatif des jours ouvrés entre les 2 dates.
	else - (select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between rec.t_ddte and rec.t_ddta) 
	end) <= 0 
	then 1 
else 0 
end) as OTDDelaiDemande
,((select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between oa.t_odat and rec.t_ddte) - appro.t_suti) as EcartDelaiStandard
,(case 
--On calcul le nombre de jours ouvrés entre le délai contractuel et la date réelle de réception, puis on le compare par rapport au délai contractuel. Si inférieur ou égal à 0, on affiche 1, sinon on affiche 0
when ((select count(*) from ttcccp020500 cal where cal.t_ccal = @cal and cal.t_ract = @dispo and cal.t_avlb = 1 and cal.t_date between oa.t_odat and rec.t_ddte) - appro.t_suti) <= 0
	then 1
else 0
end) as OTDDelaiStandard
,rec.t_crit as ReferenceFournisseur
,rec.t_pseq as SequenceMere
,concat(oa.t_orno, right(replicate('0',4) + cast(rec.t_pono as varchar(4)), 4), right(replicate('0',4) + cast(rec.t_sqnb as varchar(4)), 4)) as ClefLigne
,concat(oa.t_orno, right(replicate('0',4) + cast(rec.t_pono as varchar(4)), 4), right(replicate('0',4) + cast(rec.t_pseq as varchar(4)), 4)) as ClefMere
,'=SI(BH2=0;AA2;RECHERCHEV(BJ2;BI:BK;3;FAUX))' as DatePlanifiee
,art.t_ctyp as TypeProduit
,oa.t_cpay as ConditionReglement
,cr.t_dsca as DescriptionConditionReglement
from ttdpur400500 oa --Commande Fournisseur
inner join ttccom100500 tier on tier.t_bpid = oa.t_otbp --Tiers
left outer join ttccom001500 emp on oa.t_ccon = emp.t_emno --Employés
inner join ttdpur401500 rec on rec.t_orno = oa.t_orno and (rec.t_oltp = 2 or rec.t_oltp = 3 or rec.t_oltp = 4) --Lignes de Commandes Fournisseur
inner join ttcibd001500 art on rec.t_item = art.t_item --Articles
left outer join ttdipu010500 appro on appro.t_item = art.t_item and appro.t_otbp = oa.t_otbp --Article - Achats Tiers
left outer join ttdsmi101500 d on d.t_bpid = oa.t_otbp and d.t_role = 7 and d.t_sern = 1 
left outer join ttdsmi101500 e on e.t_bpid = oa.t_otbp and e.t_role = 7 and e.t_sern = 2 
left outer join ttdsmi101500 f on f.t_bpid = oa.t_otbp and f.t_role = 7 and f.t_sern = 3 
left outer join ttdpur430500 recach on recach.t_orno = rec.t_orno and recach.t_pono = rec.t_pono and recach.t_sqnb = rec.t_sqnb --Receptions d'achat à payer pour les commandes
left outer join ttcmcs018500 sig on sig.t_csig = art.t_csig --Signal d'Articles
inner join ttfacp240500 cdeappr on cdeappr.t_orno = rec.t_orno and cdeappr.t_pono = rec.t_pono and cdeappr.t_sqnb = rec.t_sqnb and cdeappr.t_otyp = 1 
left outer join ttcibd003500 faconv on faconv.t_item = art.t_item and faconv.t_basu = art.t_cuni and faconv.t_unit = rec.t_cuqp --Facteur de Conversion
left outer join ttdipu001500 achart on achart.t_item = rec.t_item --Données d'Achat Article
left outer join ttdipu100500 priach on priach.t_item = rec.t_item --Prix d'achat Réel de l'article
left outer join ttcmcs041500 cliv on cliv.t_cdec = oa.t_cdec --Conditions de Livraisons
left outer join ttcmcs013500 cr on cr.t_cpay = oa.t_cpay --Conditions de Reglement
--left outer join ttfacp253500 fac on fac.t_orno = oa.t_orno and fac.t_pono = rec.t_pono and fac.t_sqnb = rec.t_sqnb --Facture liées aux achats de consommations
where rec.t_odat between @datecde_f and @datecde_t --Bornage sur la Date de Commande
and rec.t_ddta between @dated_f and @dated_t --Bornage sur la Date de Réception Planifiée
and rec.t_ddte between @datercp_f and @datercp_t --Bornage sur la Date Réelle de Réception
and oa.t_otbp between @tier_f and @tier_t --Bornage sur le Tiers Fournisseur
and rec.t_cprj between @prj_f and @prj_t --Bornage sur le Projet
and oa.t_orno between @ordre_f and @ordre_t --Bornage sur la Commande / Programme
and oa.t_cofc in (@serv) --Bornage sur le Service des Achats
and art.t_kitm in (@typ) --Bornage sur le Type Article
and substring(rec.t_item, 10, len(rec.t_item)) not like @artu --On exclu ou non les articles en U
and e.t_dats not like @soufam --On exclu ou non la sous famille d'achat FRN GROUPE GRUAU ET RESEAU
and left(oa.t_cofc, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le service des achats
--and fac.t_data between @data_f and @data_t --Bornage sur la date d'approbation
) 
--Partie tout ce qui touche aux programmes d'achats
union 
(select left(lpa.t_item, 9) as Projet
,substring(lpa.t_item, 10, len(lpa.t_item)) as Article
,art.t_dsca as DescriptionArticle
,pa.t_cofc as ServiceAchat
,lpa.t_otbp as Fournisseur
,tier.t_nama as NomFournisseur
,d.t_dats as FamilleAchat
,e.t_dats as SousFamille
,f.t_dats as Segment
,pa.t_plan as CodeApprovisionneur
,pa.t_cdec as Incoterm
,pa.t_buyr as Acheteur
,emp.t_nama as NomAcheteur
,'' as CodeOrigineCde
,'Programme Achat' as OrigineCde
,lpa.t_schn as OrdreAchatProgramme
,lpa.t_spon as Position
,'' as Sequence
,rec.t_seqn as SequenceReception
,pa.t_cono as NumContratAchat
,pa.t_pono as PositionContrat
,art.t_dcre as DateCreationArticle
,appro.t_suti as DelaiApproContractuel
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,art.t_csig as CodeSignal
,sig.t_dsca as DescriptionSignal
,isnull(va.t_egdt, rec.t_rcld) as DateOrdre
,isnull(lva.t_edat, rec.t_rcld) as DateRecCourantePlanifiee
,'' as DateRecConfirmee
,'' as DateRecModifiee
,rec.t_rcld as DateReelleReception
,lpa.t_qrrq as QuantiteCommandee
,lpa.t_cuqp as UniteAchat
,(case 
when lpa.t_qior != 0
	then (lpa.t_samt / lpa.t_qior)
else 0
end) as PrixUnitaire
,lpa.t_samt as CACommande
,recach.t_qipr as QuantiteLivree
,art.t_cuni as Unite
,recach.t_qiiv as QuantiteFactureeUteAchat
,lpa.t_cvrq as FacteurConv
,recach.t_iamt as PrixFacturee
,(select sum(a.t_amth_1) from ttfacp251500 a where (a.t_otyp = 1 and a.t_orno = lpa.t_schn and a.t_pono = lpa.t_spon and a.t_rcno = rec.t_rcno and a.t_data > '01/01/1990')) as CAPaye --On ne prend que ce qui a été approuvé (bornage sur la date d'approbation)
,lpa.t_revi as Indice
,year(rec.t_rcld) as AnneeReception
,month(rec.t_rcld) as MoisReception
,'' as CritereCAPaye
,priach.t_ltpr as DernierPrixAchat
,achart.t_ccur as DeviseDernierPrixAchat
,priach.t_ltpp as DateDernierPrixAchat
,'' as TypeLigne
,pa.t_cdec as ConditionLivraison
,cliv.t_dsca as DescriptionConditionLivraison
,'' as EcartEngagementFournisseur
,'' as OTDEngagementFournisseur
,'' as EcartDelaiDemande
,'' as OTDDelaiDemande
,'' as EcartDelaiStandard
,'' as OTDDelaiStandard
,rec.t_mpnr as ReferenceFournisseur
,'' as SequenceMere
,'' as ClefLigne
,'' as ClefMere
,'' as DatePlanifiee
,art.t_ctyp as TypeProduit 
,pa.t_cpay as ConditionReglement
,cr.t_dsca as DescriptionConditionReglement
from ttdpur311500 lpa --Lignes de Programmes d'Achats, la position dans la version d'achat ne correspond pas à celle du programme
inner join ttdpur310500 pa on pa.t_schn = lpa.t_schn and pa.t_styp = lpa.t_styp --Programmes d'Achats
left outer join ttdpur314500 lig on lig.t_schn = lpa.t_schn and lig.t_styp = lpa.t_styp and lig.t_spon = lpa.t_spon and lig.t_rlrv = (select top 1 lig2.t_rlrv from ttdpur314500 lig2 where lig2.t_schn = lig.t_schn and lig2.t_styp = lig.t_styp and lig2.t_spon = lig.t_spon) --Lignes de Programmes par Détails de Lignes de Lancement (lien entre le programme et la version)
left outer join ttdpur322500 lva on lva.t_rlno = lig.t_rlno and lva.t_rlrv = lig.t_rlrv and lva.t_rpon = lig.t_rpon and lva.t_posd = lig.t_posd --Lignes de Versions d'Achats
left outer join ttdpur320500 va on va.t_rlno = lig.t_rlno and va.t_rlrv = lig.t_rlrv --Versions d'Achat
left outer join ttdpur315500 rec on rec.t_schn = lpa.t_schn and rec.t_styp = lpa.t_styp and rec.t_spon = lpa.t_spon --Détails sur la Réception
inner join ttccom100500 tier on tier.t_bpid = lpa.t_otbp --Tiers
left outer join ttccom001500 emp on pa.t_buyr = emp.t_emno --Employés - Acheteur
inner join ttcibd001500 art on lpa.t_item = art.t_item --Articles
left outer join ttdipu010500 appro on appro.t_item = art.t_item and appro.t_otbp = lpa.t_otbp --Article - Achats Tiers
left outer join ttdsmi101500 d on d.t_bpid = lpa.t_otbp and d.t_role = 7 and d.t_sern = 1 
left outer join ttdsmi101500 e on e.t_bpid = lpa.t_otbp and e.t_role = 7 and e.t_sern = 2 
left outer join ttdsmi101500 f on f.t_bpid = lpa.t_otbp and f.t_role = 7 and f.t_sern = 3 
left outer join ttdipu001500 achart on achart.t_item = art.t_item --Données d'Achat Article
left outer join ttdipu100500 priach on priach.t_item = art.t_item --Prix d'achat Réel de l'article
left outer join ttcmcs018500 sig on sig.t_csig = art.t_csig --Signal d'Articles
left outer join ttdpur430500 recach on recach.t_orno = lpa.t_schn and recach.t_pono = lpa.t_spon and recach.t_rsqn = rec.t_seqn --Receptions d'achat à payer pour les commandes
left outer join ttcmcs041500 cliv on cliv.t_cdec = pa.t_cdec --Conditions de Livraisons
left outer join ttcmcs013500 cr on cr.t_cpay = pa.t_cpay --Conditions de Reglement
--left outer join ttfacp253500 fac on fac.t_orno = lpa.t_schn and fac.t_pono = lpa.t_spon --Facture liées aux achats de consommations
where rec.t_rcld between @datercp_f and @datercp_t --Bornage sur la Date Réelle de Réception
and isnull(va.t_egdt, rec.t_rcld) between @datecde_f and @datecde_t --Bornage sur la Date de Commande
and isnull(lva.t_edat, rec.t_rcld) between @dated_f and @dated_t --Bornage sur la Date de Réception Planifiée
and lpa.t_otbp between @tier_f and @tier_t --Bornage sur le Tiers Fournisseur
and left(lpa.t_item, 9) between @prj_f and @prj_t --Bornage sur le Projet
and lpa.t_schn between @ordre_f and @ordre_t --Bornage sur la Commande / Programme
and pa.t_cofc in (@serv) --Bornage sur le Service des Achats
and art.t_kitm in (@typ) --Bornage sur le Type Article
and left(lpa.t_schn, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le service des achats
--and fac.t_data between @data_f and @data_t --Bornage sur la date d'approbation
)