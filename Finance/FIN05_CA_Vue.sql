-------------------------------------------
-- FIN05 - CA Facturé et à Facturer - Vue
-------------------------------------------

--Pour ce SSRS, le nombre de caractères pose problème à SSRS, on est bloqué au seuil de 33000 environ. Pour contourner ce problème, on crée une vue sans bornage, et ensuite on vient interroger cette vue avec les critères que l'on souhaite. La formule pour éviter le blocage des tables ne fonctionne pas dans la vue, il faut la mettre au moment de l'interrogation
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- dboivin 22/06/2018, ajout des variables pour utilisation hors SSRS
/*declare @lcde_t_prdt_f date = DATEADD(DD, -20, CAST(CURRENT_TIMESTAMP AS DATE));
declare @lcde_t_prdt_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @ue_f nvarchar(2) = '  '
declare @ue_t nvarchar(2) = 'ZZ'
*/

--create 
alter
view FIN05_VIEW
as
select 'A Facturer 1' as Source
,'1' as CodeSource
,'01/01/1970' as DateFacture
,'' as SemaineDateFacture
,'' as MoisDateFacture
,'' as AnneeDateFacture
,'' as AnneeMoisDateFacture
,'' as AnneeSemaineDateFacture
,'' as TypeEcritureFinanciere
,'' as NumeroFacture
,cde.t_cofc as Service
,cde.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lcde.t_odat as DateCommande
,convert(int,datepart(isowk, lcde.t_odat)) as SemaineDateCommande
,convert(int,month(lcde.t_odat)) as MoisDateCommande
,year(lcde.t_odat) as AnneeDateCommande
,concat(year(lcde.t_odat), ' - ', month(lcde.t_odat)) as AnneeMoisDateCommande
,concat(year(lcde.t_odat), ' - ', datepart(isowk, lcde.t_odat)) as AnneeSemaineDateCommande
,lcde.t_orno as CommandeClient
,lcde.t_pono as Position
,lcde.t_sqnb as Sequence
,cde.t_sotp as TypeCommandeClient
,typecdecli.t_dsca as DescriptionTypeCommandeClient
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,lcde.t_serl as NumeroSerie
,lcdeart.t_citg as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,left(lcdeart.t_citg,2) as Activite
,act.t_desc as LibelleActivite
,lcdeart.t_csgs as GroupeStatistiqueVente
,lcdeart.t_cpcl as ClasseProduit
,cde.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
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
,datepart(isowk, lcde.t_prdt) as SemaineDateMADCPrevue
,month(lcde.t_prdt) as MoisDateMADCPrevue
,year(lcde.t_prdt) as AnneeDateMADCPrevue
,livcde.t_dldt as DateLivraisonReelle
,cde.t_osrp as RepresentantExterne
,empb.t_nama as NomRepresentantExterne
,cde.t_ofad as AdresseCommande
,adr.t_dsca as NomVille
,adr.t_pstc as CodePostalCommande
,left(adr.t_pstc, 2) as Departement
,cde.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,marq.t_dsca as NomContremarque
,cde.t_clin as ClientIndirect
,clin.t_nama as NomClientIndirect
,cde.t_clfi as ClientFinal
,clfi.t_nama as NomClientFinal
,'0' as MontantFacture
,lcde.t_oamt / lcde.t_rats_1 as Montant
--,livcde.t_namt / lcde.t_rats_1 as MontantAFacturer
,lcde.t_oamt / lcde.t_rats_1 as MontantAFacturer
,cde.t_ccur as DeviseCommande
,left(cde.t_cofc,2) as UE
,ue.t_desc as Site
,cde.t_stad as AdresseLivree
,adrl.t_dsca as NomVilleLivree
,adrl.t_pstc as CodePostalLivre
,left(adrl.t_pstc, 2) as DepartementLivre
,cde.t_corg as CodeOrigineOrdre
,dbo.convertenum('td','B61C','a9','bull','sls.corg',cde.t_corg,'4') as OrigineOrdre
,lcde.t_bkyn as CodeBloquee
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_bkyn, '4') as Bloquee
,art.t_csig as CodeSignal
,cde.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,bloccde.t_hrea as Motif
,bloc.t_dsca as DescriptionMotif
,iif(dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo, '4') != '__ERROR__',dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo, '4')
	,dbo.convertlistcdf('tx','B61C','a9','ext','sdm',cde.t_cdf_sdmo, '4')) as StTransfo
from ttdsls401500 lcde --Lignes de Commandes Clients
left outer join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttdsls406500 livcde on livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb --Lignes de Livraison de Commandes Clients
left outer join ttdsls420500 bloccde on bloccde.t_orno = lcde.t_orno --Gestion de Blocage de la commande
left outer join ttdsls090500 bloc on bloc.t_hrea = bloccde.t_hrea --Motifs de Blocage
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttdsls411500 lcdeart on lcdeart.t_orno = cde.t_orno and lcdeart.t_pono = lcde.t_pono and lcdeart.t_sqnb = 0 --Données Articles de la Ligne de Commande
left outer join ttccom001500 empa on empa.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom001500 empb on empb.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join ttcmcs066500 chan on chan.t_chan = lcde.t_chan --Canaux de Distribution
left outer join tzgsls001500 marq on marq.t_cont = cde.t_cntr --Gestion des Contremarques
left outer join ttccom100500 clin on clin.t_bpid = cde.t_clin --Tiers - Client Indirect
left outer join ttccom100500 clfi on clfi.t_bpid = cde.t_clfi --Tiers - Client Final
left outer join ttccom100500 tiers on tiers.t_bpid = cde.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = cde.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = cde.t_itbp --Tiers - Facturé
left outer join ttccom130500 adr on adr.t_cadr = cde.t_ofad --Adresses Commandes
left outer join ttccom130500 adrl on adrl.t_cadr = cde.t_stad --Adresses Livrées
left outer join ttcmcs023500 grpart on grpart.t_citg = lcdeart.t_citg --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = left(lcdeart.t_citg,2) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(cde.t_cofc,2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
left outer join ttdsls094500 typecdecli on typecdecli.t_sotp = cde.t_sotp --Type de Commandes Clients
where lcde.t_dldt = '01/01/1970' --Bornage sur la Date de Livraison qui doit être vide
and lcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
and lcde.t_clyn <> 1 --Bornage sur la Ligne de Commande qui ne doit pas être Annulée
union
select 'A Facturer 2' as Source
,'2' as CodeSource
,'01/01/1970' as DateFacture
,'' as SemaineDateFacture
,'' as MoisDateFacture
,'' as AnneeDateFacture
,'' as AnneeMoisDateFacture
,'' as AnneeSemaineDateFacture
,'' as TypeEcritureFinanciere
,'' as NumeroFacture
,cde.t_cofc as Service
,cde.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lcde.t_odat as DateCommande
,convert(int,datepart(isowk, lcde.t_odat)) as SemaineDateCommande
,convert(int,month(lcde.t_odat)) as MoisDateCommande
,year(lcde.t_odat) as AnneeDateCommande
,concat(year(lcde.t_odat), ' - ', month(lcde.t_odat)) as AnneeMoisDateCommande
,concat(year(lcde.t_odat), ' - ', datepart(isowk, lcde.t_odat)) as AnneeSemaineDateCommande
,livcde.t_orno as CommandeClient
,livcde.t_pono as Position
,livcde.t_sqnb as Sequence
,cde.t_sotp as TypeCommandeClient
,typecdecli.t_dsca as DescriptionTypeCommandeClient
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,lcde.t_serl as NumeroSerie
,lcdeart.t_citg as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,left(lcdeart.t_citg,2) as Activite
,act.t_desc as LibelleActivite
,lcdeart.t_csgs as GroupeStatistiqueVente
,lcdeart.t_cpcl as ClasseProduit
,cde.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
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
,datepart(isowk, lcde.t_prdt) as SemaineDateMADCPrevue
,month(lcde.t_prdt) as MoisDateMADCPrevue
,year(lcde.t_prdt) as AnneeDateMADCPrevue
,livcde.t_dldt as DateLivraisonReelle
,cde.t_osrp as RepresentantExterne
,empb.t_nama as NomRepresentantExterne
,cde.t_ofad as AdresseCommande
,adr.t_dsca as NomVille
,adr.t_pstc as CodePostalCommande
,left(adr.t_pstc, 2) as Departement
,cde.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,marq.t_dsca as NomContremarque
,cde.t_clin as ClientIndirect
,clin.t_nama as NomClientIndirect
,cde.t_clfi as ClientFinal
,clfi.t_nama as NomClientFinal
,'0' as MontantFacture
--,lcde.t_oamt / lcde.t_rats_1 as Montant
,livcde.t_namt / lcde.t_rats_1 as Montant
,livcde.t_namt / lcde.t_rats_1 as MontantAFacturer
,cde.t_ccur as DeviseCommande
,left(cde.t_cofc,2) as UE
,ue.t_desc as Site
,cde.t_stad as AdresseLivree
,adrl.t_dsca as NomVilleLivree
,adrl.t_pstc as CodePostalLivre
,left(adrl.t_pstc, 2) as DepartementLivre
,cde.t_corg as CodeOrigineOrdre
,dbo.convertenum('td','B61C','a9','bull','sls.corg',cde.t_corg,'4') as OrigineOrdre
,lcde.t_bkyn as CodeBloquee
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_bkyn, '4') as Bloquee
,art.t_csig as CodeSignal
,cde.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,bloccde.t_hrea as Motif
,bloc.t_dsca as DescriptionMotif
,iif(dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo, '4') != '__ERROR__',dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo, '4')
	,dbo.convertlistcdf('tx','B61C','a9','ext','sdm',cde.t_cdf_sdmo, '4')) as StTransfo
from ttdsls401500 lcde --Lignes de Commandes Clients
left outer join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttdsls406500 livcde on livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb --Lignes de Livraison de Commandes Clients
left outer join ttdsls420500 bloccde on bloccde.t_orno = lcde.t_orno --Gestion de Blocage de la commande
left outer join ttdsls090500 bloc on bloc.t_hrea = bloccde.t_hrea --Motifs de Blocage
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttdsls411500 lcdeart on lcdeart.t_orno = cde.t_orno and lcdeart.t_pono = lcde.t_pono and lcdeart.t_sqnb = 0 --Données Articles de la Ligne de Commande
left outer join ttccom001500 empa on empa.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom001500 empb on empb.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join ttcmcs066500 chan on chan.t_chan = lcde.t_chan --Canaux de Distribution
left outer join tzgsls001500 marq on marq.t_cont = cde.t_cntr --Gestion des Contremarques
left outer join ttccom100500 clin on clin.t_bpid = cde.t_clin --Tiers - Client Indirect
left outer join ttccom100500 clfi on clfi.t_bpid = cde.t_clfi --Tiers - Client Final
left outer join ttccom100500 tiers on tiers.t_bpid = cde.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = cde.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = cde.t_itbp --Tiers - Facturé
left outer join ttccom130500 adr on adr.t_cadr = cde.t_ofad --Adresses Commandes
left outer join ttccom130500 adrl on adrl.t_cadr = cde.t_stad --Adresses Livrées
left outer join ttcmcs023500 grpart on grpart.t_citg = lcdeart.t_citg --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = left(lcdeart.t_citg,2) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(cde.t_cofc,2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
left outer join ttdsls094500 typecdecli on typecdecli.t_sotp = cde.t_sotp --Type de Commandes Clients
where lcde.t_dldt <> '01/01/1970' --Bornage sur la Date de Livraison qui ne doit pas être vide
and lcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
and livcde.t_invd = '01/01/1970' --Bornage sur la Date de Facture qui doit être vide
and livcde.t_stat < 20 --Le Statut doit être soit Ouvert (5), Approuvé (10) ou Lancé (15)
union
select distinct 'PV A Facturer 1' as Source
,'3' as CodeSource
,'01/01/1970' as DateFacture
,'' as SemaineDateFacture
,'' as MoisDateFacture
,'' as AnneeDateFacture
,'' as AnneeMoisDateFacture
,'' as AnneeSemaineDateFacture
,'' as TypeEcritureFinanciere
,'' as NumeroFacture
,'' as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,lprog.t_odat as DateCommande
,convert(int,datepart(isowk, lprog.t_odat)) as SemaineDateCommande
,convert(int,month(lprog.t_odat)) as MoisDateCommande
,year(lprog.t_odat) as AnneeDateCommande
,concat(year(lprog.t_odat), ' - ', month(lprog.t_odat)) as AnneeMoisDateCommande
,concat(year(lprog.t_odat), ' - ', datepart(isowk, lprog.t_odat)) as AnneeSemaineDateCommande
,lprog.t_schn as CommandeClient
,lprog.t_spon as Position
,lprog.t_revn as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,'' as Article
,'' as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,(select top 1 art.t_citg from ttcibd001500 art where art.t_item = lprog.t_item) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lprog.t_item) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lprog.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,lprog.t_qrrq as QuantiteCommandee
,lprog.t_qrrq as QuantiteALivrer
,'0' as QuantiteLivreeNonFacturee
,'' as QuantiteLivree
,lprog.t_sdat as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,datepart(isowk, lprog.t_sdat) as SemaineDateMADCPrevue
,month(lprog.t_sdat) as MoisDateMADCPrevue
,year(lprog.t_sdat) as AnneeDateMADCPrevue
--,'' as SemaineDateMADCPrevue
--,'' as MoisDateMADCPrevue
--,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,progven.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,'0' as MontantFacture
,lprog.t_samt as Montant
,lprog.t_samt as MontantAFacturer
,'' as DeviseCommande
,left(lprog.t_schn, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,progven.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from ttdsls307500 lprog --Lignes de Programme de Vente
left outer join ttccom100500 tiers on tiers.t_bpid = lprog.t_ofbp --Tiers - Acheteur
inner join ttdsls311500 progven on progven.t_schn = lprog.t_schn and progven.t_sctp = lprog.t_sctp and progven.t_revn = lprog.t_revn --Programmes de Ventes
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 art.t_citg from ttcibd001500 art where art.t_item = lprog.t_item) --Groupe Article
left outer join ttccom100500 tiersf on tiersf.t_bpid = progven.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = progven.t_itbp --Tiers - Facturé
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lprog.t_item) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(lprog.t_schn,2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lprog.t_stat < 6 --Bornage sur le statut qui doit être inférieur à 6 (Expédié partiellement), cela correspond à tout ce qui est à livrer
and lprog.t_sctp = 2 --On ne prend que les programmes d'expédition
and lprog.t_revn = (select top 1 prog1.t_revn from ttdsls307500 prog1 where prog1.t_schn = lprog.t_schn and prog1.t_sctp = lprog.t_sctp order by prog1.t_revn desc) --On prend la dernière révision
and progven.t_stat != 4 --On enlève les programmes résiliés
and progven.t_stat != 5 --On enlève les programmes au statut résiliation en cours
union 
select distinct 'PV A Facturer 2' as Source
,'4' as CodeSource
,'01/01/1970' as DateFacture
,'' as SemaineDateFacture
,'' as MoisDateFacture
,'' as AnneeDateFacture
,'' as AnneeMoisDateFacture
,'' as AnneeSemaineDateFacture
,'' as TypeEcritureFinanciere
,'' as NumeroFacture
,'' as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,lprog.t_odat as DateCommande
,convert(int,datepart(isowk, lprog.t_odat)) as SemaineDateCommande
,convert(int,month(lprog.t_odat)) as MoisDateCommande
,year(lprog.t_odat) as AnneeDateCommande
,concat(year(lprog.t_odat), ' - ', month(lprog.t_odat)) as AnneeMoisDateCommande
,concat(year(lprog.t_odat), ' - ', datepart(isowk, lprog.t_odat)) as AnneeSemaineDateCommande
,lprog.t_schn as CommandeClient
,lprog.t_spon as Position
,lprog.t_revn as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,'' as Article
,'' as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,(select top 1 art.t_citg from ttcibd001500 art where art.t_item = lprog.t_item) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lprog.t_item) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lprog.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,lprog.t_qrrq as QuantiteCommandee
,lprog.t_qrrq as QuantiteALivrer
,'0' as QuantiteLivreeNonFacturee
,'' as QuantiteLivree
,lprog.t_sdat as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,datepart(isowk, lprog.t_sdat) as SemaineDateMADCPrevue
,month(lprog.t_sdat) as MoisDateMADCPrevue
,year(lprog.t_sdat) as AnneeDateMADCPrevue
--,'' as SemaineDateMADCPrevue
--,'' as MoisDateMADCPrevue
--,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,progven.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,'0' as MontantFacture
,lprog.t_samt as Montant
,lprog.t_samt as MontantAFacturer
,'' as DeviseCommande
,left(lprog.t_schn, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,progven.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from ttdsls307500 lprog --Lignes de Programme de Vente
left outer join ttccom100500 tiers on tiers.t_bpid = lprog.t_ofbp --Tiers - Acheteur
inner join ttdsls311500 progven on progven.t_schn = lprog.t_schn and progven.t_sctp = lprog.t_sctp and progven.t_revn = lprog.t_revn --Programmes de Ventes
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 art.t_citg from ttcibd001500 art where art.t_item = lprog.t_item) --Groupe Article
left outer join ttccom100500 tiersf on tiersf.t_bpid = progven.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = progven.t_itbp --Tiers - Facturé
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lprog.t_item) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(lprog.t_schn,2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lprog.t_stat >= 6 and lprog.t_stat < 9 --Bornage sur le statut qui doit être supérieur ou égal à 6 (Expédié partiellement), et inférieur à 9 (Facturé) cela correspond à tout ce qui est livré et à facturer
and lprog.t_sctp = 2 --On ne prend que les programmes d'expéditions
and lprog.t_revn = (select top 1 prog1.t_revn from ttdsls307500 prog1 where prog1.t_schn = lprog.t_schn and prog1.t_sctp = lprog.t_sctp order by prog1.t_revn desc) --On prend la dernière révision
and progven.t_stat != 4 --On enlève les programmes résiliés
and progven.t_stat != 5 --On enlève les programmes au statut résiliation en cours
union
select 'Facturé' as Source
,'5' as CodeSource
,livcde.t_invd as DateFacture
,convert(int,datepart(isowk, livcde.t_invd)) as SemaineDateFacture
,convert(int,month(livcde.t_invd)) as MoisDateFacture
,year(livcde.t_invd) as AnneeDateFacture
,concat(year(livcde.t_invd), ' - ', month(livcde.t_invd)) as AnneeMoisDateFacture
,concat(year(livcde.t_invd), ' - ', datepart(isowk, livcde.t_invd)) as AnneeSemaineDateFacture
,livcde.t_ttyp as TypeEcritureFinanciere
,livcde.t_invn as NumeroFacture
,cde.t_cofc as Service
,cde.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lcde.t_odat as DateCommande
,convert(int,datepart(isowk, lcde.t_odat)) as SemaineDateCommande
,convert(int,month(lcde.t_odat)) as MoisDateCommande
,year(lcde.t_odat) as AnneeDateCommande
,concat(year(lcde.t_odat), ' - ', month(lcde.t_odat)) as AnneeMoisDateCommande
,concat(year(lcde.t_odat), ' - ', datepart(isowk, lcde.t_odat)) as AnneeSemaineDateCommande
,livcde.t_orno as CommandeClient
,livcde.t_pono as Position
,livcde.t_sqnb as Sequence
,cde.t_sotp as TypeCommandeClient
--,'' as TypeCommandeClient
,typecdecli.t_dsca as DescriptionTypeCommandeClient
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,lcde.t_serl as NumeroSerie
,lcdeart.t_citg as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,left(lcdeart.t_citg,2) as Activite
,act.t_desc as LibelleActivite
,lcdeart.t_csgs as GroupeStatistiqueVente
,lcdeart.t_cpcl as ClasseProduit
,cde.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
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
,datepart(isowk, lcde.t_prdt) as SemaineDateMADCPrevue
,month(lcde.t_prdt) as MoisDateMADCPrevue
,year(lcde.t_prdt) as AnneeDateMADCPrevue
,livcde.t_dldt as DateLivraisonReelle
,cde.t_osrp as RepresentantExterne
,empb.t_nama as NomRepresentantExterne
,cde.t_ofad as AdresseCommande
,adr.t_dsca as NomVille
,adr.t_pstc as CodePostalCommande
,left(adr.t_pstc, 2) as Departement
,cde.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,marq.t_dsca as NomContremarque
,cde.t_clin as ClientIndirect
,clin.t_nama as NomClientIndirect
,cde.t_clfi as ClientFinal
,clfi.t_nama as NomClientFinal
,livcde.t_namt / lcde.t_rats_1 as MontantFacture
,livcde.t_namt / lcde.t_rats_1 as Montant
--,lcde.t_oamt / lcde.t_rats_1 as Montant
,'0' as MontantAFacturer
,cde.t_ccur as DeviseCommande
,substring(cde.t_cofc,1,2) as UE
,ue.t_desc as Site
,cde.t_stad as AdresseLivree
,adrl.t_dsca as NomVilleLivree
,adrl.t_pstc as CodePostalLivre
,left(adrl.t_pstc, 2) as DepartementLivre
,cde.t_corg as CodeOrigineOrdre
,dbo.convertenum('td','B61C','a9','bull','sls.corg',cde.t_corg,'4') as OrigineOrdre
,lcde.t_bkyn as CodeBloquee
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_bkyn, '4') as Bloquee
,art.t_csig as CodeSignal
,cde.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,iif(dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo, '4') != '__ERROR__',dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo, '4')
	,dbo.convertlistcdf('tx','B61C','a9','ext','sdm',cde.t_cdf_sdmo, '4')) as StTransfo
from ttdsls406500 livcde --Lignes de Commandes Clients livrées
inner join ttdsls400500 cde on cde.t_orno = livcde.t_orno --Commandes Clients
inner join ttdsls401500 lcde on lcde.t_orno = livcde.t_orno and lcde.t_pono = livcde.t_pono and lcde.t_sqnb = livcde.t_sqnb --Lignes de Livraison de Commandes Clients
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttdsls411500 lcdeart on lcdeart.t_orno = livcde.t_orno and lcdeart.t_pono = lcde.t_pono and lcdeart.t_sqnb = 0 --Données Articles de la Ligne de Commande
left outer join ttccom001500 empa on empa.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom001500 empb on empb.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join ttcmcs066500 chan on chan.t_chan = lcde.t_chan --Canaux de Distribution
left outer join tzgsls001500 marq on marq.t_cont = cde.t_cntr --Gestion des Contremarques
left outer join ttccom100500 clin on clin.t_bpid = cde.t_clin --Tiers - Client Indirect
left outer join ttccom100500 clfi on clfi.t_bpid = cde.t_clfi --Tiers - Client Final
left outer join ttccom100500 tiers on tiers.t_bpid = cde.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = cde.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = cde.t_itbp --Tiers - Facturé
left outer join ttccom130500 adr on adr.t_cadr = cde.t_ofad --Adresses Commandes
left outer join ttccom130500 adrl on adrl.t_cadr = cde.t_stad --Adresses Livrées
left outer join ttcmcs023500 grpart on grpart.t_citg = lcdeart.t_citg --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = left(lcdeart.t_citg,2) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(cde.t_cofc,2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
left outer join ttdsls094500 typecdecli on typecdecli.t_sotp = cde.t_sotp --Type de Commandes Clients
where livcde.t_invd <> '01/01/1970' --Bornage sur les Dates de Facture qui ne sont pas vides, autrement dit la facture existe
union
select distinct 'Programme de Vente' as Source
,'6' as CodeSource
,llivpv.t_invd as DateFacture
,convert(int,datepart(isowk, llivpv.t_invd)) as SemaineDateFacture
,convert(int,month(llivpv.t_invd)) as MoisDateFacture
,year(llivpv.t_invd) as AnneeDateFacture
,concat(year(llivpv.t_invd), ' - ', month(llivpv.t_invd)) as AnneeMoisDateFacture
,concat(year(llivpv.t_invd), ' - ', datepart(isowk, llivpv.t_invd)) as AnneeSemaineDateFacture
,llivpv.t_ttyp as TypeEcritureFinanciere
,llivpv.t_invn as NumeroFacture
,'' as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,lprog.t_odat as DateCommande
,convert(int,datepart(isowk, lprog.t_odat)) as SemaineDateCommande
,convert(int,month(lprog.t_odat)) as MoisDateCommande
,year(lprog.t_odat) as AnneeDateCommande
,concat(year(lprog.t_odat), ' - ', month(lprog.t_odat)) as AnneeMoisDateCommande
,concat(year(lprog.t_odat), ' - ', datepart(isowk, lprog.t_odat)) as AnneeSemaineDateCommande
,lprog.t_schn as CommandeClient
,lprog.t_spon as Position
,lprog.t_revn as Sequence
,'' as TypeCommandeClient
--,llivpv.t_sctp as TypeCommandeClient
,dbo.convertenum('td','B61C','a9','bull','sls.reltype',llivpv.t_sctp,'4') as DescriptionTypeCommandeClient
,left(lprog.t_item, 9) as Projet
,substring(lprog.t_item, 10, len(lprog.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,'' as NumeroSerie
,art.t_citg as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,left(art.t_citg, 2) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lprog.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,lprog.t_qrrq as QuantiteCommandee
,(ompv.t_qoor - ompv.t_qidl) as QuantiteALivrer
,'0' as QuantiteLivreeNonFacturee
,llivpv.t_qnvc as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,llivpv.t_dldt as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,llivpv.t_stad as AdresseCommande
,vil.t_dsca as NomVille
,adr.t_pstc as CodePostalCommande
,adr.t_cste as Departement
,progven.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,llivpv.t_namt as MontantFacture
,llivpv.t_namt as Montant
,'0' as MontantAFacturer
,'' as DeviseCommande
,left(llivpv.t_schn, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,progven.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from ttdsls340500 llivpv --Lignes de Livraison de Programme de Vente Réelles
inner join ttdsls321500 ompv on ompv.t_worn = llivpv.t_schn and ompv.t_wpon = llivpv.t_wpon and ompv.t_wsqn = llivpv.t_wsqn and ompv.t_sctp = llivpv.t_sctp --Liens Ordres Magasins Planifiés et Programmes de Ventes
inner join ttdsls307500 lprog on lprog.t_schn = ompv.t_schn and lprog.t_spon = ompv.t_spon and lprog.t_revn = ompv.t_revn and lprog.t_sctp = ompv.t_sctp --Lignes de Programmes de Ventes
inner join ttdsls311500 progven on progven.t_schn = lprog.t_schn and progven.t_sctp = lprog.t_sctp and progven.t_revn = lprog.t_revn --Programmes de Ventes
inner join ttcibd001500 art on art.t_item = lprog.t_item --Articles
inner join ttccom100500 tiers on tiers.t_bpid = lprog.t_ofbp --Tiers - Acheteur
left outer join ttccom130500 adr on adr.t_cadr = llivpv.t_stad --Adresses
left outer join ttccom139500 vil on vil.t_city = adr.t_ccit and vil.t_ccty = adr.t_ccty and vil.t_cste = adr.t_cste --Villes
left outer join ttccom100500 tiersf on tiersf.t_bpid = progven.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = progven.t_itbp --Tiers - Facturé
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = left(art.t_citg, 2) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(llivpv.t_schn, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where llivpv.t_stat between 9 and 10 --Bornage sur le statut qui doit être Facturé (9) ou Traité (10)
and lprog.t_sctp = 2 --On ne prend que les programmes d'expéditions
/*union
select distinct 'Programme de Vente' as Source
,'6' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,'' as CommandeClient
,'' as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,'' as Article
,'' as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,(select top 1 art.t_citg from ttcibd001500 art where art.t_item = lfac.t_item) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lfac.t_item) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,(select sum(lfact.t_dqua) from tcisli310500 lfact where lfact.t_sfcp = lfac.t_sfcp and lfact.t_idoc = lfac.t_idoc and lfact.t_tran = lfac.t_tran and lfact.t_ofbp = lfac.t_ofbp and lfact.t_srtp = 40 and lfact.t_koor = 7) as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,(select sum(lfact.t_amti) from tcisli310500 lfact where lfact.t_sfcp = lfac.t_sfcp and lfact.t_idoc = lfac.t_idoc and lfact.t_tran = lfac.t_tran and lfact.t_ofbp = lfac.t_ofbp and lfact.t_srtp = 40 and lfact.t_koor = 7) as MontantFacture
,(select sum(lfact.t_amti) from tcisli310500 lfact where lfact.t_sfcp = lfac.t_sfcp and lfact.t_idoc = lfac.t_idoc and lfact.t_tran = lfac.t_tran and lfact.t_ofbp = lfac.t_ofbp and lfact.t_srtp = 40 and lfact.t_koor = 7) as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305500 fact --En-tête de facture
inner join tcisli310500 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 art.t_citg from ttcibd001500 art where art.t_item = lfac.t_item) --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(art.t_citg, 2) from ttcibd001500 art where art.t_item = lfac.t_item) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 40 --Bornage sur le type de source qui doit être Commande Client
and lfac.t_koor = 7 --Bornage sur le type de source qui doit être Programme de Vente
*/
union 
select 'Bilatérale 500' as Source
,'7' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,lfac.t_tran as TypeEcritureFinanciere
,lfac.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,lfac.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lfac.t_odat as DateCommande
,convert(int,datepart(isowk, lfac.t_odat)) as SemaineDateCommande
,convert(int,month(lfac.t_odat)) as MoisDateCommande
,year(lfac.t_odat) as AnneeDateCommande
,concat(year(lfac.t_odat), ' - ', month(lfac.t_odat)) as AnneeMoisDateCommande
,concat(year(lfac.t_odat), ' - ', datepart(isowk, lfac.t_odat)) as AnneeSemaineDateCommande
,lfac.t_shpm as CommandeClient
,lfac.t_pono as Position
,lfac.t_line as Sequence
,'' as TypeCommandeClient
,'Ordre Magasin' as DescriptionTypeCommandeClient
,left(lfac.t_item, 9) as Projet
,substring(lfac.t_item, 10, len(lfac.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,'' as NumeroSerie
,(case len(art.t_citg)
when 6
	then art.t_citg
else 'LAK001'
end) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(case len(art.t_citg)
when 6
	then left(art.t_citg,2)
else 'LA'
end) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,lfac.t_shpm as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,lfac.t_ddat as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305500 fact --En-tête de facture
inner join tcisli310500 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttccom001500 empa on empa.t_emno = lfac.t_crep --Employés - Représentant Interne
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = (case len(art.t_citg) when 6 then art.t_citg else 'LAK001' end) --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = (case len(art.t_citg) when 6 then left(art.t_citg,2) else 'LA' end) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where lfac.t_srtp = 44 --Bornage sur le type de source qui doit être Ordre Magasin
and lfac.t_koor = 60 --Bornage sur la Quantité d'Achat Proposée qui doit être Transfert Magasin
union 
select 'Bilatérale 400' as Source
,'7' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,lfac.t_tran as TypeEcritureFinanciere
,lfac.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,lfac.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lfac.t_odat as DateCommande
,convert(int,datepart(isowk, lfac.t_odat)) as SemaineDateCommande
,convert(int,month(lfac.t_odat)) as MoisDateCommande
,year(lfac.t_odat) as AnneeDateCommande
,concat(year(lfac.t_odat), ' - ', month(lfac.t_odat)) as AnneeMoisDateCommande
,concat(year(lfac.t_odat), ' - ', datepart(isowk, lfac.t_odat)) as AnneeSemaineDateCommande
,lfac.t_shpm as CommandeClient
,lfac.t_pono as Position
,lfac.t_line as Sequence
,'' as TypeCommandeClient
,'Ordre Magasin' as DescriptionTypeCommandeClient
,left(lfac.t_item, 9) as Projet
,substring(lfac.t_item, 10, len(lfac.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,'' as NumeroSerie
,(case len(art.t_citg)
when 6
	then art.t_citg
else 'LAK001'
end) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(case len(art.t_citg)
when 6
	then left(art.t_citg,2)
else 'LA'
end) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,lfac.t_shpm as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,lfac.t_ddat as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305400 fact --En-tête de facture
inner join tcisli310400 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttccom001500 empa on empa.t_emno = lfac.t_crep --Employés - Représentant Interne
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = (case len(art.t_citg) when 6 then art.t_citg else 'LAK001' end) --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = (case len(art.t_citg) when 6 then left(art.t_citg,2) else 'LA' end) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where lfac.t_srtp = 44 --Bornage sur le type de source qui doit être Ordre Magasin
and lfac.t_koor = 60 --Bornage sur la Quantité d'Achat Proposée qui doit être Transfert Magasin
union 
select 'Bilatérale 600' as Source
,'7' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,lfac.t_tran as TypeEcritureFinanciere
,lfac.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,lfac.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lfac.t_odat as DateCommande
,convert(int,datepart(isowk, lfac.t_odat)) as SemaineDateCommande
,convert(int,month(lfac.t_odat)) as MoisDateCommande
,year(lfac.t_odat) as AnneeDateCommande
,concat(year(lfac.t_odat), ' - ', month(lfac.t_odat)) as AnneeMoisDateCommande
,concat(year(lfac.t_odat), ' - ', datepart(isowk, lfac.t_odat)) as AnneeSemaineDateCommande
,lfac.t_shpm as CommandeClient
,lfac.t_pono as Position
,lfac.t_line as Sequence
,'' as TypeCommandeClient
,'Ordre Magasin' as DescriptionTypeCommandeClient
,left(lfac.t_item, 9) as Projet
,substring(lfac.t_item, 10, len(lfac.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,'' as NumeroSerie
,(case len(art.t_citg)
when 6
	then art.t_citg
else 'LAK001'
end) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(case len(art.t_citg)
when 6
	then left(art.t_citg,2)
else 'LA'
end) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,lfac.t_shpm as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,lfac.t_ddat as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305600 fact --En-tête de facture
inner join tcisli310600 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttccom001500 empa on empa.t_emno = lfac.t_crep --Employés - Représentant Interne
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = (case len(art.t_citg) when 6 then art.t_citg else 'LAK001' end) --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = (case len(art.t_citg) when 6 then left(art.t_citg,2) else 'LA' end) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where lfac.t_srtp = 44 --Bornage sur le type de source qui doit être Ordre Magasin
and lfac.t_koor = 60 --Bornage sur la Quantité d'Achat Proposée qui doit être Transfert Magasin
union 
select 'Bilatérale 610' as Source
,'7' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,lfac.t_tran as TypeEcritureFinanciere
,lfac.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,lfac.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lfac.t_odat as DateCommande
,convert(int,datepart(isowk, lfac.t_odat)) as SemaineDateCommande
,convert(int,month(lfac.t_odat)) as MoisDateCommande
,year(lfac.t_odat) as AnneeDateCommande
,concat(year(lfac.t_odat), ' - ', month(lfac.t_odat)) as AnneeMoisDateCommande
,concat(year(lfac.t_odat), ' - ', datepart(isowk, lfac.t_odat)) as AnneeSemaineDateCommande
,lfac.t_shpm as CommandeClient
,lfac.t_pono as Position
,lfac.t_line as Sequence
,'' as TypeCommandeClient
,'Ordre Magasin' as DescriptionTypeCommandeClient
,left(lfac.t_item, 9) as Projet
,substring(lfac.t_item, 10, len(lfac.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,'' as NumeroSerie
,(case len(art.t_citg)
when 6
	then art.t_citg
else 'LAK001'
end) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(case len(art.t_citg)
when 6
	then left(art.t_citg,2)
else 'LA'
end) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,lfac.t_shpm as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,lfac.t_ddat as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305610 fact --En-tête de facture
inner join tcisli310610 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttccom001500 empa on empa.t_emno = lfac.t_crep --Employés - Représentant Interne
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = (case len(art.t_citg) when 6 then art.t_citg else 'LAK001' end) --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = (case len(art.t_citg) when 6 then left(art.t_citg,2) else 'LA' end) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where lfac.t_srtp = 44 --Bornage sur le type de source qui doit être Ordre Magasin
and lfac.t_koor = 60 --Bornage sur la Quantité d'Achat Proposée qui doit être Transfert Magasin
union 
select 'Bilatérale 620' as Source
,'7' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,lfac.t_tran as TypeEcritureFinanciere
,lfac.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,lfac.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lfac.t_odat as DateCommande
,convert(int,datepart(isowk, lfac.t_odat)) as SemaineDateCommande
,convert(int,month(lfac.t_odat)) as MoisDateCommande
,year(lfac.t_odat) as AnneeDateCommande
,concat(year(lfac.t_odat), ' - ', month(lfac.t_odat)) as AnneeMoisDateCommande
,concat(year(lfac.t_odat), ' - ', datepart(isowk, lfac.t_odat)) as AnneeSemaineDateCommande
,lfac.t_shpm as CommandeClient
,lfac.t_pono as Position
,lfac.t_line as Sequence
,'' as TypeCommandeClient
,'Ordre Magasin' as DescriptionTypeCommandeClient
,left(lfac.t_item, 9) as Projet
,substring(lfac.t_item, 10, len(lfac.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,'' as NumeroSerie
,(case len(art.t_citg)
when 6
	then art.t_citg
else 'LAK001'
end) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(case len(art.t_citg)
when 6
	then left(art.t_citg,2)
else 'LA'
end) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,lfac.t_shpm as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,lfac.t_ddat as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305620 fact --En-tête de facture
inner join tcisli310620 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttccom001500 empa on empa.t_emno = lfac.t_crep --Employés - Représentant Interne
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = (case len(art.t_citg) when 6 then art.t_citg else 'LAK001' end) --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = (case len(art.t_citg) when 6 then left(art.t_citg,2) else 'LA' end) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where lfac.t_srtp = 44 --Bornage sur le type de source qui doit être Ordre Magasin
and lfac.t_koor = 60 --Bornage sur la Quantité d'Achat Proposée qui doit être Transfert Magasin
union 
select 'Bilatérale 630' as Source
,'7' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,lfac.t_tran as TypeEcritureFinanciere
,lfac.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,lfac.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lfac.t_odat as DateCommande
,convert(int,datepart(isowk, lfac.t_odat)) as SemaineDateCommande
,convert(int,month(lfac.t_odat)) as MoisDateCommande
,year(lfac.t_odat) as AnneeDateCommande
,concat(year(lfac.t_odat), ' - ', month(lfac.t_odat)) as AnneeMoisDateCommande
,concat(year(lfac.t_odat), ' - ', datepart(isowk, lfac.t_odat)) as AnneeSemaineDateCommande
,lfac.t_shpm as CommandeClient
,lfac.t_pono as Position
,lfac.t_line as Sequence
,'' as TypeCommandeClient
,'Ordre Magasin' as DescriptionTypeCommandeClient
,left(lfac.t_item, 9) as Projet
,substring(lfac.t_item, 10, len(lfac.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,'' as NumeroSerie
,(case len(art.t_citg)
when 6
	then art.t_citg
else 'LAK001'
end) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(case len(art.t_citg)
when 6
	then left(art.t_citg,2)
else 'LA'
end) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,lfac.t_shpm as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,lfac.t_ddat as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305630 fact --En-tête de facture
inner join tcisli310630 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttccom001500 empa on empa.t_emno = lfac.t_crep --Employés - Représentant Interne
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = (case len(art.t_citg) when 6 then art.t_citg else 'LAK001' end) --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = (case len(art.t_citg) when 6 then left(art.t_citg,2) else 'LA' end) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where lfac.t_srtp = 44 --Bornage sur le type de source qui doit être Ordre Magasin
and lfac.t_koor = 60 --Bornage sur la Quantité d'Achat Proposée qui doit être Transfert Magasin
union
select 'Service Matière' as Source
,'8' as CodeSource
,coutmat.t_invd as DateFacture
,convert(int,datepart(isowk, coutmat.t_invd)) as SemaineDateFacture
,convert(int,month(coutmat.t_invd)) as MoisDateFacture
,year(coutmat.t_invd) as AnneeDateFacture
,concat(year(coutmat.t_invd), ' - ', month(coutmat.t_invd)) as AnneeMoisDateFacture
,concat(year(coutmat.t_invd), ' - ', datepart(isowk, coutmat.t_invd)) as AnneeSemaineDateFacture
,coutmat.t_ityp as TypeEcritureFinanciere
,coutmat.t_idoc as NumeroFacture
,os.t_cwoc as Service
,os.t_emno as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,os.t_ordt as DateCommande
,convert(int,datepart(isowk, os.t_ordt)) as SemaineDateCommande
,convert(int,month(os.t_ordt))as MoisDateCommande
,year(os.t_ordt) as AnneeDateCommande
,concat(year(os.t_ordt), ' - ', month(os.t_ordt)) as AnneeMoisDateCommande
,concat(year(os.t_ordt), ' - ', datepart(isowk, os.t_ordt)) as AnneeSemaineDateCommande
,coutmat.t_orno as CommandeClient
,coutmat.t_lino as Position
,'' as Sequence
,'' as TypeCommandeClient
,'Ordre Service' as DescriptionTypeCommandeClient
,left(coutmat.t_item, 9) as Projet
,substring(coutmat.t_item, 10, len(coutmat.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,'' as NumeroSerie
,(select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = coutmat.t_orno) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = coutmat.t_orno) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,os.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,os.t_corn as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,coutmat.t_adqt as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,coutmat.t_adtm as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,tiersa.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,coutmat.t_inam / os.t_rats_1 as MontantFacture
,coutmat.t_inam / os.t_rats_1 as Montant
,'0' as MontantAFacturer
,os.t_ccur as DeviseCommande
,left(os.t_cwoc, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,os.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from ttssoc220500 coutmat --Couts matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = coutmat.t_orno --Ordre de Service
left outer join ttccom001500 empa on empa.t_emno = os.t_emno --Employés - Représentant Interne
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers - Acheteur
left outer join ttccom110500 tiersa on tiersa.t_ofbp = os.t_ofbp --Tiers Acheteur
left outer join ttcmcs066500 chan on chan.t_chan = tiersa.t_chan --Canaux de Distribution
left outer join ttccom100500 tiersf on tiersf.t_bpid = os.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = os.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = coutmat.t_item --Articles
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = coutmat.t_orno) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = coutmat.t_orno) --Groupe Article
left outer join ttfgld010500 ue on ue.t_dimx = left(os.t_cwoc, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
union
select 'Service MO' as Source
,'9' as CodeSource
,coutmo.t_invd as DateFacture
,convert(int,datepart(isowk, coutmo.t_invd)) as SemaineDateFacture
,convert(int,month(coutmo.t_invd)) as MoisDateFacture
,year(coutmo.t_invd) as AnneeDateFacture
,concat(year(coutmo.t_invd), ' - ', month(coutmo.t_invd)) as AnneeMoisDateFacture
,concat(year(coutmo.t_invd), ' - ', datepart(isowk, coutmo.t_invd)) as AnneeSemaineDateFacture
,coutmo.t_ityp as TypeEcritureFinanciere
,coutmo.t_idoc as NumeroFacture
,os.t_cwoc as Service
,os.t_emno as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,os.t_ordt as DateCommande
,convert(int,datepart(isowk, os.t_ordt)) as SemaineDateCommande
,convert(int,month(os.t_ordt)) as MoisDateCommande
,year(os.t_ordt) as AnneeDateCommande
,concat(year(os.t_ordt), ' - ', month(os.t_ordt)) as AnneeMoisDateCommande
,concat(year(os.t_ordt), ' - ', datepart(isowk, os.t_ordt)) as AnneeSemaineDateCommande
,coutmo.t_orno as CommandeClient
,coutmo.t_lino as Position
,'' as Sequence
,'' as TypeCommandeClient
,'Ordre Service' as DescriptionTypeCommandeClient
,'' as Projet
,'' as Article
,'' as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,(select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = coutmo.t_orno) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = coutmo.t_orno) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,os.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,os.t_corn as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,'' as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,tiersa.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,coutmo.t_inam / os.t_rats_1 as MontantFacture
,coutmo.t_inam / os.t_rats_1 as Montant
,'0' as MontantAFacturer
,os.t_ccur as DeviseCommande
,left(os.t_cwoc, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,os.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from ttssoc230500 coutmo --Couts matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = coutmo.t_orno --Ordre de Service
left outer join ttccom001500 empa on empa.t_emno = os.t_emno --Employés - Représentant Interne
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers - Acheteur
left outer join ttccom110500 tiersa on tiersa.t_ofbp = os.t_ofbp --Tiers Acheteur
left outer join ttcmcs066500 chan on chan.t_chan = tiersa.t_chan --Canaux de Distribution
left outer join ttccom100500 tiersf on tiersf.t_bpid = os.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = os.t_itbp --Tiers - Facturé
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = coutmo.t_orno) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = coutmo.t_orno) --Groupe Article
left outer join ttfgld010500 ue on ue.t_dimx = left(os.t_cwoc, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
union
select 'Service Autre' as Source
,'10' as CodeSource
,coutautre.t_invd as DateFacture
,convert(int,datepart(isowk, coutautre.t_invd)) as SemaineDateFacture
,convert(int,month(coutautre.t_invd)) as MoisDateFacture
,year(coutautre.t_invd) as AnneeDateFacture
,concat(year(coutautre.t_invd), ' - ', month(coutautre.t_invd)) as AnneeMoisDateFacture
,concat(year(coutautre.t_invd), ' - ', datepart(isowk, coutautre.t_invd)) as AnneeSemaineDateFacture
,coutautre.t_ityp as TypeEcritureFinanciere
,coutautre.t_idoc as NumeroFacture
,os.t_cwoc as Service
,os.t_emno as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,os.t_ordt as DateCommande
,convert(int,datepart(isowk, os.t_ordt)) as SemaineDateCommande
,convert(int,month(os.t_ordt)) as MoisDateCommande
,year(os.t_ordt) as AnneeDateCommande
,concat(year(os.t_ordt), ' - ', month(os.t_ordt)) as AnneeMoisDateCommande
,concat(year(os.t_ordt), ' - ', datepart(isowk, os.t_ordt)) as AnneeSemaineDateCommande
,coutautre.t_orno as CommandeClient
,coutautre.t_lino as Position
,'' as Sequence
,'' as TypeCommandeClient
,'Ordre Service' as DescriptionTypeCommandeClient
,'' as Projet
,'' as Article
,'' as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,(select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = coutautre.t_orno) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = coutautre.t_orno) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,os.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,os.t_corn as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,'' as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,tiersa.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,coutautre.t_inam / os.t_rats_1 as MontantFacture
,coutautre.t_inam / os.t_rats_1 as Montant
,'0' as MontantAFacturer
,os.t_ccur as DeviseCommande
,left(os.t_cwoc, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,os.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from ttssoc240500 coutautre --Couts matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = coutautre.t_orno --Ordre de Service
left outer join ttccom001500 empa on empa.t_emno = os.t_emno --Employés - Représentant Interne
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers - Acheteur
left outer join ttccom110500 tiersa on tiersa.t_ofbp = os.t_ofbp --Tiers Acheteur
left outer join ttcmcs066500 chan on chan.t_chan = tiersa.t_chan --Canaux de Distribution
left outer join ttccom100500 tiersf on tiersf.t_bpid = os.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = os.t_itbp --Tiers - Facturé
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = coutautre.t_orno) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = coutautre.t_orno) --Groupe Article
left outer join ttfgld010500 ue on ue.t_dimx = left(os.t_cwoc, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
union
select 'Service Prix Fixe' as Source
,'11' as CodeSource
,prixfixe.t_invd as DateFacture
,convert(int,datepart(isowk, prixfixe.t_invd)) as SemaineDateFacture
,convert(int,month(prixfixe.t_invd)) as MoisDateFacture
,year(prixfixe.t_invd) as AnneeDateFacture
,concat(year(prixfixe.t_invd), ' - ', month(prixfixe.t_invd)) as AnneeMoisDateFacture
,concat(year(prixfixe.t_invd), ' - ', datepart(isowk, prixfixe.t_invd)) as AnneeSemaineDateFacture
,prixfixe.t_ityp as TypeEcritureFinanciere
,prixfixe.t_idoc as NumeroFacture
,os.t_cwoc as Service
,os.t_emno as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,os.t_ordt as DateCommande
,convert(int,datepart(isowk, os.t_ordt)) as SemaineDateCommande
,convert(int,month(os.t_ordt)) as MoisDateCommande
,year(os.t_ordt) as AnneeDateCommande
,concat(year(os.t_ordt), ' - ', month(os.t_ordt)) as AnneeMoisDateCommande
,concat(year(os.t_ordt), ' - ', datepart(isowk, os.t_ordt)) as AnneeSemaineDateCommande
,prixfixe.t_orno as CommandeClient
,prixfixe.t_acln as Position
,'' as Sequence
,'' as TypeCommandeClient
,'Ordre Service' as DescriptionTypeCommandeClient
,'' as Projet
,'' as Article
,'' as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,(select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = prixfixe.t_orno) as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,(select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = prixfixe.t_orno) as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,os.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,os.t_corn as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,'' as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,tiersa.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,tarif.t_pris / os.t_rats_1 as MontantFacture
,tarif.t_pris / os.t_rats_1 as Montant
,'0' as MontantAFacturer
,os.t_ccur as DeviseCommande
,left(os.t_cwoc, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,os.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from ttssoc215500 prixfixe --Ordres de Service - Prix Fixe
inner join ttstdm100500 tarif on tarif.t_prid = prixfixe.t_prid and tarif.t_pobr = prixfixe.t_acln --Informations sur les tarifs
inner join ttssoc200500 os on os.t_orno = prixfixe.t_orno --Ordre de Service
left outer join ttccom001500 empa on empa.t_emno = os.t_emno --Employés - Représentant Interne
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers - Acheteur
left outer join ttccom110500 tiersa on tiersa.t_ofbp = os.t_ofbp --Tiers Acheteur
left outer join ttcmcs066500 chan on chan.t_chan = tiersa.t_chan --Canaux de Distribution
left outer join ttccom100500 tiersf on tiersf.t_bpid = os.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = os.t_itbp --Tiers - Facturé
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = prixfixe.t_orno) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = prixfixe.t_orno) --Groupe Article
left outer join ttfgld010500 ue on ue.t_dimx = left(os.t_cwoc, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
union
select distinct 'Contrat TP' as Source
,'12' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,'' as TypeEcritureFinanciere
,'' as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,'' as CommandeClient
,'' as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,'' as Article
,'' as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,'IAR001' as GroupeArticle
,'Régularisation Etudes' as DescriptionGroupeArticle
,'IA' as Activite
,'Services' as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,fact.t_itbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,(select sum(lfact.t_dqua) from tcisli310500 lfact inner join tcisli305500 factu on factu.t_sfcp = lfact.t_sfcp and factu.t_tran = lfact.t_tran and factu.t_idoc = lfact.t_idoc where factu.t_idat = fact.t_idat and factu.t_itbp = fact.t_itbp and lfact.t_srtp = 30) as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,'' as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,(select sum(lfact.t_amti) from tcisli310500 lfact inner join tcisli305500 factu on factu.t_sfcp = lfact.t_sfcp and factu.t_tran = lfact.t_tran and factu.t_idoc = lfact.t_idoc where factu.t_idat = fact.t_idat and factu.t_itbp = fact.t_itbp and lfact.t_srtp = 30) as MontantFacture
,(select sum(lfact.t_amti) from tcisli310500 lfact inner join tcisli305500 factu on factu.t_sfcp = lfact.t_sfcp and factu.t_tran = lfact.t_tran and factu.t_idoc = lfact.t_idoc where factu.t_idat = fact.t_idat and factu.t_itbp = fact.t_itbp and lfact.t_srtp = 30) as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305500 fact --En-tête de facture
inner join tcisli310500 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttccom100500 tiers on tiers.t_bpid = fact.t_itbp --Tiers - Acheteur
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1'
where lfac.t_srtp = 30 --Bornage sur le type de source qui doit être Contrat
union
select distinct 'Factures Manuelles 500' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305500 fact --En-tête de facture
inner join tcisli310500 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225500 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select distinct 'Factures Manuelles 400' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305400 fact --En-tête de facture
inner join tcisli310400 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225400 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select distinct 'Factures Manuelles 600' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305600 fact --En-tête de facture
inner join tcisli310600 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225600 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select distinct 'Factures Manuelles 610' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305610 fact --En-tête de facture
inner join tcisli310610 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225610 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select distinct 'Factures Manuelles 620' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305620 fact --En-tête de facture
inner join tcisli310620 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225620 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select distinct 'Factures Manuelles 630' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305630 fact --En-tête de facture
inner join tcisli310630 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225630 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select distinct 'Factures Manuelles 720' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305720 fact --En-tête de facture
inner join tcisli310720 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225720 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
/*
union
select distinct 'Factures Manuelles 100' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305100 fact --En-tête de facture
inner join tcisli310100 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225100 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 101' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305101 fact --En-tête de facture
inner join tcisli310101 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225101 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 102' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305102 fact --En-tête de facture
inner join tcisli310102 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225102 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 103' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305103 fact --En-tête de facture
inner join tcisli310103 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225103 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 104' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305104 fact --En-tête de facture
inner join tcisli310104 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225104 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 105' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305105 fact --En-tête de facture
inner join tcisli310105 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225105 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 106' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305106 fact --En-tête de facture
inner join tcisli310106 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225106 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select distinct 'Factures Manuelles 107' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305107 fact --En-tête de facture
inner join tcisli310107 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225107 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select distinct 'Factures Manuelles 108' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305108 fact --En-tête de facture
inner join tcisli310108 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225108 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select distinct 'Factures Manuelles 109' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305109 fact --En-tête de facture
inner join tcisli310109 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225109 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 110' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305110 fact --En-tête de facture
inner join tcisli310110 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225110 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 111' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305111 fact --En-tête de facture
inner join tcisli310111 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225111 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 112' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305112 fact --En-tête de facture
inner join tcisli310112 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225112 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
/*union
select distinct 'Factures Manuelles 120' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,datepart(isowk, fact.t_idat) as SemaineDateFacture
,month(fact.t_idat) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
from tcisli305120 fact --En-tête de facture
inner join tcisli310120 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225120 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
*/
union
select distinct 'Factures Manuelles 130' as Source
,'13' as CodeSource
,fact.t_idat as DateFacture
,convert(int,datepart(isowk, fact.t_idat)) as SemaineDateFacture
,convert(int,month(fact.t_idat)) as MoisDateFacture
,year(fact.t_idat) as AnneeDateFacture
,concat(year(fact.t_idat), ' - ', month(fact.t_idat)) as AnneeMoisDateFacture
,concat(year(fact.t_idat), ' - ', datepart(isowk, fact.t_idat)) as AnneeSemaineDateFacture
,fact.t_tran as TypeEcritureFinanciere
,fact.t_idoc as NumeroFacture
,fact.t_fdpt as Service
,'' as RepresentantInterne
,'' as NomRepresentantInterne
,'' as DateCommande
,'' as SemaineDateCommande
,'' as MoisDateCommande
,'' as AnneeDateCommande
,'' as AnneeMoisDateCommande
,'' as AnneeSemaineDateCommande
,lfac.t_orno as CommandeClient
,lfac.t_pono as Position
,'' as Sequence
,'' as TypeCommandeClient
,'' as DescriptionTypeCommandeClient
,'' as Projet
,lfac.t_item as Article
,art.t_dsca as DescriptionArticle
,'' as CodeTypeArticle
,'' as TypeArticle
,'' as NumeroSerie
,facliman.t_dim4 as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,facliman.t_dim3 as Activite
,act.t_desc as LibelleActivite
,'' as GroupeStatistiqueVente
,'' as ClasseProduit
,lfac.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,'' as CommandeDuClient
,'' as QuantiteCommandee
,'' as QuantiteALivrer
,'' as QuantiteLivreeNonFacturee
,lfac.t_dqua as QuantiteLivree
,'' as DateLivraisonPlanifiee
,'' as DateMADCPrevue
,'' as SemaineDateMADCPrevue
,'' as MoisDateMADCPrevue
,'' as AnneeDateMADCPrevue
,'' as DateLivraisonReelle
,'' as RepresentantExterne
,'' as NomRepresentantExterne
,'' as AdresseCommande
,'' as NomVille
,'' as CodePostalCommande
,'' as Departement
,lfac.t_creg as Zone
,'' as DescriptionCanauxDistribution
,facliman.t_dim8 as NomContremarque
,'' as ClientIndirect
,'' as NomClientIndirect
,'' as ClientFinal
,'' as NomClientFinal
,lfac.t_amti as MontantFacture
,lfac.t_amti as Montant
,'0' as MontantAFacturer
,fact.t_ccur as DeviseCommande
,left(fact.t_fdpt, 2) as UE
,ue.t_desc as Site
,'' as AdresseLivree
,'' as NomVilleLivree
,'' as CodePostalLivre
,'' as DepartementLivre
,'' as CodeOrigineOrdre
,'' as OrigineOrdre
,'' as CodeBloquee
,'' as Bloquee
,'' as CodeSignal
,fact.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,'' as Motif
,'' as DescriptionMotif
,'' as StTransfo
from tcisli305130 fact --En-tête de facture
inner join tcisli310130 lfac on lfac.t_sfcp = fact.t_sfcp and lfac.t_tran = fact.t_tran and lfac.t_idoc = fact.t_idoc --Lignes de facture
left outer join tcisli225130 facliman on facliman.t_msid = lfac.t_orno and facliman.t_msln = lfac.t_pono and facliman.t_sfcp = fact.t_sfcp --Détails des factures clients manuelles
left outer join ttccom100500 tiers on tiers.t_bpid = lfac.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = fact.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = fact.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = lfac.t_item --Article de la ligne de facture
left outer join ttcmcs023500 grpart on grpart.t_citg = facliman.t_dim4 --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = facliman.t_dim3 and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(fact.t_fdpt, 2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
where lfac.t_srtp = 20 --Bornage sur le type de source qui doit être Vente manuelle
union
select 'Commandes Clients Annulées' as Source
,'14' as CodeSource
,'01/01/1970' as DateFacture
,'' as SemaineDateFacture
,'' as MoisDateFacture
,'' as AnneeDateFacture
,'' as AnneeMoisDateFacture
,'' as AnneeSemaineDateFacture
,'' as TypeEcritureFinanciere
,'' as NumeroFacture
,cde.t_cofc as Service
,cde.t_crep as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,lcde.t_odat as DateCommande
,convert(int,datepart(isowk, lcde.t_odat)) as SemaineDateCommande
,convert(int,month(lcde.t_odat)) as MoisDateCommande
,year(lcde.t_odat) as AnneeDateCommande
,concat(year(lcde.t_odat), ' - ', month(lcde.t_odat)) as AnneeMoisDateCommande
,concat(year(lcde.t_odat), ' - ', datepart(isowk, lcde.t_odat)) as AnneeSemaineDateCommande
,lcde.t_orno as CommandeClient
,lcde.t_pono as Position
,lcde.t_sqnb as Sequence
,cde.t_sotp as TypeCommandeClient
,typecdecli.t_dsca as DescriptionTypeCommandeClient
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle
,lcde.t_serl as NumeroSerie
,lcdeart.t_citg as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,left(lcdeart.t_citg,2) as Activite
,act.t_desc as LibelleActivite
,lcdeart.t_csgs as GroupeStatistiqueVente
,lcdeart.t_cpcl as ClasseProduit
,cde.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
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
,datepart(isowk, lcde.t_prdt) as SemaineDateMADCPrevue
,month(lcde.t_prdt) as MoisDateMADCPrevue
,year(lcde.t_prdt) as AnneeDateMADCPrevue
,livcde.t_dldt as DateLivraisonReelle
,cde.t_osrp as RepresentantExterne
,empb.t_nama as NomRepresentantExterne
,cde.t_ofad as AdresseCommande
,adr.t_dsca as NomVille
,adr.t_pstc as CodePostalCommande
,left(adr.t_pstc, 2) as Departement
,cde.t_creg as Zone
,chan.t_dsca as DescriptionCanauxDistribution
,marq.t_dsca as NomContremarque
,cde.t_clin as ClientIndirect
,clin.t_nama as NomClientIndirect
,cde.t_clfi as ClientFinal
,clfi.t_nama as NomClientFinal
,'0' as MontantFacture
,lcde.t_oamt / lcde.t_rats_1 as Montant
--,livcde.t_namt / lcde.t_rats_1 as MontantAFacturer
,lcde.t_oamt / lcde.t_rats_1 as MontantAFacturer
,cde.t_ccur as DeviseCommande
,left(cde.t_cofc,2) as UE
,ue.t_desc as Site
,cde.t_stad as AdresseLivree
,adrl.t_dsca as NomVilleLivree
,adrl.t_pstc as CodePostalLivre
,left(adrl.t_pstc, 2) as DepartementLivre
,cde.t_corg as CodeOrigineOrdre
,dbo.convertenum('td','B61C','a9','bull','sls.corg',cde.t_corg,'4') as OrigineOrdre
,lcde.t_bkyn as CodeBloquee
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_bkyn, '4') as Bloquee
,art.t_csig as CodeSignal
,cde.t_itbp as TiersFacture
,tiersf.t_nama as NomTiersFacture
,tiersff.t_cfcg as GroupeFinancierTiersFacture
,(case
when lcde.t_crcd = ''
	then cde.t_crcd
else lcde.t_crcd
end) as Motif
,motmod.t_dsca as DescriptionMotif
,iif(dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo, '4') != '__ERROR__',dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo, '4')
	,dbo.convertlistcdf('tx','B61C','a9','ext','sdm',cde.t_cdf_sdmo, '4')) as StTransfo
from ttdsls401500 lcde --Lignes de Commandes Clients
left outer join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttdsls406500 livcde on livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb --Lignes de Livraison de Commandes Clients
left outer join ttdsls097500 motmod on motmod.t_crcd = (case when lcde.t_crcd = '' then cde.t_crcd else lcde.t_crcd end) --Motifs de modifications
left outer join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttdsls411500 lcdeart on lcdeart.t_orno = cde.t_orno and lcdeart.t_pono = lcde.t_pono and lcdeart.t_sqnb = 0 --Données Articles de la Ligne de Commande
left outer join ttccom001500 empa on empa.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom001500 empb on empb.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join ttcmcs066500 chan on chan.t_chan = lcde.t_chan --Canaux de Distribution
left outer join tzgsls001500 marq on marq.t_cont = cde.t_cntr --Gestion des Contremarques
left outer join ttccom100500 clin on clin.t_bpid = cde.t_clin --Tiers - Client Indirect
left outer join ttccom100500 clfi on clfi.t_bpid = cde.t_clfi --Tiers - Client Final
left outer join ttccom100500 tiers on tiers.t_bpid = cde.t_ofbp --Tiers - Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = cde.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = cde.t_itbp --Tiers - Facturé
left outer join ttccom130500 adr on adr.t_cadr = cde.t_ofad --Adresses Commandes
left outer join ttccom130500 adrl on adrl.t_cadr = cde.t_stad --Adresses Livrées
left outer join ttcmcs023500 grpart on grpart.t_citg = lcdeart.t_citg --Groupe Article
left outer join ttfgld010500 act on act.t_dimx = left(lcdeart.t_citg,2) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttfgld010500 ue on ue.t_dimx = left(cde.t_cofc,2) and ue.t_dtyp = '1' --Site que l'on trouve dans la dimension 1
left outer join ttdsls094500 typecdecli on typecdecli.t_sotp = cde.t_sotp --Type de Commandes Clients
where lcde.t_dldt = '01/01/1970' --Bornage sur la Date de Livraison qui doit être vide
and lcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
and lcde.t_clyn = 1 --Bornage sur la Ligne de Commande qui doit être Annulée