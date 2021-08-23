------------------------
-- GEN05 - Supervision
------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lcde.t_orno as NumeroCommande, 
lcde.t_pono as PositionCommande, 
lcde.t_sqnb as SequenceCommande, 
'' as NumeroAvenant, 
(select count(*) from ttdsls401500 comde where comde.t_item like '%AVENANT%' and comde.t_orno = lcde.t_orno) as NombreAvenantOrigineInterne, 
cde.t_odat as DateSaisieOV, 
ofab.t_pdno as OrdreFabrication, 
lcde.t_serl as NumeroChassis, 
emp.t_nama as Interlocuteur, 
'' as QteRouge, 
'' as QteBlanc, 
'' as QteExport, 
lcde.t_qoor as QteCommandeeLigneOV, 
(select sum(lcomde.t_qoor) 
from ttdsls401500 lcomde 
inner join ttdsls411500 artlcomde on artlcomde.t_orno = lcomde.t_orno and artlcomde.t_pono = lcomde.t_pono and artlcomde.t_sqnb = lcomde.t_sqnb 
where lcomde.t_orno = lcde.t_orno 
and artlcomde.t_citg like '%T%') as QteTotaleCommandee, --On ne prend que les groupes articles qui contiennent un T
cde.t_ofbp as TiersAcheteur, 
tier.t_nama as NomTiersAcheteur, 
concat(cde.t_clfi,' ',clfi.t_nama) as ClientFinal, 
isnull(((select sum(lc.t_oamt) from ttdsls401500 lc where lc.t_orno = lcde.t_orno and lc.t_item = '         VCHASSIS') / (select sum(lcomde.t_qoor) from ttdsls401500 lcomde inner join ttdsls411500 artlcomde on artlcomde.t_orno = lcomde.t_orno and artlcomde.t_pono = lcomde.t_pono and artlcomde.t_sqnb = lcomde.t_sqnb where lcomde.t_orno = lcde.t_orno and artlcomde.t_citg like '%T%')), '') as MontantVCHASSIS, 
isnull(((select sum(lc.t_oamt) from ttdsls401500 lc inner join ttcibd001500 artlc on artlc.t_item = lc.t_item where lc.t_orno = lcde.t_orno and lc.t_item != '         VCHASSIS' and artlc.t_kitm != 4) / (select sum(lcomde.t_qoor) from ttdsls401500 lcomde inner join ttdsls411500 artlcomde on artlcomde.t_orno = lcomde.t_orno and artlcomde.t_pono = lcomde.t_pono and artlcomde.t_sqnb = lcomde.t_sqnb where lcomde.t_orno = lcde.t_orno and artlcomde.t_citg like '%T%')), '') as MontantEquipement, 
isnull(((select sum(lc.t_oamt) from ttdsls401500 lc inner join ttcibd001500 artlc on artlc.t_item = lc.t_item where lc.t_orno = lcde.t_orno and artlc.t_kitm = 4) / (select sum(lcomde.t_qoor) from ttdsls401500 lcomde inner join ttdsls411500 artlcomde on artlcomde.t_orno = lcomde.t_orno and artlcomde.t_pono = lcomde.t_pono and artlcomde.t_sqnb = lcomde.t_sqnb where lcomde.t_orno = lcde.t_orno and artlcomde.t_citg like '%T%')), '') as MontantService, 
marq.t_dsca as NomContremarque, 
cde.t_osrp as RepresentantExterne, 
empb.t_nama as NomRepresentantExterne, 
adrta.t_pstc as CodePostalTiersAcheteur, 
vilta.t_dsca as VilleTiersAcheteur, 
adrcf.t_pstc as CodePostalClientFinal, 
vilcf.t_dsca as VilleClientFinal, 
'' as LivraisonVehiculeImmatriculee, 
cde.t_cdf_bcdt as DateSignatureCommandeClient, --Rajout le 21/07/2017 par rbesnier
cde.t_corn as InfoCommandeClient, 
cde.t_cdf_prdt as DatePenaliteContractuelle, --Rajout le 21/07/2017 par rbesnier
cde.t_ddat as DateProductionGruau, 
lcde.t_dlsc as DateLivraisonSouhaitee, 
lcde.t_prdt as DateMADCPrevue, 
'' as DateEnvoiAccuseReception, 
'' as DateRevueContrat, 
(case 
when (lcde.t_serl <> '' and lcde.t_item = '         CHASSIS') 
	then (select left(dbo.convertlistcdf('wh','B61C','a9','grup','mar',e.t_cdf_marq,'4'), charindex(dbo.convertlistcdf('wh','B61C','a9','grup','mar',e.t_cdf_marq,'4'), ' ')) from twhltc500500 e 
		where (lcde.t_item = e.t_item and lcde.t_serl = e.t_serl and lcde.t_cwar = e.t_cwar)) 
    else left(cpro.t_dsca, charindex(cpro.t_dsca, ' '))
end) as Marque, 
(case
when (lcde.t_serl <> '' and lcde.t_item = '         CHASSIS') 
	then (select substring(dbo.convertlistcdf('wh','B61C','a9','grup','mar',f.t_cdf_marq,'4'), charindex(dbo.convertlistcdf('wh','B61C','a9','grup','mar',f.t_cdf_marq,'4'), ' ') + 1, len(dbo.convertlistcdf('wh','b61c','a9','grup','mar',f.t_cdf_marq,'4'))) from twhltc500500 f
		where (lcde.t_item = f.t_item and lcde.t_serl = f.t_serl and lcde.t_cwar = f.t_cwar)) 
    else substring(cpro.t_dsca, charindex(cpro.t_dsca, ' ') + 1, len(cpro.t_dsca)) 
end) as Modele, 
chass.t_cdf_dim as Empattement, 
dbo.convertlistcdf('wh','B61C','a9','grup','dim',t_cdf_dim,'4') as NomEmpattement, 
artlig.t_citg as FamilleProduit, 
grpart.t_dsca as LibelleFamilleProduit, 
'' as CodeConstructeur, 
dbo.convertlistcdf('td','B61C','a9','grup','ost',cde.t_cdf_opst,'4') as Suspension, 
dbo.convertlistcdf('td','B61C','a9','grup','sdm',cde.t_cdf_sdmo,'4') as SousTraitantTransformation, --Modification avec le CDF par rbesnier le 21/07/2017 qui remplace la reference B
cde.t_refb as ReferenceB, 
'' as ChassisACommander, 
'' as DateCommandeChassis, 
lcde.t_dapc as DateArriveePrevueChassis, 
(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) as DateArriveeChassis, --On apprend la date la plus récente
lcde.t_prdt as DateFacturationPlanifiee, 
ofab.t_cmdt as DateDeclarationInformatiqueOF, 
cde.t_cdf_redt as DateReceptionClient, 
(select top 1 ligliv.t_dldt from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb)) as DateLivraisonConfirmationExpedition, 
(select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (lcde.t_orno = ligliv.t_orno and lcde.t_pono = ligliv.t_pono and lcde.t_sqnb = ligliv.t_sqnb))) as DateEditionBL, 
--Rajout le 21/08/2017, rbesnier pour le Montant Facture et à Facturer
(select sum(livcdefact.t_namt) / lcde.t_rats_1 from ttdsls406500 livcdefact where livcdefact.t_orno = livcde.t_orno and livcdefact.t_pono = livcde.t_pono and livcdefact.t_invd <> '01/01/1970') as MontantFacture, 
(select sum(livcdeafact.t_namt) / lcde.t_rats_1 from ttdsls406500 livcdeafact where livcdeafact.t_orno = livcde.t_orno and livcdeafact.t_pono = livcde.t_pono and livcdeafact.t_invd = '01/01/1970' and livcde.t_stat < 20) as MontantAFacturer, 
--Fonctionne, test avec l'OV AP3100002
cde.t_ccur as DeviseCommande, 
livcde.t_invd as DateFacture, 
concat(livcde.t_ttyp, livcde.t_invn) as NumeroFacture, 
'' as DateAppelFeedBackClient, 
cde.t_cofc as ServiceVente, 
projet.t_dsca as DescriptifProjet, 
left(lcde.t_item, 9) as Projet, 
substring(lcde.t_item, 10, len(lcde.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
prj.t_psta as EtapeProjet, 
lcde.t_cpva as Variante, 
dbo.textnumtotext(lcde.t_txta,'4') as TexteLigneOV, 
(case 
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
end) as TaGlobal, 
lcde.t_dtaf as DateAffectationChassis, 
prj.t_ddat as DatePrevDossierSpe, 
ofab.t_osta as StatutOF, 
ofab.t_prdt as DDOF, 
ofab.t_pldt as DateProductionFinOF, 
cde.t_refa as ParcOuBesoin, 
--rajout par rbesnier le 03/11/2017 suite aux dernières informations voulues par JCGT
art.t_dcre as DateCreationArticle, 
lcde.t_dmad as DateMADCConfirmee, 
dbo.convertenum('td','B61C','a9','bull','sls.hdst',cde.t_hdst,'4') as StatutOV, 
cout.t_pric_1 as MontantCommandeAchatChassis, 
cupf.t_nuna as TempsRealise, 
ofab.t_apdt as DateReelleDebutFabrication, 
lcde.t_drpv as DateEditionCOC, 
ofab.t_adld as DateLivraisonReelle 
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employés
left outer join ttccom001500 empb on empb.t_emno = cde.t_osrp --Employés - Représentant Externe
left outer join ttccom100500 tier on tier.t_bpid = cde.t_ofbp --Tiers
left outer join ttccom130500 adrta on adrta.t_cadr = cde.t_ofad --Adresse du Tiers Acheteur
left outer join ttccom139500 vilta on vilta.t_city = adrta.t_ccit and vilta.t_ccty = 'FRA' and vilta.t_cste = left(adrta.t_pstc, 2) --Villes du Tiers Acheteur
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --Ordres de Fabrication
left outer join ttccom100500 clfi on clfi.t_bpid = isnull(cde.t_clfi, cde.t_stad) --Tiers - Client Final
left outer join ttccom130500 adrcf on adrcf.t_cadr = clfi.t_cadr --Adresse du Client Final
left outer join ttccom139500 vilcf on vilcf.t_city = adrcf.t_ccit and vilcf.t_ccty = 'FRA' and vilcf.t_cste = left(adrcf.t_pstc, 2) --Villes du Client Final
left outer join tzgsls001500 marq on marq.t_cont = cde.t_cntr --Gestion des Contremarques
inner join ttdsls411500 artlig on artlig.t_orno = lcde.t_orno and artlig.t_pono = lcde.t_pono and artlig.t_sqnb = lcde.t_sqnb --Données Articles de la Ligne de Commande Client
left outer join ttcmcs062500 cpro on cpro.t_cpcl = artlig.t_cpcl --Classe de Produits
left outer join ttcmcs023500 grpart on grpart.t_citg = artlig.t_citg --Groupe Article
left outer join ttdsls406500 livcde on livcde.t_orno = lcde.t_orno and livcde.t_pono = lcde.t_pono and livcde.t_sqnb = lcde.t_sqnb --Lignes de Livraison de Commandes Clients Réelles
left outer join ttcmcs052500 projet on projet.t_cprj = left(lcde.t_item, 9) --Projets
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttipcs030500 prj on prj.t_cprj = left(lcde.t_item, 9) --Details du Projet
left outer join ttirou101500 gam on gam.t_mitm = lcde.t_item and ltrim(rtrim(gam.t_opro)) = '0' and lcde.t_item != '         CHASSIS' --Code Gamme par Article
left outer join twhltc500500 chass on chass.t_item = lcde.t_item and chass.t_serl = lcde.t_serl --Numéros de Série par Magasin
left outer join twhltc502500 cout on cout.t_item = '         VCHASSIS' and cout.t_serl = lcde.t_serl and cout.t_cwar = concat(left(lcde.t_orno, 2), 'PARC') and cout.t_trdt = (select top 1 ct.t_trdt from twhltc502500 ct where ct.t_item = '         VCHASSIS' and ct.t_serl = lcde.t_serl and ct.t_cwar = concat(left(lcde.t_orno, 2), 'PARC') and cout.t_cpcp = 'MATIER' order by ct.t_seqn desc) and cout.t_cpcp = 'MATIER' --Détails des coûts de transactions de prix de n°
left outer join tticst010500 cupf on cupf.t_pdno = ofab.t_pdno and cupf.t_cstv = 1 and cupf.t_cpcp = 'MO_AGG' --Couts Unitaires Produits Finis
where artlig.t_citg like '%T%' --Permet de récupérer uniquement les véhicules et ainsi enlever les CHASSIS, VCHASSIS...
and art.t_kitm != 4 --On exclu les articles de coût
and lcde.t_orno between @cde_f and @cde_t --Bornage sur le Numéro de Commande
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le Numéro de Commande
--Ajout par rbesnier le 03/11/2017. Cela fait suite au problème de la division par 0, car parfois dans les montants, la quantité calculée est égale à 0 lorsqu'ils font de fausses manipulations. Cette solution supprime la ligne qui aurait fait planter la requête.
and (select sum(lcomde.t_qoor) from ttdsls401500 lcomde inner join ttdsls411500 artlcomde on artlcomde.t_orno = lcomde.t_orno and artlcomde.t_pono = lcomde.t_pono and artlcomde.t_sqnb = lcomde.t_sqnb where lcomde.t_orno = lcde.t_orno and artlcomde.t_citg like '%T%') != 0
--rajout par rbesnier le 04/03/2019 pour limiter les données ramenées
and cde.t_cofc between @cofc_f and @cofc_t --Bornage sur le service de vente
and cde.t_odat between @dateov_f and @dateov_t --Bornage sur la date de saisie d'OV
order by lcde.t_orno asc