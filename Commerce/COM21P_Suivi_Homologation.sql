-----------------------------------------
-- COM021P - Suivi des Homologations PVS   
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
lcde.t_cwar as Magasin
,artlig.t_citg as FamilleProduit
,grpart.t_dsca as LibelleFamilleProduit
,lcde.t_odat as DateSaisieOV
,lcde.t_orno as NumeroCommande
,lcde.t_pono as PositionCommande
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
,artlig.t_cpcl as ClasseProduit
,cpro.t_dsca as Marque
,cde.t_ofbp as TiersAcheteur
,tier.t_nama as NomTiersAcheteur
,dbo.textnumtotext(lcde.t_txta,'4') as TexteLigneOV
,lcde.t_qoor as QuantiteCommandee
,chass.t_rdat as DateArriveeChassis
,lcde.t_serl as NumeroChassis
,lcde.t_dapc as DateArriveePrevueChassis
,lcde.t_ddta as DateProductionGruau
,lcde.t_prdt as DateMADCPrevue
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_trti,'4') as RTI
,emp.t_nama as Interlocuteur
,(select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) as DateEditionBL
,dbo.convertlistcdf('td','B61C','a9','grup','ost',cde.t_cdf_opst,'4') as SousTraitantOperation
,dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo,'4') as SousTraitantTransformation
,chass.t_cdf_nuni as NumeroUnique
,concat(convert(varchar, lastopof.t_rsdt, 103), '_', tache.t_dsca) as StatutADV
-- 
,(case
	when lcde.t_cdf_thom <= 9
		then dbo.convertlistcdf('td','B61C','a9','grup','tho',lcde.t_cdf_thom,'4') 
		else dbo.convertlistcdf('tx','B61C','a9','ext','tho',lcde.t_cdf_thom,'4')
end) as TypeHomologation
--
,lcde.t_cdf_cblo as CommentaireBlocage
,lcde.t_cdf_ridt as DateProgrammeeRI
,lcde.t_cdf_tvvo as TvvOrigine
,lcde.t_cdf_codt as DateReceptionCoc_Origine
,lcde.t_cdf_andt as DateReceptionDu3en1OuAnnexe
,(case
when chass.t_cdf_mtot != ''
	then chass.t_cdf_mtot
else lcde.t_cdf_mavc
end) as MasseTotaleAvantTransfo
,(case
when chassapre.t_cdf_mtot != ''
	then chassapre.t_cdf_mtot
else lcde.t_cdf_mavt
end) as MasseTotaleApresTransfo
,lcde.t_cdf_dpdt as DateMiseDispoPlan
,lcde.t_cdf_cfdt as DateMadFicheCtrlFinal
,lcde.t_cdf_wldt as DateduDocWLTP
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_cdf_wltp, '4') as SoumisWltp
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_cdf_beco,'4') as BesoinDocCompl
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_cdf_bfin,'4') as BesoinFinancement
,dbo.convertlistcdf('td','B61C','a9','grup','tfi',lcde.t_cdf_typf,'4') as TypeFinancement
,dbo.convertlistcdf('td','B61C','a9','grup','tyd',lcde.t_cdf_tydo,'4') as TypeDocument
,lcde.t_cdf_rcdt as DateReceptionDocCompl
,lcde.t_cdf_dhdt as DateTrtDossierHomolo
,lcde.t_cdf_epdt as DateEditionPlaque
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_cdf_cpir,'4') as CpiRequis
,lcde.t_cdf_cpdt as DateReceptCpiOuCarteGrise
,lcde.t_cdf_imat as NumeroImmatriculation
,lcde.t_cdf_dimm as DeptImmatriculation
,chassapre.t_cdf_meav as MasseEssieuAV
,chassapre.t_cdf_mear as MasseEssieuAR
,chassapre.t_cdf_nbp as NbPlacesCab
,lcde.t_cdf_cosc as CommentSupCom
,lcde.t_cdf_a1dt as DateRedacAnnexe1
,lcde.t_cdf_a3dt as DateRedacAnnexe3
,lcde.t_cdf_a7dt as DateRedacAnnexe7
,ofab.t_pdno as OrdreFab
,clifin.t_nama as ClientFinal
,lcde.t_cdf_etvv as TvvGruau
,lcde.t_cdf_moav as MotifAvoir
,lcde.t_cdf_mrdt as MiseALaRoute
,lcde.t_cdf_nchq as NumCheque
,lcde.t_cdf_acdt as DateRedacAttestationCarrossier
,lcde.t_cdf_tran as Transport
,cde.t_crep as RepInterne
,lcde.t_cdf_atdt as DateRecAutoTransfoConst
,tier.t_cdf_noco as NomCommercial
,lcde.t_cdf_wlt1 as Co2Wltp
,lcde.t_cdf_wlt2 as ConsoWltp
,lcde.t_cdf_phdt as DatePrepDossierHomolo
,lcde.t_cdf_didt as DateEnvoiDocImmat
,lcde.t_cdf_nupv as NumPvRiRti
,'' as NumRecepOrigine
,'' as DateRecepOrigine
,'' as NumRecepGruau
,'' as DateRecepGruau
,'' as CertifImmatProv
,'' as DateEnvoiDreal
,'' as InterlocuteurDreal
,'' as DateRetourDreal
,'' as DateSignRiRti
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttcemm112500 mag on mag.t_loco = 500 and mag.t_waid = lcde.t_cwar --Magasins
inner join ttdsls411500 artlig on artlig.t_orno = lcde.t_orno and artlig.t_pono = lcde.t_pono and artlig.t_sqnb = lcde.t_sqnb --Données Articles de la Ligne de Commande Client
left outer join ttccom100500 tier on tier.t_bpid = cde.t_ofbp --Tiers
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttcmcs023500 grpart on grpart.t_citg = artlig.t_citg --Groupe Article
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --Ordres de Fabrication
left outer join ttcmcs062500 cpro on cpro.t_cpcl = artlig.t_cpcl --Classe de Produits
left outer join twhltc500500 chass on chass.t_item = '         CHASSIS' and chass.t_serl = lcde.t_serl and chass.t_cwar = lcde.t_cwar --Numéro de série par magasin
left outer join twhltc500500 chassapre on chassapre.t_item = lcde.t_item and chassapre.t_serl = lcde.t_serl and chassapre.t_cwar = lcde.t_cwar --Numéro de série par magasin
left outer join ttisfc010500 lastopof on lastopof.t_pdno = ofab.t_pdno and lastopof.t_nopr = 0 and (lastopof.t_tano like 'LVT5%' or lastopof.t_tano = 'LBT205') --Ordre de Fabrication - Derniere Operation
left outer join ttirou003500 tache on tache.t_tano = lastopof.t_tano --Tâches
left outer join ttccom100500 clifin on clifin.t_bpid = cde.t_clfi --Client Final
where lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and lcde.t_ddta between @ddta_f and @ddta_t --Bornage sur la Date de Production Gruau
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'CHASSIS' -- Ne pas prendre en compte les CHASSIS au sens large
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'VCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'PCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'OCHASSIS'
and lcde.t_cdf_thom in (@thom_f) -- Bornage sur type homologation
and lcde.t_cdf_wltp in (@wltp_f) -- Bornage sur Soumis WLTP
and lcde.t_cdf_beco in (@beco_f) -- Bornage sur Besoin Doc Complémentaire
and lcde.t_cdf_cpir in (@cpir_f) -- Bornage sur CPI Requis
and lcde.t_cdf_dhdt between @dhdt_f and @dhdt_t --Bornage sur la Date trt dossier homologation
and cde.t_sotp in (@sotp_f) --Bornage sur le Type de Commande
and cde.t_cofc in (@cofc_f) --Bornage sur le Service des Ventes
and cde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and artlig.t_citg in (@citg) --Bornage sur le Groupe Article
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3) --Type Article Acheté, Fabriqué ou Générique
and (@facture = 1 --Réponse à la Question Posée pour Inclure ou Non les Lignes Facturées
	or (not exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb))
		or exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb) and ttdsls406500.t_invn = 0)))