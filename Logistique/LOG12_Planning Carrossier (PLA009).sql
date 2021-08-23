-----------------------------------------
-- LOG12 - Planning Carrossier (PLA009)
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select mag.t_dicl as Cluste, 
lcde.t_cwar as Magasin, 
cde.t_cofc as ServiceVente, 
cde.t_sotp as TypeCommande, 
artlig.t_citg as FamilleProduit, 
grpart.t_dsca as LibelleFamilleProduit, 
cde.t_odat as DateSaisieOV, 
lcde.t_orno as NumeroCommande, 
lcde.t_pono as PositionCommande, 
lcde.t_sqnb as SequenceCommande, 
left(lcde.t_item, 9) as Projet, 
substring(lcde.t_item, 10, len(lcde.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
ofab.t_sfpl as PiloteAtelier, 
--Modification par rbesnier le 31/10/2018 suite au ticket 40362
--ofab.t_osta as StatutOF, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
prj.t_psta as EtapeProjet, 
(case
when (lcde.t_serl <> '' and lcde.t_item = '         CHASSIS') 
	then (select dbo.convertlistcdf('wh','b61c','a9','grup','mar',e.t_cdf_marq,'4') from twhltc500500 e
		where (lcde.t_item = e.t_item and lcde.t_serl = e.t_serl and lcde.t_cwar = e.t_cwar)) 
    else cpro.t_dsca 
end) as Marque, 
ofab.t_pdno as OrdreFabrication, 
--Rajout le 21/06/2017, remplace la colonne OF de Kit qui n'était pas utilisée
(case
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
end) as TempsGamme, --LVC145ouLVC184
cde.t_ofbp as TiersAcheteur, 
tier.t_nama as NomTiersAcheteur, 
lcde.t_cpva as Variante, 
dbo.textnumtotext(lcde.t_txta,'4') as TexteLigneOV, 
--Modification du 21/06/2017
--(select sum(prprj.t_nune) from ttipcs360500 prprj where prprj.t_cprj = left(lcde.t_item, 9) and (prprj.t_cpcp = 'LV0100' or prprj.t_cpcp 'LV0101')) as TaGlobal, --Table des Prix de Revient par Projet
/* Ancienne Version, changée le 21/06/2017, champ trouvé plus cohérent
Il faut utiliser l'ancienne formule dans le cas ou pas de projet, et la nouvelle dans le cas ou c'est un projet
*/
(case 
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
--Modification le 19/09/2017 par rbesnier car cela ne marche pas pour les autres sites
--	then (select sum(prprj.t_nune) from ttipcs360500 prprj where prprj.t_cprj = left(lcde.t_item, 9) and (prprj.t_cpcp = 'LV0100' or prprj.t_cpcp = 'LV0101'))
	then (select sum(prprj.t_nune) from ttipcs360500 prprj where prprj.t_cprj = left(lcde.t_item, 9) and (prprj.t_cpcp like '%0100' or prprj.t_cpcp like '%0101'))
end) as TaGlobal, 
lcde.t_qoor as QuantiteCommandee, 
--Modification le 21/06/2017 en s'inspirant du GEN05
(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) as DateArriveeChassis, --On apprend la date la plus récente
--Modif suite problème en prod
--lcde.t_dtaf as DateAffectationChassis, 
(case 
when lcde.t_serl != '' and lcde.t_dtaf < '01/01/1980' 
	then (select top 1 lc.t_dtaf from ttdsls401500 lc where lc.t_orno = lcde.t_orno and lc.t_item = '         CHASSIS' and lc.t_serl = lcde.t_serl)
else
	lcde.t_dtaf
end) as DateAffectationChassis, 
lcde.t_serl as NumeroChassis, 
ofab.t_prdt as DDOF, 
lcde.t_dlsc as DateLivraisonSouhaitee, 
lcde.t_dapc as DateArriveePrevueChassis, 
lcde.t_dmad as DateMADCConfirmee, 
ofab.t_pldt as DateProductionFinOF, 
cde.t_ddat as DateProductionGruau, 
lcde.t_prdt as DateMADCPrevue, 
lcde.t_dcde as DelaiReceptionCommande, 
lcde.t_drch as DelaiReceptionChassis, 
--21/06/2017, le champ trti est maintenant sur la tdsls401 au lieu de la 400, changement de la table
dbo.convertenum('tc','B61C','a9','bull','yesno',lcde.t_trti,'4') as RTI, 
emp.t_nama as Interlocuteur, 
prj.t_ddat as DatePrevDossierSpe, 
dbo.textnumtotext(ofab.t_txta,'4') as TexteOF, 
'' as DateMADVehiculeReelle, 
ofab.t_cmdt as DateDeclarationInformatiqueOF, 
cde.t_refa as ParcOuBesoin, 
cde.t_corn as InfoCommandeClient, 
cde.t_refb as ReferenceB, 
projet.t_dsca as DescriptifProjet, 
(select top 1 ligliv.t_dldt from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb)) as DateLivraisonConfirmationExpedition, 
(select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) as DateEditionBL, 
--Rajout le 21/06/2017
lcde.t_drti as DatePassageRTI, 
--Rajout le 21/06/2017
lcde.t_dple as DateEditionPlaque, 
--Rajout le 21/06/2017
lcde.t_oamt as MontantLigneCommande 
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttcemm112500 mag on mag.t_loco = 500 and mag.t_waid = lcde.t_cwar --Magasins
inner join ttdsls411500 artlig on artlig.t_orno = lcde.t_orno and artlig.t_pono = lcde.t_pono and artlig.t_sqnb = lcde.t_sqnb --Données Articles de la Ligne de Commande Client
left outer join ttipcs030500 prj on prj.t_cprj = left(lcde.t_item, 9) --Details du Projet
left outer join ttccom100500 tier on tier.t_bpid = cde.t_ofbp --Tiers
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employés
left outer join ttcmcs023500 grpart on grpart.t_citg = artlig.t_citg --Groupe Article
left outer join ttirou101500 gam on gam.t_mitm = lcde.t_item and ltrim(rtrim(gam.t_opro)) = '0' and lcde.t_item != '         CHASSIS' --Code Gamme par Article
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --Ordres de Fabrication
left outer join ttcmcs062500 cpro on cpro.t_cpcl = artlig.t_cpcl --Classe de Produits
left outer join ttcmcs052500 projet on projet.t_cprj = left(lcde.t_item, 9) --Projets
where lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and cde.t_sotp between @sotp_f and @sotp_t --Bornage sur le Type de Commande
and cde.t_cofc between @cofc_f and @cofc_t --Bornage sur le Service des Ventes
and cde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and artlig.t_citg between @citg_f and @citg_t --Bornage sur le Groupe Article
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV ; rajout rbesnier le 30112016
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3) --Type Article Acheté, Fabriqué ou Générique
--Rajout le 21/06/2017 pour ne plus ramener les châssis
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'CHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'VCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'PCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'OCHASSIS'
and (@facture = 1 --Réponse à la Question Posée pour Inclure ou Non les Lignes Facturées
	or (not exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb))
		or exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb) and ttdsls406500.t_invn = 0)))