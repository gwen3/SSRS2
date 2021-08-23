-----------------------------------------
-- FIN08 Ctrl du crédit client
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
cde.t_itbp as CodeTiers
,tiers.t_nama as NomTiers
,tiersf.t_crat as NotationCredit
,tiersf.t_crlr as PlafondCredit
,(isnull((select sum(solde.t_buor) from ttccom113500 solde where  solde.t_itbp = cde.t_itbp and solde.t_buor <> 0),0)) as SoldeCdeEnAttente
,(isnull((select sum(solde.t_obra) from ttccom113500 solde where  solde.t_itbp = cde.t_itbp and (solde.t_obra >= 1 or solde.t_obra <= -1)),0)) as Fact_Prep
,(isnull((select sum(solde.t_buin) from ttccom113500 solde where  solde.t_itbp = cde.t_itbp and (solde.t_buin >= 1 or solde.t_buin <= -1)),0)) as SoldeCpteClient
,convert(date,cde.t_prdt) as Date_MADC
,cde.t_orno as Commande_client
,dbo.convertenum('td','B61C','a9','bull','sls.hdst',cde.t_hdst,'4') as StatutCde
,(case
	when (exists(select top 1 hbloc.t_lobl 
					from ttdsls421500 hbloc 
					where hbloc.t_orno = cde.t_orno and hbloc.t_hrea = 'CRE'
					order by hbloc.t_dtbl desc))
		then 
			case when (select top 1 hbloc.t_lobl 
					from ttdsls421500 hbloc 
					where hbloc.t_orno = cde.t_orno and hbloc.t_hrea = 'CRE'
					order by hbloc.t_dtbl desc) = 'baan'
			then	'JOB'
			else	(select top 1 emp.t_nama 
					from ttdsls421500 hbloc 
					left outer join ttccom001500 emp on emp.t_loco = hbloc.t_lobl
					where hbloc.t_orno = cde.t_orno and hbloc.t_hrea = 'CRE'
					order by hbloc.t_dtbl desc)
			end
		else ''
	end
) as Auteur_Blocage
,(case
	when (exists(select top 1 dbo.convertenum('td','B61C','a9','bull','sls.rlty',hbloc.t_rlty,'4') 
					from ttdsls421500 hbloc where hbloc.t_orno = cde.t_orno and hbloc.t_hrea = 'CRE'
					order by hbloc.t_dtbl desc))
		then (select top 1 dbo.convertenum('td','B61C','a9','bull','sls.rlty',hbloc.t_rlty,'4') 
				from ttdsls421500 hbloc where hbloc.t_orno = cde.t_orno and hbloc.t_hrea = 'CRE'
				order by hbloc.t_dtbl desc)
		else ''
	end
) as Statut_Blocage
--,(select top 1 txtva.t_pvat 
--	from ttcmcs032500 txtva 
--	where txtva.t_ccty = lcde.t_ccty and txtva.t_cvat = lcde.t_cvat
--	order by txtva.t_edat desc) as Taux_TVA
--
-- Montant des lignes de la commande
,(sum(lcde.t_oamt)) as Montant_Lignes_Cde
--
-- Montant Cumulé lignes de commandes tous sites
,(isnull((select sum(tlcde.t_oamt) 
	from ttdsls400500 tcde --Commandes Clients
	inner join ttdsls401500 tlcde on tlcde.t_orno = tcde.t_orno --Lignes de Commandes Clients
	where tcde.t_itbp = cde.t_itbp --Bornage sur le Tiers facturé 
	and tcde.t_hdst in ('10','20', '25','40') --Statut Ordre de Vente: Approuvé, En Cours, Modifié, Bloqué
	and (convert(date,tcde.t_prdt) < convert(date,cde.t_prdt) or (convert(date,tcde.t_prdt) = convert(date,cde.t_prdt) and tcde.t_orno <= cde.t_orno))
	and tlcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
	and tlcde.t_invn = '' -- Pas de n° de facture 
	and tlcde.t_oamt <> 0 -- Montant ligne de commande non nul
),0)) as Montant_Cumulé_Cdes_Ts_Sites
--
,(
-- GCV
(isnull((select 
	sum(facreg.t_balc)
	from ttfacr200200 facreg
	where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
	group by facreg.t_itbp),0)) +
-- LE MANS
(isnull((select 
	sum(facreg.t_balc)
	from ttfacr200300 facreg
	where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
	group by facreg.t_itbp),0)) +
-- LABBE
(isnull((select 
	sum(facreg.t_balc)
	from ttfacr200400 facreg
	where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
	group by facreg.t_itbp),0)) +
-- GRUAU LAVAL
(isnull((select 
	sum(facreg.t_balc)
	from ttfacr200500 facreg
	where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
	group by facreg.t_itbp),0)) +
-- GIFA-COLLET
(isnull((select 
	sum(facreg.t_balc)
	from ttfacr200600 facreg
	where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
	group by facreg.t_itbp),0)) +
-- PETIT-PICOT
(isnull((select 
	sum(facreg.t_balc)
	from ttfacr200610 facreg
	where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
	group by facreg.t_itbp),0)) +
-- SANICAR
(isnull((select 
	sum(facreg.t_balc)
	from ttfacr200620 facreg
	where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
	group by facreg.t_itbp),0)) +
-- DUCARME
(isnull((select 
	sum(facreg.t_balc)
	from ttfacr200630 facreg
	where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
	group by facreg.t_itbp),0)) +
-- GRUAU DEUTSHLAND Gmbh
(isnull((select 
	sum(facreg.t_balc)
	from ttfacr200720 facreg
	where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
	group by facreg.t_itbp),0))) as SoldeCpteClient_MADC
--
-- Calcul crédits disponibles
--
-- (1) En prenant en compte les reglements à venir dont date échéance <= date MADC 
,(tiersf.t_crlr - 
	-- Montant Cdes cumulé
	((isnull((select sum(tlcde.t_oamt) 
			from ttdsls400500 tcde --Commandes Clients
			inner join ttdsls401500 tlcde on tlcde.t_orno = tcde.t_orno --Lignes de Commandes Clients
			where tcde.t_itbp = cde.t_itbp --Bornage sur le Tiers facturé 
			and tcde.t_hdst in ('10','20', '25','40') --Statut Ordre de Vente: Approuvé, En Cours, Modifié, Bloqué
			and (convert(date,tcde.t_prdt) < convert(date,cde.t_prdt) or (convert(date,tcde.t_prdt) = convert(date,cde.t_prdt) and tcde.t_orno <= cde.t_orno))
			and tlcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
			and tlcde.t_invn = '' -- Pas de n° de facture 
			and tlcde.t_oamt <> 0 -- Montant ligne de commande non nul
	),0)) + 
	(
	-- GCV
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200200 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- LE MANS
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200300 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- LABBE
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200400 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- GRUAU LAVAL
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200500 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- GIFA-COLLET
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200600 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- PETIT-PICOT
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200610 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- SANICAR
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200620 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- DUCARME
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200630 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- GRUAU DEUTSHLAND Gmbh
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200720 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0))))) as Crédit_Dispo_Si_Regt_KO
--
-- (2) En ne prenant pas en compte les reglements à venir dont date échéance <= date MADC (on considère que le client aura réglé ces montants)
--
,(tiersf.t_crlr - 
	-- Montant Cdes cumulé
	((isnull((select sum(tlcde.t_oamt) 
			from ttdsls400500 tcde --Commandes Clients
			inner join ttdsls401500 tlcde on tlcde.t_orno = tcde.t_orno --Lignes de Commandes Clients
			where tcde.t_itbp = cde.t_itbp --Bornage sur le Tiers facturé 
			and tcde.t_hdst in ('10','20', '25','40') --Statut Ordre de Vente: Approuvé, En Cours, Modifié, Bloqué
			and (convert(date,tcde.t_prdt) < convert(date,cde.t_prdt) or (convert(date,tcde.t_prdt) = convert(date,cde.t_prdt) and tcde.t_orno <= cde.t_orno))
			and tlcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
			and tlcde.t_invn = '' -- Pas de n° de facture 
			and tlcde.t_oamt <> 0 -- Montant ligne de commande non nul
		),0))) + 
	(
	-- GCV
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200200 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- LE MANS
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200300 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- LABBE
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200400 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- GRUAU LAVAL
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200500 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- GIFA-COLLET
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200600 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- PETIT-PICOT
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200610 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- SANICAR
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200620 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- DUCARME
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200630 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)) +
	-- GRUAU DEUTSHLAND Gmbh
	(isnull((select 
		sum(facreg.t_balc)
		from ttfacr200720 facreg
		where facreg.t_itbp = cde.t_itbp and facreg.t_dued between '01/01/1753' and CONVERT(date,cde.t_prdt)
		group by facreg.t_itbp),0)))) as Crédit_Dispo_Si_Regt_OK
--
-- Plafond crédit - Cde_en_Attente_Fact - Facture_en_Preparation - Solde_cdes_clients
,(tiersf.t_crlr - (isnull((select sum(solde.t_buor) from ttccom113500 solde where  solde.t_itbp = cde.t_itbp and solde.t_buor <> 0),0))
		- (isnull((select sum(solde.t_obra) from ttccom113500 solde where  solde.t_itbp = cde.t_itbp and (solde.t_obra >= 1 or solde.t_obra <= -1)),0))
		- (isnull((select sum(solde.t_buin) from ttccom113500 solde where  solde.t_itbp = cde.t_itbp and (solde.t_buin >= 1 or solde.t_buin <= -1)),0))) as Crédit_Disponible
--
--
from ttdsls400500 cde --Commandes Clients
inner join ttdsls401500 lcde on lcde.t_orno = cde.t_orno --Lignes de Commandes Clients
left outer join ttccom100500 tiers on tiers.t_bpid = cde.t_itbp --Tiers
left outer join ttccom112500 tiersf on tiersf.t_itbp = cde.t_itbp --Tiers facturés
where 
left(cde.t_orno,2) in (@UE)
and cde.t_itbp between @tiers_f and @tiers_t --Bornage sur le Tiers Facturé 
and cde.t_hdst in ('10', '20', '25', '40') --Statut Ordre de Vente (Approuvé, Encours, Modifié, Bloqué)
and cde.t_prdt <= GETDATE() + cast(@horizon as integer)
and lcde.t_clyn <> 1 --Bornage sur Annulé différent de Oui (autrement dit Non)
and lcde.t_invn = '' -- Pas de n° de facture 
and lcde.t_oamt <> 0 -- Montant ligne de commande non nul
and tiersf.t_crlr between @crlr_f and @crlr_t --Bornage sur le plafond crédit
group by cde.t_itbp, tiers.t_nama, tiersf.t_crat, tiersf.t_crlr ,CONVERT(date,cde.t_prdt), cde.t_orno, dbo.convertenum('td','B61C','a9','bull','sls.hdst',cde.t_hdst,'4')
order by cde.t_itbp, CONVERT(date,cde.t_prdt)