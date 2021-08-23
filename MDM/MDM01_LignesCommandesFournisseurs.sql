---------------------------------------------
-- MDM01 - Lignes de Commandes Fournisseurs
---------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
(case left(lcdeach.t_orno, 2) 
when 'AC' 
	then 'Sanicar' 
when 'AD' 
	then 'Ducarme' 
when 'AL' 
	then 'Gifa' 
when 'AM' 
	then 'Gifa' 
when 'AP' 
	then 'PetitPicot' 
when 'EC' 
	then 'Electron' 
when 'LB' 
	then 'Labbe' 
when 'LV' 
	then 'Laval' 
when 'LY' 
	then 'Lyon' 
when 'PN' 
	then 'Paris Nord' 
when 'PS' 
	then 'Paris Sud' 
when 'SM' 
	then 'Lorraine' 
end) as SiteGruau, 
lcdeach.t_orno as NumeroCommande, 
lcdeach.t_pono as PositionCommande, 
lcdeach.t_sqnb as SequenceCommande, 
dbo.convertenum('td','B61C','a9','bull','gen.oltp',lcdeach.t_oltp,'4') as TypeLigneCommande, 
dbo.convertenum('td','B61C','a9','bull','pur.hdst',cdeach.t_hdst,'4') as StatutCommande, 
cdeach.t_cofc as ServiceAchat, 
sach.t_dsca as DescriptionServiceAchat, 
cdeach.t_plnr as Planificateur, 
planif.t_nama as NomPlanificateur, 
lcdeach.t_cwar as Magasin, 
mag.t_dsca as DescriptionMagasin, 
lcdeach.t_otbp as Tiers, 
tier.t_nama as NomTiers, 
left(lcdeach.t_item, 9) as ProjetArticle, 
substring(lcdeach.t_item, 10, len(lcdeach.t_item)) as Article, 
art.t_dsca as DesignationArticle, 
art.t_citg as GroupeArticle, 
grpart.t_dsca as DescriptionGroupeArticle, 
lcdeach.t_odat as DateCommande, 
lcdeach.t_qoor as QuantiteCommandee, 
lcdeach.t_qidl as QuantiteLivree, 
'' as ResteALivrer, 
lcdeach.t_pric / 
(case 
when lcdeach.t_cuqp = lcdeach.t_cupp or lcdeach.t_cupp is null
	then 1
else
	isnull(faconv.t_conv, (select faconvgen.t_conv from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_basu = lcdeach.t_cuqp and faconvgen.t_unit = lcdeach.t_cupp)) 
end) as PrixUnitaire, 
cdeach.t_oamt as MontantCommande, 
adr.t_ccty as Pays, 
adr.t_pstc as CodePostal, 
adr.t_ccit as CodeVille, 
vil.t_dsca as NomVille, 
lcdeach.t_ddta as DateLivraisonPlanifiee, 
lcdeach.t_revi as Revision, 
donmag.t_oqmf as IncrementCommande, 
donmag.t_mioq as MiniCommande, 
donmag.t_oint as IntervalleOrdre, 
donmag.t_sfst as StockSecurite, 
donmag.t_sftm as DelaiSecurite, 
(case 
when lcdeach.t_cuqp = lcdeach.t_cupp or lcdeach.t_cupp is null
	then 1
else
	isnull(faconv.t_conv, (select faconvgen.t_conv from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_basu = lcdeach.t_cuqp and faconvgen.t_unit = lcdeach.t_cupp)) 
end) as FacteurConversion, 
(donmag.t_oqmf + donmag.t_mioq + donmag.t_oint + donmag.t_sfst + donmag.t_sftm) as IndiceParametrage 
from ttdpur401500 lcdeach --Lignes de Commandes Fournisseurs
left outer join ttccom100500 tier on tier.t_bpid = lcdeach.t_otbp --Tiers Vendeur
left outer join ttcibd001500 art on art.t_item = lcdeach.t_item --Article
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Articles
inner join ttdpur400500 cdeach on cdeach.t_orno = lcdeach.t_orno --Commandes Fournisseurs
left outer join ttcmcs065500 sach on sach.t_cwoc = cdeach.t_cofc --Service Achat
left outer join ttcmcs003500 mag on mag.t_cwar = lcdeach.t_cwar --Magasins
left outer join ttccom130500 adr on adr.t_cadr = cdeach.t_sfad --Adresses
left outer join ttccom139500 vil on vil.t_city = adr.t_ccit and vil.t_ccty = adr.t_ccty and vil.t_cste = adr.t_cste --Villes
left outer join twhwmd210500 donmag on donmag.t_item = lcdeach.t_item and donmag.t_cwar = lcdeach.t_cwar --Magasin - Données Articles
left outer join ttcibd003500 faconv on faconv.t_item = lcdeach.t_item and faconv.t_basu = lcdeach.t_cuqp and faconv.t_unit = lcdeach.t_cupp --Facteur de Conversion 
left outer join ttccom001500 planif on planif.t_emno = cdeach.t_plnr --Employés - Planificateur
where lcdeach.t_oltp != 1 --On ne prend pas les séquences de total
and lcdeach.t_oltp != 3 --On ne prend pas les séquences de reliquats
and left(lcdeach.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise définit par la commande fournisseur
and lcdeach.t_odat between @datecde_f and @datecde_t --Bornage sur la Date de Commande
and cdeach.t_hdst in (@stat) --Bornage sur le Statut de Commande
and lcdeach.t_item != '         C00000010' --On exclu les mini de commandes
order by NumeroCommande, PositionCommande