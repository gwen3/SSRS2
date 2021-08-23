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
,datepart(isowk, lcde.t_odat) as SemaineDateCommande
,month(lcde.t_odat) as MoisDateCommande
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
,datepart(isowk, lcde.t_odat) as SemaineDateCommande
,month(lcde.t_odat) as MoisDateCommande
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
,datepart(isowk, lprog.t_odat) as SemaineDateCommande
,month(lprog.t_odat) as MoisDateCommande
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
,datepart(isowk, lprog.t_odat) as SemaineDateCommande
,month(lprog.t_odat) as MoisDateCommande
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
select 'Service Matière' as Source
,'8' as CodeSource
,coutmat.t_invd as DateFacture
,datepart(isowk, coutmat.t_invd) as SemaineDateFacture
,month(coutmat.t_invd) as MoisDateFacture
,year(coutmat.t_invd) as AnneeDateFacture
,concat(year(coutmat.t_invd), ' - ', month(coutmat.t_invd)) as AnneeMoisDateFacture
,concat(year(coutmat.t_invd), ' - ', datepart(isowk, coutmat.t_invd)) as AnneeSemaineDateFacture
,coutmat.t_ityp as TypeEcritureFinanciere
,coutmat.t_idoc as NumeroFacture
,os.t_cwoc as Service
,os.t_emno as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,os.t_ordt as DateCommande
,datepart(isowk, os.t_ordt) as SemaineDateCommande
,month(os.t_ordt) as MoisDateCommande
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
,'' as DescriptionCanauxDistribution
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
from ttssoc220500 coutmat --Couts matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = coutmat.t_orno --Ordre de Service
left outer join ttccom001500 empa on empa.t_emno = os.t_emno --Employés - Représentant Interne
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers - Acheteur
left outer join ttccom110500 tiersa on tiersa.t_ofbp = os.t_ofbp --Tiers Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = os.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = os.t_itbp --Tiers - Facturé
left outer join ttcibd001500 art on art.t_item = coutmat.t_item --Articles
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = coutmat.t_orno) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = coutmat.t_orno) --Groupe Article
left outer join ttfgld010500 ue on ue.t_dimx = left(os.t_cwoc, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where coutmat.t_idoc = ''
union
select 'Service MO' as Source
,'9' as CodeSource
,coutmo.t_invd as DateFacture
,datepart(isowk, coutmo.t_invd) as SemaineDateFacture
,month(coutmo.t_invd) as MoisDateFacture
,year(coutmo.t_invd) as AnneeDateFacture
,concat(year(coutmo.t_invd), ' - ', month(coutmo.t_invd)) as AnneeMoisDateFacture
,concat(year(coutmo.t_invd), ' - ', datepart(isowk, coutmo.t_invd)) as AnneeSemaineDateFacture
,coutmo.t_ityp as TypeEcritureFinanciere
,coutmo.t_idoc as NumeroFacture
,os.t_cwoc as Service
,os.t_emno as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,os.t_ordt as DateCommande
,datepart(isowk, os.t_ordt) as SemaineDateCommande
,month(os.t_ordt) as MoisDateCommande
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
,'' as DescriptionCanauxDistribution
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
from ttssoc230500 coutmo --Couts matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = coutmo.t_orno --Ordre de Service
left outer join ttccom001500 empa on empa.t_emno = os.t_emno --Employés - Représentant Interne
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers - Acheteur
left outer join ttccom110500 tiersa on tiersa.t_ofbp = os.t_ofbp --Tiers Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = os.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = os.t_itbp --Tiers - Facturé
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = coutmo.t_orno) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = coutmo.t_orno) --Groupe Article
left outer join ttfgld010500 ue on ue.t_dimx = left(os.t_cwoc, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where coutmo.t_idoc = ''
union
select 'Service Autre' as Source
,'10' as CodeSource
,coutautre.t_invd as DateFacture
,datepart(isowk, coutautre.t_invd) as SemaineDateFacture
,month(coutautre.t_invd) as MoisDateFacture
,year(coutautre.t_invd) as AnneeDateFacture
,concat(year(coutautre.t_invd), ' - ', month(coutautre.t_invd)) as AnneeMoisDateFacture
,concat(year(coutautre.t_invd), ' - ', datepart(isowk, coutautre.t_invd)) as AnneeSemaineDateFacture
,coutautre.t_ityp as TypeEcritureFinanciere
,coutautre.t_idoc as NumeroFacture
,os.t_cwoc as Service
,os.t_emno as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,os.t_ordt as DateCommande
,datepart(isowk, os.t_ordt) as SemaineDateCommande
,month(os.t_ordt) as MoisDateCommande
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
,'' as DescriptionCanauxDistribution
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
from ttssoc240500 coutautre --Couts matières de l'Ordre de Service
inner join ttssoc200500 os on os.t_orno = coutautre.t_orno --Ordre de Service
left outer join ttccom001500 empa on empa.t_emno = os.t_emno --Employés - Représentant Interne
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers - Acheteur
left outer join ttccom110500 tiersa on tiersa.t_ofbp = os.t_ofbp --Tiers Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = os.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = os.t_itbp --Tiers - Facturé
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = coutautre.t_orno) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = coutautre.t_orno) --Groupe Article
left outer join ttfgld010500 ue on ue.t_dimx = left(os.t_cwoc, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where coutautre.t_idoc = ''
and coutautre.t_invd > Evenement.DateFacture
union
select 'Service Prix Fixe' as Source
,'11' as CodeSource
,prixfixe.t_invd as DateFacture
,datepart(isowk, prixfixe.t_invd) as SemaineDateFacture
,month(prixfixe.t_invd) as MoisDateFacture
,year(prixfixe.t_invd) as AnneeDateFacture
,concat(year(prixfixe.t_invd), ' - ', month(prixfixe.t_invd)) as AnneeMoisDateFacture
,concat(year(prixfixe.t_invd), ' - ', datepart(isowk, prixfixe.t_invd)) as AnneeSemaineDateFacture
,prixfixe.t_ityp as TypeEcritureFinanciere
,prixfixe.t_idoc as NumeroFacture
,os.t_cwoc as Service
,os.t_emno as RepresentantInterne
,empa.t_nama as NomRepresentantInterne
,os.t_ordt as DateCommande
,datepart(isowk, os.t_ordt) as SemaineDateCommande
,month(os.t_ordt) as MoisDateCommande
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
,'' as DescriptionCanauxDistribution
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
from ttssoc215500 prixfixe --Ordres de Service - Prix Fixe
inner join ttstdm100500 tarif on tarif.t_prid = prixfixe.t_prid and tarif.t_pobr = prixfixe.t_acln --Informations sur les tarifs
inner join ttssoc200500 os on os.t_orno = prixfixe.t_orno --Ordre de Service
left outer join ttccom001500 empa on empa.t_emno = os.t_emno --Employés - Représentant Interne
left outer join ttccom100500 tiers on tiers.t_bpid = os.t_ofbp --Tiers - Acheteur
left outer join ttccom110500 tiersa on tiersa.t_ofbp = os.t_ofbp --Tiers Acheteur
left outer join ttccom100500 tiersf on tiersf.t_bpid = os.t_itbp --Tiers - Facturé
left outer join ttccom112500 tiersff on tiersff.t_itbp = os.t_itbp --Tiers - Facturé
left outer join ttfgld010500 act on act.t_dimx = (select top 1 left(presta.t_crac, 2) from ttssoc210500 presta where presta.t_orno = prixfixe.t_orno) and act.t_dtyp = '3' --Activité que l'on trouve dans la dimension 3
left outer join ttcmcs023500 grpart on grpart.t_citg = (select top 1 presta.t_crac from ttssoc210500 presta where presta.t_orno = prixfixe.t_orno) --Groupe Article
left outer join ttfgld010500 ue on ue.t_dimx = left(os.t_cwoc, 2) and ue.t_dtyp = '1' --Activité que l'on trouve dans la dimension 1
where prixfixe.t_idoc = ''
