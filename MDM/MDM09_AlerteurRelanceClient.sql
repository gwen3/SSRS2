------------------------------------
-- MDM09 - Alerteur Relance Client
------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lcde.t_orno as CommandeClient
,lcde.t_pono as PositionCommandeClient
,cde.t_cofc as ServiceVente
,lcde.t_corn as CommandeDuClient
,lcde.t_serl as NumeroSerie
,cde.t_ofbp as TiersAcheteur
,tiers.t_nama as NomTiersAcheteur
,cde.t_ofcn as ContactCommandeClient
,contact.t_fuln as NomContactCommandeClient
,contact.t_info as MailContactCommandeClient
,(select top 1 hlcde.t_prdt from ttdsls451500 hlcde where hlcde.t_orno = lcde.t_orno and hlcde.t_pono = lcde.t_pono and hlcde.t_trdt > dateadd("d", -1, getdate())) as 'Date MADC Prevue Avant'
,lcde.t_prdt as 'Date MADC Prevue Actuelle'
,lcde.t_dmad as 'Date MADC Confirmee'
,cde.t_crep as RepresentantInterne
,empi.t_nama as NomRepresentantInterne
,cde.t_osrp as RepresentantExterne
,empe.t_nama as NomRepresentantExterne
from ttdsls401500 lcde --Commandes Clients
inner join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Lignes de Commande Client
left outer join ttccom100500 tiers on tiers.t_bpid = cde.t_ofbp --Tiers
left outer join ttccom140500 contact on contact.t_ccnt = cde.t_ofcn --Contact du Tiers Acheteur
left outer join ttccom001500 empi on empi.t_emno = cde.t_crep --Employés - Représentant Interne
left outer join ttccom001500 empe on empe.t_emno = cde.t_osrp --Employés - Représentant Externe
where cde.t_orno between @cde_f and @cde_t --Bornage sur le numéro de commande client
and cde.t_ofbp between @tiers_f and @tiers_t --Bornage sur le Tiers Acheteur
and cde.t_crep between @rep_f and @rep_t --Bornage sur le Représentant Interne
and cde.t_cofc in (@cofc) --Bornage sur le service de vente
and lcde.t_prdt != (select top 1 hlcde.t_prdt from ttdsls451500 hlcde where hlcde.t_orno = lcde.t_orno and hlcde.t_pono = lcde.t_pono and hlcde.t_trdt > dateadd("d", -1, getdate())) --On regarde uniquement les commandes où la date MADC prévue a été modifiée depuis la veille
and lcde.t_item not like '%CHASSIS%' --On exclu les lignes châssis
and cde.t_ofbp != '100005506' --On exclu le tiers avance client, pas de contact dessus