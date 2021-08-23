-----------------------------------
-- INV02 - Liste Détaillée des OI
-----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select inv.t_orno as Ordre, 
dbo.convertenum('wh','B61C','a9','bull','inh.ccst',inv.t_ccst,'4') as StatutOrdre, 
inv.t_cntn as NumeroInventaire, 
inv.t_cwar as Magasin, 
mag.t_dsca as DescriptionMagasin, 
inv.t_odat as DateCommande, 
dbo.convertenum('tc','B61C','a9','bull','yesno',inv.t_prnt,'4') as Imprime, 
dbo.convertenum('tc','B61C','a9','bull','yesno',inv.t_prcc,'4') as TraiterInventaire, 
lginv.t_pono as Ligne, 
lginv.t_zone as ZoneStockage, 
lginv.t_loca as Emplacement, 
left(lginv.t_item, 9) as Projet, 
substring(lginv.t_item, 10, len(lginv.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
lginv.t_clot as Lot, 
lginv.t_qstp as PointStockageUteStk, 
art.t_cuni as Unite, 
lginv.t_qcnt as StockInventorieUteStk, 
lginv.t_cadj as MotifEcart, 
lginv.t_qvrc as EcartUteStk, 
lginv.t_idat as DateStockage, 
dbo.convertenum('tc','B61C','a9','bull','yesno',lginv.t_csts,'4') as StockInventorie, 
dbo.convertenum('tc','B61C','a9','bull','yesno',lginv.t_prcd,'4') as Traite, 
lginv.t_cdat as DateInventaire, 
dbo.convertenum('tc','B61C','a9','bull','yesno',lginv.t_nstp,'4') as NouveauPointStockage, 
lginv.t_adpr as PrixCorrection, 
lginv.t_pric as ValeurStock, 
lginv.t_amnt as MontantTransaction, 
dbo.convertenum('wh','B61C','a9','bull','inh.vara',lginv.t_appr,'4') as Approbation, 
dbo.convertenum('tc','B61C','a9','bull','owns',lginv.t_owns,'4') as Propriete, 
lginv.t_ownr as Proprietaire, 
dbo.convertenum('tc','B61C','a9','bull','yesno',lginv.t_reco,'4') as Recompter, 
invtourn.t_lcdt as DateDernierInventaire 
from twhinh501500 lginv --Ligne Ordre Inventaire
inner join twhinh500500 inv on inv.t_orno = lginv.t_orno --Ordre Inventaire
inner join ttcmcs003500 mag on mag.t_cwar = inv.t_cwar --Magasin
inner join ttcibd001500 art on art.t_item = lginv.t_item --Article
left outer join twhinh540500 invtourn on invtourn.t_orno = inv.t_orno and invtourn.t_pono = lginv.t_pono --Données de l'inventaire tournant
where left(inv.t_cwar, 2) between @ue_f and @ue_t --Bornage d'UE à partir du Magasin
and inv.t_orno >= @orno_f and inv.t_orno <= @orno_t --Bornage sur l'Ordre d'Inventaire
and inv.t_odat >= @odat_f and inv.t_odat <= @odat_t --Bornage sur la Date ordre inventaire
and inv.t_ccst between @stat_f and @stat_t --Bornage sur le Statut de l'Ordre d'Inventaire
and lginv.t_prcd between @traite_f and @traite_t --Bornage sur le Traité, oui ou non
and lginv.t_csts between @stkinv_f and @stkinv_t --Bornage sur le Stock Inventorié, oui ou non
and lginv.t_appr between @approb_f and @approb_t --Bornage sur l'Approbation, oui ou non