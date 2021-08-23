---------------------------
-- LOG05 - Entrée Magasin
---------------------------

--Version mise à jour le 04/07/2018 suite à la demande du ticket 37934, remise en forme au standard Gruau, écriture des formules en requêtes SQL et ajout de nouvelles règles :
--Bornage : ajout du bornage sur la date de réception réelle
--Suppression du statut de la ligne et création d'un statut corrigé pour les programmes d'achats
--Pour prendre en compte ce statut, on crée 2 requêtes, une si le statut sélectionné en bornage est Traité Physiquement, et une comme actuellement dans le cas contraire.
--Attention, cela permet de récupérer les Traité Physiquement du statut corrigé, par contre si on prend un autre Statut, on risque de récupérer des Traité Physiquement recalculé pour les programmes d'achats car le statut de la ligne est lui à Ouvert par exemple.

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

if (@daterec_f = '01/01/1970')
--On fait le traitement des date de réceptions réelles à vide, c'est à dire qu'on veut tout récupérer
(select dbo.convertenum('wh','B61C','a9','bull','inh.oorg',omag.t_oorg,4) as OrigineOrdre, 
omag.t_oset as Groupe, 
omag.t_orno as Ordre, 
dbo.convertenum('wh','B61C','a9','bull','inh.ittp',omag.t_ittp,4) as TypeTransaction, 
omag.t_odat as DateOrdre, 
omag.t_pddt as DateLivraisonPlanifiee, 
omag.t_prdt as DateReceptionPlanifiee, 
dbo.convertenum('tc','B61C','a9','bull','typs',omag.t_sfty,4) as TypeExpediteur, 
omag.t_sfco as CodeExpediteur, 
tiersexp.t_nama as NomExpediteur, 
dbo.convertenum('tc','B61C','a9','bull','typs',omag.t_stty,4) as TypeDestinataire, 
omag.t_stco as CodeDestinataire, 
tiersdest.t_nama as NomDestinataire, 
omag.t_sfcp as SocieteExpediteur, 
omag.t_stcp as SocieteDestinataire, 
dbo.convertenum('wh','B61C','a9','bull','inh.hsta',omag.t_hsta,4) as StatutEnTete, 
line.t_pono as Ligne, 
line.t_seqn as Sequence, 
left(line.t_item, 9) as ProjetArticle, 
substring(line.t_item, 10, len(line.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
line.t_qoro as QuantiteCommandeeUniteOrdre, 
line.t_orun as UniteOrdre, 
art.t_cuni as UniteStock, 
dbo.convertenum('wh','B61C','a9','bull','inh.lsta',line.t_lsta,4) as StatutLigne, 
dbo.convertenum('wh','B61C','a9','bull','inh.lstc',recp.t_lsta,4) as StatutLigneReception, 
line.t_qord as QuantiteCommandee, 
recp.t_qrec as QuantiteRecue, 
line.t_qorc as QuantiteRecueOuverte, 
recp.t_qadv as QuantiteProposee, 
recp.t_qapr as QuantiteApprouvee, 
recp.t_qdes as QuantiteDetruite,  
recp.t_qrej as QuantiteRejetee, 
line.t_qput as QuantiteTraitee, 
recp.t_qadi as ProposeeQuantiteControle, 
recp.t_qpui as TraiteeQuantiteControle, 
recp.t_qrcr as QuantiteBonLivraisonUniteStock, 
recp.t_qput as QuantiteTraiteeReception, 
line.t_blck as CodeBloque, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_blck,'4') as Bloque, 
line.t_tprj as ProjetA, 
prj.t_dsca as DescriptionProjetA, 
recp.t_ardt as DateReceptionReelle, 
recp.t_rcno as Reception, 
recp.t_logn as LoginReception, 
isnull(recp.t_cwar, line.t_cwar) as Magasin, 
isnull(recp.t_psno, '') as NumeroBonLivraison, 
ofab.t_prcd as Priorite, 
/*(case 
when omag.t_prdt = '01/01/1970' 
	then '' 
when omag.t_prdt < getdate() 
	then 'RETARD' 
when omag.t_prdt < dateadd(d, 1, getdate()) 
	then 'JOUR J' 
when omag.t_prdt < dateadd(d, 2, getdate()) 
	then 'JOUR J+1' 
when omag.t_prdt < dateadd(d, 3, getdate()) 
	then 'JOUR J+2' 
when omag.t_prdt < dateadd(d, 4, getdate()) 
	then 'JOUR J+3' 
when omag.t_prdt < dateadd(d, 5, getdate()) 
	then 'JOUR J+4' 
when omag.t_prdt < dateadd(d, 6, getdate()) 
	then 'JOUR J+5' 
when omag.t_prdt < dateadd(d, 7, getdate()) 
	then 'JOUR J+6' 
when omag.t_prdt < dateadd(d, 8, getdate()) 
	then 'JOUR J+7' 
else 'J+15' 
end) as DatePlanifiee, */
(case 
when omag.t_prdt = '01/01/1970' 
	then '' 
when datediff(d, getdate(), omag.t_prdt) < 0 
	then 'RETARD' 
when datediff(d, getdate(), omag.t_prdt) = 0 
	then 'JOUR J' 
when datediff(d, getdate(), omag.t_prdt) < 7 
	then concat('J+', convert(varchar, datediff(d, getdate(), omag.t_prdt))) 
else 
	'>J+7'
end) as DatePlanifiee, 
--On compare la date de réception réelle à celle planifiée. Si la réelle est inférieure à la planifiée, on est avance, sinon on est en retard.
(case 
when omag.t_prdt = '01/01/1970' 
	then '' 
when recp.t_ardt = '01/01/1970' 
	then '' 
when datediff(d, omag.t_prdt, recp.t_ardt) < -5 
	then '<J-5' 
when datediff(d, omag.t_prdt, recp.t_ardt) > 5 
	then '>J+5' 
when datediff(d, omag.t_prdt, recp.t_ardt) = 0 
	then 'JOUR J' 
when datediff(d, omag.t_prdt, recp.t_ardt) > 0 
	then concat('J+', convert(varchar, datediff(d, omag.t_prdt, recp.t_ardt))) 
when datediff(d, omag.t_prdt, recp.t_ardt) < 0 
	then concat('J', convert(varchar, datediff(d, omag.t_prdt, recp.t_ardt))) 
else 
	''
end) as DeltaDateReceptionReellePlanifiee, 
(case left(line.t_item, 3) 
when 'LVP' 
	then 'Projet' 
else '' 
end) as FabArticleProjet, 
--Correction par rbesnier suite mail Gaëtan du 20/07/2018 à 17h10
(case 
when omag.t_oorg = 81 --On ne fait le traitement que pour les programmes d'achats
	then (case
		when omag.t_hsta = 20 --On regarde si le statut de l'Ordre Magasin est Ouvert
			then (case 
				when recp.t_lsta is null --Il n'y a pas de réception, le statut est donc ouvert
					then 'Ouvert' 
				when recp.t_lsta = 20 --On regarde si le statut de la ligne de réception est reçu
					then 'Reçu Ouvert' 
				else (case
					when recp.t_insp = 2 --On regarde si le contrôle est à non
						then (case 
							when recp.t_qput = recp.t_qrcr --Quantité Traitée de la ligne de Réception = Quantité du BL sur la ligne de réception
								then 'Traité Physiquement' 
							else (case 
								when recp.t_qadv = recp.t_qrcr --Si Quantité Proposée = Quantité du BL sur la ligne de réception
									then 'Proposé' 
								else 'Reçu' 
								end) 
							end) 
					else --Le Contrôle est à Oui
						(case 
						when recp.t_qpui = recp.t_qrcr --La Quantité Traitée du Contrôle = Quantité du BL	--Point 1
							then 'Traité Physiquement' 
						else (case 
							when recp.t_qadi = recp.t_qrcr --La Quantité Proposée du Contrôle = Quantité du BL	--Point 2
								then 'Proposé' 
							else (case 
								when (recp.t_qapr + recp.t_qdes + recp.t_qrej) = recp.t_qrcr --Quantité du Contrôle Approuvée + Detruit + Rejetée = Quantité du BL	--Point 3
									then 'Contrôlé' 
								else (case 
									when recp.t_qput = recp.t_qrcr --Quantité Traitée sur la Ligne de Réception = Quantité du BL --Point 4
										then 'A Contrôler' 
									else (case 
										when recp.t_qadv = recp.t_qrcr --Quantité Proposée sur la Ligne de Réception = Quantité du BL --Point 5
											then 'Proposé' 
										else 
											'Reçu' 
										end) 
									end) 
								end) 
							end) 
						end) 
					end)
				end)
		else dbo.convertenum('wh','B61C','a9','bull','inh.lsta',line.t_lsta,4) --On ramène le statut de la ligne 
		end)
else dbo.convertenum('wh','B61C','a9','bull','inh.lsta',line.t_lsta,4) --On ramène le statut de la ligne 
end) as StatutCorrige 
from twhinh200500 omag --Ordres Magasin
left join twhinh210500 line on line.t_oorg = omag.t_oorg and line.t_orno = omag.t_orno and line.t_oset = omag.t_oset --Lignes d'Ordre d'Entrée en Stock
left join ttcibd001500 art on art.t_item = line.t_item --Articles 
left join ttccom100500 tiersexp on tiersexp.t_bpid = omag.t_sfco --Tiers Expediteur
left join ttccom100500 tiersdest on tiersdest.t_bpid = omag.t_stco --Tiers Destinataire
left join ttppdm600500 prj on prj.t_cprj = line.t_tprj --Projets A
left join twhinh312500 recp on recp.t_oorg = line.t_oorg and recp.t_orno=line.t_orno and recp.t_oset=line.t_oset and recp.t_pono=line.t_pono and recp.t_seqn=line.t_seqn and recp.t_ardt between @daterec_f and @daterec_t --Lignes de Réception
left join ttisfc001500 ofab on ofab.t_pdno = omag.t_orno and (omag.t_oorg = 50 or omag.t_oorg = 51) --Ordres de Fabrication
where left(line.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le Magasin
and line.t_cwar between @cwar_f and @cwar_t --Bornage sur le Magasin
and (omag.t_prdt between @prdt_f and @prdt_t or omag.t_oorg = 81) --Bornage sur la Date de Réception Planifiée. Modification par rbesnier le 19/01/2018 pour ramener systématiquement les programmes d'achats qui n'ont pas de date de réception planifiée.
--Ajout par rbesnier le 04/07/2018
--and recp.t_ardt between @daterec_f and @daterec_t --Bornage sur la date de Réception Réelle ou on ramène les dates vides si le paramètre est à oui
and line.t_lsta between @stat_f and @stat_t --Bornage sur le Statut de la Ligne
)
else 
--On fait le traitement des date de réceptions réelles renseignées, autrement dit il y a eu une réception de telle date à telle date
(select dbo.convertenum('wh','B61C','a9','bull','inh.oorg',omag.t_oorg,4) as OrigineOrdre, 
omag.t_oset as Groupe, 
omag.t_orno as Ordre, 
dbo.convertenum('wh','B61C','a9','bull','inh.ittp',omag.t_ittp,4) as TypeTransaction, 
omag.t_odat as DateOrdre, 
omag.t_pddt as DateLivraisonPlanifiee, 
omag.t_prdt as DateReceptionPlanifiee, 
dbo.convertenum('tc','B61C','a9','bull','typs',omag.t_sfty,4) as TypeExpediteur, 
omag.t_sfco as CodeExpediteur, 
tiersexp.t_nama as NomExpediteur, 
dbo.convertenum('tc','B61C','a9','bull','typs',omag.t_stty,4) as TypeDestinataire, 
omag.t_stco as CodeDestinataire, 
tiersdest.t_nama as NomDestinataire, 
omag.t_sfcp as SocieteExpediteur, 
omag.t_stcp as SocieteDestinataire, 
dbo.convertenum('wh','B61C','a9','bull','inh.hsta',omag.t_hsta,4) as StatutEnTete, 
line.t_pono as Ligne, 
line.t_seqn as Sequence, 
left(line.t_item, 9) as ProjetArticle, 
substring(line.t_item, 10, len(line.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
line.t_qoro as QuantiteCommandeeUniteOrdre, 
line.t_orun as UniteOrdre, 
art.t_cuni as UniteStock, 
dbo.convertenum('wh','B61C','a9','bull','inh.lsta',line.t_lsta,4) as StatutLigne, 
dbo.convertenum('wh','B61C','a9','bull','inh.lstc',recp.t_lsta,4) as StatutLigneReception, 
line.t_qord as QuantiteCommandee, 
recp.t_qrec as QuantiteRecue, 
line.t_qorc as QuantiteRecueOuverte, 
recp.t_qadv as QuantiteProposee, 
recp.t_qapr as QuantiteApprouvee, 
recp.t_qdes as QuantiteDetruite,  
recp.t_qrej as QuantiteRejetee, 
line.t_qput as QuantiteTraitee, 
recp.t_qadi as ProposeeQuantiteControle, 
recp.t_qpui as TraiteeQuantiteControle, 
recp.t_qrcr as QuantiteBonLivraisonUniteStock, 
recp.t_qput as QuantiteTraiteeReception, 
line.t_blck as CodeBloque, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_blck,'4') as Bloque, 
line.t_tprj as ProjetA, 
prj.t_dsca as DescriptionProjetA, 
recp.t_ardt as DateReceptionReelle, 
recp.t_rcno as Reception, 
recp.t_logn as LoginReception, 
isnull(recp.t_cwar, line.t_cwar) as Magasin, 
isnull(recp.t_psno, '') as NumeroBonLivraison, 
ofab.t_prcd as Priorite, 
(case 
when omag.t_prdt = '01/01/1970' 
	then '' 
when datediff(d, getdate(), omag.t_prdt) < 0 
	then 'RETARD' 
when datediff(d, getdate(), omag.t_prdt) = 0 
	then 'JOUR J' 
when datediff(d, getdate(), omag.t_prdt) < 7 
	then concat('J+', convert(varchar, datediff(d, getdate(), omag.t_prdt))) 
else 
	'>J+7'
end) as DatePlanifiee, 
(case left(line.t_item, 3) 
when 'LVP' 
	then 'Projet' 
else '' 
end) as FabArticleProjet, 
--Correction par rbesnier suite mail Gaëtan du 20/07/2018 à 17h10
(case 
when omag.t_prdt = '01/01/1970' 
	then '' 
when recp.t_ardt = '01/01/1970' 
	then '' 
when datediff(d, omag.t_prdt, recp.t_ardt) < -5 
	then '<J-5' 
when datediff(d, omag.t_prdt, recp.t_ardt) > 5 
	then '>J+5' 
when datediff(d, omag.t_prdt, recp.t_ardt) = 0 
	then 'JOUR J' 
when datediff(d, omag.t_prdt, recp.t_ardt) > 0 
	then concat('J+', convert(varchar, datediff(d, omag.t_prdt, recp.t_ardt))) 
when datediff(d, omag.t_prdt, recp.t_ardt) < 0 
	then concat('J', convert(varchar, datediff(d, omag.t_prdt, recp.t_ardt))) 
else 
	''
end) as DeltaDateReceptionReellePlanifiee, 
(case 
when omag.t_oorg = 81 --On ne fait le traitement que pour les programmes d'achats
	then (case
		when omag.t_hsta = 20 --On regarde si le statut de l'Ordre Magasin est Ouvert
			then (case 
				when recp.t_lsta is null --Il n'y a pas de réception, le statut est donc ouvert
					then 'Ouvert' 
				when recp.t_lsta = 20 --On regarde si le statut de la ligne de réception est reçu
					then 'Reçu Ouvert' 
				else (case
					when recp.t_insp = 2 --On regarde si le contrôle est à non
						then (case 
							when recp.t_qput = recp.t_qrcr --Quantité Traitée de la ligne de Réception = Quantité du BL sur la ligne de réception
								then 'Traité Physiquement' 
							else (case 
								when recp.t_qadv = recp.t_qrcr --Si Quantité Proposée = Quantité du BL sur la ligne de réception
									then 'Proposé' 
								else 'Reçu' 
								end) 
							end) 
					else --Le Contrôle est à Oui
						(case 
						when recp.t_qpui = recp.t_qrcr --La Quantité Traitée du Contrôle = Quantité du BL	--Point 1
							then 'Traité Physiquement' 
						else (case 
							when recp.t_qadi = recp.t_qrcr --La Quantité Proposée du Contrôle = Quantité du BL	--Point 2
								then 'Proposé' 
							else (case 
								when (recp.t_qapr + recp.t_qdes + recp.t_qrej) = recp.t_qrcr --Quantité du Contrôle Approuvée + Detruit + Rejetée = Quantité du BL	--Point 3
									then 'Contrôlé' 
								else (case 
									when recp.t_qput = recp.t_qrcr --Quantité Traitée sur la Ligne de Réception = Quantité du BL --Point 4
										then 'A Contrôler' 
									else (case 
										when recp.t_qadv = recp.t_qrcr --Quantité Proposée sur la Ligne de Réception = Quantité du BL --Point 5
											then 'Proposé' 
										else 
											'Reçu' 
										end) 
									end) 
								end) 
							end) 
						end) 
					end)
				end)
		else dbo.convertenum('wh','B61C','a9','bull','inh.lsta',line.t_lsta,4) --On ramène le statut de la ligne 
		end)
else dbo.convertenum('wh','B61C','a9','bull','inh.lsta',line.t_lsta,4) --On ramène le statut de la ligne 
end) as StatutCorrige 
from twhinh200500 omag --Ordres Magasin
left join twhinh210500 line on line.t_oorg = omag.t_oorg and line.t_orno = omag.t_orno and line.t_oset = omag.t_oset --Lignes d'Ordre d'Entrée en Stock
left join ttcibd001500 art on art.t_item = line.t_item --Articles 
left join ttccom100500 tiersexp on tiersexp.t_bpid = omag.t_sfco --Tiers Expediteur
left join ttccom100500 tiersdest on tiersdest.t_bpid = omag.t_stco --Tiers Destinataire
left join ttppdm600500 prj on prj.t_cprj = line.t_tprj --Projets A
left join twhinh312500 recp on recp.t_oorg = line.t_oorg and recp.t_orno=line.t_orno and recp.t_oset=line.t_oset and recp.t_pono=line.t_pono and recp.t_seqn=line.t_seqn --Lignes de Réception
left join ttisfc001500 ofab on ofab.t_pdno = omag.t_orno and (omag.t_oorg = 50 or omag.t_oorg = 51) --Ordres de Fabrication
where left(line.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le Magasin
and line.t_cwar between @cwar_f and @cwar_t --Bornage sur le Magasin
and (omag.t_prdt between @prdt_f and @prdt_t or omag.t_oorg = 81) --Bornage sur la Date de Réception Planifiée. Modification par rbesnier le 19/01/2018 pour ramener systématiquement les programmes d'achats qui n'ont pas de date de réception planifiée.
--Ajout par rbesnier le 04/07/2018
and recp.t_ardt between @daterec_f and @daterec_t --Bornage sur la date de Réception Réelle ou on ramène les dates vides si le paramètre est à oui
and line.t_lsta between @stat_f and @stat_t --Bornage sur le Statut de la Ligne
)