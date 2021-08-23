---------------------------------
-- COM03 - Suivi Petit Forestier
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lcde.t_orno as NumeroCommande
,lcde.t_pono as PositionNumeroCommande
,lcde.t_corn as NumeroMarquage
,(select top 1 corstk.t_trdt from twhinr110500 corstk where corstk.t_koor = 52 and corstk.t_item = concat(lcde.t_cprj, 'DON00220') order by corstk.t_trdt desc) as DateReceptionMarquage
,(select top 1 corstk1.t_trdt from twhinr110500 corstk1 where corstk1.t_koor = 52 and corstk1.t_item = concat(lcde.t_cprj, 'DON00247') order by corstk1.t_trdt desc) as DateReceptionPub
,(select top 1 corstk2.t_trdt from twhinr110500 corstk2 where corstk2.t_koor = 52 and (corstk2.t_item = concat(lcde.t_cprj, 'DON00248') or corstk2.t_item = concat(lcde.t_cprj, 'DON00249')) order by corstk2.t_trdt desc) as DateReceptionGrp
,descoptvardeco.t_dsca as Publicite
,lcde.t_serl as NumeroChassis
,lcde.t_dapc as DateArriveePrevueChassis
,(case 
when lcde.t_serl != '' and lcde.t_dtaf < '01/01/1980' 
	then (select top 1 lc.t_dtaf from ttdsls401500 lc where lc.t_orno = lcde.t_orno and lc.t_item = '         CHASSIS' and lc.t_serl = lcde.t_serl)
else
	lcde.t_dtaf
end) as DateAffectationChassis
,(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = lcde.t_serl and cha.t_cwar = lcde.t_cwar order by cha.t_rdat desc) as DateArriveeChassis 
,lcde.t_cdf_cpdt as DateReceptionImmatriculation
,lcde.t_dmad as DateMADCConfirmee
,lcde.t_prdt as DateMADCPrevue
,lcde.t_cdf_imat as Immatriculation
,lcde.t_cdf_dimm as DateImmatriculation
,concat(lcde.t_cdf_imat, ' ',lcde.t_cdf_dimm) as NumDateImmat
,cde.t_ofbp as TiersAcheteur
,tier.t_nama as NomTiersAcheteur
,left(lcde.t_item, 9) as Projet
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,lcde.t_cdf_cpdt as DateReceptCpiOuCarteGrise
,lcde.t_ddta as DateProduction_Gruau
,concat(titre.t_dsca, ' ', cont.t_fuln) as CodeAssocie
,lcde.t_cdf_codt as DateEditionCOC
,lcde.t_cdf_wldt as DateDocWltpIssueCal
,descoptvarclasse.t_dsca as ClasseFroid
,(case 
when exists (select ttdsls406500.t_invd from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb and ttdsls406500.t_invn <> 0))
then (select ttdsls406500.t_invd from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb))
else '01/01/1970'
end) as DateFacture
,cpro.t_dsca as MarqueModel
,lcde.t_cdf_refc as RefC
,lcde.t_cdf_refd as RefD
,lcde.t_cdf_ddtr as DateDemandeTransport
,dbo.convertlistcdf('td','B61C','a9','grup','pig',lcde.t_cdf_pigr,'4') as PosePlaqueGruau
,lcde.t_cdf_pptr as PrestPostTransfo
,lcde.t_cdf_redt as DateRealPostEquip
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join ttdsls411500 artcde on	artcde.t_orno = lcde.t_orno and artcde.t_pono = lcde.t_pono and artcde.t_sqnb = 0
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
inner join ttdsls411500 artlig on artlig.t_orno = lcde.t_orno and artlig.t_pono = lcde.t_pono and artlig.t_sqnb = lcde.t_sqnb --Données Articles de la Ligne de Commande Client
left outer join ttccom100500 tier on tier.t_bpid = cde.t_ofbp --Tiers
left outer join ttipcf520500 optvardeco on optvardeco.t_cpva = lcde.t_cpva and optvardeco.t_cpft = 'Deco' --Options par Variantes de Produits - Décoration
left outer join ttipcf520500 optvarclasse on optvarclasse.t_cpva = lcde.t_cpva and optvarclasse.t_cpft = 'classe' --Options par Variantes de Produits - Classe
left outer join ttipcf510500 strucvarprddeco on strucvarprddeco.t_cpva = lcde.t_cpva and strucvarprddeco.t_opts = optvardeco.t_opts
left outer join ttipcf510500 strucvarprdclasse on strucvarprdclasse.t_cpva = lcde.t_cpva and strucvarprdclasse.t_opts = optvarclasse.t_opts
left outer join ttipcf110500 descoptvardeco on descoptvardeco.t_item = strucvarprddeco.t_item and descoptvardeco.t_copt = optvardeco.t_copt and descoptvardeco.t_cpft = optvardeco.t_cpft --Description de l'option decoration
left outer join ttipcf110500 descoptvarclasse on descoptvarclasse.t_item = strucvarprdclasse.t_item and descoptvarclasse.t_copt = optvarclasse.t_copt and descoptvarclasse.t_cpft = optvarclasse.t_cpft --Description de l'option Classe
left outer join ttccom140500 cont on cont.t_ccnt = cde.t_ofcn --Contacts - Tiers Acheteur
left outer join ttcmcs019500 titre on titre.t_ctit = cont.t_ctit --Titre du contact tiers acheteur
left outer join ttcmcs062500 cpro on cpro.t_cpcl = artlig.t_cpcl --Classe de Produits
where 
lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and lcde.t_qoor > 0 -- Ne pas prendre les avoirs
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'CHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'VCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'PCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'OCHASSIS'
and cde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and cde.t_ofbp in (@tierspf) --Bornage sur le Tiers Acheteur - Liste des Tiers Petit Forestier
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3) --Type Article Acheté, Fabriqué ou Générique
--
-- Réponse à la question Exclure BL imprimé ? 
and (
	(@ExclureBLImp =  1 and 
		(select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (ligliv.t_orno = lcde.t_orno and ligliv.t_pono = lcde.t_pono and ligliv.t_sqnb = lcde.t_sqnb))) = '01/01/1970')
or (@ExclureBLImp =  1 and 
	not exists (select expe.t_pdat from twhinh430500 expe where expe.t_shpm = (select top 1 ligliv.t_shpm from ttdsls406500 ligliv where (ligliv.t_orno = lcde.t_orno and ligliv.t_pono = lcde.t_pono and ligliv.t_sqnb = lcde.t_sqnb))))
--	not exists(select top 1 exped.t_shpm from twhinh431500 exped where exped.t_worg = '1' and exped.t_worn = lcde.t_orno and exped.t_wpon = lcde.t_pono))
or @ExclureBLImp != 1
)
--
--Réponse à la Question Posée pour Inclure ou Non les Lignes Facturées
and (
(@facture = 1 and exists(select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb and ttdsls406500.t_invd between @dtfac_f and @dtfac_t)))
 or (not exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb)))
 or (exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb and ttdsls406500.t_invn = 0 and ttdsls406500.t_stat <> '25'))))