-------------------------------------
-- EDI03 - Ecart d'Auto Facturation
-------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select liglivpv.t_ttyp as TypeEcritureFinanciere, 
liglivpv.t_invn as NumeroFacture, 
liglivpv.t_invd as DateFacture, 
pv.t_itbp as TiersFacture, 
tiers.t_nama as NomTiersFacture, 
liglivpv.t_schn as NumeroCommande, 
liglivpv.t_dlno as NumeroExpedition, 
liglivpv.t_refs as ReferenceExpedition, 
left(pv.t_item, 9) as Projet, 
substring(pv.t_item, 10, len(pv.t_item)) as Article, 
pv.t_citm as CodeArticleClient, 
liglivpv.t_dldt as DateLivraison, 
liglivpv.t_qidl as QuantiteLivree, 
liglivpv.t_namt as MontantFacturableGruau, 
liglivpv.t_iamv as Ecart, 
(liglivpv.t_namt - liglivpv.t_iamv) as MontantAutoFacture, 
(liglivpv.t_namt / liglivpv.t_qidl) as PrixPieceGruau, 
((liglivpv.t_namt - liglivpv.t_iamv) / liglivpv.t_qidl) as PrixPieceAutoFacturation, 
(case 
when liglivpv.t_iamv > 0
	then 'Oui'
else 'Non'
end) as FactureComplementaire --On met à oui si c'est positif, cela signifie que l'on doit demander de l'argent en plus.
from ttdsls340500 liglivpv --Lignes de Livraisons de Programmes de Ventes Réelles
inner join ttdsls311500 pv on pv.t_schn = liglivpv.t_schn and pv.t_sctp = 2 and pv.t_revn = (select top 1 pv2.t_revn from ttdsls311500 pv2 where pv2.t_schn = pv.t_schn and pv2.t_sctp = 2 order by pv2.t_revn desc) --Programmes de Vente, on prend les Programmes d'expédition (sctp = 2) et on prend la dernière révision connue, les informations cherchées sont identiques
inner join ttccom100500 tiers on tiers.t_bpid = pv.t_itbp --Tiers - Acheteur
where liglivpv.t_iamv != 0 --On ne prend que les factures qui ont un écart
and liglivpv.t_invd between @datefact_f and @datefact_t --Bornage sur la date de facture
--Rajout le 23/03/2018 par rbesnier suite à demande de Gaëtan
order by liglivpv.t_ttyp, liglivpv.t_invn desc --On tri par numéro de facture et par type