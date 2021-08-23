---------------------------------------
-- FIN02 - Suivi des Litiges Factures
---------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select fact.t_ttyp as Document, 
fact.t_ninv as fg, 
fact.t_line as ffg, 
fact.t_tpay as CodeDocument, 
dbo.convertenum('tf','B61C','a9','bull','acp.tpay',fact.t_tpay,'4') as TypeDocument, 
fact.t_ifbp as TiersFacturant, 
tier.t_nama as NomTiers, 
fact.t_bloc as MotifBlocage, 
fact.t_bref as ApprobAssigne, 
fact.t_dued as DateEcheance, 
fact.t_isup as FactureFournisseur, 
fact.t_ptbp as TiersPaye, 
fact.t_docd as DateDocument, 
fact.t_stap as CodeStatutFacture, 
dbo.convertenum('tf','B61C','a9','bull','acp.stap',fact.t_stap,'4') as StatutFacture, 
fact.t_amnt as MontantFacture, 
fact.t_ccur as Devise, 
fact.t_amth_1 as MontantSociete, 
fact.t_balc as SoldeFacture, 
fact.t_balh_1 as SoldeSociete 
from ttfacp200610 fact --Factures et Règlements Fournisseurs
inner join ttccom100500 tier on tier.t_bpid = fact.t_ifbp --Tiers
where fact.t_bloc between @motif_f and @motif_t --On borne sur le motif de blocage
and fact.t_bloc != ""; --On enlève le motif de blocage vide
