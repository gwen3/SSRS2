------------------------
-- COM09 - PIC Facturé
------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 'Facturé' as Source, 
'5' as CodeSource, 
livcde.t_invd as DateFacture, 
livcde.t_ttyp as TypeEcritureFinanciere, 
livcde.t_invn as NumeroFacture, 
cde.t_cofc as ServiceVente, 
cde.t_crep as RepresentantInterne, 
empa.t_nama as NomRepresentantInterne, 
lcde.t_odat as DateCommande, 
livcde.t_orno as CommandeClient, 
livcde.t_pono as Position, 
livcde.t_sqnb as Sequence, 
cde.t_sotp as TypeCommandeClient, 
left(lcde.t_item, 9) as Projet, 
substring(lcde.t_item, 10, len(lcde.t_item)) as Article, 
art.t_dsca as DescArticle, 
dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle, 
lcde.t_serl as NumeroSerie, 
lcdeart.t_citg as CodeGroupeArticle, 
substring(lcdeart.t_citg,1,2) as GroupeArticle, 
lcdeart.t_csgs as GroupeStatistiqueVente, 
lcdeart.t_cpcl as ClasseProduit, 
concat(cde.t_ofbp,' ',ofbp.t_nama) as TiersAcheteur, 
cde.t_corn as CommandeDuClient, 
lcde.t_qoor as QuantiteCommandee, 
(case 
when (livcde.t_qidl = 0) 
	then lcde.t_qoor - livcde.t_qidl 
else '0' 
end) as QuantiteALivrer, 
'' as QuantiteLivreeNonFacturee, 
livcde.t_qidl as QuantiteLivree, 
lcde.t_ddta as DateLivraisonPlanifiee, 
lcde.t_prdt as DateMADCPrevue, 
livcde.t_dldt as DateLivraisonReelle, 
cde.t_osrp as RepresentantExterne, 
empb.t_nama as NomRepresentantExterne, 
cde.t_creg as Zone, 
chan.t_dsca as DescriptionCanauxDistribution, 
marq.t_dsca as NomContremarque, 
concat(cde.t_clin,' ',clin.t_nama) as ClientIndirect, 
concat(cde.t_clfi,' ',clfi.t_nama) as ClientFinal, 
livcde.t_namt / lcde.t_rats_1 as MontantFacture, 
lcde.t_oamt / lcde.t_rats_1 as Montant, 
'0' / lcde.t_rats_1 as MontantAFacturer, 
cde.t_ccur as DeviseCommande, 
substring(cde.t_cofc,1,2) as UE 
from ttdsls406500 livcde --Lignes de Commandes Clients
left outer join ttdsls400500 cde on cde.t_orno = livcde.t_orno --Commandes Clients
left outer join ttdsls401500 lcde on lcde.t_orno = livcde.t_orno and lcde.t_pono = livcde.t_pono and lcde.t_sqnb = livcde.t_sqnb --Lignes de Livraison de Commandes Clients
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttdsls411500 lcdeart on lcdeart.t_orno = livcde.t_orno and lcdeart.t_pono = lcde.t_pono and lcdeart.t_sqnb = 0 --Données Articles de la Ligne de Commande
left outer join ttccom001500 empa on empa.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom001500 empb on empb.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join ttcmcs066500 chan on chan.t_chan = lcde.t_chan --Canaux de Distribution
left outer join tzgsls001500 marq on marq.t_cont = cde.t_cntr --Gestion des Contremarques
left outer join ttccom100500 clin on clin.t_bpid = cde.t_clin --Tiers - Client Indirect
left outer join ttccom100500 clfi on clfi.t_bpid = cde.t_clfi --Tiers - Client Final
left outer join ttccom100500 ofbp on ofbp.t_bpid = cde.t_ofbp --Tiers - Acheteur
where livcde.t_invd between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Facture
and livcde.t_invd <> '01/01/1970' --Bornage sur les Dates de Facture qui ne sont pas vides, autrement dit la facture existe
and left(cde.t_cofc, 2) between @ue_f and @ue_t --Bornage sur l'UE
--Rajout pour les Programmes de vente le 21/08/2017
union
select distinct 'Programme de Vente' as Source, 
'6' as CodeSource, 
fact.t_idat as DateFacture, 
fact.t_tran as TypeEcritureFinanciere, 
fact.t_idoc as NumeroFacture, 
fact.t_fdpt as ServiceVente, 
'' as RepresentantInterne, 
'' as NomRepresentantInterne, 
'' as DateCommande, 
'' as CommandeClient, 
'' as Position, 
'' as Sequence, 
'' as TypeCommandeClient, 
'' as Projet, 
'' as Article, 
'' as DescArticle, 
'' as TypeArticle, 
'' as NumeroSerie, 
(select top 1 art.t_citg from ttcibd001500 art where art.t_item = lfac.t_item) as CodeGroupeArticle, 
(select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lfac.t_item) as GroupeArticle, 
'' as GroupeStatistiqueVente, 
'' as ClasseProduit, 
concat(lfac.t_ofbp, ' ', tiers.t_nama) as TiersAcheteur, 
'' as CommandeDuClient, 
'' as QuantiteCommandee, 
'' as QuantiteALivrer, 
'' as QuantiteLivreeNonFacturee, 
(select sum(lfact.t_dqua) from tcisli310500 lfact where lfact.t_idoc = lfac.t_idoc and lfact.t_tran = lfac.t_tran and lfact.t_ofbp = lfac.t_ofbp and lfact.t_srtp = 40 and lfact.t_koor = 7) as QuantiteLivree, 
'' as DateLivraisonPlanifiee, 
'' as DateMADCPrevue, 
'' as DateLivraisonReelle, 
'' as RepresentantExterne, 
'' as NomRepresentantExterne, 
lfac.t_creg as Zone, 
'' as DescriptionCanauxDistribution, 
'' as NomContremarque, 
'' as ClientIndirect, 
'' as ClientFinal, 
(select sum(lfact.t_amti) from tcisli310400 lfact where lfact.t_idoc = lfac.t_idoc and lfact.t_tran = lfac.t_tran and lfact.t_ofbp = lfac.t_ofbp and lfact.t_srtp = 40 and lfact.t_koor = 7) as MontantFacture, 
(select sum(lfact.t_amti) from tcisli310400 lfact where lfact.t_idoc = lfac.t_idoc and lfact.t_tran = lfac.t_tran and lfact.t_ofbp = lfac.t_ofbp and lfact.t_srtp = 40 and lfact.t_koor = 7) as Montant, 
'0' as MontantAFacturer, 
fact.t_ccur as DeviseCommande, 
left(fact.t_fdpt, 2) as UE 
from tcisli305400 fact --Lignes de Commandes Clients
left outer join tcisli310400 lfac on lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Commandes Clients
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
where lfac.t_srtp = 40 --Bornage sur le type de source qui doit être Commande Client
and lfac.t_koor = 7 --Bornage sur le type de source qui doit être Programme de Vente
and fact.t_idat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Facture
and left(fact.t_fdpt, 2) between @ue_f and @ue_t --Bornage sur l'UE
--Rajout pour la bilatérale le 21/08/2017
union 
select 'Bilatérale' as Source, 
'7' as CodeSource, 
fact.t_idat as DateFacture, 
lfac.t_tran as TypeEcritureFinanciere, 
lfac.t_idoc as NumeroFacture, 
fact.t_fdpt as ServiceVente, 
lfac.t_crep as RepresentantInterne, 
empa.t_nama as NomRepresentantInterne, 
lfac.t_odat as DateCommande, 
lfac.t_shpm as CommandeClient, 
lfac.t_pono as Position, 
lfac.t_line as Sequence, 
'Ordre Magasin' as TypeCommandeClient, 
left(lfac.t_item, 9) as Projet, 
substring(lfac.t_item, 10, len(lfac.t_item)) as Article, 
art.t_dsca as DescArticle, 
dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle, 
'' as NumeroSerie, 
art.t_citg as CodeGroupeArticle, 
substring(art.t_citg,1,2) as GroupeArticle, 
'' as GroupeStatistiqueVente, 
'' as ClasseProduit, 
concat(lfac.t_ofbp, ' ', tiers.t_nama) as TiersAcheteur, 
lfac.t_shpm as CommandeDuClient, 
'' as QuantiteCommandee, 
'' as QuantiteALivrer, 
'' as QuantiteLivreeNonFacturee, 
lfac.t_dqua as QuantiteLivree, 
'' as DateLivraisonPlanifiee, 
'' as DateMADCPrevue, 
lfac.t_ddat as DateLivraisonReelle, 
'' as RepresentantExterne, 
'' as NomRepresentantExterne, 
lfac.t_creg as Zone, 
'' as DescriptionCanauxDistribution, 
'' as NomContremarque, 
'' as ClientIndirect, 
'' as ClientFinal, 
lfac.t_amti as MontantFacture, 
lfac.t_amti as Montant, 
'0' as MontantAFacturer, 
fact.t_ccur as DeviseCommande, 
left(fact.t_fdpt, 2) as UE 
from tcisli310400 lfac --Lignes de Factures
inner join tcisli305400 fact on lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Factures
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom001500 empa on empa.t_emno = lfac.t_crep --Employés - Représentant Interne
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Articles
where lfac.t_srtp = 44 --Bornage sur le type de source qui doit être Ordre Magasin
and lfac.t_koor = 60 --Bornage sur la Quantité d'Achat Proposée qui doit être Transfert Magasin
and fact.t_idat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Facture
and left(fact.t_fdpt, 2) between @ue_f and @ue_t --Bornage sur l'UE
--Rajout pour les Services le 21/08/2017
union
select 'Service' as Source, 
'8' as CodeSource, 
fact.t_idat as DateFacture, 
fact.t_tran as TypeEcritureFinanciere, 
fact.t_idoc as NumeroFacture, 
fact.t_fdpt as ServiceVente, 
lfac.t_crep as RepresentantInterne, 
empa.t_nama as NomRepresentantInterne, 
'' as DateCommande, 
'' as CommandeClient, 
'' as Position, 
'' as Sequence, 
'Ordre Service' as TypeCommandeClient, 
'' as Projet, 
'' as Article, 
'' as DescArticle, 
'' as TypeArticle, 
'' as NumeroSerie, 
(select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = fact.t_csvo) as CodeGroupeArticle, 
'IA' as GroupeArticle, 
'' as GroupeStatistiqueVente, 
'' as ClasseProduit, 
concat(lfac.t_ofbp, ' ', tiers.t_nama) as TiersAcheteur, 
'' as CommandeDuClient, 
'' as QuantiteCommandee, 
'' as QuantiteALivrer, 
'' as QuantiteLivreeNonFacturee, 
(select sum(lfact.t_dqua) from tcisli310500 lfact where lfact.t_tran = fact.t_tran and lfact.t_idoc = fact.t_idoc) as QuantiteLivree, 
'' as DateLivraisonPlanifiee, 
'' as DateMADCPrevue, 
fact.t_rtdt as DateLivraisonReelle, 
'' as RepresentantExterne, 
'' as NomRepresentantExterne, 
lfac.t_creg as Zone, 
'' as DescriptionCanauxDistribution, 
'' as NomContremarque, 
'' as ClientIndirect, 
'' as ClientFinal, 
(select sum(lfact.t_amti) from tcisli310400 lfact where lfact.t_tran = fact.t_tran and lfact.t_idoc = fact.t_idoc) as MontantFacture, 
(select sum(lfact.t_amti) from tcisli310400 lfact where lfact.t_tran = fact.t_tran and lfact.t_idoc = fact.t_idoc) as Montant, 
'0' as MontantAFacturer, 
fact.t_ccur as DeviseCommande, 
left(fact.t_fdpt, 2) as UE 
from tcisli305400 fact --Lignes de Factures
inner join tcisli310400 lfac on lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Factures
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom001500 empa on empa.t_emno = lfac.t_crep --Employés - Représentant Interne
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Articles
where lfac.t_srtp = 60 --Bornage sur le type de source qui doit être Ordre Service
and fact.t_idat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Facture
and left(fact.t_fdpt, 2) between @ue_f and @ue_t --Bornage sur l'UE
--Rajout pour les Programmes de vente le 21/08/2017
union
select distinct 'Contrat TP' as Source, 
'9' as CodeSource, 
cast(fact.t_idat as date) as DateFacture, 
'' as TypeEcritureFinanciere, 
'' as NumeroFacture, 
fact.t_fdpt as ServiceVente, 
'' as RepresentantInterne, 
'' as NomRepresentantInterne, 
'' as DateCommande, 
'' as CommandeClient, 
'' as Position, 
'' as Sequence, 
'' as TypeCommandeClient, 
'' as Projet, 
'' as Article, 
'' as DescArticle, 
'' as TypeArticle, 
'' as NumeroSerie, 
'IAR001' as CodeGroupeArticle, 
'IA' as GroupeArticle, 
'' as GroupeStatistiqueVente, 
'' as ClasseProduit, 
concat(fact.t_itbp, ' ', tiers.t_nama) as TiersAcheteur, 
'' as CommandeDuClient, 
'' as QuantiteCommandee, 
'' as QuantiteALivrer, 
'' as QuantiteLivreeNonFacturee, 
(select sum(lfact.t_dqua) from tcisli310500 lfact inner join tcisli305500 factu on factu.t_tran = lfact.t_tran and factu.t_idoc = lfact.t_idoc where cast(factu.t_idat as date) = cast(fact.t_idat as date) and factu.t_itbp = fact.t_itbp and lfact.t_srtp = 30) as QuantiteLivree, 
'' as DateLivraisonPlanifiee, 
'' as DateMADCPrevue, 
'' as DateLivraisonReelle, 
'' as RepresentantExterne, 
'' as NomRepresentantExterne, 
lfac.t_creg as Zone, 
'' as DescriptionCanauxDistribution, 
'' as NomContremarque, 
'' as ClientIndirect, 
'' as ClientFinal, 
(select sum(lfact.t_amti) from tcisli310400 lfact inner join tcisli305400 factu on factu.t_tran = lfact.t_tran and factu.t_idoc = lfact.t_idoc where cast(factu.t_idat as date) = cast(fact.t_idat as date) and factu.t_itbp = fact.t_itbp and lfact.t_srtp = 30) as MontantFacture, 
(select sum(lfact.t_amti) from tcisli310400 lfact inner join tcisli305400 factu on factu.t_tran = lfact.t_tran and factu.t_idoc = lfact.t_idoc where cast(factu.t_idat as date) = cast(fact.t_idat as date) and factu.t_itbp = fact.t_itbp and lfact.t_srtp = 30) as Montant, 
'0' as MontantAFacturer, 
fact.t_ccur as DeviseCommande, 
left(fact.t_fdpt, 2) as UE 
from tcisli305400 fact --Lignes de Commandes Clients
left outer join tcisli310400 lfac on lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Commandes Clients
left outer join ttccom100500 tiers on tiers.t_bpid = fact.t_itbp --Tiers - Acheteur
where lfac.t_srtp = 30 --Bornage sur le type de source qui doit être Contrat
and fact.t_idat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Facture
and left(fact.t_fdpt, 2) between @ue_f and @ue_t --Bornage sur l'UE