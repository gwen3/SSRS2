----------------------------------------
-- COM11 - CA Facture pour Contact Com
----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select top 1000
livcde.t_orno as CommandeClient,
livcde.t_pono as Position, 
livcde.t_sqnb as Sequence, 
-- cde.t_sotp as TypeCommande,
-- tcde.t_dsca as NomTypeCommande,
cde.t_corg as Origine, -- 4 manuel, 9, constructeur, 100 extranet
convert(char(10),lcde.t_odat,103) as DateCommande, 
convert(char(10),livcde.t_invd,103) as DateFacture, 
livcde.t_ttyp as TypeEcritureFinanciere, 
livcde.t_invn as NumeroFacture, 
cde.t_cofc as ServiceVente, 
left(lcde.t_item, 9) as Projet, 
substring(lcde.t_item, 10, len(lcde.t_item)) as Article, 
art.t_dsca as DescArticle, 
cde.t_itbp as NumTiersFacture,
itbp.t_nama as NomTiersFacture, 
cde.t_stbp as NumTiersDestinataire,
stbp.t_nama as NomTiersDestinataire, 
chad.t_chan as CanalTiersDestinataire,
chal.t_dsca as NomCanalTiersDestinataire,
substring(lcdeart.t_citg,1,2) as GroupeArticle,
lcdeart.t_citg as CodeGroupeArticle, 
cde.t_crep as RepresentantInterne, 
empa.t_nama as NomRepresentantInterne, 
cde.t_osrp as RepresentantExterne, 
empb.t_nama as NomRepresentantExterne, 
left(stad.t_pstc,2) as DepTiersDestinataire,
livcde.t_qidl as QuantiteLivree, 
livcde.t_namt / lcde.t_rats_1 as MontantFactureEuro, 
lcdeart.t_cpcl as ClasseProduit, 
concat(cde.t_ofbp,' ',ofbp.t_nama) as TiersAcheteur, 
cde.t_corn as CommandeDuClient, 
lcde.t_qoor as QuantiteCommandee, 
(case 
when (livcde.t_qidl = 0) 
	then lcde.t_qoor - livcde.t_qidl 
else '0' 
end) as QuantiteALivrer, 
chan.t_dsca as DescriptionCanauxDistribution, 
cde.t_ccur as DeviseCommandeOri, 
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
left outer join ttccom100500 itbp on itbp.t_bpid = cde.t_itbp --Tiers - Facturé
left outer join ttccom100500 stbp on stbp.t_bpid = cde.t_stbp --Tiers - Destinataire
left outer join ttccom110500 chad on chad.t_ofbp = cde.t_stbp --Tiers Acheteur du Tiers - Destinataire
left outer join ttcmcs066500 chal on chal.t_chan = chad.t_chan --Canaux de distribution
left outer join ttccom130500 stad on stad.t_cadr = cde.t_stad --Adresse Destinataire sur Commande
where
livcde.t_invd between @lcde_t_invd_f and @lcde_t_invd_t --Bornage sur la Date de facture
and livcde.t_invd <> '01/01/1970' --Bornage sur les Dates de Facture qui ne sont pas vides, autrement dit la facture existe
and left(cde.t_cofc, 2) between @ue_f and @ue_t --Bornage sur l'UE*/