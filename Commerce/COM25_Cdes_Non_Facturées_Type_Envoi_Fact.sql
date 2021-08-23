-------------------------------------------------------------
-- COM25 - Commandes non facturées pour mode d'envoi facture
-------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
cde.t_crep as RepresentantInterne, 
empa.t_nama as NomRepresentantInterne, 
cde.t_orno as CommandeClient, 
cde.t_odat as DateCommande,  
cde.t_ofbp as CodeTiersAcheteur,
ofbp.t_nama as NomTiersAcheteur, 
cde.t_corn as CommandeDuClient,
cde.t_itbp as CodeTiersFact,
itbp.t_nama as NomTiersFacturé,
--
-- Recherche Date MADC mini des lignes de commandes
(case
	when exists(select top 1 min(ligcde.t_prdt)
		from ttdsls401500 ligcde
		left outer join ttdsls406500 livcde on livcde.t_orno = ligcde.t_orno and livcde.t_pono = ligcde.t_pono and livcde.t_sqnb = ligcde.t_sqnb --Lignes de Livraison de Commandes Clients
		where
		ligcde.t_orno = cde.t_orno
		and ligcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
		and ligcde.t_clyn <> 1 --Bornage sur la Ligne de Commande qui ne doit pas être Annulée
		-- Soit ligne non livrée, soit livrée mais non facturée (Le Statut doit être soit Ouvert (5), Approuvé (10) ou Lancé (15))
		and( (ligcde.t_dldt = '01/01/1970') or
				(ligcde.t_dldt <> '01/01/1970' and livcde.t_invd = '01/01/1970'
				and livcde.t_stat < 20))
		group by ligcde.t_orno
		order by ligcde.t_orno)
	then (select top 1 min(ligcde.t_prdt)
			from ttdsls401500 ligcde
			left outer join ttdsls406500 livcde on livcde.t_orno = ligcde.t_orno and livcde.t_pono = ligcde.t_pono and livcde.t_sqnb = ligcde.t_sqnb --Lignes de Livraison de Commandes Clients
			where
			ligcde.t_orno = cde.t_orno
			and ligcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
			and ligcde.t_clyn <> 1 --Bornage sur la Ligne de Commande qui ne doit pas être Annulée
			-- Soit ligne non livrée, soit livrée mais non facturée (Le Statut doit être soit Ouvert (5), Approuvé (10) ou Lancé (15))
			and( (ligcde.t_dldt = '01/01/1970') or
					(ligcde.t_dldt <> '01/01/1970' and livcde.t_invd = '01/01/1970'
					and livcde.t_stat < 20))
			group by ligcde.t_orno
			order by ligcde.t_orno)
	else '01/01/1970'
	end) as Date_MADC,
--
--Recherche Informations d'un contact "Tiers facturé général"
-- Code du contact
(case
	when (exists (select contacttiers.t_ccnt as Contact_Tiers
					from ttccom145500 contacttiers 
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1'))
	then	(select contacttiers.t_ccnt
					from ttccom145500 contacttiers 
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1')
		
	else ''
end) as Contact_Tiers_Fact,
-- Nom du contact
(case
	when (exists (select contacts.t_fuln 
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1'))
	then	(select contacts.t_fuln
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1')
		
	else ''
end) as Nom_Contact_Tiers_Fact,
--
-- Mail du contact
(case
	when (exists (select contacts.t_info 
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1'))
	then	(select contacts.t_info
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1')
		
	else ''
end) as  Contact_Email_Tiers_Fact,
--
-- Controle MAIL
--
cde.t_itcn as ContactTiersFact_Cde,
isnull(contcde.t_fuln,'') as NomContactFactCde,
isnull(contcde.t_info,'') as MailContactFactCde,
(case
	when (isnull(contcde.t_info,'') = '')
		then 'A CORRIGER'
	When (isnull(contcde.t_info,'') != (select contacts.t_info
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1'))
		then 'A VERIFIER'
	else 'OK'
end) as Controle_Mail,
--
-- Mode d'envoi facture
--
tiersf.t_cidm as Mode_Env_Fact,
isnull(modenv.t_dsca,'') as Lib_Mode_Envoi_Fact,
--
substring(cde.t_cofc,1,2) as UE 
from ttdsls400500 cde
left outer join ttccom001500 empa on empa.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom100500 ofbp on ofbp.t_bpid = cde.t_ofbp --Tiers (Acheteur)
left outer join ttccom140500 contcde on contcde.t_ccnt = cde.t_itcn --Contacts tiers facturé de la commande
inner join ttccom112500 tiersf on tiersf.t_itbp = cde.t_itbp -- Tiers Facturé
left outer join ttccom100500 itbp on itbp.t_bpid = cde.t_itbp --Tiers (Facturé)
left outer join ttcmcs056500 modenv on modenv.t_cidm = tiersf.t_cidm --Mode Envoi Facture
where 
left(cde.t_cofc, 2) between @ue_f and @ue_t --Bornage sur l'UE
and cde.t_hdst not in ('30','35') --Commande non fermée et non annulée
and cde.t_crep between @crep_f and @crep_t -- Représentant interne
-- Mode d'envoi de facture
and tiersf.t_cidm in (@cidm)
--
--Controle Mail dans la liste de choix
--
and (case
	when (isnull(contcde.t_info,'') = '')
		then 'A CORRIGER'
	When (isnull(contcde.t_info,'') != (select contacts.t_info
					from ttccom145500 contacttiers 
						 left outer join ttccom140500 contacts on contacts.t_ccnt = contacttiers.t_ccnt --Contacts
					where contacttiers.t_bpid = tiersf.t_itbp
						and contacttiers.t_cmsk_3 = '1'
						and contacttiers.t_ctpr_3 = '1'))
		then 'A VERIFIER'
	else 'OK'
	end) in (@info)
--
-- Commandes avec au moins une ligne non facturée
and exists (select top 1 ligcde.t_orno 
				from ttdsls401500 ligcde
				left outer join ttdsls406500 livcde on livcde.t_orno = ligcde.t_orno and livcde.t_pono = ligcde.t_pono and livcde.t_sqnb = ligcde.t_sqnb --Lignes de Liv de Cdes
				where
				ligcde.t_orno = cde.t_orno
				and ligcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
				and ligcde.t_clyn <> 1 --Bornage sur la Ligne de Commande qui ne doit pas être Annulée
				-- Soit ligne non livrée, soit livrée mais non facturée (Le Statut doit être soit Ouvert (5), Approuvé (10) ou Lancé (15))
				and( (ligcde.t_dldt = '01/01/1970') or
						(ligcde.t_dldt <> '01/01/1970' and livcde.t_invd = '01/01/1970'
						and livcde.t_stat < 20))
				group by ligcde.t_orno
				order by ligcde.t_orno) 
-- Date MADC
and (select top 1 min(ligcde.t_prdt)
			from ttdsls401500 ligcde
			left outer join ttdsls406500 livcde on livcde.t_orno = ligcde.t_orno and livcde.t_pono = ligcde.t_pono and livcde.t_sqnb = ligcde.t_sqnb --Lignes de Liv de Cdes
			where
			ligcde.t_orno = cde.t_orno
			and ligcde.t_dltp <> 1 --Bornage sur le Type de Livraison qui ne doit pas être à "Non applicable"
			and ligcde.t_clyn <> 1 --Bornage sur la Ligne de Commande qui ne doit pas être Annulée
			-- Soit ligne non livrée, soit livrée mais non facturée (Le Statut doit être soit Ouvert (5), Approuvé (10) ou Lancé (15))
			and( (ligcde.t_dldt = '01/01/1970') or
					(ligcde.t_dldt <> '01/01/1970' and livcde.t_invd = '01/01/1970'
					and livcde.t_stat < 20))
			group by ligcde.t_orno
			order by ligcde.t_orno) between @prdt_f and @prdt_t