-----------------------------------------
-- LOG12A - Planning Carrossier (PLA009)
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select mag.t_dicl as Cluste
,lcde.t_cwar as Magasin
,cde.t_cofc as ServiceVente
,cde.t_sotp as TypeCommande
,artlig.t_citg as FamilleProduit
,grpart.t_dsca as LibelleFamilleProduit
,lcde.t_odat as DateSaisieOV
,lcde.t_orno as NumeroCommande
,lcde.t_pono as PositionCommande
,lcde.t_sqnb as SequenceCommande
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
-- Modification pour LAVAL : Remplacement du pilote atelier par le planificateur (table articles planification)
,(case
when left(lcde.t_orno, 2) = 'LV'
	then (select top 1 artp.t_plid from tcprpd100500 artp where artp.t_plni = concat(mag.t_dicl,lcde.t_item))
	else ofab.t_sfpl
end) as PiloteAtelier
--
,dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF
,prj.t_psta as EtapeProjet
,cpro.t_dsca as Marque
,ofab.t_pdno as OrdreFabrication
,(case
--gamme Standard
when gam.t_stor = 1 then 
	(select sum ((h.t_sutm*h.t_most)/60 + (h.t_rutm*h.t_mopr)/60) from ttirou102500 h
		where (h.t_mitm = '' and (h.t_cwoc = 'LVC145' or h.t_cwoc = 'LVC184') and h.t_opro = gam.t_strc))
--Gamme Non Standard
when gam.t_stor = 2 then
	(select sum ((h.t_sutm*h.t_most)/60 + (h.t_rutm*h.t_mopr)/60) from ttirou102500 h
		where (lcde.t_item = h.t_mitm and (h.t_cwoc = 'LVC145' or h.t_cwoc = 'LVC184') and lcde.t_item <> '         CHASSIS' and ltrim(rtrim(h.t_opro)) = '0'))
--Par Défaut
else
	0.0
end) as TempsGamme
,cde.t_ofbp as TiersAcheteur
,tier.t_nama as NomTiersAcheteur
,concat(lcde.t_cpva, '_', convert(date, var.t_pcfd, 105)) as Variante
,dbo.textnumtotext(lcde.t_txta,'4') as TexteLigneOV
,(case 
when left(lcde.t_item, 9) = ' '
	then (case
	--gamme Standard
	when gam.t_stor = 1 then 
		(select sum ((h.t_sutm*h.t_most)/60 + (h.t_rutm*h.t_mopr)/60) from ttirou102500 h
			where (h.t_mitm = '' and h.t_opro = gam.t_strc))
	--Gamme Non Standard
	when gam.t_stor = 2 then
		(select sum ((h.t_sutm*h.t_most)/60 + (h.t_rutm*h.t_mopr)/60) from ttirou102500 h
			where (lcde.t_item = h.t_mitm and lcde.t_item <> '         CHASSIS' and ltrim(rtrim(h.t_opro)) = '0'))
	--Par Défaut
	else
		0.0
	end)
when left(lcde.t_item, 9) != ' '
	then (select sum(prprj.t_nune) from ttipcs360500 prprj where prprj.t_cprj = left(lcde.t_item, 9) and (prprj.t_cpcp like '%0100' or prprj.t_cpcp like '%0101'))
end) as TaGlobal
,lcde.t_qoor as QuantiteCommandee
,(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) as DateArriveeChassis
,(case 
when lcde.t_serl != '' and lcde.t_dtaf < '01/01/1980' 
	then (select top 1 lc.t_dtaf from ttdsls401500 lc where lc.t_orno = lcde.t_orno and lc.t_item = '         CHASSIS' and lc.t_serl = lcde.t_serl)
else
	lcde.t_dtaf
end) as DateAffectationChassis
,lcde.t_serl as NumeroChassis
,ofab.t_prdt as DDOF
,lcde.t_dlsc as DateLivraisonSouhaitee
,lcde.t_dapc as DateArriveePrevueChassis
,lcde.t_dmad as DateMADCConfirmee
,ofab.t_pldt as DateProductionFinOF
,lcde.t_ddta as DateProductionGruau
,lcde.t_prdt as DateMADCPrevue
--
-- Modification pour SANICAR/DUCARME : détournement du champ pour récupérer le client final et son nom
,(case
when left(lcde.t_orno, 2) = 'AC'
	then concat(cde.t_clfi, ' ', tierclifin.t_nama)
when left(lcde.t_orno, 2) = 'AD'
	then concat(cde.t_clfi, ' ', tierclifin.t_nama)
else convert(varchar,lcde.t_dcde)
end) as DelaiReceptionCommande
--
,lcde.t_drch as DelaiReceptionChassis
,dbo.convertlistcdf('td','B61C','a9','grup','tho',lcde.t_cdf_thom,'4') as TypeHomologation
,emp.t_nama as Interlocuteur
,prj.t_ddat as DatePrevDossierSpe
,dbo.textnumtotext(ofab.t_txta,'4') as TexteOF
,ofab.t_cmdt as DateDeclarationInformatiqueOF
,cde.t_refa as ParcOuBesoin
,cde.t_corn as InfoCommandeClient
,cde.t_refb as ReferenceB
,projet.t_dsca as DescriptifProjet
,(select top 1 ligliv.t_dldt from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb)) as DateLivraisonConfirmationExpedition
,(select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) as DateEditionBL
,lcde.t_drti as DatePassageRTI
,(case 
when lcde.t_dple < '01/01/1980'
	then lcde.t_cdf_epdt
else 
	lcde.t_dple
end) as DateEditionPlaqueDossier
,lcde.t_oamt as MontantLigneCommande
,cde.t_cdf_bcdt as DateSignatureBonCommande
,cde.t_oamt as MontantCommande
,cde.t_ccur as DeviseCommande
,cde.t_cdf_redt as DateRecettePlanifiee
,cde.t_cdf_prdt as DateDemarragePenaliteRetard
,cde.t_cdf_cmbq as CommentaireBlocage
,dbo.convertlistcdf('td','B61C','a9','grup','ost',cde.t_cdf_opst,'4') as SousTraitantOperation
,dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo,'4') as SousTraitantTransformation
--
-- Recherche descriptions options de la variante
--
,(case 
-- Pour LAVAL et article ISO-LV
when (substring(lcde.t_item, 10, len(lcde.t_item)) like 'ISO-LV%')
	then (select top 1 concat('GroupeA: ',descoptvar.t_dsca,'  /GroupeF: ',descoptvar1.t_dsca,'  /Tgroupe: ',descoptvar2.t_dsca,'  /Moteur: ',descoptvar3.t_dsca)
		from ttipcf520500 optvar  --Options par Variantes de Produits
		left outer join ttipcf510500 strucvarprd on strucvarprd.t_cpva = lcde.t_cpva and strucvarprd.t_opts = optvar.t_opts --Structure
		left outer join ttipcf110500 descoptvar on descoptvar.t_item = strucvarprd.t_item and descoptvar.t_copt = optvar.t_copt and descoptvar.t_cpft = optvar.t_cpft --Description de l'option
		left outer join ttipcf520500 optvar1  on optvar1.t_cpva = lcde.t_cpva and optvar1.t_cpft = 'GroupeF'--Options par Variantes de Produits
		left outer join ttipcf510500 strucvarprd1 on strucvarprd1.t_cpva = lcde.t_cpva and strucvarprd1.t_opts = optvar1.t_opts --Structure
		left outer join ttipcf110500 descoptvar1 on descoptvar1.t_item = strucvarprd1.t_item and descoptvar1.t_copt = optvar1.t_copt and descoptvar1.t_cpft = optvar1.t_cpft --Description de l'option
		left outer join ttipcf520500 optvar2  on optvar2.t_cpva = lcde.t_cpva and optvar2.t_cpft = 'TGroupe'--Options par Variantes de Produits
		left outer join ttipcf510500 strucvarprd2 on strucvarprd2.t_cpva = lcde.t_cpva and strucvarprd2.t_opts = optvar2.t_opts --Structure
		left outer join ttipcf110500 descoptvar2 on descoptvar2.t_item = strucvarprd2.t_item and descoptvar2.t_copt = optvar2.t_copt and descoptvar2.t_cpft = optvar2.t_cpft --Description de l'option
		left outer join ttipcf520500 optvar3  on optvar3.t_cpva = lcde.t_cpva and optvar3.t_cpft = 'Moteur'--Options par Variantes de Produits
		left outer join ttipcf510500 strucvarprd3 on strucvarprd3.t_cpva = lcde.t_cpva and strucvarprd3.t_opts = optvar3.t_opts --Structure
		left outer join ttipcf110500 descoptvar3 on descoptvar3.t_item = strucvarprd3.t_item and descoptvar3.t_copt = optvar3.t_copt and descoptvar3.t_cpft = optvar3.t_cpft --Description de l'option
		where optvar.t_cpva = lcde.t_cpva and optvar.t_cpft = 'GroupeA')
when (left(lcde.t_item, 3) = 'LV2' and substring(lcde.t_item, 10, 6) != 'ISO-LV')
	then (select top 1 carac.t_dsca from ttipcf110500 carac inner join ttipcf520500 optvar on optvar.t_cpva = lcde.t_cpva and optvar.t_cpft = carac.t_cpft where carac.t_cpft = 'TGroupe' and carac.t_copt = optvar.t_copt)
-- Pour LABBE et pour article source = LBG005'
when (left(lcde.t_orno, 2) = 'LB' and substring(art.t_dfit, 10, len(art.t_dfit)) = 'LBG005')
	then ltrim(concat((select top 1 'CHARGE' from ttipcf520500 optvar where optvar.t_cpva = lcde.t_cpva and optvar.t_cpft = 'plateaupl' and optvar.t_copt like '%ctbx%'), '  ', 
				(select top 1 'PEINTURE' from ttipcf520500 optvar where optvar.t_cpva = lcde.t_cpva and optvar.t_cpft = 'peinture' and optvar.t_copt not like '%0')))
else ''
end) as CaracteristiquePrincipale
--
,cde.t_osrp as RepresentantExterne
,emp2.t_nama as NomRepresentantExterne
,(select sum(opof.t_prtm) from ttisfc010500 opof where opof.t_pdno = ofab.t_pdno) as TempsAlloueOF
,(select sum(transtk.t_nuni) from tticst300500 transtk where transtk.t_orno = ofab.t_pdno and transtk.t_fitr = 61) as TempsPasseOF
,((select sum(opof.t_prtm) from ttisfc010500 opof where opof.t_pdno = ofab.t_pdno) - (select sum(transtk.t_nuni) from tticst300500 transtk where transtk.t_orno = ofab.t_pdno and transtk.t_fitr = 61)) as TempsRestant
,isnull(((select sum(lc.t_oamt) from ttdsls401500 lc where lc.t_orno = lcde.t_orno and lc.t_item = '         VCHASSIS') / NULLIF((select sum(lcomde.t_qoor) from ttdsls401500 lcomde inner join ttdsls411500 artlcomde on artlcomde.t_orno = lcomde.t_orno and artlcomde.t_pono = lcomde.t_pono and artlcomde.t_sqnb = lcomde.t_sqnb where lcomde.t_qoor != 0 and lcomde.t_orno = lcde.t_orno and artlcomde.t_citg like '%T%' and artlcomde.t_kitm != 4), 0)), '') as MontantVCHASSIS
,isnull(((select sum(lc.t_oamt) from ttdsls401500 lc inner join ttcibd001500 artlc on artlc.t_item = lc.t_item where lc.t_orno = lcde.t_orno and lc.t_item != '         VCHASSIS' and artlc.t_kitm != 4) / NULLIF((select sum(lcomde.t_qoor) from ttdsls401500 lcomde inner join ttdsls411500 artlcomde on artlcomde.t_orno = lcomde.t_orno and artlcomde.t_pono = lcomde.t_pono and artlcomde.t_sqnb = lcomde.t_sqnb where lcomde.t_qoor != 0 and lcomde.t_orno = lcde.t_orno and artlcomde.t_citg like '%T%' and artlcomde.t_kitm != 4), 0)), '') as MontantEquipement
,isnull(((select sum(lc.t_oamt) from ttdsls401500 lc inner join ttcibd001500 artlc on artlc.t_item = lc.t_item where lc.t_orno = lcde.t_orno and artlc.t_kitm = 4) / NULLIF((select sum(lcomde.t_qoor) from ttdsls401500 lcomde inner join ttdsls411500 artlcomde on artlcomde.t_orno = lcomde.t_orno and artlcomde.t_pono = lcomde.t_pono and artlcomde.t_sqnb = lcomde.t_sqnb where lcomde.t_qoor != 0 and lcomde.t_orno = lcde.t_orno and artlcomde.t_citg like '%T%' and artlcomde.t_kitm != 4), 0)), '') as MontantService
,cde.t_cdec as CodeConditionLivraison
,cliv.t_dsca as ConditionLivraison
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_tcar,'4') as CarrossageCCI
,(case 
when (lcde.t_serl <> '') 
	then (select e.t_cdf_libr from twhltc500500 e
		where (e.t_item = '         CHASSIS' and lcde.t_serl = e.t_serl and lcde.t_cwar = e.t_cwar)) 
    else '' 
end) as SaisieLibreChassis
,prj.t_psta as PhaseProjet
,cde.t_cntr as CodeContremarque
,cmar.t_dsca as Contremarque
--
-- Pour SANICAR/DUCARME : Récupération du n° unique en scrutant le parc des deux sites
,(case
	when (left(lcde.t_orno, 2) = 'AC' or left(lcde.t_orno, 2) = 'AD')
	then (case	
			when isnull(chass.t_cdf_nuni,'') = ''
			then iif(left(lcde.t_orno, 2) = 'AD',(select top 1 isnull(chassan.t_cdf_nuni,'')i from twhltc500500 chassan where chassan.t_item = '         CHASSIS' and chassan.t_serl = lcde.t_serl and chassan.t_cwar = 'ACPARC')
												,(select top 1 isnull(chassan.t_cdf_nuni,'') from twhltc500500 chassan where chassan.t_item = '         CHASSIS' and chassan.t_serl = lcde.t_serl and chassan.t_cwar = 'ADPARC'))
			else chass.t_cdf_nuni
		end)
	-- Autres sites
	else isnull(chass.t_cdf_nuni,'')
end) as NumeroUnique
--
,concat(convert(varchar, lastopof.t_rsdt, 103), '_', tache.t_dsca) as StatutADV
,dbo.convertlistcdf('tx','B61C','a9','ext','ppr',prj.t_cdf_ppro,'4') as PiloteProjet
,lcde.t_cdf_cosc as CommentaireADV
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttcemm112500 mag on mag.t_loco = 500 and mag.t_waid = lcde.t_cwar --Magasins
inner join ttdsls411500 artlig on artlig.t_orno = lcde.t_orno and artlig.t_pono = lcde.t_pono and artlig.t_sqnb = lcde.t_sqnb --Données Articles de la Ligne de Commande Client
left outer join ttipcs030500 prj on prj.t_cprj = left(lcde.t_item, 9) --Details du Projet
left outer join ttccom100500 tier on tier.t_bpid = cde.t_ofbp --Tiers
left outer join ttccom100500 tierclifin on tierclifin.t_bpid = cde.t_clfi --Tiers (client final)
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom001500 emp2 on emp2.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join ttcmcs023500 grpart on grpart.t_citg = artlig.t_citg --Groupe Article
left outer join ttirou101500 gam on gam.t_mitm = lcde.t_item and ltrim(rtrim(gam.t_opro)) = '0' and lcde.t_item != '         CHASSIS' --Code Gamme par Article
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --Ordres de Fabrication
left outer join ttcmcs062500 cpro on cpro.t_cpcl = artlig.t_cpcl --Classe de Produits
left outer join ttcmcs052500 projet on projet.t_cprj = left(lcde.t_item, 9) --Projets
left outer join ttcmcs041500 cliv on cliv.t_cdec = cde.t_cdec --Conditions de Livraison
left outer join tzgsls001500 cmar on cmar.t_cont = cde.t_cntr --Contremarque
left outer join ttipcf500500 var on var.t_cpva = lcde.t_cpva --Variantes
left outer join twhltc500500 chass on chass.t_item = '         CHASSIS' and chass.t_serl = lcde.t_serl and chass.t_cwar = lcde.t_cwar --Numéro de série par magasin
left outer join ttisfc010500 lastopof on lastopof.t_pdno = ofab.t_pdno and lastopof.t_nopr = 0 and (lastopof.t_tano like 'LVT5%' or lastopof.t_tano = 'LBT205') --Ordre de Fabrication - Derniere Operation
left outer join ttirou003500 tache on tache.t_tano = lastopof.t_tano --Tâches
where lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV ; rajout rbesnier le 30112016
and lcde.t_ddta between @ddta_f and @ddta_t --Bornage sur la Date de Production Gruau
and cde.t_sotp between @sotp_f and @sotp_t --Bornage sur le Type de Commande
and cde.t_cofc between @cofc_f and @cofc_t --Bornage sur le Service des Ventes
and cde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and artlig.t_citg in (@citg) --Bornage sur le Groupe Article
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3) --Type Article Acheté, Fabriqué ou Générique
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'CHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'VCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'PCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'OCHASSIS'
and (@facture = 1 --Réponse à la Question Posée pour Inclure ou Non les Lignes Facturées
	or (not exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb))
		or exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb) and ttdsls406500.t_invn = 0)))