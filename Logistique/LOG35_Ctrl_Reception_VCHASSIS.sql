----------------------------------
-- LOG35 - Ctrl_Reception_Chassis   
----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
lcde.t_orno as CommandeClient
,lcde.t_pono as LigneCommandeClient
,cde.t_odat as DateCommande
,tiersach.t_nama as TiersAcheteur
,clientfin.t_nama as ClientFinal
,cde.t_corn as CommandeDuClient
,substring(lcde.t_item, 10, len(lcde.t_item)) as Article
,lcde.t_serl as NumSerie
,lcde.t_prdt as DateMADCPrevue
,lcde.t_dmad as DateMADCConf
,lcde.t_dapc as DateArrPrevChassis
,substring(artsermag.t_item, 10, len(artsermag.t_item)) as ArtChassis
,artsermag.t_qhnd as StockChassis
,artsermag.t_rdat as DateReceptionChassis
,artsermag.t_isdt as DateSortieChassis
,sermag.t_qhnd as StockChassisAchete
,sermag.t_qord as EnCde
,sermag.t_orno as Ordre
,dbo.convertenum('wh','B61C','a9','bull','ltc.olot',sermag.t_oser,'4') as OrigineSerie
,sermag.t_bpid as Tiers
,tiers.t_nama as NomTiers
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join twhltc500500 artsermag on artsermag.t_item = '         CHASSIS' and artsermag.t_serl = lcde.t_serl and artsermag.t_cwar = lcde.t_cwar --Numéros de série du CHASSIS
left outer join twhltc500500 sermag on sermag.t_item = lcde.t_item and sermag.t_serl = lcde.t_serl and sermag.t_cwar = lcde.t_cwar --Numéros de série par magasin
left outer join ttccom100500 tiers on tiers.t_bpid = sermag.t_bpid --Tiers vendeur Chassis
left outer join ttccom100500 tiersach on tiersach.t_bpid = cde.t_ofbp --Tiers acheteur
left outer join ttccom100500 clientfin on clientfin.t_bpid = cde.t_clfi --Client Final
where 
left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV
and substring(lcde.t_item, 10, len(lcde.t_item)) IN  ('VCHASSIS', 'OCHASSIS', 'PCHASSIS')
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and lcde.t_serl <> '' -- N° de Série renseigné
and lcde.t_qidl = 0 --Ligne non livrée
and (artsermag.t_qhnd > 0 or artsermag.t_isdt > '01/01/1970') -- Article CHASSIS en stock ou déjà livré
and sermag.t_qhnd = 0 -- Article VCHASSIS/OCHASSIS/PCHASSIS non en stock
--
order by lcde.t_orno, lcde.t_pono