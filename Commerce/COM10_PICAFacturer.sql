---------------------------
-- COM10 - PIC à Facturer
---------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 'A_facturer_1' as Source, 
'1' as CodeSource, 
'01/01/1970' as DateFacture, 
'' as TypeEcritureFinanciere, 
'' as NumeroFacture, 
cde.t_cofc as ServiceVente, 
cde.t_crep as RepresentantInterne, 
empa.t_nama as NomRepresentantInterne, 
lcde.t_odat as DateCommande, 
lcde.t_orno as CommandeClient, 
lcde.t_pono as Position, 
lcde.t_sqnb as Sequence, 
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
when (lcde.t_qidl = 0) 
	then lcde.t_qoor - lcde.t_qidl 
else '0' 
end) as QuantiteALivrer, 
lcde.t_qidl as QuantiteLivreeNonFacturee, 
'' as QuantiteLivree, 
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
'0' as MontantFacture, 
lcde.t_oamt / lcde.t_rats_1 as Montant, 
livcde.t_namt / lcde.t_rats_1 as MontantAFacturer, 
cde.t_ccur as DeviseCommande, 
substring(cde.t_cofc,1,2) as UE 
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
where lcde.t_odat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Commande
and lcde.t_dldt = '01/01/1970' --Bornage sur la Date de Livraison qui doit être vide
and lcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
and lcde.t_clyn <> 1 --Bornage sur la Ligne de Commande qui ne doit pas être Annulée
and left(cde.t_cofc, 2) between @ue_f and @ue_t) --Bornage sur l'UE
union all
(select 'A_facturer_2' as Source, 
'2' as CodeSource, 
'01/01/1970' as DateFacture, 
'' as TypeEcritureFinanciere, 
'' as NumeroFacture, 
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
when (lcde.t_qidl = 0) 
	then lcde.t_qoor - lcde.t_qidl 
else '0' 
end) as QuantiteALivrer, 
livcde.t_qidl as QuantiteLivreeNonFacturee, 
'' as QuantiteLivree, 
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
'0' as MontantFacture, 
lcde.t_oamt / lcde.t_rats_1 as Montant, 
livcde.t_namt / lcde.t_rats_1 as MontantAFacturer, 
cde.t_ccur as DeviseCommande, 
substring(cde.t_cofc,1,2) as UE 
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
where lcde.t_odat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Commande
and lcde.t_dldt <> '01/01/1970' --Bornage sur la Date de Livraison qui ne doit pas être vide
and lcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
and livcde.t_invd = '01/01/1970' --Bornage sur la Date de Facture qui doit être vide
and livcde.t_stat < 20 --Le Statut doit être soit Ouvert (5), Approuvé (10) ou Lancé (15)
and left(cde.t_cofc, 2) between @ue_f and @ue_t) --Bornage sur l'UE
union all 
(select distinct 'PV_A_facturer_1' as Source, 
'3' as CodeSource, 
'01/01/1970' as DateFacture, 
'' as TypeEcritureFinanciere, 
'' as NumeroFacture, 
'' as ServiceVente, 
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
(select top 1 art.t_citg from ttcibd001500 art where art.t_item = lprog.t_item) as CodeGroupeArticle, 
(select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lprog.t_item) as GroupeArticle, 
'' as GroupeStatistiqueVente, 
'' as ClasseProduit, 
concat(lprog.t_ofbp,' ',tiers.t_nama) as TiersAcheteur, 
'' as CommandeDuClient, 
(select sum(lprog2.t_qrrq) from ttdsls307500 lprog2 where cast(lprog2.t_sdat as date) = cast(lprog.t_sdat as date) and lprog2.t_ofbp = lprog.t_ofbp and lprog2.t_stat < 6 and lprog2.t_sctp = 2) as QuantiteCommandee, 
(select sum(lprog2.t_qrrq) from ttdsls307500 lprog2 where cast(lprog2.t_sdat as date) = cast(lprog.t_sdat as date) and lprog2.t_ofbp = lprog.t_ofbp and lprog2.t_stat < 6 and lprog2.t_sctp = 2) as QuantiteALivrer, 
'0' as QuantiteLivreeNonFacturee, 
'' as QuantiteLivree, 
cast(lprog.t_sdat as date) as DateLivraisonPlanifiee, 
'' as DateMADCPrevue, 
'' as DateLivraisonReelle, 
'' as RepresentantExterne, 
'' as NomRepresentantExterne, 
'' as Zone, 
'' as DescriptionCanauxDistribution, 
'' as NomContremarque, 
'' as ClientIndirect, 
'' as ClientFinal, 
'0' as MontantFacture, 
(select sum(lprog3.t_samt) from ttdsls307500 lprog3 where cast(lprog3.t_sdat as date) = cast(lprog.t_prdt as date) and lprog3.t_ofbp = lprog.t_ofbp and lprog3.t_stat < 6 and lprog3.t_sctp = 2) as Montant, --pri = Gestion des informations sur les prix
(select sum(lprog3.t_samt) from ttdsls307500 lprog3 where cast(lprog3.t_sdat as date) = cast(lprog.t_prdt as date) and lprog3.t_ofbp = lprog.t_ofbp and lprog3.t_stat < 6 and lprog3.t_sctp = 2) as MontantAFacturer, --pri = Gestion des informations sur les prix
'' as DeviseCommande, 
left(lprog.t_schn, 2) as UE 
from ttdsls307500 lprog --Lignes de Programme de Vente
left outer join ttccom100500 tiers on tiers.t_bpid = lprog.t_ofbp --Tiers - Acheteur
inner join ttdsls311500 progven on progven.t_schn = lprog.t_schn and progven.t_sctp = lprog.t_sctp and progven.t_revn = lprog.t_revn --Programmes de Ventes
where lprog.t_stat < 6 --Bornage sur le statut qui doit être inférieur à 6 (Expédié partiellement), cela correspond à tout ce qui est à livrer
and lprog.t_sdat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Commande
and left(lprog.t_schn, 2) between @ue_f and @ue_t --Bornage sur l'UE défini par les Ordres Magasins
and lprog.t_sctp = 2 --On ne prend que les programmes d'expédition
and lprog.t_revn = (select top 1 prog1.t_revn from ttdsls307500 prog1 where prog1.t_schn = lprog.t_schn and prog1.t_sctp = lprog.t_sctp order by prog1.t_revn desc) --On prend la dernière révision
and progven.t_stat != 4 --On enlève les programmes résiliés
and progven.t_stat != 5) --On enlève les programmes au statut résiliation en cours
union all 
(select distinct 'PV_A_facturer_2' as Source, 
'4' as CodeSource, 
'01/01/1970' as DateFacture, 
'' as TypeEcritureFinanciere, 
'' as NumeroFacture, 
'' as ServiceVente, 
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
(select top 1 art.t_citg from ttcibd001500 art where art.t_item = lprog.t_item) as CodeGroupeArticle, 
(select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lprog.t_item) as GroupeArticle, 
'' as GroupeStatistiqueVente, 
'' as ClasseProduit, 
concat(lprog.t_ofbp,' ',tiers.t_nama) as TiersAcheteur, 
'' as CommandeDuClient, 
(select sum(lprog2.t_qrrq) from ttdsls307500 lprog2 where cast(lprog2.t_sdat as date) = cast(lprog.t_sdat as date) and lprog2.t_ofbp = lprog.t_ofbp and lprog2.t_stat >= 6 and lprog2.t_stat < 9 and lprog2.t_sctp = 2) as QuantiteCommandee, 
(select sum(lprog2.t_qrrq) from ttdsls307500 lprog2 where cast(lprog2.t_sdat as date) = cast(lprog.t_sdat as date) and lprog2.t_ofbp = lprog.t_ofbp and lprog2.t_stat >= 6 and lprog2.t_stat < 9 and lprog2.t_sctp = 2) as QuantiteALivrer, 
'0' as QuantiteLivreeNonFacturee, 
'' as QuantiteLivree, 
cast(lprog.t_sdat as date) as DateLivraisonPlanifiee, 
'' as DateMADCPrevue, 
'' as DateLivraisonReelle, 
'' as RepresentantExterne, 
'' as NomRepresentantExterne, 
'' as Zone, 
'' as DescriptionCanauxDistribution, 
'' as NomContremarque, 
'' as ClientIndirect, 
'' as ClientFinal, 
'0' as MontantFacture, 
(select sum(lprog3.t_samt) from ttdsls307500 lprog3 where cast(lprog3.t_sdat as date) = cast(lprog.t_prdt as date) and lprog3.t_ofbp = lprog.t_ofbp and lprog3.t_stat >= 6 and lprog3.t_stat < 9 and lprog3.t_sctp = 2) as Montant, --pri = Gestion des informations sur les prix
(select sum(lprog3.t_samt) from ttdsls307500 lprog3 where cast(lprog3.t_sdat as date) = cast(lprog.t_prdt as date) and lprog3.t_ofbp = lprog.t_ofbp and lprog3.t_stat >= 6 and lprog3.t_stat < 9 and lprog3.t_sctp = 2) as MontantAFacturer, --pri = Gestion des informations sur les prix
'' as DeviseCommande, 
left(lprog.t_schn, 2) as UE 
from ttdsls307500 lprog --Lignes de Programme de Vente
left outer join ttccom100500 tiers on tiers.t_bpid = lprog.t_ofbp --Tiers - Acheteur
inner join ttdsls311500 progven on progven.t_schn = lprog.t_schn and progven.t_sctp = lprog.t_sctp and progven.t_revn = lprog.t_revn --Programmes de Ventes
where lprog.t_stat >= 6 and lprog.t_stat < 9 --Bornage sur le statut qui doit être supérieur ou égal à 6 (Expédié partiellement), et inférieur à 9 (Facturé) cela correspond à tout ce qui est livré et à facturer
and lprog.t_sdat between @lcde_t_prdt_f and @lcde_t_prdt_t --Bornage sur la Date de Commande
and left(lprog.t_schn, 2) between @ue_f and @ue_t --Bornage sur l'UE défini par les Ordres Magasins
and lprog.t_sctp = 2 --On ne prend que les programmes d'expéditions
and lprog.t_revn = (select top 1 prog1.t_revn from ttdsls307500 prog1 where prog1.t_schn = lprog.t_schn and prog1.t_sctp = lprog.t_sctp order by prog1.t_revn desc) --On prend la dernière révision
and progven.t_stat != 4 --On enlève les programmes résiliés
and progven.t_stat != 5) --On enlève les programmes au statut résiliation en cours