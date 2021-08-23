--------------------------
-- COM06 - Suivi Chassis
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
chass.t_orno as OrdreAchat, 
chass.t_qall as Affecte, 
chass.t_ornv as CommandeClient, 
chass.t_ponv as PositionLigne, 
cde.t_refa as ReferenceA, 
cde.t_refb as ReferenceB, 
cde.t_ofbp as CodeTiersAcheteur, 
tiersa.t_nama as NomTiersAcheteur, 
left(lcdevar.t_item, 9) as ProjetArticleVariante, 
substring(lcdevar.t_item, 10, len(lcdevar.t_item)) as ArticleVariante, 
stk.t_stoc as StockArticleVariante, 
ofab.t_pdno as OrdreFabrication, 
ofab.t_prdt as DateDebutOF, 
ofab.t_cmdt as DateAchevementOF, 
ofab.t_qdlv as QuantiteDeclareOF, 
lcde.t_ddta as DateProductionGruauOV, 
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
chass.t_cdf_rce as RCE, 
chass.t_cdf_mtot as MasseTotaleAVide, 
chass.t_cdf_imma as Immatriculation, 
lcdevar.t_cpva as CodeVarianteProduit, 
var010.t_copt as OptionVariante010, 
var020.t_copt as OptionVariante020, 
var030.t_copt as OptionVariante030, 
var040.t_copt as OptionVariante040, 
var110.t_copt as OptionVariante110, 
var120.t_copt as OptionVariante120, 
var130.t_copt as OptionVariante130, 
var140.t_copt as OptionVariante140, 
var145.t_copt as OptionVariante145, 
var147.t_copt as OptionVariante147, 
var150.t_copt as OptionVariante150, 
var160.t_copt as OptionVariante160, 
var170.t_copt as OptionVariante170, 
var180.t_copt as OptionVariante180, 
var190.t_copt as OptionVariante190, 
var1100.t_copt as OptionVariante1100 
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
left outer join ttdsls401500 lcdevar on chass.t_item = '         VCHASSIS' and chass.t_ornv != '' and chass.t_isdt < '01/01/1980' and lcdevar.t_orno = cde.t_orno and lcdevar.t_pono = '10' --and lcdevar.t_item like '%PIC' 
left outer join ttipcf520500 var010 on var010.t_cpva = lcdevar.t_cpva and var010.t_opts = 0 and var010.t_sern = 10 --Options par Variante de Produits
left outer join ttipcf520500 var020 on var020.t_cpva = lcdevar.t_cpva and var020.t_opts = 0 and var020.t_sern = 20 --Options par Variante de Produits
left outer join ttipcf520500 var030 on var030.t_cpva = lcdevar.t_cpva and var030.t_opts = 0 and var030.t_sern = 30 --Options par Variante de Produits
left outer join ttipcf520500 var040 on var040.t_cpva = lcdevar.t_cpva and var040.t_opts = 0 and var040.t_sern = 40 --Options par Variante de Produits
left outer join ttipcf520500 var110 on var110.t_cpva = lcdevar.t_cpva and var110.t_opts = 1 and var110.t_sern = 10 --Options par Variante de Produits
left outer join ttipcf520500 var120 on var120.t_cpva = lcdevar.t_cpva and var120.t_opts = 1 and var120.t_sern = 20 --Options par Variante de Produits
left outer join ttipcf520500 var130 on var130.t_cpva = lcdevar.t_cpva and var130.t_opts = 1 and var130.t_sern = 30 --Options par Variante de Produits
left outer join ttipcf520500 var140 on var140.t_cpva = lcdevar.t_cpva and var140.t_opts = 1 and var140.t_sern = 40 --Options par Variante de Produits
left outer join ttipcf520500 var145 on var145.t_cpva = lcdevar.t_cpva and var145.t_opts = 1 and var145.t_sern = 45 --Options par Variante de Produits
left outer join ttipcf520500 var147 on var147.t_cpva = lcdevar.t_cpva and var147.t_opts = 1 and var147.t_sern = 47 --Options par Variante de Produits
left outer join ttipcf520500 var150 on var150.t_cpva = lcdevar.t_cpva and var150.t_opts = 1 and var150.t_sern = 50 --Options par Variante de Produits
left outer join ttipcf520500 var160 on var160.t_cpva = lcdevar.t_cpva and var160.t_opts = 1 and var160.t_sern = 60 --Options par Variante de Produits
left outer join ttipcf520500 var170 on var170.t_cpva = lcdevar.t_cpva and var170.t_opts = 1 and var170.t_sern = 70 --Options par Variante de Produits
left outer join ttipcf520500 var180 on var180.t_cpva = lcdevar.t_cpva and var180.t_opts = 1 and var180.t_sern = 80 --Options par Variante de Produits
left outer join ttipcf520500 var190 on var190.t_cpva = lcdevar.t_cpva and var190.t_opts = 1 and var190.t_sern = 90 --Options par Variante de Produits
left outer join ttipcf520500 var1100 on var1100.t_cpva = lcdevar.t_cpva and var1100.t_opts = 1 and var1100.t_sern = 100 --Options par Variante de Produits
left outer join ttisfc001500 ofab on ofab.t_mitm = lcdevar.t_item /*and chass.t_oser = 2*/ --Ordre de Fabrication ; On fait le lien avec l'article PIC
left outer join ttcibd100500 stk on stk.t_item = lcdevar.t_item --Stock d'Articles
where chass.t_item in ('         CHASSIS', '         OCHASSIS', '         VCHASSIS', '         PCHASSIS') --On récupère les chassis
and chass.t_qhnd between @qhnd_f and @qhnd_t --Bornage sur le Stock
and chass.t_cwar between @mag_f and @mag_t --Bornage sur le Magasin
and chass.t_ornv between @cde_f and @cde_t --Bornage sur la Commande Client
and ((chass.t_isdt between @dtesortie_f and @dtesortie_t) or (chass.t_isdt = '01/01/1970')) --Bornage sur la Date de Sortie
and ((chass.t_rdat between @dterecept_f and @dterecept_t) or (chass.t_rdat = '01/01/1970')) --Bornage sur la Date de Réception
and chass.t_bpid between @tven_f and @tven_t --Bornage sur le Tiers Vendeur
and left(chass.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE à partir du Magasin