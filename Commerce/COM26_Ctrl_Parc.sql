---------------------------------
-- COM26 - Ctrl PARC
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
select 
--left(chass.t_item, 9) as Projet
substring(chass.t_item, 10, len(chass.t_item)) as Article
,chass.t_cwar as Magasin 
,chass.t_serl as NumeroSerie
,chass.t_rdat as DateReception
,isnull(lcde.t_dtaf,'01/01/1970') as DateAffectation
,chass.t_ornv as CommandeAffectee
,isnull(lcde.t_pono,'') as PosCde
,isnull(lcde.t_cpva,'') as Variante
,isnull(artcde.t_citg,'') as GroupeArt
,isnull(left(artcde.t_citg,2),'') as Famille
,isnull(descoptvar1.t_dsca,'') as Attelage
,isnull(descoptvar2.t_dsca,'') as Climatisation
,isnull(descoptvar3.t_dsca,'') as CloisonOrigine
,isnull(descoptvar4.t_dsca,'') as AccesLat
,isnull(descoptvar5.t_dsca,'') as ExtClCh
,isnull(descoptvar6.t_dsca,'') as FinitVeh
,isnull(descoptvar7.t_dsca,'') as Hauteur
,isnull(descoptvar8.t_dsca,'') as Longueur
,isnull(descoptvar9.t_dsca,'') as LongRetro
,isnull(descoptvar10.t_dsca,'') as Moteur
,isnull(descoptvar11.t_dsca,'') as Radar
,isnull(descoptvar12.t_dsca,'') as OuvLat
,isnull(descoptvar13.t_dsca,'') as PlaceAvt
,isnull(descoptvar14.t_dsca,'') as Rds
,isnull(descoptvar15.t_dsca,'') as Retro
,isnull(descoptvar16.t_dsca,'') as ToleVitre
,isnull(descoptvar17.t_dsca,'') as TractionPropulsion
,isnull(descoptvar18.t_dsca,'') as VoiesArr
--
from twhltc500500 chass --Articles Sérialisés
left outer join ttdsls401500 lcde on lcde.t_orno = chass.t_ornv and lcde.t_pono = 
(select top 1 lcdetrans.t_pono from ttdsls401500 lcdetrans where lcdetrans.t_orno = chass.t_ornv and lcdetrans.t_serl = chass.t_serl 
	and lcdetrans.t_item not like '%CHASSIS%' order by lcdetrans.t_pono) --Lignes Commande Client
left outer join ttdsls411500 artcde on	artcde.t_orno = lcde.t_orno and artcde.t_pono = lcde.t_pono and artcde.t_sqnb = 0
--
-- Caractéristiques/Options
-- (1) Attelage
left outer join ttipcf520500 optvar1 on optvar1.t_cpva = lcde.t_cpva and optvar1.t_cpft = 'Attelage' --Options par Variantes de Produits
left outer join ttipcf510500 strucvar1 on strucvar1.t_cpva = lcde.t_cpva and strucvar1.t_opts = optvar1.t_opts -- Structure de variante
left outer join ttipcf110500 descoptvar1 on descoptvar1.t_item = strucvar1.t_item and descoptvar1.t_cpft = optvar1.t_cpft and descoptvar1.t_copt = optvar1.t_copt --Description de l'option
-- (2) Climatisation
left outer join ttipcf520500 optvar2 on optvar2.t_cpva = lcde.t_cpva and optvar2.t_cpft = 'clim' 
left outer join ttipcf510500 strucvar2 on strucvar2.t_cpva = lcde.t_cpva and strucvar2.t_opts = optvar2.t_opts 
left outer join ttipcf110500 descoptvar2 on descoptvar2.t_item = strucvar2.t_item and descoptvar2.t_cpft = optvar2.t_cpft and descoptvar2.t_copt = optvar2.t_copt 
-- (3) Cloison Origine
left outer join ttipcf520500 optvar3 on optvar3.t_cpva = lcde.t_cpva and optvar3.t_cpft = 'CloisonOr' 
left outer join ttipcf510500 strucvar3 on strucvar3.t_cpva = lcde.t_cpva and strucvar3.t_opts = optvar3.t_opts 
left outer join ttipcf110500 descoptvar3 on descoptvar3.t_item = strucvar3.t_item and descoptvar3.t_cpft = optvar3.t_cpft and descoptvar3.t_copt = optvar3.t_copt 
-- (4) Accès Lat.
left outer join ttipcf520500 optvar4 on optvar4.t_cpva = lcde.t_cpva and optvar4.t_cpft = 'AccesLat' 
left outer join ttipcf510500 strucvar4 on strucvar4.t_cpva = lcde.t_cpva and strucvar4.t_opts = optvar4.t_opts 
left outer join ttipcf110500 descoptvar4 on descoptvar4.t_item = strucvar4.t_item and descoptvar4.t_cpft = optvar4.t_cpft and descoptvar4.t_copt = optvar4.t_copt 
-- (5) Extension climatisation
left outer join ttipcf520500 optvar5 on optvar5.t_cpva = lcde.t_cpva and optvar5.t_cpft = 'extclch' 
left outer join ttipcf510500 strucvar5 on strucvar5.t_cpva = lcde.t_cpva and strucvar5.t_opts = optvar5.t_opts 
left outer join ttipcf110500 descoptvar5 on descoptvar5.t_item = strucvar5.t_item and descoptvar5.t_cpft = optvar5.t_cpft and descoptvar5.t_copt = optvar5.t_copt 
-- (6) Finition Veh.
left outer join ttipcf520500 optvar6 on optvar6.t_cpva = lcde.t_cpva and optvar6.t_cpft = 'finitveh' 
left outer join ttipcf510500 strucvar6 on strucvar6.t_cpva = lcde.t_cpva and strucvar6.t_opts = optvar6.t_opts 
left outer join ttipcf110500 descoptvar6 on descoptvar6.t_item = strucvar6.t_item and descoptvar6.t_cpft = optvar6.t_cpft and descoptvar6.t_copt = optvar6.t_copt 
-- (7) Hauteur
left outer join ttipcf520500 optvar7 on optvar7.t_cpva = lcde.t_cpva and optvar7.t_cpft = 'Haut' 
left outer join ttipcf510500 strucvar7 on strucvar7.t_cpva = lcde.t_cpva and strucvar7.t_opts = optvar7.t_opts 
left outer join ttipcf110500 descoptvar7 on descoptvar7.t_item = strucvar7.t_item and descoptvar7.t_cpft = optvar7.t_cpft and descoptvar7.t_copt = optvar7.t_copt 
-- (8) Longueur
left outer join ttipcf520500 optvar8 on optvar8.t_cpva = lcde.t_cpva and optvar8.t_cpft = 'Long' 
left outer join ttipcf510500 strucvar8 on strucvar8.t_cpva = lcde.t_cpva and strucvar8.t_opts = optvar8.t_opts 
left outer join ttipcf110500 descoptvar8 on descoptvar8.t_item = strucvar8.t_item and descoptvar8.t_cpft = optvar8.t_cpft and descoptvar8.t_copt = optvar8.t_copt 
-- (9) Longueur Retro
left outer join ttipcf520500 optvar9 on optvar9.t_cpva = lcde.t_cpva and optvar9.t_cpft = 'longretro' 
left outer join ttipcf510500 strucvar9 on strucvar9.t_cpva = lcde.t_cpva and strucvar9.t_opts = optvar9.t_opts 
left outer join ttipcf110500 descoptvar9 on descoptvar9.t_item = strucvar9.t_item and descoptvar9.t_cpft = optvar9.t_cpft and descoptvar9.t_copt = optvar9.t_copt 
-- (10) Moteur
left outer join ttipcf520500 optvar10 on optvar10.t_cpva = lcde.t_cpva and optvar10.t_cpft = 'Moteur' 
left outer join ttipcf510500 strucvar10 on strucvar10.t_cpva = lcde.t_cpva and strucvar10.t_opts = optvar10.t_opts 
left outer join ttipcf110500 descoptvar10 on descoptvar10.t_item = strucvar10.t_item and descoptvar10.t_cpft = optvar10.t_cpft and descoptvar10.t_copt = optvar10.t_copt 
-- (11) Radar
left outer join ttipcf520500 optvar11 on optvar11.t_cpva = lcde.t_cpva and optvar11.t_cpft = 'OptRadarVeh' 
left outer join ttipcf510500 strucvar11 on strucvar11.t_cpva = lcde.t_cpva and strucvar11.t_opts = optvar11.t_opts 
left outer join ttipcf110500 descoptvar11 on descoptvar11.t_item = strucvar11.t_item and descoptvar11.t_cpft = optvar11.t_cpft and descoptvar11.t_copt = optvar11.t_copt 
-- (12) Ouverture Arrière
left outer join ttipcf520500 optvar12 on optvar12.t_cpva = lcde.t_cpva and optvar12.t_cpft = 'OuvertAr' 
left outer join ttipcf510500 strucvar12 on strucvar12.t_cpva = lcde.t_cpva and strucvar12.t_opts = optvar12.t_opts 
left outer join ttipcf110500 descoptvar12 on descoptvar12.t_item = strucvar12.t_item and descoptvar12.t_cpft = optvar12.t_cpft and descoptvar12.t_copt = optvar12.t_copt
-- (13) Places Avant
left outer join ttipcf520500 optvar13 on optvar13.t_cpva = lcde.t_cpva and optvar13.t_cpft = 'plav' 
left outer join ttipcf510500 strucvar13 on strucvar13.t_cpva = lcde.t_cpva and strucvar13.t_opts = optvar13.t_opts 
left outer join ttipcf110500 descoptvar13 on descoptvar13.t_item = strucvar13.t_item and descoptvar13.t_cpft = optvar13.t_cpft and descoptvar13.t_copt = optvar13.t_copt
-- (14) RDS
left outer join ttipcf520500 optvar14 on optvar14.t_cpva = lcde.t_cpva and optvar14.t_cpft = 'rds' 
left outer join ttipcf510500 strucvar14 on strucvar14.t_cpva = lcde.t_cpva and strucvar14.t_opts = optvar14.t_opts 
left outer join ttipcf110500 descoptvar14 on descoptvar14.t_item = strucvar14.t_item and descoptvar14.t_cpft = optvar14.t_cpft and descoptvar14.t_copt = optvar14.t_copt
-- (15) Retro
left outer join ttipcf520500 optvar15 on optvar15.t_cpva = lcde.t_cpva and optvar15.t_cpft = 'retro' 
left outer join ttipcf510500 strucvar15 on strucvar15.t_cpva = lcde.t_cpva and strucvar15.t_opts = optvar15.t_opts 
left outer join ttipcf110500 descoptvar15 on descoptvar15.t_item = strucvar15.t_item and descoptvar15.t_cpft = optvar15.t_cpft and descoptvar15.t_copt = optvar15.t_copt
-- (16) Tolé/Vitré
left outer join ttipcf520500 optvar16 on optvar16.t_cpva = lcde.t_cpva and optvar16.t_cpft = 'ToleVitre' 
left outer join ttipcf510500 strucvar16 on strucvar16.t_cpva = lcde.t_cpva and strucvar16.t_opts = optvar16.t_opts 
left outer join ttipcf110500 descoptvar16 on descoptvar16.t_item = strucvar16.t_item and descoptvar16.t_cpft = optvar16.t_cpft and descoptvar16.t_copt = optvar16.t_copt
-- (17) Traction/Propulsion
left outer join ttipcf520500 optvar17 on optvar17.t_cpva = lcde.t_cpva and optvar17.t_cpft = 'tracprop' 
left outer join ttipcf510500 strucvar17 on strucvar17.t_cpva = lcde.t_cpva and strucvar17.t_opts = optvar17.t_opts 
left outer join ttipcf110500 descoptvar17 on descoptvar17.t_item = strucvar17.t_item and descoptvar17.t_cpft = optvar17.t_cpft and descoptvar17.t_copt = optvar17.t_copt
-- (18) Voies Arrière
left outer join ttipcf520500 optvar18 on optvar18.t_cpva = lcde.t_cpva and optvar18.t_cpft = 'VoiesArr' 
left outer join ttipcf510500 strucvar18 on strucvar18.t_cpva = lcde.t_cpva and strucvar18.t_opts = optvar18.t_opts 
left outer join ttipcf110500 descoptvar18 on descoptvar18.t_item = strucvar18.t_item and descoptvar18.t_cpft = optvar18.t_cpft and descoptvar18.t_copt = optvar18.t_copt
--
where 
left(chass.t_cwar,2) between @ue_f and @ue_t --Unité Entreprise
and chass.t_cwar between @cwar_f and @cwar_t --Magasin/Parc
and chass.t_rdat between @rdat_f and @rdat_t --Date de Reception du Chassis
and rtrim(substring(chass.t_item, 10, len(chass.t_item))) = 'CHASSIS' --Uniquement les CHASSIS
and chass.t_qhnd = 1 --Stock Physique = 1