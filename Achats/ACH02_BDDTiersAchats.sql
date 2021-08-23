-----------------------------
-- ACH02 - BDD Tiers Achats 
-----------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select emp.t_cwoc as ServiceAchat, 
tierven.t_seak as CritereTiersVendeur, 
tier.t_seak as CritereTiers, 
tier.t_bpid as CodeTiers, 
tier.t_nama as NomTiers, 
tierven.t_bpst as CodeStatutTiersVendeur, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tierven.t_bpst,'4') as StatutTiersVendeur, 
tierven.t_crdt as DateCreationTiersVendeur, 
tierven.t_cadr as CodeAdresseTiersVendeur, 
concat(adr.t_nama, ' ', adr.t_namb, ' ', adr.t_namc, ' ', adr.t_namd) as NomRue, 
adr.t_pstc as CodePostal, 
adr.t_ccty as Pays, 
adr.t_ccit as Ville, 
d.t_dats as FamilleAchat, 
e.t_dats as SousFamille, 
f.t_dats as Segment,
isnull(optattr.t_sern,'') as CodeSegment,
tierven.t_ccon as Acheteur, 
emp.t_nama as NomAcheteur, 
tva.t_fovn as NumeroTVA, 
tier.t_lgid as NumRegistreCommerce, 
tier.t_cmid as Duns, 
(select count(arttier.t_item) from ttdipu010500 arttier where arttier.t_otbp = tierven.t_otbp and arttier.t_exdt > getdate() and left(t_item, 9) = '         ') as NombreArticlesStandardsActifs, 
(select count(arttier.t_item) from ttdipu010500 arttier where arttier.t_otbp = tierven.t_otbp and arttier.t_exdt > getdate() and left(t_item, 9) = '         ' and arttier.t_pref = 2) as DontSourceUnique, 
(select count(arttier.t_item) from ttdipu010500 arttier where arttier.t_otbp = tierven.t_otbp and arttier.t_exdt < getdate() and left(t_item, 9) = '         ') as NombreArticlesExpires, 
grpcouttar.t_ccos as GroupeCout, 
grpcout.t_dsca as DescriptionGroupeCout, 
tiersfact.t_cpay as ConditionReglement, 
condregl.t_dsca as DescriptionConditionReglement, 
tiersfact.t_paym as MethodeReglement, 
methregl.t_desc as DescriptionMethodeReglement, 
tierven.t_cdec as ConditionLivraison, 
condliv.t_dsca as DescriptionConditionLivraison, 
(case
when @socfin = '500'
	then (select sum(d.t_amth_1) as t_amth_1 from ttfacp200500 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '400'
	then (select sum(d.t_amth_1) as t_amth_1 from ttfacp200400 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '600'
	then (select sum(d.t_amth_1) as t_amth_1 from ttfacp200600 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '610'
	then (select sum(d.t_amth_1) as t_amth_1 from ttfacp200610 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '620'
	then (select sum(d.t_amth_1) as t_amth_1 from ttfacp200620 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '630'
	then (select sum(d.t_amth_1) as t_amth_1 from ttfacp200630 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '300'
	then (select sum(d.t_amth_1) as t_amth_1 from ttfacp200300 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
else '0' 
end) as SocieteMontant, 
(select sum(t_amth_1) from 
(select sum(d.t_amth_1) as t_amth_1 from ttfacp200500 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4) 
union 
select sum(d.t_amth_1) as t_amth_1 from ttfacp200400 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union 
select sum(d.t_amth_1) as t_amth_1 from ttfacp200600 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union 
select sum(d.t_amth_1) as t_amth_1 from ttfacp200610 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union 
select sum(d.t_amth_1) as t_amth_1 from ttfacp200620 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union 
select sum(d.t_amth_1) as t_amth_1 from ttfacp200630 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union 
select sum(d.t_amth_1) as t_amth_1 from ttfacp200300 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)) as temp) as GroupeMontant, 
(case
when @socfin = '500'
	then (select sum(d.t_vath_1) as t_vath_1 from ttfacp200500 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '400'
	then (select sum(d.t_vath_1) as t_vath_1 from ttfacp200400 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '600'
	then (select sum(d.t_vath_1) as t_vath_1 from ttfacp200600 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '610'
	then (select sum(d.t_vath_1) as t_vath_1 from ttfacp200610 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '620'
	then (select sum(d.t_vath_1) as t_vath_1 from ttfacp200620 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '630'
	then (select sum(d.t_vath_1) as t_vath_1 from ttfacp200630 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
when @socfin = '300'
	then (select sum(d.t_vath_1) as t_vath_1 from ttfacp200300 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4))
else '0' 
end) as SocieteTotalTVA, 
(select sum(t_vath_1) from
(select sum(d.t_vath_1) as t_vath_1 from ttfacp200500 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4) 
union
select sum(d.t_vath_1) as t_vath_1 from ttfacp200400 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union
select sum(d.t_vath_1) as t_vath_1 from ttfacp200600 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union
select sum(d.t_vath_1) as t_vath_1 from ttfacp200610 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union
select sum(d.t_vath_1) as t_vath_1 from ttfacp200620 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union
select sum(d.t_vath_1) as t_vath_1 from ttfacp200630 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)
union
select sum(d.t_vath_1) as t_vath_1 from ttfacp200300 d where d.t_otbp = tierven.t_otbp and d.t_docd between @daterecfac_f and @daterecfac_t and d.t_tpay in (1,4)) as temp) as GroupeTotalTVA 
from ttccom120500 tierven --Tiers Vendeur
inner join ttccom100500 tier on tier.t_bpid = tierven.t_otbp --Tiers
inner join ttccom130500 adr on adr.t_cadr = tierven.t_cadr --Adresses
left outer join ttdsmi101500 d on d.t_bpid = tier.t_bpid and d.t_role = 7 and d.t_sern = 1 
left outer join ttdsmi101500 e on e.t_bpid = tier.t_bpid and e.t_role = 7 and e.t_sern = 2 
left outer join ttdsmi101500 f on f.t_bpid = tier.t_bpid and f.t_role = 7 and f.t_sern = 3 
left outer join ttdsmi051500 optattr on optattr.t_cfea = f.t_cfea and optattr.t_opti = f.t_dats --Options par attribut
left outer join ttccom001500 emp on tierven.t_ccon = emp.t_emno --Employés
left outer join ttctax400500 tva on tva.t_ccty = adr.t_ccty and tva.t_bpid = tier.t_bpid --Numéro de TVA
left outer join ttdpur027500 grpcouttar on grpcouttar.t_otbp = tierven.t_otbp --Groupe de coûts par tarif d'achat/tiers vendeur
left outer join ttdpur024500 grpcout on grpcout.t_ccos = grpcouttar.t_ccos --Groupe de Coûts
left outer join ttccom122500 tiersfact on tiersfact.t_ifbp = tierven.t_otbp --Tiers Facturant
left outer join ttcmcs013500 condregl on condregl.t_cpay = tiersfact.t_cpay --Conditions de Règlements
left outer join ttfcmg003500 methregl on methregl.t_paym = tiersfact.t_paym --Méthodes de Règlements
left outer join ttcmcs041500 condliv on condliv.t_cdec = tierven.t_cdec --Condition de Livraison
where tierven.t_bpst between @stat_f and @stat_t --Statut Tiers
and tier.t_bpid between @four_f and @four_t --Bornage sur le Fournisseur