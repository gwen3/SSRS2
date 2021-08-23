-------------------------------------
-- COM02 - Facturation Constructeur
-------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Fonction SSRS pour calculer le nombre de ligne suivant le service de vente : =CountRows("TiersFacture")
--GCV
if (@socfin = '200')
(select fact.t_itbp as TiersFacture, 
tier.t_nama as NomTiersFacture, 
fact.t_idat as DateFacture, 
cde.t_cofc as ServiceVente, 
fact.t_tran as JournalFacture, 
fact.t_idoc as NumeroFacture, 
fact.t_itoa as CodeAdresseFacturation 
from tcisli305200 fact --En-tête de Factures
inner join ttccom100500 tier on tier.t_bpid = fact.t_itbp --Tiers Facture
inner join ttdsls400500 cde on cde.t_orno = fact.t_cslo --Commande Client
where fact.t_idat between @datefac_f and @datefac_t --Bornage sur la Date de Facture
and cde.t_cofc between @servent_f and @servent_t --Bornage sur le Service de Vente
)
--Le Mans
else if (@socfin = '300')
(select fact.t_itbp as TiersFacture, 
tier.t_nama as NomTiersFacture, 
fact.t_idat as DateFacture, 
cde.t_cofc as ServiceVente, 
fact.t_tran as JournalFacture, 
fact.t_idoc as NumeroFacture, 
fact.t_itoa as CodeAdresseFacturation 
from tcisli305300 fact --En-tête de Factures
inner join ttccom100500 tier on tier.t_bpid = fact.t_itbp --Tiers Facture
inner join ttdsls400500 cde on cde.t_orno = fact.t_cslo --Commande Client
where fact.t_idat between @datefac_f and @datefac_t --Bornage sur la Date de Facture
and cde.t_cofc between @servent_f and @servent_t --Bornage sur le Service de Vente
)
--Labbé
else if (@socfin = '400')
(select fact.t_itbp as TiersFacture, 
tier.t_nama as NomTiersFacture, 
fact.t_idat as DateFacture, 
cde.t_cofc as ServiceVente, 
fact.t_tran as JournalFacture, 
fact.t_idoc as NumeroFacture, 
fact.t_itoa as CodeAdresseFacturation 
from tcisli305400 fact --En-tête de Factures
inner join ttccom100500 tier on tier.t_bpid = fact.t_itbp --Tiers Facture
inner join ttdsls400500 cde on cde.t_orno = fact.t_cslo --Commande Client
where fact.t_idat between @datefac_f and @datefac_t --Bornage sur la Date de Facture
and cde.t_cofc between @servent_f and @servent_t --Bornage sur le Service de Vente
)
--Grand Laval
else if (@socfin = '500')
(select fact.t_itbp as TiersFacture, 
tier.t_nama as NomTiersFacture, 
fact.t_idat as DateFacture, 
cde.t_cofc as ServiceVente, 
fact.t_tran as JournalFacture, 
fact.t_idoc as NumeroFacture, 
fact.t_itoa as CodeAdresseFacturation 
from tcisli305500 fact --En-tête de Factures
inner join ttccom100500 tier on tier.t_bpid = fact.t_itbp --Tiers Facture
inner join ttdsls400500 cde on cde.t_orno = fact.t_cslo --Commande Client
where fact.t_idat between @datefac_f and @datefac_t --Bornage sur la Date de Facture
and cde.t_cofc between @servent_f and @servent_t --Bornage sur le Service de Vente
)
--Gifa
else if (@socfin = '600')
(select fact.t_itbp as TiersFacture, 
tier.t_nama as NomTiersFacture, 
fact.t_idat as DateFacture, 
cde.t_cofc as ServiceVente, 
fact.t_tran as JournalFacture, 
fact.t_idoc as NumeroFacture, 
fact.t_itoa as CodeAdresseFacturation 
from tcisli305600 fact --En-tête de Factures
inner join ttccom100500 tier on tier.t_bpid = fact.t_itbp --Tiers Facture
inner join ttdsls400500 cde on cde.t_orno = fact.t_cslo --Commande Client
where fact.t_idat between @datefac_f and @datefac_t --Bornage sur la Date de Facture
and cde.t_cofc between @servent_f and @servent_t --Bornage sur le Service de Vente
)
--Petit Picot
else if (@socfin = '610')
(select fact.t_itbp as TiersFacture, 
tier.t_nama as NomTiersFacture, 
fact.t_idat as DateFacture, 
cde.t_cofc as ServiceVente, 
fact.t_tran as JournalFacture, 
fact.t_idoc as NumeroFacture, 
fact.t_itoa as CodeAdresseFacturation 
from tcisli305610 fact --En-tête de Factures
inner join ttccom100500 tier on tier.t_bpid = fact.t_itbp --Tiers Facture
inner join ttdsls400500 cde on cde.t_orno = fact.t_cslo --Commande Client
where fact.t_idat between @datefac_f and @datefac_t --Bornage sur la Date de Facture
and cde.t_cofc between @servent_f and @servent_t --Bornage sur le Service de Vente
)
--Sanicar
else if (@socfin = '620')
(select fact.t_itbp as TiersFacture, 
tier.t_nama as NomTiersFacture, 
fact.t_idat as DateFacture, 
cde.t_cofc as ServiceVente, 
fact.t_tran as JournalFacture, 
fact.t_idoc as NumeroFacture, 
fact.t_itoa as CodeAdresseFacturation 
from tcisli305620 fact --En-tête de Factures
inner join ttccom100500 tier on tier.t_bpid = fact.t_itbp --Tiers Facture
inner join ttdsls400500 cde on cde.t_orno = fact.t_cslo --Commande Client
where fact.t_idat between @datefac_f and @datefac_t --Bornage sur la Date de Facture
and cde.t_cofc between @servent_f and @servent_t --Bornage sur le Service de Vente
)
--Ducarme
else if (@socfin = '630')
(select fact.t_itbp as TiersFacture, 
tier.t_nama as NomTiersFacture, 
fact.t_idat as DateFacture, 
cde.t_cofc as ServiceVente, 
fact.t_tran as JournalFacture, 
fact.t_idoc as NumeroFacture, 
fact.t_itoa as CodeAdresseFacturation 
from tcisli305630 fact --En-tête de Factures
inner join ttccom100500 tier on tier.t_bpid = fact.t_itbp --Tiers Facture
inner join ttdsls400500 cde on cde.t_orno = fact.t_cslo --Commande Client
where fact.t_idat between @datefac_f and @datefac_t --Bornage sur la Date de Facture
and cde.t_cofc between @servent_f and @servent_t --Bornage sur le Service de Vente
)
--Par défaut on prend le Grand Laval
else 
(select fact.t_itbp as TiersFacture, 
tier.t_nama as NomTiersFacture, 
fact.t_idat as DateFacture, 
cde.t_cofc as ServiceVente, 
fact.t_tran as JournalFacture, 
fact.t_idoc as NumeroFacture, 
fact.t_itoa as CodeAdresseFacturation 
from tcisli305500 fact --En-tête de Factures
inner join ttccom100500 tier on tier.t_bpid = fact.t_itbp --Tiers Facture
inner join ttdsls400500 cde on cde.t_orno = fact.t_cslo --Commande Client
where fact.t_idat between @datefac_f and @datefac_t --Bornage sur la Date de Facture
and cde.t_cofc between @servent_f and @servent_t --Bornage sur le Service de Vente
)