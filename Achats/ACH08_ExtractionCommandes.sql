---------------------------------
-- ACH08 - Extraction Commandes
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--declare @cal as char(10);
--set @cal = 'LV0000001'
--declare @dispo as char(3);
--set @dispo = '001';

--Réorganisation de l'ordre et ajout des programmes d'achats le 15/11/2017
(select rec.t_cprj as Projet, 
substring(rec.t_item, 10, len(rec.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
rec.t_crit as ReferenceFournisseur, 
oa.t_cofc as ServiceAchat, 
(case left(oa.t_cofc, 2) 
when 'AC' 
	then 'Sanicar' 
when 'AD' 
	then 'Ducarme' 
when 'AL' 
	then 'Gifa' 
when 'AM' 
	then 'Gifa' 
when 'AP' 
	then 'PetitPicto' 
when 'EC' 
	then 'Electron' 
when 'LB' 
	then 'Labbe' 
when 'LV' 
	then 'Laval' 
when 'LY' 
	then 'Lyon' 
when 'PN' 
	then 'Paris Nord' 
when 'PS' 
	then 'Paris Sud' 
when 'SM' 
	then 'Lorraine' 
end) as SiteGruau, 
oa.t_otbp as Fournisseur, 
tier.t_nama as NomFournisseur, 
d.t_dats as FamilleAchat, 
e.t_dats as SousFamille, 
f.t_dats as Segment, 
rec.t_cdec as Incoterm, 
oa.t_ccon as Acheteur, 
emp.t_nama as NomAcheteur, 
appro.t_suti as DelaiApproContractuel, 
rec.t_pric as PrixUnitaire, 
priach.t_ltpr as DernierPrixAchat, 
achart.t_ccur as DeviseDernierPrixAchat, 
recach.t_qiiv as QuantiteFactureeUteAchat, 
rec.t_cuqp as UniteAchat, 
recach.t_iamt as PrixFacture, 
(case
when rec.t_ddte = '01/01/1970'
	then ''
	else year(rec.t_ddte)
end) as AnneeReception,
(case
when rec.t_ddte = '01/01/1970'
	then ''
	else month(rec.t_ddte)
end) as MoisReception, 
art.t_csig as CodeSignal, 
oa.t_orno as OrdreAchatProgramme, 
rec.t_pono as Position, 
rec.t_sqnb as Sequence, 
recach.t_rsqn as SequenceReception, 
sig.t_dsca as DescriptionSignal, 
rec.t_glco as ComptaGenerale,
oa.t_odat as DateOrdre
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
left outer join ttcmcs041500 cliv on cliv.t_cdec = oa.t_cdec --Conditions de Livraisons)
--Vérifier pour les dates vides
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
) 
union 
(select left(lpa.t_item, 9) as Projet, 
substring(lpa.t_item, 10, len(lpa.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
'' as ReferenceFournisseur, 
pa.t_cofc as ServiceAchat, 
(case left(pa.t_cofc, 2) 
when 'AC' 
	then 'Sanicar' 
when 'AD' 
	then 'Ducarme' 
when 'AL' 
	then 'Gifa' 
when 'AM' 
	then 'Gifa' 
when 'AP' 
	then 'PetitPicto' 
when 'EC' 
	then 'Electron' 
when 'LB' 
	then 'Labbe' 
when 'LV' 
	then 'Laval' 
when 'LY' 
	then 'Lyon' 
when 'PN' 
	then 'Paris Nord' 
when 'PS' 
	then 'Paris Sud' 
when 'SM' 
	then 'Lorraine' 
end) as SiteGruau, 
lpa.t_otbp as Fournisseur, 
tier.t_nama as NomFournisseur, 
d.t_dats as FamilleAchat, 
e.t_dats as SousFamille, 
f.t_dats as Segment, 
pa.t_cdec as Incoterm, 
pa.t_buyr as Acheteur, 
emp.t_nama as NomAcheteur, 
appro.t_suti as DelaiApproContractuel, 
(case 
when lpa.t_qior != 0
	then (lpa.t_samt / lpa.t_qior)
else 0
end) as PrixUnitaire, 
priach.t_ltpr as DernierPrixAchat, 
achart.t_ccur as DeviseDernierPrixAchat, 
recach.t_qiiv as QuantiteFactureeUteAchat, 
lpa.t_cuqp as UniteAchat, 
recach.t_iamt as PrixFacture, 
(case
when rec.t_rcld = '01/01/1970'
	then ''
	else year(rec.t_rcld)
end) as AnneeReception,
(case
when rec.t_rcld = '01/01/1970'
	then ''
	else month(rec.t_rcld)
end) as MoisReception, 
art.t_csig as CodeSignal, 
lpa.t_schn as OrdreAchatProgramme, 
lpa.t_spon as Position, 
'' as Sequence, 
rec.t_seqn as SequenceReception, 
sig.t_dsca as DescriptionSignal,
'' as ComptaGenerale,
pa.t_gdat as DateOrdre
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
--Vérifier pour les dates vides
where rec.t_rcld between @datercp_f and @datercp_t --Bornage sur la Date Réelle de Réception
--and rec.t_odat between @datecde_f and @datecde_t --Bornage sur la Date de Commande
--and rec.t_ddta between @dated_f and @dated_t --Bornage sur la Date de Réception Planifiée
and lpa.t_otbp between @tier_f and @tier_t --Bornage sur le Tiers Fournisseur
and left(lpa.t_item, 9) between @prj_f and @prj_t --Bornage sur le Projet
and lpa.t_schn between @ordre_f and @ordre_t --Bornage sur la Commande / Programme
and pa.t_cofc in (@serv) --Bornage sur le Service des Achats
and art.t_kitm in (@typ) --Bornage sur le Type Article
and left(lpa.t_schn, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le service des achats
)