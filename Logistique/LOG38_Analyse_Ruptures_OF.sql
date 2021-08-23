-------------------------------------------------------------------------
-- LOG38 - Analyse ruptures OF
-------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


select left(tspa.t_cwar, 2) as Site
,tspa.t_cprj as ProjetPCS
,prj.t_seak as DecriptionProjet
,tspa.t_orno as OrdreFabrication
,tspa.t_pono as LigneOF
,tspa.t_ponb as SeqLigOF
,dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF
,ofab.t_orno as Commande_Client
,ofab.t_pono as CommandeClientLigne
,cdecli.t_odat as DateCommande
,cdecli.t_clfi as CodeClientFinal
,tiers.t_nama as NomClientFinal
,tspa.t_date as DateLivraisonPrevue
,left(tspa.t_item, 9) as ProjetArticle 
,substring(tspa.t_item, 10, len(tspa.t_item)) as Article 
,art.t_dsca as DesignationArticle 
,art.t_csig as CodeSignal
,tspa.t_qana as QtePlanif
-- Besoin total pour Projet
,(select sum(tspprj.t_qana) 
	from twhinp100500 tspprj 
	where  tspprj.t_item = tspa.t_item 
			and tspprj.t_cwar = tspa.t_cwar
			and tspprj.t_kotr = '2'
			and tspprj.t_koor = '1' 
			and tspprj.t_cprj = tspa.t_cprj) as QteTotalePrj
--
,tspa.t_cwar as Magasin
,tspa.t_cuni as UnitStock
,stock.t_qhnd as QteStock
,stock.t_qord as QteEnCde
,stock.t_qall as QteReserve
,(case
	when (exists(select top 1 aat.t_otbp 
					from ttdipu010500 aat
					where aat.t_item = tspa.t_item 
					and (aat.t_pref = '2' or (aat.t_pref = '1' and (select count(*) from ttdipu010500 aatc where aatc.t_item = tspa.t_item) = 1))
					and aat.t_ibps = '1'
					and aat.t_efdt <= getdate() and aat.t_exdt > getdate()))
		then (select top 1 tiersaat.t_nama 
					from ttdipu010500 aat
					inner join ttccom100500 tiersaat on tiersaat.t_bpid = aat.t_otbp
					where aat.t_item = tspa.t_item 
					and (aat.t_pref = '2' or (aat.t_pref = '1' and (select count(*) from ttdipu010500 aatc where aatc.t_item = tspa.t_item) = 1))
					and aat.t_ibps = '1'
					and aat.t_efdt <= getdate() and aat.t_exdt > getdate())
		-- Recherche tiers de la dernière commande fournisseur receptionnée
		else (case
				when (exists(select top 1 trs.t_bpid
					from twhinr110500 trs
					where trs.t_item = tspa.t_item
					and trs.t_cwar = tspa.t_cwar
					and trs.t_koor = '2' -- Cde fournisseur et réception
					and trs.t_kost = '3'))
					then (select top 1 tierstrs.t_nama 
						from twhinr110500 trs
						inner join ttccom100500 tierstrs on tierstrs.t_bpid = trs.t_bpid
						where trs.t_item = tspa.t_item
						and trs.t_cwar = tspa.t_cwar
						and trs.t_koor = '2' -- Cde fournisseur et réception
						and trs.t_kost = '3'
						order by trs.t_item, trs.t_cwar, trs.t_trdt desc)
				else ''
				end)
	end
) as TiersArtAchatTiers
,(case
	when (exists(select top 1 tspoa.t_bpid 
					from twhinp100500 tspoa 
					where tspoa.t_koor = '2' 
					and tspoa.t_item = tspa.t_item and tspoa.t_cwar = tspa.t_cwar))
		then (select top 1 tiersa.t_nama 
					from twhinp100500 tspoa 
					inner join ttccom100500 tiersa on tiersa.t_bpid = tspoa.t_bpid
					where tspoa.t_koor = '2' 
					and tspoa.t_item = tspa.t_item and tspoa.t_cwar = tspa.t_cwar)
		else ''
	end
) as TiersOrdreAchat
,(case
	when (exists(select top 1 tspoa.t_orno 
					from twhinp100500 tspoa 
					where tspoa.t_koor = '2' and tspoa.t_item = tspa.t_item and tspoa.t_cwar = tspa.t_cwar))
		then (select top 1 tspoa.t_orno 
					from twhinp100500 tspoa 
					where tspoa.t_koor = '2' and tspoa.t_item = tspa.t_item and tspoa.t_cwar = tspa.t_cwar)
		else ''
	end
) as OrdreAchat
,(case
	when (exists(select top 1 tspoa.t_date 
					from twhinp100500 tspoa 
					where tspoa.t_koor = '2' and tspoa.t_item = tspa.t_item and tspoa.t_cwar = tspa.t_cwar))
		then (select top 1 tspoa.t_date 
					from twhinp100500 tspoa 
					where tspoa.t_koor = '2' and tspoa.t_item = tspa.t_item and tspoa.t_cwar = tspa.t_cwar)
		else '01/01/1970'
	end
) as DateOrdreAchat
,(case
	when (exists(select top 1 tspoa.t_qana 
					from twhinp100500 tspoa 
					where tspoa.t_koor = '2' and tspoa.t_item = tspa.t_item and tspoa.t_cwar = tspa.t_cwar))
		then (select top 1 tspoa.t_qana 
					from twhinp100500 tspoa 
					where tspoa.t_koor = '2' and tspoa.t_item = tspa.t_item and tspoa.t_cwar = tspa.t_cwar)
		else ''
	end
) as QteOrdreAchat
,(case
	when (exists(select top 1 tspoa.t_orno 
					from twhinp100500 tspoa 
					where tspoa.t_koor = '2' and tspoa.t_item = tspa.t_item and tspoa.t_cwar = tspa.t_cwar))
		then (select  top 1 lcde.t_cdf_crel from ttdpur401500 lcde where lcde.t_orno = (select top 1 tspoa.t_orno from twhinp100500 tspoa 
																	where tspoa.t_koor = '2' and tspoa.t_item = tspa.t_item
																	and tspoa.t_cwar = tspa.t_cwar) and lcde.t_pono = (select top 1 tspoa.t_pono from twhinp100500 tspoa 
																	where tspoa.t_koor = '2' and tspoa.t_item = tspa.t_item
																	and tspoa.t_cwar = tspa.t_cwar))
		else ''
	end
) as Commentaire_Relance
-- Booleens Rupture
,(case
	when stock.t_qhnd = 0
		then 'Oui'
		else ''
	end
) as Rupture_Ss_Stock
--
,(case
	when (stock.t_qhnd - stock.t_qall) < 0
		then 'Oui'
		else ''
	end
) as Rupture_Besoin_Total
--
,(case
	when (stock.t_qhnd - (select sum(tspprj.t_qana) 
							from twhinp100500 tspprj 
							where  tspprj.t_item = tspa.t_item 
									and tspprj.t_cwar = tspa.t_cwar
									and tspprj.t_kotr = '2'
									and tspprj.t_koor = '1' 
									and tspprj.t_cprj = tspa.t_cprj) < 0)
	then 'Oui'
	else ''
	end
) as Rupture_Projet
--
from twhinp100500 tspa --Transactions de stock planifiées par article
inner join ttcibd001500 art on art.t_item = tspa.t_item --Articles
inner join ttisfc001500 ofab on ofab.t_pdno = tspa.t_orno --Ordres de Fabrication
left outer join ttdsls400500 cdecli on cdecli.t_orno = ofab.t_orno -- Commandes clients (entête)
left outer join ttccom100500 tiers on tiers.t_bpid = cdecli.t_clfi --Tiers
inner join twhwmd215500 stock on stock.t_cwar = tspa.t_cwar and stock.t_item = tspa.t_item --Stocks par magasin
left outer join ttipcs020500 prj on prj.t_cprj = tspa.t_cprj --Projets PCS
where 
tspa.t_koor = '1' --On ne prend que les ordres de Fabrication
and tspa.t_kotr = '2' -- Besoins uniquement
and left(tspa.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le magasin
and tspa.t_cprj between @prj_f and @prj_t --Bornage sur n° de Projet
and tspa.t_orno between @orno_f and @orno_t  --Bornage sur n° OF
and substring(tspa.t_item, 10, len(tspa.t_item)) not like 'ETUDESPE%'
and (tiers.t_nama like concat('%', @clifin, '%') or @clifin is null)
-- Etats :
-- 1 = Détail
-- 2 = Ruptures Projet
-- 3 = Rupture besoin total
-- 4 = Composant sans stock
and (@etat = '1' or 
	(@etat = '2' and (stock.t_qhnd - (select sum(tspprj.t_qana) 
							from twhinp100500 tspprj 
							where  tspprj.t_item = tspa.t_item 
									and tspprj.t_cwar = tspa.t_cwar
									and tspprj.t_kotr = '2'
									and tspprj.t_koor = '1' 
									and tspprj.t_cprj = tspa.t_cprj) < 0)) or
	(@etat = '3' and (stock.t_qhnd - stock.t_qall) < 0) or 
	(@etat = '4' and stock.t_qhnd = 0))
order by tspa.t_orno, tspa.t_pono