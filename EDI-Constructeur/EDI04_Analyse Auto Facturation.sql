-------------------------------------
-- EDI04 - Analyse Auto Facturation
-------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/*
declare @fact_f as int;
declare @fact_t as int;
declare @ecart as varchar;

set @fact_f = '1';
set @fact_t = '999999999';
set @ecart = '2';
*/

select etfac.t_sfcp as Societe, 
etfac.t_ttyp as CodeFactureAutoClient, 
etfac.t_idoc as NumeroFactureAutoClient, 
etfac.t_itbp as TiersFacture, 
tierfac.t_nama as NomTiersFacture, 
etfac.t_ccur as Devise, 
etfac.t_cidt as DateAutoFacture, 
etfac.t_fovc as ClientCodeTVA, 
etfac.t_fovn as FournisseurCodeTVA, 
etfac.t_cirf as FournisseurReferenceFacture, 
lfacauto.t_slin as Ligne, 
lfacauto.t_item as ArticleGruau, 
lfacauto.t_ctem as ArticleClient, 
lfacauto.t_pric as PrixUnitaireFacturationAuto, 
lfacauto.t_cups as UnitePrix, 
lfacauto.t_dqua as QuantiteLivreeFacturationAuto, 
lfacauto.t_cuns as UniteFacturationAuto, 
lfacauto.t_amnt as Total, 
lfacauto.t_ccty as PaysTVAExpediteur, 
lfacauto.t_cvat as CodeTVA, 
lfacauto.t_damt as MontantRemiseEnDevise,
lfacauto.t_refs as ReferenceExpedition, 
lfacauto.t_srco as CodeRelationRapprochement, 
relfacauto.t_tran as CodeFactureGruau, 
relfacauto.t_idoc as NumeroFactureGruau, 
relfacauto.t_line as LigneNumeroFactureGruau, 
lfac.t_orno as NumeroCommande, 
lfac.t_bpct as PaysTVADestinataire, 
lfac.t_stbp as TiersDestinataire, 
tierdes.t_nama as NomTiersDestinataire, 
lfac.t_amti as MontantNetLigne, 
lfac.t_amth_1 as MontantNetLigneDeviseSociete, 
lfac.t_tbai as MontantBaseTVA, 
lfac.t_tbah_1 as MontantBaseTVADeviseSociete, 
lfac.t_slai as MontantLigneSource, 
lfac.t_slah_1 as MontantLigneSourceDeviseSociete, 
lfac.t_pric as PrixUnitaire, 
lfac.t_dqua as QuantiteLivree, 
lfac.t_cuqs as Unite, 
lfac.t_cdec as ConditionLivraison, 
lfac.t_shpm as NumeroExpedition, 
lfac.t_shln as LigneExpedition, 
lfac.t_odat as DateCommande, 
lfac.t_ddat as DateLivraison 
from tcisli500500 etfac --En-tête de Facture Automatique
left outer join ttccom100500 tierfac on tierfac.t_bpid = etfac.t_itbp --Tiers Facture
left outer join tcisli505500 lfacauto on etfac.t_ttyp = lfacauto.t_ttyp and etfac.t_idoc = lfacauto.t_idoc --Lignes Factures Automatique
left outer join tcisli515500 relfacauto on lfacauto.t_srco = relfacauto.t_srco --Relations Factures Automatiques Rapprochées - Ligne
left outer join tcisli310500 lfac on relfacauto.t_idoc = lfac.t_idoc and relfacauto.t_line = lfac.t_line -- Lignes Facture
left outer join ttccom100500 tierdes on tierdes.t_bpid = lfac.t_stbp --Tiers Destinataire
where etfac.t_idoc between @fact_f and @fact_t --Bornage sur le Numéro de la Facture Auto Client
and (relfacauto.t_line not in (select lfac2.t_line from tcisli310500 lfac2 where relfacauto.t_idoc = lfac2.t_idoc and relfacauto.t_line = lfac2.t_line) or @ecart = 2) --On ne prend que les AutoFacturations si elles n'ont pas de lignes de factures associées (via @ecart)
