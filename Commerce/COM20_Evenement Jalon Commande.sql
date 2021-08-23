------------------------------------------
-- COM20 - Evenements Jalons de Commande
------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/*
declare @ue_f nvarchar(2) = 'LV'
declare @ue_t nvarchar(2) = 'LV'
declare @odat_f date = DATEADD(DD, -20, CAST(CURRENT_TIMESTAMP AS DATE));
declare @odat_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @ddta_f date = DATEADD(DD, -20, CAST(CURRENT_TIMESTAMP AS DATE));
declare @ddta_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @orno_f nvarchar(9) = ' '
declare @orno_t nvarchar(9) = 'ZZZZZZZZZ'
declare @sotp_f nvarchar(9) = ' '
declare @sotp_t nvarchar(9) = 'ZZZZZZZZZ'
declare @cofc_f nvarchar(9) = ' '
declare @cofc_t nvarchar(9) = 'ZZZZZZZZZ'
declare @citg nvarchar(9) = 'BAT001'
declare @datebl_f date = DATEADD(DD, -20, CAST(CURRENT_TIMESTAMP AS DATE));
declare @datebl_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
*/
select cde.t_cofc as ServiceVente
,artlig.t_citg as FamilleProduit
,grpart.t_dsca as LibelleFamilleProduit
,lcde.t_odat as DateSaisieOV
,lcde.t_orno as NumeroCommande
,lcde.t_pono as PositionCommande
,lcde.t_sqnb as SequenceCommande
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
,dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF
,prj.t_psta as EtapeProjet
,cpro.t_dsca as Marque
,ofab.t_pdno as OrdreFabrication
,cde.t_ofbp as TiersAcheteur
,tier.t_nama as NomTiersAcheteur
,concat(titre.t_dsca, ' ', cont.t_fuln) as TitreEtNomCompletContactTiersAcheteur
,cont.t_info as MailContact
,dbo.textnumtotext(lcde.t_txta,'4') as TexteLigneOV
,(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) as DateArriveeChassis --On prend la date la plus récente
,(case 
when lcde.t_serl != '' and lcde.t_dtaf < '01/01/1980' 
	then (select top 1 lc.t_dtaf from ttdsls401500 lc where lc.t_orno = lcde.t_orno and lc.t_item = '         CHASSIS' and lc.t_serl = lcde.t_serl)
else
	lcde.t_dtaf
end) as DateAffectationChassis
,lcde.t_serl as NumeroChassis
,ofab.t_apdt as DDOF
,lcde.t_dlsc as DateLivraisonSouhaitee
,lcde.t_dapc as DateArriveePrevueChassis
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
,lcde.t_dcde as DelaiReceptionCommande
,lcde.t_drch as DelaiReceptionChassis
,cde.t_crep as CodeRepresentantInterne
,emp.t_nama as RepresentantInterne
,emp.t_namb as PrenomRepresentantInterne
,emp.t_namd as NomRepresentantInterne
,empdet.t_mail as MailRepresentantInterne
,empdet.t_telw as TelephoneRepresentantInterne
,ofab.t_cmdt as DateDeclarationInformatiqueOF
,cde.t_refa as ReferenceA
,cde.t_corn as NumeroCommandeClient
,cde.t_refb as ReferenceB
,(select top 1 ligliv.t_dldt from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb)) as DateLivraisonConfirmationExpedition
,(select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) as DateEditionBL
,lcde.t_drti as DatePassageRTI
,(case 
when lcde.t_dple < '01/01/1980'
	then lcde.t_cdf_epdt
else 
	lcde.t_dple
end) as DateEditionPlaqueDossier
,cde.t_cdf_bcdt as DateSignatureBonCommande
,cde.t_cdf_redt as DateRecettePlanifiee
,cde.t_cdf_prdt as DateDemarragePenaliteRetard
,cde.t_cdf_cmbq as CommentaireBlocage
,dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo,'4') as SousTraitantTransformation
,cde.t_osrp as RepresentantExterne
,emp2.t_nama as NomRepresentantExterne
,empdet2.t_mail as MailRepresentantExterne
,cliv.t_dsca as ConditionLivraison
,dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_tcar,'4') as CarrossageCCI
,cmar.t_dsca as Contremarque
,lastopof.t_cmdt as DateAchevementDerniereOperation
,tache.t_dsca as TacheDerniereOperation
,lastopof.t_rsdt as DateInsertionTache
,ofab.t_qdlv as QuantiteLivree
,dbo.convertlistcdf('td','B61C','a9','grup','tho',lcde.t_cdf_thom,'4') as TypeHomologation
,lcde.t_cdf_andt as DateReception3En1Annexe17
,lcde.t_cdf_codt as DateReceptionCOCOrigine
,dbo.convertlistcdf('td','B61C','a9','grup','cpi',lcde.t_cdf_cpir,'4') as CPIRequis
,lcde.t_cdf_cpdt as DateReceptionCPICarteGrise
,lcde.t_cdf_dimm as DepartementImmatriculation
,lcde.t_cdf_imat as NumeroImmatriculation
,cde.t_cdf_adco as AdresseMailCompl
,lcde.t_invd as DateFacture
,lcde.t_cdf_ddtr as DateDemandeTransport
,bloccde.t_hrea as Motif
,dbo.convertlistcdf('tx','B61C','a9','ext','tsu',cde.t_cdf_tsui,'4') as TypeSuivi
,empdet.t_jobt as FonctionRepresentantInterne
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
left outer join ttisfc010500 lastopof on lastopof.t_pdno = ofab.t_pdno and lastopof.t_nopr = 0 and (lastopof.t_tano like 'LVT5%' or lastopof.t_tano = 'LBT205') --Ordre de Fabrication - Derniere Operation
left outer join ttirou003500 tache on tache.t_tano = lastopof.t_tano --Tâches
left outer join ttcmcs062500 cpro on cpro.t_cpcl = artlig.t_cpcl --Classe de Produits
left outer join ttcmcs041500 cliv on cliv.t_cdec = cde.t_cdec --Conditions de Livraison
left outer join tzgsls001500 cmar on cmar.t_cont = cde.t_cntr --Contremarque
left outer join ttdsls420500 bloccde on bloccde.t_orno = lcde.t_orno --Gestion de Blocage de la commande
where left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV
and lcde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and lcde.t_ddta between @ddta_f and @ddta_t --Bornage sur la Date de Production Gruau
and lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and cde.t_sotp between @sotp_f and @sotp_t --Bornage sur le Type de Commande
and cde.t_cofc between @cofc_f and @cofc_t --Bornage sur le Service des Ventes
and artlig.t_citg in (@citg) --Bornage sur le Groupe Article
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3) --Type Article Acheté, Fabriqué ou Générique
and lcde.t_qoor >= 1 --Quantité de commandes supérieure ou égale à 1 pour exclure les avoirs et les compléments de commande
--Bornage pour ne pas ramener les lignes de châssis
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'CHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'VCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'PCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'OCHASSIS'
and (((select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) IS NULL) or ((select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) < '01/01/1980') or ((select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) between @datebl_f and @datebl_t))