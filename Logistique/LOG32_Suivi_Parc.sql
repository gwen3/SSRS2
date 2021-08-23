-----------------------------------------
-- LOG32 - SUIVI PARC
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
cde.t_ofbp as TiersAcheteur
,tier.t_nama as NomTiersAcheteur
,lcde.t_orno as NumeroCommande
,lcde.t_pono as PositionCommande
,lcde.t_cdf_epdt as DatePlaqueDocHomolo
,lcde.t_serl as NumeroChassis
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,art.t_dsca as DescriptionArticle
,concat(convert(varchar, lastopof.t_rsdt, 103), '_', tache.t_dsca) as StatutADV
,lastopof.t_rsdt as DateInsertTacheHomolo
,tache.t_dsca as TacheHomolo
,dbo.convertlistcdf('td','B61C','a9','grup','tho',lcde.t_cdf_thom,'4') as TypeHomologation
,dbo.convertlistcdf('td','B61C','a9','grup','pig',lcde.t_cdf_pigr,'4') as PosePlaque
,lcde.t_cdf_cpdt as DateReceptImmat
,lcde.t_cdf_imat as Immatriculation
,lcde.t_cdf_dimm as Departement
,ofab.t_cmdt as DateDeclarationInformatiqueOF
,cde.t_cdec as CodeConditionLivraison
,cliv.t_dsca as ConditionLivraison
,lcde.t_cdf_ddtr as DateDmdeTransp
,lcde.t_qoor as QuantiteCommandee
,cde.t_cofc as ServiceVente
,cde.t_sotp as TypeCommande
,artlig.t_citg as FamilleProduit
,grpart.t_dsca as LibelleFamilleProduit
,cpro.t_dsca as Marque
,lcde.t_odat as DateSaisieOV
,lcde.t_ddta as DateProductionGruau
,lcde.t_qidl as QteLivree
,stocks.t_qhnd as QteStock
,cde.t_stad as CodeAdresseLivre
,concat(adrl.t_namc,' ',adrl.t_namd) as AdresseLivree
,adrl.t_dsca as NomVilleLivree
,adrl.t_pstc as CodePostalLivre
,left(adrl.t_pstc, 2) as DepartementLivre
,left(cde.t_cofc, 2) as UniteEntreprise
-- Expéditions (whinh430500) et Lignes de livraison des commandes clients (tdsls406500)
,(select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) as DateEditionBL
--
,ofab.t_pdno as NumeroOrdreFab
,dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4')	as StatutOrdreFab
,dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo,'4') as StTransfo
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
inner join ttdsls411500 artlig on artlig.t_orno = lcde.t_orno and artlig.t_pono = lcde.t_pono and artlig.t_sqnb = lcde.t_sqnb --Données Articles de la Ligne de Commande Client
left outer join ttccom130500 adrl on adrl.t_cadr = cde.t_stad --Adresses Livrées
left outer join ttccom100500 tier on tier.t_bpid = cde.t_ofbp --Tiers
left outer join ttcmcs023500 grpart on grpart.t_citg = artlig.t_citg --Groupe Article
left outer join ttcmcs062500 cpro on cpro.t_cpcl = artlig.t_cpcl --Classe de Produits
left outer join ttcmcs041500 cliv on cliv.t_cdec = cde.t_cdec --Conditions de Livraison
left outer join twhltc500500 stocks on stocks.t_item = lcde.t_item and stocks.t_serl = lcde.t_serl and stocks.t_cwar = lcde.t_cwar --Articles Série Magasin
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --Ordres de Fabrication
-- Test tache de la dernière opération LVT5 pour Laval et LBT205 pour Labbé
left outer join ttisfc010500 lastopof on lastopof.t_pdno = ofab.t_pdno and lastopof.t_nopr = 0 
	and (lastopof.t_tano like 'LVT5%' or lastopof.t_tano = 'LBT205') --Ordre de Fabrication - Derniere Operation
left outer join ttirou003500 tache on tache.t_tano = lastopof.t_tano --Tâches
where lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and lcde.t_ddta between @ddta_f and @ddta_t --Bornage sur la Date de Production Gruau
and cde.t_sotp in ('208','209') --Bornage sur le Type de Commande
and cde.t_cofc in (@cofc_f) --Bornage sur le Service des Ventes
and cde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and artlig.t_citg in (@citg_f) --Bornage sur le Groupe Article
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3) --Type Article Acheté, Fabriqué ou Générique
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'CHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'VCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'PCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'OCHASSIS'
-- BL non édité ou véhicule pas livré
and ((concat(convert(varchar, lastopof.t_rsdt, 103), tache.t_dsca) <> '' or (stocks.t_qhnd > 0  or lcde.t_qidl > 0)) and
    (((select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) = '01/01/1970') or
	 (select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) is NULL))