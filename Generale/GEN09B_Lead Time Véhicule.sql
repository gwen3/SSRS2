-------------------------------
-- GEN09B - Lead Time Véhicule
-------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select cde.t_cofc as ServiceVente
,artlig.t_citg as FamilleProduit
,grpart.t_dsca as LibelleFamilleProduit
,lcde.t_odat as DateSaisieOV
,lcde.t_orno as NumeroCommande
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
,dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF
,cpro.t_dsca as Marque
,ofab.t_pdno as OrdreFabrication
,cde.t_ofbp as TiersAcheteur
,tier.t_nama as NomTiersAcheteur
,(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) as DateArriveeChassis --On prend la date la plus récente
,lcde.t_dapc as DateArriveePrevueChassis
,(select top 1 hlcde2.t_cdf_dapc from ttdsls451500 hlcde2 where hlcde2.t_orno = lcde.t_orno and hlcde2.t_pono = lcde.t_pono and hlcde2.t_sqnb = lcde.t_sqnb and hlcde2.t_cdf_dapc <> '01/01/1970' order by hlcde2.t_cdf_dapc) as PremDateArriveeChassis
--Ecart Première Date arrivée prévue chassis et date arrivée effective
,(case
when exists (select top 1 cha1.t_rdat from twhltc500500 cha1 where cha1.t_item = '         CHASSIS' and cha1.t_serl = lcde.t_serl and cha1.t_cwar = lcde.t_cwar and cha1.t_rdat <> '01/01/1970' order by cha1.t_rdat desc)
	then datediff(day, 
		(select top 1 hlcde3.t_cdf_dapc from ttdsls451500 hlcde3 where hlcde3.t_orno = lcde.t_orno and hlcde3.t_pono = lcde.t_pono and hlcde3.t_sqnb = lcde.t_sqnb and hlcde3.t_cdf_dapc <> '01/01/1970' order by hlcde3.t_cdf_dapc)
		,(select top 1 cha1.t_rdat from twhltc500500 cha1 where cha1.t_item = '         CHASSIS' and cha1.t_serl = lcde.t_serl and cha1.t_cwar = lcde.t_cwar order by cha1.t_rdat desc))
	else
		0
end) as EcartDtArriveePremDatePrevue
--Ecart Date arrivée prévue chassis et date arrivée effective
,(case
when exists (select top 1 cha2.t_rdat from twhltc500500 cha2 where cha2.t_item = '         CHASSIS' and cha2.t_serl = lcde.t_serl and cha2.t_cwar = lcde.t_cwar and cha2.t_rdat <> '01/01/1970' order by cha2.t_rdat desc)
	then datediff(day, lcde.t_dapc,(select top 1 cha2.t_rdat from twhltc500500 cha2 where cha2.t_item = '         CHASSIS' and cha2.t_serl = lcde.t_serl and cha2.t_cwar = lcde.t_cwar order by cha2.t_rdat desc))	
	else
		0
end) as EcartDtArriveeDatePrevue
--
,(case 
when lcde.t_serl != '' and lcde.t_dtaf < '01/01/1980' 
	then (select top 1 lc.t_dtaf from ttdsls401500 lc where lc.t_orno = lcde.t_orno and lc.t_item = '         CHASSIS' and lc.t_serl = lcde.t_serl)
else
	lcde.t_dtaf
end) as DateAffectationChassis
,lcde.t_serl as NumeroChassis
,ofab.t_apdt as DDOF
,lcde.t_dlsc as DateLivraisonSouhaitee
,(case (select count(distinct hlcde1.t_cdf_dmad) from ttdsls451500 hlcde1 where hlcde1.t_orno = lcde.t_orno and hlcde1.t_pono = lcde.t_pono)
when 0
	then '01/01/1970'
when 1
	then '01/01/1970'
when 2
	then '01/01/1970'
else
	(select top 1 hlcde.t_trdt from ttdsls451500 hlcde where hlcde.t_orno = lcde.t_orno and hlcde.t_pono = lcde.t_pono and hlcde.t_sqnb = lcde.t_sqnb and hlcde.t_cdf_dmad = lcde.t_dmad) 
end) as DateMiseAJourMADCConfirmee
,lcde.t_dmad as DateMADCConfirmee
,lcde.t_ddta as DateProductionGruau
,lcde.t_prdt as DateMADCPrevue
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_trti,'4') as RTI
,ofab.t_cmdt as DateDeclarationInformatiqueOF
,(select top 1 ligliv.t_dldt from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb)) as DateLivraisonConfirmationExpedition
,(select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) as DateEditionBL
,lcde.t_drti as DatePassageRTI
,lcde.t_dple as DateEditionPlaque
,dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo,'4') as SousTraitantTransformation
,cliv.t_dsca as ConditionLivraison
,cmar.t_dsca as Contremarque
,tache.t_dsca as TacheDerniereOperation
,lastopof.t_rsdt as DateInsertionTache
,ofab.t_qdlv as QuantiteLivree
,lcde.t_invd as DateFacturation
,(case
when (ofab.t_apdt < '01/01/1980' or (select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) < '01/01/1980')
	then ''
else
	datediff(day, ofab.t_apdt, (select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc))
end) as TempsParcAmont
,(case
when lastopof.t_rsdt < '01/01/1980' or lastopof.t_rsdt IS NULL
	then datediff(day, ofab.t_apdt, ofab.t_cmdt)
else
	datediff(day, ofab.t_apdt, lastopof.t_rsdt)
end) as TempsTraverseAtelier
,(case
when (lastopof.t_rsdt < '01/01/1980' or ofab.t_cmdt < '01/01/1980')
	then 0
else
	datediff(day, lastopof.t_rsdt, ofab.t_cmdt)
end) as TempsTraverseADVHomolo
,(case
when (lcde.t_invd < '01/01/1980' or ofab.t_cmdt < '01/01/1980')
	then ''
else
	datediff(day, ofab.t_cmdt, lcde.t_invd)
end) as TempsFacturation
,(case
when (lcde.t_invd < '01/01/1980' or (select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) < '01/01/1980')
	then ''
else
	datediff(day, lcde.t_invd, (select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))))
end) as TempsTraverseParcAval
,(case
when ofab.t_cmdt < '01/01/1980'
	then ''
else
	datediff(day, ofab.t_apdt, ofab.t_cmdt)
end) as TempsTraverseOFTotal
--
-- Ajout récupération Date du document de la table Pièces à traiter (factures clients et Règlements)
,(case left(lcde.t_orno, 2)
when 'AC' 
	then (select top 1 facreg.t_docd
		from ttdsls406500 livcde
		inner join ttfacr200620 facreg on facreg.t_ttyp = livcde.t_ttyp and facreg.t_ninv = livcde.t_invn
		where livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb and facreg.t_docn > '0'
		order by facreg.t_docd desc)
when 'AD' 
	then (select top 1 facreg.t_docd
		from ttdsls406500 livcde
		inner join ttfacr200630 facreg on facreg.t_ttyp = livcde.t_ttyp and facreg.t_ninv = livcde.t_invn
		where livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb and facreg.t_docn > '0'
		order by facreg.t_docd desc) 
when 'AL' 
	then (select top 1 facreg.t_docd
		from ttdsls406500 livcde
		inner join ttfacr200600 facreg on facreg.t_ttyp = livcde.t_ttyp and facreg.t_ninv = livcde.t_invn
		where livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb and facreg.t_docn > '0'
		order by facreg.t_docd desc)
when 'AM' 
	then (select top 1 facreg.t_docd
		from ttdsls406500 livcde
		inner join ttfacr200600 facreg on facreg.t_ttyp = livcde.t_ttyp and facreg.t_ninv = livcde.t_invn
		where livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb and facreg.t_docn > '0'
		order by facreg.t_docd desc) 
when 'AP' 
	then (select top 1 facreg.t_docd
		from ttdsls406500 livcde
		inner join ttfacr200610 facreg on facreg.t_ttyp = livcde.t_ttyp and facreg.t_ninv = livcde.t_invn
		where livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb and facreg.t_docn > '0'
		order by facreg.t_docd desc) 
when 'LB' 
	then (select top 1 facreg.t_docd
		from ttdsls406500 livcde
		inner join ttfacr200400 facreg on facreg.t_ttyp = livcde.t_ttyp and facreg.t_ninv = livcde.t_invn
		where livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb and facreg.t_docn > '0'
		order by facreg.t_docd desc) 
Else (select top 1 facreg.t_docd
		from ttdsls406500 livcde
		inner join ttfacr200500 facreg on facreg.t_ttyp = livcde.t_ttyp and facreg.t_ninv = livcde.t_invn
		where livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb and facreg.t_docn > '0'
		order by facreg.t_docd desc)
end) as DateFactReg
--
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
inner join ttdsls411500 artlig on artlig.t_orno = lcde.t_orno and artlig.t_pono = lcde.t_pono and artlig.t_sqnb = lcde.t_sqnb --Données Articles de la Ligne de Commande Client
left outer join ttipcs030500 prj on prj.t_cprj = left(lcde.t_item, 9) --Details du Projet
left outer join ttccom100500 tier on tier.t_bpid = cde.t_ofbp --Tiers
left outer join ttccom140500 cont on cont.t_ccnt = cde.t_ofcn --Contacts - Tiers Acheteur
left outer join ttcmcs019500 titre on titre.t_ctit = cont.t_ctit --Titre du contact tiers acheteur
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join tbpmdm001500 empdet on empdet.t_emno = cde.t_crep --Données du Personnel - Représentant Interne
left outer join ttccom001500 emp2 on emp2.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join tbpmdm001500 empdet2 on empdet2.t_emno = cde.t_osrp --Données du Personnel - Représentant Externe
left outer join ttcmcs023500 grpart on grpart.t_citg = artlig.t_citg --Groupe Article
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --Ordres de Fabrication
left outer join ttisfc010500 lastopof on lastopof.t_pdno = ofab.t_pdno and lastopof.t_nopr = 0 and lastopof.t_tano like 'LVT5%' --Ordre de Fabrication - Derniere Operation
left outer join ttirou003500 tache on tache.t_tano = lastopof.t_tano --Tâches
left outer join ttcmcs062500 cpro on cpro.t_cpcl = artlig.t_cpcl --Classe de Produits
left outer join ttcmcs041500 cliv on cliv.t_cdec = cde.t_cdec --Conditions de Livraison
left outer join tzgsls001500 cmar on cmar.t_cont = cde.t_cntr --Contremarque
where left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV
and cde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and lcde.t_ddta between @ddta_f and @ddta_t --Bornage sur la Date de Production Gruau
and lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and cde.t_sotp between @sotp_f and @sotp_t --Bornage sur le Type de Commande
and cde.t_cofc between @cofc_f and @cofc_t --Bornage sur le Service des Ventes
and artlig.t_citg in (@citg) --Bornage sur le Groupe Article
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3) --Type Article Acheté, Fabriqué ou Générique
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'CHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'VCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'PCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'OCHASSIS'
and (@facture = 1 --Réponse à la Question Posée pour Inclure ou Non les Lignes Facturées
	or (not exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb))
		or exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb) and ttdsls406500.t_invn = 0)))