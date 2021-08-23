-----------------------------------------
-- COM22 - SUIVI CLIENTS ADV
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lcde.t_orno as NumeroCommande
,lcde.t_pono as LigneCommande
,lcde.t_odat as DateSaisieOV
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
,cpro.t_dsca as Marque
,cde.t_ofbp as CodeClient
,tier.t_nama as NomClient
,(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) as DateArriveeChassis
,(case 
when lcde.t_serl != '' and lcde.t_dtaf < '01/01/1980' 
	then (select top 1 lc.t_dtaf from ttdsls401500 lc where lc.t_orno = lcde.t_orno and lc.t_item = '         CHASSIS' and lc.t_serl = lcde.t_serl)
else
	lcde.t_dtaf
end) as DateAffectationChassis
,lcde.t_serl as NumeroChassis
,ofab.t_prdt as DateLancementProd
,lcde.t_dlsc as DateLivraisonSouhaitee
,lcde.t_dapc as DateArriveePrevueChassis
,lcde.t_dmad as DateMADCConfirmee
,lcde.t_ddta as DateProductionGruau
,lcde.t_prdt as DateMADCPrevue
,dbo.convertlistcdf('td','B61C','a9','grup','tho',lcde.t_cdf_thom,'4') as TypeHomologation
,emp.t_nama as InterlocuteurSupportGruau
,ofab.t_cmdt as DateMadcRealise
,cde.t_refa as ChampLibreA
,cde.t_corn as NumCommandeClient
,cde.t_refb as ChampLibreB
,lcde.t_cdf_refc as ChampLibreC
,lcde.t_cdf_refd as ChampLibreD
,(case 
when exists (select ttdsls406500.t_invd from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb and ttdsls406500.t_invn <> 0))
then (select ttdsls406500.t_invd from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb))
else '01/01/1970'
end) as DateFacture
,(case
when exists (select ttdsls406500.t_invn from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb and ttdsls406500.t_invn <> 0))
then (select concat(ttdsls406500.t_ttyp, ' ', ttdsls406500.t_invn) from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb))
else ''
end) as NumFacture
,(select top 1 ligliv.t_dldt from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb)) as DateLivraisonConfirmationExpedition
,(select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) as DateEditionBL
,cde.t_cdf_bcdt as DateSignatureBonCommande
,cde.t_cdf_redt as DateRecettePlanifiee
,cde.t_cntr as CodeContremarque
,cmar.t_dsca as Contremarque
,concat(titre.t_dsca, ' ', cont.t_fuln) as NomContactClient
,lcde.t_cdf_ridt as DateProgrammeeRI
,lcde.t_cdf_tvvo as TvvOrigine
,lcde.t_cdf_codt as DateReceptionCoc_Origine
,lcde.t_cdf_andt as DateReceptionDu3en1OuAnnexe
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_cdf_wltp, '4') as SoumisWltp
,lcde.t_cdf_wldt as DateDocWltpIssueCal
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_cdf_beco,'4') as BesoinDocCompl
,dbo.convertlistcdf('td','B61C','a9','grup','tyd',lcde.t_cdf_tydo,'4') as TypeDocument
,lcde.t_cdf_rcdt as DateReceptionDocCompl
,lcde.t_cdf_dhdt as DateTrtDossierHomolo
,lcde.t_cdf_epdt as DateEditionPlaque
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_cdf_cpir,'4') as CpiRequis
,lcde.t_cdf_cpdt as DateReceptionImmatriculation
,lcde.t_cdf_imat as NumeroImmatriculation
,lcde.t_cdf_dimm as DeptImmatriculation
,lastopof.t_rsdt as DateInsertionTache
,lcde.t_cdf_ddtr as DateDemTransport
,(case
when lcde.t_cdf_mrdt = '1' 
then 'OUI' 
else 'NON'
end) as MiseRoute
,dbo.convertlistcdf('td','B61C','a9','grup','pig',lcde.t_cdf_pigr,'4') as PoseImmatGruau
,lcde.t_cdf_pptr as PrestPostTransfo
,lcde.t_cdf_redt as DateRealPostEquip
,lcde.t_cdf_cosc as CommentaireSupCom
--
-- Recherche si fourniture client de la date de réception du premier composant
,(case	
	when exists(select optvar.t_cpva, optvar.t_copt
				from ttipcf520500 optvar where optvar.t_cpva = lcde.t_cpva and optvar.t_cpft = 'NbreDon' and optvar.t_copt != '0')
		then (select top 1 mvt.t_trdt from twhinr110500 mvt where mvt.t_item = concat(lcde.t_cprj,'DONG001') and mvt.t_kost = '1' and mvt.t_koor = '52' and mvt.t_qstk > 0)
		else '01/01/1970'
end) as Date_Recept_Dong
--
-- Recherche de l'adresse de livraison prévue
,(select concat(adr.t_nama, iif(adr.t_hono = '',' ',',' + adr.t_hono), iif(adr.t_namc = '','',',' + adr.t_namc), iif(adr.t_namd = '','',',' + adr.t_namd), ',',adr.t_pstc,' ',
	(select top 1 vil.t_dsca from ttccom139500 vil where vil.t_city = adr.t_ccit and vil.t_ccty = adr.t_ccty)) from ttccom130500 adr where adr.t_cadr = cde.t_stad) as Adresse_Liv_Prev
--
-- Date de liv finale prévue en agence
,concat(datename(yyyy,dateadd(day,7,lcde.t_prdt)),'-',datename(isoww,dateadd(day,7,lcde.t_prdt))) as SemaineLiv
--
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
inner join ttdsls411500 artlig on artlig.t_orno = lcde.t_orno and artlig.t_pono = lcde.t_pono and artlig.t_sqnb = lcde.t_sqnb --Données Articles de la Ligne de Commande Client
left outer join ttccom100500 tier on tier.t_bpid = cde.t_ofbp --Tiers
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --Ordres de Fabrication
left outer join ttisfc010500 lastopof on lastopof.t_pdno = ofab.t_pdno and lastopof.t_nopr = 0 and lastopof.t_tano like 'LVT5%' --Ordre de Fabrication - Derniere Operation
left outer join ttcmcs062500 cpro on cpro.t_cpcl = artlig.t_cpcl --Classe de Produits
left outer join tzgsls001500 cmar on cmar.t_cont = cde.t_cntr --Contremarque
left outer join ttccom140500 cont on cont.t_ccnt = cde.t_ofcn --Contacts client
left outer join ttcmcs019500 titre on titre.t_ctit = cont.t_ctit --Titre du contact client
where lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'CHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'VCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'PCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'OCHASSIS'
and cde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and cde.t_ofbp between @tiers_f and @tiers_t --Bornage sur le Tiers Acheteur 
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3) --Type Article Acheté, Fabriqué ou Générique
--Réponse à la Question Posée pour Inclure ou Non les Lignes Facturées
and (
(@facture = 1 and exists(select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb and ttdsls406500.t_invd between @dtfac_f and @dtfac_t)))
 or (not exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb)))
 or (exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb and ttdsls406500.t_invn = 0 and ttdsls406500.t_stat <> '25'))))