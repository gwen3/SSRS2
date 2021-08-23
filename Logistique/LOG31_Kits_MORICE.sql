------------------------
-- LOG31 - Kits MORICE    
------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
lcde.t_prdt as DateMADC
,lcde.t_orno as CommandeClient
,lcde.t_serl as NumeroDeChassis
,ofab.t_pdno as OrdreFabrication
,isnull(descoptvarverkit.t_dsca, '') as VersionKit
,isnull((select top 1 seriecomp.t_serl from twhltc510500 seriecomp inner join tticst001500 matof on matof.t_pdno = ofab.t_pdno where seriecomp.t_item = matof.t_sitm and seriecomp.t_orto = matof.t_pdno and seriecomp.t_poto = matof.t_pono and matof.t_qucs > 0 order by seriecomp.t_trdt desc), lcde.t_cdf_refc) as NumeroKit
,(select top 1 seriecomp.t_trdt from twhltc510500 seriecomp inner join tticst001500 matof on matof.t_pdno = ofab.t_pdno where seriecomp.t_item = matof.t_sitm and seriecomp.t_orto = matof.t_pdno and seriecomp.t_poto = matof.t_pono and matof.t_qucs > 0 order by seriecomp.t_trdt desc) as DateMontageKit
,dbo.convertlistcdf('td','B61C','a9','grup','tho',lcde.t_cdf_thom,'4') as TypeHomologation
,(case 
when lcde.t_serl = '' or sermag.t_cdf_marq = '204'
	then artlig.t_cpcl
else 
	dbo.convertlistcdf('wh','B61C','a9','grup','mar',sermag.t_cdf_marq,'4')
end) as MarqueModele
--,dbo.convertlistcdf('wh','B61C','a9','grup','dim',sermag.t_cdf_dim,'4') as DimensionVehicule
,isnull(descoptvardimveh.t_dsca, '') as DimensionVehicule
,dbo.convertlistcdf('wh','B61C','a9','grup','cou',sermag.t_cdf_coul,'4') as CouleurVehicule
--,dbo.convertlistcdf('wh','B61C','a9','grup','nas',sermag.t_cdf_nbas,'4') as NombrePlaces
,isnull(descoptvarnbplace.t_dsca, lcde.t_cdf_refd) as NombrePlaces
,isnull(descoptvarnbplace1.t_dsca, '') as NombrePlaces1
,dbo.convertlistcdf('wh','B61C','a9','grup','pta',sermag.t_cdf_ptac,'4') as PTAC
,isnull(descoptvarusage.t_dsca, '') as Usage
,lcde.t_cdf_rcdt as DateReceptionDossierMorice
,isnull(sermagpf.t_cdf_meav,'') as MasseEssieuAV
,isnull(sermagpf.t_cdf_mear,'') as MasseEssieuAR
,isnull(sermagpf.t_cdf_mtot,'') as MasseTotApresTransfo
,lcde.t_cdf_cosc as Commentaire
-- Statut du Dossier
,(case
when lcde.t_cdf_rcdt > '01/01/1980' --Pas de date de réception du dossier Morice
	then 'Fermé'
when lcde.t_cdf_tydo = 4 and lcde.t_cdf_rcdt < '01/01/1980' and lcde.t_cdf_codt > '01/01/1980' and lcde.t_cdf_andt > '01/01/1980' and lcde.t_cdf_cfdt > '01/01/1980' and sermagpf.t_cdf_mtot != '0'
		and upper(lcde.t_cdf_cosc) not like 'MORICE%'
	then 'A traiter'
when lcde.t_cdf_tydo = 4 and lcde.t_cdf_rcdt < '01/01/1980' and lcde.t_cdf_codt > '01/01/1980' and lcde.t_cdf_andt > '01/01/1980' and lcde.t_cdf_cfdt > '01/01/1980' and sermagpf.t_cdf_mtot != '0' 
		and upper(lcde.t_cdf_cosc) like 'MORICE%'
	then 'Envoyé'
else
	'Ouvert'
end) as StatutDossier --Géré sur SSRS
--
from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
inner join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono and ofab.t_mitm = lcde.t_item --OF de l'article de la cde client
left outer join ttdsls411500 artlig on artlig.t_orno = lcde.t_orno and artlig.t_pono = lcde.t_pono and artlig.t_sqnb = lcde.t_sqnb --Données Articles de la Ligne de Commande Client
-- Version KIT dans Variante
left outer join ttipcf520500 optvarverkit on optvarverkit.t_cpva = lcde.t_cpva and optvarverkit.t_cpft = 'VerKit' --Options par Variantes
left outer join ttipcf510500 strucvarprdverkit on strucvarprdverkit.t_cpva = lcde.t_cpva and strucvarprdverkit.t_opts = optvarverkit.t_opts --Structure Variante
left outer join ttipcf110500 descoptvarverkit on descoptvarverkit.t_item = strucvarprdverkit.t_item and descoptvarverkit.t_copt = optvarverkit.t_copt and descoptvarverkit.t_cpft = optvarverkit.t_cpft --Description option
-- Dimension du Véhicule dans Variante
left outer join ttipcf520500 optvardimveh on optvardimveh.t_cpva = lcde.t_cpva and optvardimveh.t_cpft = 'DimVeh' --Options par Variantes 
left outer join ttipcf510500 strucvarprddimveh on strucvarprddimveh.t_cpva = lcde.t_cpva and strucvarprddimveh.t_opts = optvardimveh.t_opts --Structure Variante
left outer join ttipcf110500 descoptvardimveh on descoptvardimveh.t_item = strucvarprddimveh.t_item and descoptvardimveh.t_copt = optvardimveh.t_copt and descoptvardimveh.t_cpft = optvardimveh.t_cpft --Description option
-- Nbr de places dans Variante
left outer join ttipcf520500 optvarnbplace on optvarnbplace.t_cpva = lcde.t_cpva and optvarnbplace.t_cpft = 'Places' --Options par Variantes 
left outer join ttipcf510500 strucvarprdnbplace on strucvarprdnbplace.t_cpva = lcde.t_cpva and strucvarprdnbplace.t_opts = optvarnbplace.t_opts --Structure Variante
left outer join ttipcf110500 descoptvarnbplace on descoptvarnbplace.t_item = strucvarprdnbplace.t_item and descoptvarnbplace.t_copt = optvarnbplace.t_copt and descoptvarnbplace.t_cpft = optvarnbplace.t_cpft --Description option
-- Nbr de places 1 dans Variante
left outer join ttipcf520500 optvarnbplace1 on optvarnbplace1.t_cpva = lcde.t_cpva and optvarnbplace1.t_cpft = 'Places1' --Options par Variantes 
left outer join ttipcf510500 strucvarprdnbplace1 on strucvarprdnbplace1.t_cpva = lcde.t_cpva and strucvarprdnbplace1.t_opts = optvarnbplace1.t_opts --Structure Variante
left outer join ttipcf110500 descoptvarnbplace1 on descoptvarnbplace1.t_item = strucvarprdnbplace1.t_item and descoptvarnbplace1.t_copt = optvarnbplace1.t_copt and descoptvarnbplace1.t_cpft = optvarnbplace1.t_cpft --Description option
-- Usage dans Variante
left outer join ttipcf520500 optvarusage on optvarusage.t_cpva = lcde.t_cpva and optvarusage.t_cpft = 'usage' --Options par Variantes 
left outer join ttipcf510500 strucvarprdusage on strucvarprdusage.t_cpva = lcde.t_cpva and strucvarprdusage.t_opts = optvarusage.t_opts --Structure Variante
left outer join ttipcf110500 descoptvarusage on descoptvarusage.t_item = strucvarprdusage.t_item and descoptvarusage.t_copt = optvarusage.t_copt and descoptvarusage.t_cpft = optvarusage.t_cpft --Description option
--
left outer join twhltc500500 sermag on sermag.t_item = '         CHASSIS' and sermag.t_serl = lcde.t_serl and sermag.t_cwar = 'LVPARC' --Numéros de série par magasin
left outer join twhltc500500 sermagpf on sermagpf.t_item = lcde.t_item and sermagpf.t_serl = lcde.t_serl and sermagpf.t_cwar = lcde.t_cwar --Numéros de série par magasin du PF
where lcde.t_orno between @orno_f and @orno_t --Bornage sur l'Ordre de Vente
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and lcde.t_ddta between @ddta_f and @ddta_t --Bornage sur la Date de Production Gruau
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'CHASSIS' -- Ne pas prendre en compte les CHASSIS au sens large
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'VCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'PCHASSIS'
and substring(lcde.t_item, 10, len(lcde.t_item)) != 'OCHASSIS'
and lcde.t_odat between @odat_f and @odat_t --Bornage sur la Date de Commande
and cde.t_cofc in (@cofc_f) --Bornage sur le Service des Ventes
and artlig.t_citg in (@citg_f) --Bornage sur le Groupe Article
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3) --Type Article Acheté, Fabriqué ou Générique
and lcde.t_cdf_tydo = 4 -- Type Document "Dossier Morice"
and (@facture = 1 --Réponse à la Question Posée pour Inclure ou Non les Lignes Facturées
	or (not exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb))
		or exists (select ttdsls406500.t_orno from ttdsls406500 where (lcde.t_orno = ttdsls406500.t_orno and lcde.t_pono = ttdsls406500.t_pono and lcde.t_sqnb = ttdsls406500.t_sqnb) and ttdsls406500.t_invn = 0)))