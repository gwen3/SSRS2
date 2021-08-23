-- fait :
-- 01/06/2016 création de l'export Nissan pour vérification avant facturation puis correction avec transfert Nissan
-- 29/07/2016 correction de la jointure avec la 441 pour récupérer la séquence 0, ttdsls411500.t_sqnb = 0 au lieu de ttdsls401500.t_sqnb = 0
-- 29/07/2016 suppression de la position en première colonne
-- 30/09/2016 ajout du filtre sur la date de livraison (en test seulement)
-- 30/11/2016 sécurisation en bornant sur le Grand Laval

-- à faire :


use ln6prddb
set nocount on
-- declare @soc int -- test de déclaration de variable pour les tables, ko
-- set @soc = 500
-- declare @date_historique date = DATEADD(DD, -30, CAST(CURRENT_TIMESTAMP AS DATE))
select top 10000
	ttdsls400500.t_orno as OV, -- Ordre de vente
	ttdsls401500.t_sqnb as Sequence, -- Séquence
	ttdsls400500.t_ofbp as TiersAcheteur, -- Tiers acheteur
	'' as Vide1,
	ttccom110500.t_osno as NumFournisseur, -- Notre numéro fournisseur
	'' as Vide2, -- concat(ttdsls406500.t_ttyp,'/',ttdsls406500.t_invn), -- Numéro de facture
	ttdsls406500.t_shpm as Expedition, -- Code expédition
	convert(char(10),ttdsls400500.t_odat,103) as DateCommande, -- Date de commande
	iif(ttdsls401500.t_cprj='',substring(ttdsls401500.t_item,10,100),ttdsls401500.t_item) as Article, -- Article
	ttdsls401500.t_qidl as QuantiteLivree, -- Quantité livrée
	ttdsls401500.t_pric as Prix -- Prix
	-- infos pour tests
	-- ttdsls401500.t_qidl
	-- ,left(ttdsls411500.t_cpcl,3)
from
	dbo.ttdsls401500 -- Lignes de commande client
/*	left join	dbo.ttccom140500  -- Contacts
		on ttccom140500.t_ccnt = ttdsls401500.t_cclc
	left join	dbo.ttdsls402500 -- Données sur la ligne de commande liée
		on ttdsls402500.t_orno = ttdsls401500.t_orno and ttdsls402500.t_pono = ttdsls401500.t_pono and ttdsls401500.t_sqnb = 0
*/	left join 	dbo.ttdsls411500 -- Données article de la ligne de commande client
		on ttdsls411500.t_orno = ttdsls401500.t_orno and ttdsls411500.t_pono = ttdsls401500.t_pono and ttdsls411500.t_sqnb = 0
	inner join	dbo.ttdsls400500 -- Commandes clients
		on ttdsls400500.t_orno = ttdsls401500.t_orno
	left join	dbo.ttccom100500 -- Tiers
		on ttccom100500.t_bpid = ttdsls400500.t_ofbp
	left join	dbo.ttccom110500 -- Tiers acheteurs
		on ttccom110500.t_ofbp = ttdsls400500.t_ofbp
	left join	dbo.ttibom010500 -- Nomenclature
		on ttdsls401500.t_item = ttibom010500.t_mitm and ttibom010500.t_sitm = (select top 1 t_sitm from ttibom010500 where t_mitm = ttdsls401500.t_item)
/*	left join dbo.ttscfg200500 -- Articles sérialisés
		on ttscfg200500.t_srno = ttdsls401500.t_orno */
	left join	dbo.ttdsls406500 -- Lignes de livraison de commandes client réelles
		on ttdsls406500.t_orno = ttdsls401500.t_orno and ttdsls406500.t_pono = ttdsls401500.t_pono and ttdsls406500.t_sqnb = ttdsls401500.t_sqnb
	left join	dbo.ttccom130500 -- Adresses
		on ttdsls400500.t_stad = ttccom130500.t_cadr
where
	ttdsls401500.t_qidl <> 0 -- kit livré ou retour client
	and ttdsls406500.t_invn = 0 -- kit non facturé
	and ttdsls401500.t_chan = '007' -- canal de distribution concessionnaire
	and left(ttdsls411500.t_cpcl,3) = 'NIS' -- classe de produit Nissan
	and ttdsls400500.t_sotp = '106'
	-- and ttdsls400500.t_orno between 'LV0000000' and 'SMZZZZZZZ'
	and left(ttdsls400500.t_orno,2) in ('LV','LY','PN','PS','SM')
	-- critères pour test
	-- and ttdsls406500.t_invn='10099932' -- numéro de facture
	-- and ttdsls400500.t_orno = 'LV6003970'
	-- and ttdsls406500.t_dldt >= @date_historique
order by ttdsls400500.t_orno desc