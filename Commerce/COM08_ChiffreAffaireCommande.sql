-------------------------------------------
-- COM08 - Chiffre d'Affaire de Commandes
-------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 'A_facturer_1' as Source
,'1' as CodeSource
,'01/01/1970' as DateFacture
,'' as TypeEcritureFinanciere
,'' as NumeroFacture
,cde.t_cofc as ServiceVente
,cde.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lcde.t_odat as DateCommande
,lcde.t_orno as CommandeClient
,lcde.t_pono as Position
,lcde.t_sqnb as Sequence
,cde.t_sotp as TypeCommandeClient
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,lcde.t_serl as NumeroSerie
,lcdeart.t_citg as CodeGroupeArticle
,substring(lcdeart.t_citg,1,2) as GroupeArticle
,lcdeart.t_csgs as GroupeStatistiqueVente, lcdeart.t_cpcl as ClasseProduit
,concat(cde.t_ofbp,' ',ofbp.t_nama) as TiersAcheteur
,cde.t_corn as CommandeDuClient
,lcde.t_qoor as QuantiteCommandee
,(case 
when (lcde.t_qidl = 0) 
	then lcde.t_qoor - lcde.t_qidl 
else '0' 
end) as QuantiteALivrer
,lcde.t_qidl as QuantiteLivreeNonFacturee
,'' as QuantiteLivree
,lcde.t_ddta as DateLivraisonPlanifiee
,lcde.t_prdt as DateMADCPrevue
,livcde.t_dldt as DateLivraisonReelle
,cde.t_osrp as RepresentantExterne
,empb.t_nama as NomRepresentantExterne
,cde.t_ofad as CodeAdresseCommande
,adr.t_dsca as NomVille
,adr.t_pstc as CodePostalCommande
,left(adr.t_pstc, 2) as Departement
,cde.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,marq.t_dsca as NomContremarque
,concat(cde.t_clin,' ',clin.t_nama) as ClientIndirect
,concat(cde.t_clfi,' ',clfi.t_nama) as ClientFinal
,'0' as MontantFacture
,lcde.t_oamt / lcde.t_rats_1 as Montant
,livcde.t_namt / lcde.t_rats_1 as MontantAFacturer
,cde.t_ccur as DeviseCommande
,substring(cde.t_cofc,1,2) as UE
,cde.t_stad as CodeAdresseLivre
,adrl.t_dsca as NomVilleLivree
,adrl.t_pstc as CodePostalLivre
,left(adrl.t_pstc, 2) as DepartementLivre
,left(cde.t_cofc, 2) as UniteEntreprise
from ttdsls401500 lcde --Lignes de Commandes Clients
left outer join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttdsls406500 livcde on livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb --Lignes de Livraison de Commandes Clients
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttdsls411500 lcdeart on lcdeart.t_orno = cde.t_orno and lcdeart.t_pono = lcde.t_pono and lcdeart.t_sqnb = 0 --Données Articles de la Ligne de Commande
left outer join ttccom001500 empa on empa.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom001500 empb on empb.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join ttcmcs066500 chan on chan.t_chan = lcde.t_chan --Canaux de Distribution
left outer join tzgsls001500 marq on marq.t_cont = cde.t_cntr --Gestion des Contremarques
left outer join ttccom100500 clin on clin.t_bpid = cde.t_clin --Tiers - Client Indirect
left outer join ttccom100500 clfi on clfi.t_bpid = cde.t_clfi --Tiers - Client Final
left outer join ttccom100500 ofbp on ofbp.t_bpid = cde.t_ofbp --Tiers - Acheteur
left outer join ttccom130500 adr on adr.t_cadr = cde.t_ofad --Adresses Commandes
left outer join ttccom130500 adrl on adrl.t_cadr = cde.t_stad --Adresses Livrées
where lcde.t_odat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Commande
and lcde.t_dldt = '01/01/1970' --Bornage sur la Date de Livraison qui doit être vide
and lcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
and lcde.t_clyn <> 1 --Bornage sur la Ligne de Commande qui ne doit pas être Annulée
and left(cde.t_cofc, 2) between @ue_f and @ue_t --Bornage sur l'UE
and cde.t_ofbp between @tiers_f and @tiers_t --Bornage sur le tiers acheteur
) union all
(select 'A_facturer_2' as Source
,'2' as CodeSource
,'01/01/1970' as DateFacture
,'' as TypeEcritureFinanciere
,'' as NumeroFacture
,cde.t_cofc as ServiceVente
,cde.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lcde.t_odat as DateCommande
,livcde.t_orno as CommandeClient
,livcde.t_pono as Position
,livcde.t_sqnb as Sequence
,cde.t_sotp as TypeCommandeClient
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,lcde.t_serl as NumeroSerie
,lcdeart.t_citg as CodeGroupeArticle
,substring(lcdeart.t_citg,1,2) as GroupeArticle
,lcdeart.t_csgs as GroupeStatistiqueVente
,lcdeart.t_cpcl as ClasseProduit
,concat(cde.t_ofbp,' ',ofbp.t_nama) as TiersAcheteur
,cde.t_corn as CommandeDuClient
,lcde.t_qoor as QuantiteCommandee
,(case
when (lcde.t_qidl = 0) 
	then lcde.t_qoor - lcde.t_qidl 
else '0' 
end) as QuantiteALivrer
,livcde.t_qidl as QuantiteLivreeNonFacturee
,'' as QuantiteLivree
,lcde.t_ddta as DateLivraisonPlanifiee
,lcde.t_prdt as DateMADCPrevue
,livcde.t_dldt as DateLivraisonReelle
,cde.t_osrp as RepresentantExterne
,empb.t_nama as NomRepresentantExterne
,cde.t_ofad as CodeAdresseCommande
,adr.t_dsca as NomVille
,adr.t_pstc as CodePostalCommande
,left(adr.t_pstc, 2) as Departement
,cde.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,marq.t_dsca as NomContremarque
,concat(cde.t_clin,' ',clin.t_nama) as ClientIndirect
,concat(cde.t_clfi,' ',clfi.t_nama) as ClientFinal
,'0' as MontantFacture
,lcde.t_oamt / lcde.t_rats_1 as Montant
,livcde.t_namt / lcde.t_rats_1 as MontantAFacturer
,cde.t_ccur as DeviseCommande
,substring(cde.t_cofc,1,2) as UE
,cde.t_stad as CodeAdresseLivre
,adrl.t_dsca as NomVilleLivree
,adrl.t_pstc as CodePostalLivre
,left(adrl.t_pstc, 2) as DepartementLivre
,left(cde.t_cofc, 2) as UniteEntreprise
from ttdsls401500 lcde --Lignes de Commandes Clients
left outer join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttdsls406500 livcde on livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb --Lignes de Livraison de Commandes Clients
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttdsls411500 lcdeart on lcdeart.t_orno = cde.t_orno and lcdeart.t_pono = lcde.t_pono and lcdeart.t_sqnb = 0 --Données Articles de la Ligne de Commande
left outer join ttccom001500 empa on empa.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom001500 empb on empb.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join ttcmcs066500 chan on chan.t_chan = lcde.t_chan --Canaux de Distribution
left outer join tzgsls001500 marq on marq.t_cont = cde.t_cntr --Gestion des Contremarques
left outer join ttccom100500 clin on clin.t_bpid = cde.t_clin --Tiers - Client Indirect
left outer join ttccom100500 clfi on clfi.t_bpid = cde.t_clfi --Tiers - Client Final
left outer join ttccom100500 ofbp on ofbp.t_bpid = cde.t_ofbp --Tiers - Acheteur
left outer join ttccom130500 adr on adr.t_cadr = cde.t_ofad --Adresses Commandes
left outer join ttccom130500 adrl on adrl.t_cadr = cde.t_stad --Adresses Livrées
where lcde.t_odat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Commande
and lcde.t_dldt <> '01/01/1970' --Bornage sur la Date de Livraison qui ne doit pas être vide
and lcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
and livcde.t_invd = '01/01/1970' --Bornage sur la Date de Facture qui doit être vide
and livcde.t_stat < 20 --Le Statut doit être soit Ouvert (5), Approuvé (10) ou Lancé (15)
and left(cde.t_cofc, 2) between @ue_f and @ue_t --Bornage sur l'UE
--rajout par rbesnier le 01/09/2017 pour borner sur le tiers acheteur
and cde.t_ofbp between @tiers_f and @tiers_t --Bornage sur le tiers acheteur
) union all 
(select 'PV_AFacturer' as Source
,'3' as CodeSource
,'01/01/1970' as DateFacture
,'' as TypeEcritureFinanciere
,'' as NumeroFacture
,'' as ServiceVente
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,lprog.t_odat as DateCommande
,lprog.t_schn as CommandeClient
,lprog.t_spon as Position
,lprog.t_revn as Sequence
,'' as TypeCommandeClient
,'' as Projet
,'' as Article
,'' as DescArticle
,'' as TypeArticle
,'' as NumeroSerie
,(select top 1 art.t_citg from ttcibd001500 art where art.t_item = lprog.t_item) as CodeGroupeArticle
,(select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lprog.t_item) as GroupeArticle
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,concat(lprog.t_ofbp,' ',tiers.t_nama) as TiersAcheteur
,'' as CommandeDuClient
,lprog.t_qrrq as QuantiteCommandee
,lprog.t_qrrq as QuantiteALivrer
,'0' as QuantiteLivreeNonFacturee
,'' as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as CodeAdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,prog.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as ClientFinal
,'0' as MontantFacture
,lprog.t_samt as Montant
,lprog.t_samt as MontantAFacturer
,'' as DeviseCommande, left(lprog.t_schn, 2) as UE
,'' as CodeAdresseLivre
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre 
,left(lprog.t_schn, 2) as UniteEntreprise
from ttdsls307500 lprog --Lignes de Programme de Vente
inner join ttdsls311500 prog on prog.t_schn = lprog.t_schn and prog.t_sctp = lprog.t_sctp and prog.t_revn = lprog.t_revn --Programmes de Vente
left outer join ttccom100500 tiers on tiers.t_bpid = lprog.t_ofbp --Tiers - Acheteur
where lprog.t_revn = (select top 1 lprog2.t_revn from ttdsls307500 lprog2 where lprog2.t_schn = lprog.t_schn and lprog2.t_sctp = lprog.t_sctp order by lprog2.t_revn desc) 
and lprog.t_stat < 9 --Bornage sur le statut qui doit être inférieur à 6 (Expédié partiellement), cela correspond à tout ce qui est à livrer
and lprog.t_odat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Commande
and left(lprog.t_schn, 2) between @ue_f and @ue_t --Bornage sur l'UE défini par les Ordres Magasins
and lprog.t_sctp = 2 --On ne prend que les programmes d'expédition
and lprog.t_ofbp between @tiers_f and @tiers_t --Bornage sur le tiers acheteur
and prog.t_stat != 4 --On enlève les programmes résiliés
and prog.t_stat != 5 --On enlève les programmes au statut résiliation en cours
) union all 
(select 'PV_Facture' as Source
,'4' as CodeSource
,llivpv.t_invd as DateFacture
,llivpv.t_ttyp as TypeEcritureFinanciere
,llivpv.t_invn as NumeroFacture
,'' as ServiceVente
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,lprog.t_odat as DateCommande
,llivpv.t_schn as CommandeClient
,ompv.t_spon as Position
,ompv.t_revn as Sequence
,dbo.convertenum('td','B61C','a9','bull','sls.reltype',llivpv.t_sctp,'4') as TypeCommandeClient
,left(lprog.t_item, 9) as Projet
,substring(lprog.t_item, 10, len(lprog.t_item)) as Article
,art.t_dsca as DescArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,'' as NumeroSerie
,art.t_citg as CodeGroupeArticle
,left(art.t_citg, 2) as GroupeArticle
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,concat(lprog.t_ofbp,' ',tiers.t_nama) as TiersAcheteur
,'' as CommandeDuClient
,lprog.t_qrrq as QuantiteCommandee
,(ompv.t_qoor - ompv.t_qidl) as QuantiteALivrer --Permet de vérifier les quantités, voir s'il faut prendre celles données dans la 307 et la 340 à la place.
,'0' as QuantiteLivreeNonFacturee
,llivpv.t_qnvc as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,llivpv.t_dldt as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,llivpv.t_stad as CodeAdresseCommande
,vil.t_dsca as NomVille
,adr.t_pstc as CodePostalCommande
,adr.t_cste as Departement
,prog.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as ClientFinal
,llivpv.t_namt as MontantFacture
,llivpv.t_namt as Montant
,'0' as MontantAFacturer
,'' as DeviseCommande
,left(llivpv.t_schn, 2) as UE
,'' as CodeAdresseLivre
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,left(lprog.t_schn, 2) as UniteEntreprise
from ttdsls340500 llivpv --Lignes de Livraison de Programme de Vente Réelles
inner join ttdsls321500 ompv on ompv.t_worn = llivpv.t_schn and ompv.t_wpon = llivpv.t_wpon and ompv.t_wsqn = llivpv.t_wsqn and ompv.t_sctp = llivpv.t_sctp --Liens Ordres Magasins Planifiés et Programmes de Ventes
inner join ttdsls307500 lprog on lprog.t_schn = ompv.t_schn and lprog.t_spon = ompv.t_spon and lprog.t_revn = ompv.t_revn and lprog.t_sctp = ompv.t_sctp --Lignes de Programmes de Ventes
inner join ttcibd001500 art on art.t_item = lprog.t_item --Articles
inner join ttccom100500 tiers on tiers.t_bpid = lprog.t_ofbp --Tiers - Acheteur
inner join ttdsls311500 prog on prog.t_schn = lprog.t_schn and prog.t_sctp = lprog.t_sctp and prog.t_revn = lprog.t_revn --Programmes de Vente
left outer join ttccom130500 adr on adr.t_cadr = llivpv.t_stad --Adresses
left outer join ttccom139500 vil on vil.t_city = adr.t_ccit and vil.t_ccty = adr.t_ccty and vil.t_cste = adr.t_cste --Villes
where llivpv.t_stat between 9 and 10 --Bornage sur le statut qui doit être Facturé (9) ou Traité (10)
and lprog.t_odat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Commande
and left(lprog.t_schn, 2) between @ue_f and @ue_t --Bornage sur l'UE défini par les Ordres Magasins
and lprog.t_sctp = 2 --On ne prend que les programmes d'expéditions
and lprog.t_ofbp between @tiers_f and @tiers_t --Bornage sur le tiers acheteur
) union all
(select 'Facturé' as Source
,'5' as CodeSource
,livcde.t_invd as DateFacture
,livcde.t_ttyp as TypeEcritureFinanciere
,livcde.t_invn as NumeroFacture
,cde.t_cofc as ServiceVente
,cde.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lcde.t_odat as DateCommande
,livcde.t_orno as CommandeClient
,livcde.t_pono as Position
,livcde.t_sqnb as Sequence
,cde.t_sotp as TypeCommandeClient
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,lcde.t_serl as NumeroSerie
,lcdeart.t_citg as CodeGroupeArticle
,substring(lcdeart.t_citg,1,2) as GroupeArticle
,lcdeart.t_csgs as GroupeStatistiqueVente
,lcdeart.t_cpcl as ClasseProduit
,concat(cde.t_ofbp,' ',ofbp.t_nama) as TiersAcheteur
,cde.t_corn as CommandeDuClient
,lcde.t_qoor as QuantiteCommandee
,(case 
when (livcde.t_qidl = 0) 
	then lcde.t_qoor - livcde.t_qidl 
else '0' 
end) as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,livcde.t_qidl as QuantiteLivree
,lcde.t_ddta as DateLivraisonPlanifiee
,lcde.t_prdt as DateMADCPrevue
,livcde.t_dldt as DateLivraisonReelle
,cde.t_osrp as RepresentantExterne
,empb.t_nama as NomRepresentantExterne
,cde.t_ofad as CodeAdresseCommande
,adr.t_dsca as NomVille
,adr.t_pstc as CodePostalCommande
,left(adr.t_pstc, 2) as Departement
,cde.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,marq.t_dsca as NomContremarque
,concat(cde.t_clin,' ',clin.t_nama) as ClientIndirect
,concat(cde.t_clfi,' ',clfi.t_nama) as ClientFinal
,livcde.t_namt / lcde.t_rats_1 as MontantFacture
,lcde.t_oamt / lcde.t_rats_1 as Montant
,'0' / lcde.t_rats_1 as MontantAFacturer
,cde.t_ccur as DeviseCommande
,substring(cde.t_cofc,1,2) as UE
,cde.t_stad as CodeAdresseLivre
,adrl.t_dsca as NomVilleLivree
,adrl.t_pstc as CodePostalLivre
,left(adrl.t_pstc, 2) as DepartementLivre
,left(cde.t_cofc, 2) as UniteEntreprise
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
left outer join ttccom130500 adr on adr.t_cadr = cde.t_ofad --Adresses Commandes 
left outer join ttccom130500 adrl on adrl.t_cadr = cde.t_stad --Adresses Livrées
where lcde.t_odat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Commande
and livcde.t_invd <> '01/01/1970' --Bornage sur les Dates de Facture qui ne sont pas vides, autrement dit la facture existe
and left(cde.t_cofc, 2) between @ue_f and @ue_t --Bornage sur l'UE
and cde.t_ofbp between @tiers_f and @tiers_t --Bornage sur le tiers acheteur
)
--Formule SSRS calcul champ Quantité : =IIf(CStr(Fields!TypeArticle.Value) = "Coût", "0", IIf((GetChar(CStr(Fields!CodeGroupeArticle.Value), 3) = "K" Or GetChar(CStr(Fields!CodeGroupeArticle.Value), 3) = "T"), IIf(CStr(Fields!Source.Value) = "Facturé", Fields!QuantiteFacturee.Value, Fields!QuantiteCommandee.Value), "0"))