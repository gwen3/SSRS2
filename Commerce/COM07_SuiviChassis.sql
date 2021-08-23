--------------------------
-- COM07 - Suivi Chassis
--------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(chass.t_item, 9) as Projet, 
substring(chass.t_item, 10, len(chass.t_item)) as Article, 
art.t_dsca as Description, 
chass.t_cwar as Magasin, 
chass.t_serl as NumeroSerie, 
chass.t_loca as Emplacement, 
chass.t_qhnd as StockPhysique, 
chass.t_oser as CodeOrigineSerie, 
dbo.convertenum('wh','B61C','a9','bull','ltc.olot',chass.t_oser,'4') as OrigineSerie, 
chass.t_orno as Ordre, 
chass.t_qall as Affecte, 
chass.t_ornv as CommandeClient, 
chass.t_ponv as PositionLigne, 
cde.t_refa as ReferenceA, 
cde.t_refb as ReferenceB, 
cde.t_ofbp as CodeTiersAcheteur, 
tiersa.t_nama as NomTiersAcheteur, 
cde.t_ddat as DateMADCPrevisionnelle, 
chass.t_bpid as TiersVendeur, 
tiersv.t_nama as NomTiersVendeur, 
cout.t_pric_1 as PrixChassis, 
numser.t_stat as CodeStatut, 
dbo.convertenum('tc','B61C','a9','bull','ibd.ssts',numser.t_stat,'4') as Statut, 
chass.t_isdt as DateSortie, 
chass.t_rdat as DateReception, 
lcde.t_dapc as DateArriveePrevisionnelleChassis, 
chass.t_qblk as StockBloque, 
chass.t_qlal as EmplacementReserve, 
chass.t_qord as StockEnCommande, 
chass.t_cdf_libr as SaisieLibre, 
chass.t_cdf_ncde as NumeroCommande, 
chass.t_cdf_tvv as TVV, 
chass.t_cdf_coul as Couleur, 
dbo.convertlistcdf('wh','B61C','a9','grup','cou',t_cdf_coul,'4') as NomCouleur, 
chass.t_cdf_dim as Empattement, 
dbo.convertlistcdf('wh','B61C','a9','grup','dim',t_cdf_dim,'4') as NomEmpattement, 
chass.t_cdf_marq as MarqueModele, 
dbo.convertlistcdf('wh','B61C','a9','grup','mar',t_cdf_marq,'4') as NomMarqueModele, 
chass.t_cdf_mot as Motorisation, 
dbo.convertlistcdf('wh','B61C','a9','grup','mon',t_cdf_mot,'4') as NomMotorisation, 
chass.t_cdf_mote as Moteur, 
dbo.convertlistcdf('wh','B61C','a9','grup','mot',t_cdf_mote,'4') as NomMoteur, 
chass.t_cdf_nbas as NbPlacesAssises, 
dbo.convertlistcdf('wh','B61C','a9','grup','nas',t_cdf_nbas,'4') as NomNbPlacesAssises, 
chass.t_cdf_nbp as NbPlacesCabines, 
dbo.convertlistcdf('wh','B61C','a9','grup','nbp',t_cdf_nbp,'4') as NomNbPlacesCabines, 
chass.t_cdf_nor as NormeMoteur, 
dbo.convertlistcdf('wh','B61C','a9','grup','nor',t_cdf_nor,'4') as NomNormeMoteur, 
chass.t_cdf_ouv as OuvertureLaterale, 
dbo.convertlistcdf('wh','B61C','a9','grup','ouv',t_cdf_ouv,'4') as NomOuvertureLaterale, 
chass.t_cdf_par as PortesArrieres, 
dbo.convertlistcdf('wh','B61C','a9','grup','par',t_cdf_par,'4') as NomPortesArrieres, 
chass.t_cdf_ptac as PTAC, 
dbo.convertlistcdf('wh','B61C','a9','grup','pta',t_cdf_ptac,'4') as NomPTAC, 
chass.t_cdf_type as Typ, 
dbo.convertlistcdf('wh','B61C','a9','grup','typ',t_cdf_type,'4') as NomType, 
--
dbo.convertlistcdf('wh','B61C','a9','grup','acr',t_cdf_acre,'4') as AntiCrev,
dbo.convertlistcdf('wh','B61C','a9','grup','air',t_cdf_airb,'4') as Airbag, 
dbo.convertlistcdf('wh','B61C','a9','grup','ant',t_cdf_ante,'4') as Antenne,
dbo.convertlistcdf('wh','B61C','a9','grup','atl',t_cdf_atla,'4') as Attelage, 
dbo.convertlistcdf('wh','B61C','a9','grup','aut',t_cdf_auto,'4') as Automatisme,
dbo.convertlistcdf('wh','B61C','a9','grup','ban',t_cdf_banq,'4') as Banquette, 
dbo.convertlistcdf('wh','B61C','a9','grup','bat',t_cdf_bat2,'4') as SecBat,
dbo.convertlistcdf('wh','B61C','a9','grup','btv',t_cdf_btvi,'4') as BteVit,
dbo.convertlistcdf('wh','B61C','a9','grup','car',t_cdf_cart,'4') as Gps,
dbo.convertlistcdf('wh','B61C','a9','grup','cli',t_cdf_clim,'4') as Clim,
dbo.convertlistcdf('wh','B61C','a9','grup','cls',t_cdf_clse,'4') as CloisonSep,
dbo.convertlistcdf('wh','B61C','a9','grup','doc',t_cdf_doca,'4') as DoubleCab,
t_cdf_empl as EmplParc,
dbo.convertlistcdf('wh','B61C','a9','grup','enj',t_cdf_enjo,'4') as Enjoliveur,
dbo.convertlistcdf('wh','B61C','a9','grup','ext',t_cdf_exti,'4') as Extinct,
t_cdf_imma as Immat,
t_cdf_mear as MasseEssieuAR,
t_cdf_meav as MasseEssieuAV,
t_cdf_mtot as MasseTotale,
dbo.convertlistcdf('wh','B61C','a9','grup','nbc',t_cdf_nbcl,'4') as NbrClefsCarte,
dbo.convertlistcdf('wh','B61C','a9','grup','not',t_cdf_noti,'4') as Notice,
t_cdf_numk as NumClef,
t_cdf_nuni as NumUnique,
dbo.convertlistcdf('wh','B61C','a9','grup','pac',t_cdf_parc,'4') as ModeParcEco,
dbo.convertlistcdf('wh','B61C','a9','grup','esp',t_cdf_pesp,'4') as Esp,
dbo.convertlistcdf('wh','B61C','a9','grup','ral',t_cdf_rala,'4') as RalAcc,
dbo.convertlistcdf('wh','B61C','a9','grup','rar',t_cdf_rarr,'4') as RouesAR,
t_cdf_rce as Rce,
(case 
when t_cdf_resv = '1'  
	then 'Oui'
else
	'Non'
end) as Reserve,
dbo.convertlistcdf('wh','B61C','a9','grup','ret',t_cdf_retr,'4') as RetroExt,
dbo.convertlistcdf('wh','B61C','a9','grup','sre',t_cdf_srec,'4') as AideSta,
dbo.convertlistcdf('wh','B61C','a9','grup','sts',t_cdf_stst,'4') as StartStop,
dbo.convertlistcdf('wh','B61C','a9','grup','trs',chass.t_cdf_tran,'4') as Transmission
--
from twhltc500500 chass --Articles Sérialisés
inner join ttcibd001500 art on art.t_item = chass.t_item --Articles
inner join ttcibd401500 numser on numser.t_item = chass.t_item and numser.t_sern = chass.t_serl --Numéro de série
left outer join ttdsls400500 cde on cde.t_orno = chass.t_ornv --Commande Client
left outer join ttccom100500 tiersv on tiersv.t_bpid = chass.t_bpid -- Tiers Vendeur
left outer join ttccom100500 tiersa on tiersa.t_bpid = cde.t_ofbp --Tiers Acheteur
left outer join ttdsls401500 lcde on lcde.t_orno = cde.t_orno and lcde.t_pono = chass.t_ponv --Lignes Commande Client
left outer join twhltc502500 cout on cout.t_item = chass.t_item and cout.t_serl = chass.t_serl and cout.t_cwar = chass.t_cwar and cout.t_cpcp = 'MATIER' and cout.t_trdt = 
(select top 1 datecout.t_trdt from twhltc502500 datecout where datecout.t_item = chass.t_item and datecout.t_serl = chass.t_serl and datecout.t_cwar = chass.t_cwar and datecout.t_cpcp = 'MATIER' order by datecout.t_trdt desc) --Détails des Coûts de Transaction de Prix et N°
--Rajout du 04/04/2017 pour les problèmes de châssis en double
and cout.t_seqn = 
(select top 1 seqcout.t_seqn from twhltc502500 seqcout where seqcout.t_item = chass.t_item and seqcout.t_serl = chass.t_serl and seqcout.t_cwar = chass.t_cwar and seqcout.t_cpcp = 'MATIER' order by seqcout.t_seqn desc) --On prend la séquence la plus grande
where chass.t_item in ('         CHASSIS', '         OCHASSIS', '         VCHASSIS', '         PCHASSIS') --On récupère les chassis
and chass.t_qhnd between @qhnd_f and @qhnd_t --Bornage sur le Stock
and chass.t_cwar between @mag_f and @mag_t --Bornage sur le Magasin
and chass.t_ornv between @cde_f and @cde_t --Bornage sur la Commande Client
and ((chass.t_isdt between @dtesortie_f and @dtesortie_t) or (chass.t_isdt = '01/01/1970')) --Bornage sur la Date de Sortie
and ((chass.t_rdat between @dterecept_f and @dterecept_t) or (chass.t_rdat = '01/01/1970')) --Bornage sur la Date de Réception
and chass.t_bpid between @tven_f and @tven_t --Bornage sur le Tiers Vendeur
and left(chass.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE à partir du Magasin