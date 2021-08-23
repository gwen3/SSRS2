----------------------------------------
-- LOG24 - Expéditions Prévisionnelles
----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lcde.t_cdec as ConditionsLivraisons, 
cliv.t_dsca as DescriptionConditionsLivraisons, 
cde.t_crep as RepresentantInterne, 
empa.t_nama as NomRepresentantInterne, 
lcde.t_orno as CommandeClient, 
lcde.t_pono as Position, 
cde.t_sotp as TypeCommandeClient, 
left(lcde.t_item, 9) as Projet, 
substring(lcde.t_item, 10, len(lcde.t_item)) as Article, 
art.t_dsca as DescArticle, 
lcde.t_serl as NumeroSerie, 
lcdeart.t_citg as CodeGroupeArticle,
grpart.t_dsca as Description_Groupe_Art,
cde.t_ofbp as TiersAcheteur, 
ofbp.t_nama as NomTiersAcheteur, 
cde.t_corn as CommandeDuClient, 
lcde.t_qoor as QuantiteCommandee, 
'' as QuantiteLivree, 
lcde.t_prdt as DateMADCPrevue, 
livcde.t_dldt as DateLivraisonReelle, 
cde.t_osrp as RepresentantExterne, 
empb.t_nama as NomRepresentantExterne, 
marq.t_dsca as NomContremarque, 
cde.t_refa as ReferenceA, 
cde.t_refb as ReferenceB, 
concat(cde.t_clin,' ',clin.t_nama) as ClientIndirect, 
concat(cde.t_clfi,' ',clfi.t_nama) as ClientFinal, 
cde.t_stad as CodeAdresseLivree, 
adrl.t_nama as NomAdresseLivree, 
adrl.t_namb as NomAdresseLivree2, 
adrl.t_hono as NumeroAdresseLivree, 
adrl.t_namc as RueAdresseLivree, 
adrl.t_pstc as CodePostalAdresseLivree, 
adrl.t_dsca as NomVilleAdresseLivree, 
left(adrl.t_pstc, 2) as DepartementAdresseLivree, 
lexpe.t_stad as CodeAdresseExpedition, 
adre.t_nama as NomAdresseExpedition, 
adre.t_namb as NomAdresseExpedition2, 
adre.t_hono as NumeroAdresseExpedition, 
adre.t_namc as RueAdresseExpedition, 
adre.t_pstc as CodePostalAdresseExpedition, 
adre.t_dsca as NomVilleAdresseExpedition, 
left(adre.t_pstc, 2) as DepartementAdresseExpedition, 
ofab.t_pdno as OrdreFabrication, 
(case 
when lcdeart.t_citg like 'BAT%' 
	then 'PAR' 
when lcdeart.t_citg like 'BAK%' 
	then 'PAB' 
else 'SPE' 
end) as GroupeArticle2,
lcdeart.t_cpcl as Classe_Produit,
marmod.t_dsca as MarqueModele,
cde.t_ofcn as Contact_Acheteur,
isnull(contact.t_fuln,'') as Nom_Contact,
isnull(contact.t_telp,'') as TelService,
cde.t_stcn as Contact_Expedition,
isnull(contexp.t_fuln,'') as Nom_Contact_Exp,
isnull(contexp.t_telp,'') as TelServiceExp
from ttdsls401500 lcde --Lignes de Commandes Clients
left outer join ttcmcs041500 cliv on cliv.t_cdec = lcde.t_cdec --Conditions de Livraisons
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttccom001500 empa on empa.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttdsls406500 livcde on livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb --Lignes de Livraison de Commandes Clients
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
inner join ttdsls411500 lcdeart on lcdeart.t_orno = cde.t_orno and lcdeart.t_pono = lcde.t_pono and lcdeart.t_sqnb = 0 --Données Articles de la Ligne de Commande
left outer join ttcmcs023500 grpart on grpart.t_citg = lcdeart.t_citg -- Groupes Articles
left outer join ttcmcs062500 marmod on marmod.t_cpcl = lcdeart.t_cpcl --Classe de Produit (Marque_Model)
left outer join ttccom001500 empb on empb.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join tzgsls001500 marq on marq.t_cont = cde.t_cntr --Gestion des Contremarques
left outer join ttccom100500 clin on clin.t_bpid = cde.t_clin --Tiers - Client Indirect
left outer join ttccom100500 clfi on clfi.t_bpid = cde.t_clfi --Tiers - Client Final
left outer join ttccom100500 ofbp on ofbp.t_bpid = cde.t_ofbp --Tiers - Acheteur
left outer join ttccom130500 adrl on adrl.t_cadr = cde.t_stad --Adresse Livraison
left outer join twhinh430500 expe on expe.t_shpm = livcde.t_shpm --and expe.t_pdat = '01/01/1970' --Expéditions - On ne prend que les expéditions dont le BL n'est pas imprimé
--inner join twhinh430500 expe on expe.t_shpm = livcde.t_shpm and expe.t_pdat = '01/01/1970' --Expéditions - On ne prend que les expéditions dont le BL n'est pas imprimé
left outer join twhinh431500 lexpe on lexpe.t_shpm = expe.t_shpm and lexpe.t_pono = livcde.t_shln --Lignes d'Expéditions
left outer join ttccom130500 adre on adre.t_cadr = lexpe.t_stad --Adresse Expédition
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono --Ordres de Fabrication
left outer join ttccom140500 contact on contact.t_ccnt = cde.t_ofcn -- Contact(Acheteur)
left outer join ttccom140500 contexp on contexp.t_ccnt = cde.t_stcn -- Contact (Expédition)
where left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE
and lcde.t_orno between @cde_f and @cde_t --Bornage sur le Numéro de Commande
and lcde.t_prdt between @datemadcprev_f and @datemadcprev_t --Bornage sur la Date de MADC Prévue
and lcde.t_cdec between @cliv_f and @cliv_t --Bornage sur les Conditions de Livraison
and ((substring(lcdeart.t_citg, 3, 1) in (@transfo)) or @transfotous = 1) --On borne sur la Transformation, la 3ème lettre du groupe articles est soit T, soit K, soit tous (@transfo doit être = à Tous)
--rajout par rbesnier le 06/06/2018 pour ramener les commandes 
and (expe.t_pdat = '01/01/1970' or livcde.t_shpm = '' or lcde.t_dldt = '01/01/1970')
and lcde.t_cwar != '' --Permet d'exclure les articles de coûts qui n'ont pas de magasins renseignés
and lcde.t_clyn = 2 --On ne prend que les lignes qui ne sont pas annulées
and cde.t_clyn = 2 --On ne prend que les commandes qui ne sont pas annulées
and cde.t_hdst != 35 --On ne prend pas les commandes qui sont au statut annulées
order by lcde.t_orno, lcde.t_pono