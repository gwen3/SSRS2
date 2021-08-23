-----------------------------
-- ACH02 - BDD Tiers Achats
-----------------------------

select emp.t_cwoc as ServiceAchat, 
tierven.t_seak as CritereTiersVendeur, 
tier.t_seak as CritereTiers, 
tier.t_bpid as CodeTiers, 
tier.t_nama as NomTiers, 
tierven.t_bpst as CodeStatutTiersVendeur, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tierven.t_bpst,'4') as StatutTiersVendeur, 
tierven.t_crdt as DateCreationTiersVendeur, 
tierven.t_cadr as CodeAdresseTiersVendeur, 
concat (adr.t_nama, ' ', adr.t_namb, ' ', adr.t_namc, ' ', adr.t_namd) as NomRue, 
adr.t_pstc as CodePostal, 
adr.t_ccty as Pays, 
adr.t_ccit as Ville, 
d.t_dats as FamilleAchat, 
e.t_dats as SousFamille, 
f.t_dats as Segment, 
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
(select (solde100.t_tovr_1 + solde100.t_tovr_1_1 + solde100.t_tovr_2_1 + solde100.t_tovr_3_1 + solde100.t_tovr_4_1) 
from ttccom123500 solde100 
where solde100.t_ifbp = tiersfact.t_ifbp and solde100.t_comp = '100' and solde100.t_cryr = year(getdate())) as CA100, 
(select (solde110.t_tovr_1 + solde110.t_tovr_1_1 + solde110.t_tovr_2_1 + solde110.t_tovr_3_1 + solde110.t_tovr_4_1) 
from ttccom123500 solde110 
where solde110.t_ifbp = tiersfact.t_ifbp and solde110.t_comp = '110' and solde110.t_cryr = year(getdate())) as CA110, 
(select (solde120.t_tovr_1 + solde120.t_tovr_1_1 + solde120.t_tovr_2_1 + solde120.t_tovr_3_1 + solde120.t_tovr_4_1) 
from ttccom123500 solde120 
where solde120.t_ifbp = tiersfact.t_ifbp and solde120.t_comp = '120' and solde120.t_cryr = year(getdate())) as CA120, 
(select (solde200.t_tovr_1 + solde200.t_tovr_1_1 + solde200.t_tovr_2_1 + solde200.t_tovr_3_1 + solde200.t_tovr_4_1) 
from ttccom123500 solde200 
where solde200.t_ifbp = tiersfact.t_ifbp and solde200.t_comp = '200' and solde200.t_cryr = year(getdate())) as CA200, 
(select (solde400.t_tovr_1 + solde400.t_tovr_1_1 + solde400.t_tovr_2_1 + solde400.t_tovr_3_1 + solde400.t_tovr_4_1) 
from ttccom123500 solde400 
where solde400.t_ifbp = tiersfact.t_ifbp and solde400.t_comp = '400' and solde400.t_cryr = year(getdate())) as CA400, 
(select (solde500.t_tovr_1 + solde500.t_tovr_1_1 + solde500.t_tovr_2_1 + solde500.t_tovr_3_1 + solde500.t_tovr_4_1) 
from ttccom123500 solde500 
where solde500.t_ifbp = tiersfact.t_ifbp and solde500.t_comp = '500' and solde500.t_cryr = year(getdate())) as CA500, 
(select (solde600.t_tovr_1 + solde600.t_tovr_1_1 + solde600.t_tovr_2_1 + solde600.t_tovr_3_1 + solde600.t_tovr_4_1) 
from ttccom123500 solde600 
where solde600.t_ifbp = tiersfact.t_ifbp and solde600.t_comp = '600' and solde600.t_cryr = year(getdate())) as CA600, 
(select (solde610.t_tovr_1 + solde610.t_tovr_1_1 + solde610.t_tovr_2_1 + solde610.t_tovr_3_1 + solde610.t_tovr_4_1) 
from ttccom123500 solde610 
where solde610.t_ifbp = tiersfact.t_ifbp and solde610.t_comp = '610' and solde610.t_cryr = year(getdate())) as CA610, 
(select (solde620.t_tovr_1 + solde620.t_tovr_1_1 + solde620.t_tovr_2_1 + solde620.t_tovr_3_1 + solde620.t_tovr_4_1) 
from ttccom123500 solde620 
where solde620.t_ifbp = tiersfact.t_ifbp and solde620.t_comp = '620' and solde620.t_cryr = year(getdate())) as CA620, 
(select (solde630.t_tovr_1 + solde630.t_tovr_1_1 + solde630.t_tovr_2_1 + solde630.t_tovr_3_1 + solde630.t_tovr_4_1) 
from ttccom123500 solde630 
where solde630.t_ifbp = tiersfact.t_ifbp and solde630.t_comp = '630' and solde630.t_cryr = year(getdate())) as CA630 
from ttccom120500 tierven --Tiers Vendeur
inner join ttccom100500 tier on tier.t_bpid = tierven.t_otbp --Tiers
inner join ttccom130500 adr on adr.t_cadr = tierven.t_cadr --Adresses
left outer join ttdsmi101500 d on d.t_bpid = tier.t_bpid and d.t_role = 7 and d.t_sern = 1 
left outer join ttdsmi101500 e on e.t_bpid = tier.t_bpid and e.t_role = 7 and e.t_sern = 2 
left outer join ttdsmi101500 f on f.t_bpid = tier.t_bpid and f.t_role = 7 and f.t_sern = 3 
left outer join ttccom001500 emp on tierven.t_ccon = emp.t_emno --Employés
left outer join ttctax400500 tva on tva.t_ccty = adr.t_ccty and tva.t_bpid = tier.t_bpid --Numéro de TVA
left outer join ttdpur027500 grpcouttar on grpcouttar.t_otbp = tierven.t_otbp --Groupe de coûts par tarif d'achat/tiers vendeur
left outer join ttdpur024500 grpcout on grpcout.t_ccos = grpcouttar.t_ccos --Groupe de Coûts
left outer join ttccom122500 tiersfact on tiersfact.t_ifbp = tierven.t_otbp --Tiers Facturant
left outer join ttcmcs013500 condregl on condregl.t_cpay = tiersfact.t_cpay --Conditions de Règlements
left outer join ttfcmg003500 methregl on methregl.t_paym = tiersfact.t_paym --Méthodes de Règlements
left outer join ttcmcs041500 condliv on condliv.t_cdec = tierven.t_cdec --Condition de Livraison
where tierven.t_bpst between @stat_f and @stat_t; --Statut Tiers