-------------------------------
-- GEN06 - Contrôle des Tiers
-------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/*
declare @date_f as Date;
set @date_f = '01/01/2018';
declare @date_t as Date;
set @date_t = '31/12/2018';
*/

select 'Production' as Source, 
tiers.t_bpid as NumeroTiers, 
tiers.t_usid as CreationPar, 
tiers.t_crdt as DateCreation, 
tiers.t_lmus as ModifiePar, 
tiers.t_lmdt as DateModification, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as StatutTiers, 
tiers.t_stdt as DateStatutDe, 
tiers.t_endt as DateStatutA, 
tiers.t_nama as NomTiers, 
tiers.t_cadr as CodeAdresse, 
tiers.t_telp as TelephoneProfessionnel, 
tiers.t_ccnt as ContactPrincipal, 
tiers.t_inet as SiteWeb, 
tiers.t_ctit as Titre, 
titre.t_dsca as DescriptionTitre, 
tiers.t_clan as Langue, 
lang.t_dsca as DescriptionLangue, 
tiers.t_ccur as Devise, 
devise.t_dsca as DescriptionDevise, 
tiers.t_tefx as Fax, 
tiers.t_lgid as Siret, 
tiers.t_cmid as DunnAndBradstreet, 
numtva.t_fovn as NumeroTVA, 
numtva.t_ccty as PaysNumeroTVA, 
tiers.t_prbp as TiersPere, 
tiersacheteur.t_user as TiersAcheteurCreePar, 
tiersacheteur.t_crdt as TiersAcheteurDateCreation, 
tiersacheteur.t_lmus as TiersAcheteurModifiePar, 
tiersacheteur.t_lmdt as TiersAcheteurDateModification, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tiersacheteur.t_bpst,'4') as TiersAcheteurStatut, 
tiersacheteur.t_stdt as TiersAcheteurDateStatutDe, 
tiersacheteur.t_endt as TiersAcheteurDateStatutA, 
tiersacheteur.t_cadr as TiersAcheteurCodeAdresse, 
tiersacheteur.t_clan as TiersAcheteurLangue, 
tiersacheteur.t_cbtp as TiersAcheteurTypeTiers, 
tiersacheteur.t_creg as TiersAcheteurZone, 
tiersacheteur.t_cbrn as TiersAcheteurSecteurActivite, 
tiersacheteur.t_osrp as TiersAcheteurRepresentantExterne, 
tiersacheteur.t_osno as TiersAcheteurNotreNumeroFournisseur, 
tiersacheteur.t_chan as TiersAcheteurCanalDistribution, 
canal.t_dsca as TiersAcheteurDescriptionCanalDistribution, 
tiersacheteur.t_cdec as TiersAcheteurConditionLivraison, 
tiersdestinataire.t_user as TiersDestinataireCreePar, 
tiersdestinataire.t_crdt as TiersDestinataireDateCreation, 
tiersdestinataire.t_lmus as TiersDestinataireModifiePar, 
tiersdestinataire.t_lmdt as TiersDestinataireDateModification, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tiersdestinataire.t_bpst,'4') as TiersDestinataireStatut, 
tiersdestinataire.t_stdt as TiersDestinataireDateStatutDe, 
tiersdestinataire.t_endt as TiersDestinataireDateStatutA, 
tiersdestinataire.t_cadr as TiersDestinataireCodeAdresse, 
tiersdestinataire.t_clan as TiersDestinataireLangue, 
tiersfacture.t_user as TiersFactureCreePar, 
tiersfacture.t_crdt as TiersFactureDateCreation, 
tiersfacture.t_lmus as TiersFactureModifiePar, 
tiersfacture.t_lmdt as TiersFactureDateModification, 
dbo.convertenum('tc','B61C','a9','bull','com.itst',tiersfacture.t_itst,'4') as TiersFactureStatut, 
tiersfacture.t_stdt as TiersFactureDateStatutDe, 
tiersfacture.t_endt as TiersFactureDateStatutA, 
tiersfacture.t_cadr as TiersFactureCodeAdresse, 
tiersfacture.t_clan as TiersFactureLangue, 
tiersfacture.t_ccur as TiersFactureDevise, 
tiersfacture.t_rtyp as TiersFactureTypeTauxChange, 
tiersfacture.t_cfcg as TiersFactureGroupeClientsFinanciers, 
grpcli.t_desc as DescriptionGroupeClients, 
tiersfacture.t_ncin as TiersFactureNombreCopieFacture, 
tiersfacture.t_cinm as TiersFactureModeFacturation, 
tiersfacture.t_crat as TiersFactureNotationCredit, 
tiersfacture.t_crlr as TiersFacturePlafondCredit, 
tiersfacture.t_cpay as TiersFactureConditionReglement, 
tiersfacture.t_rpay as TiersFactureConditionReglementAvoir, 
tiersfacture.t_paym as TiersFactureMethodeReglement, 
tiersfacture.t_rpym as TiersFactureMethodeReglementAvoir, 
tierspayeur.t_user as TiersPayeurCreePar, 
tierspayeur.t_crdt as TiersPayeurDateCreation, 
tierspayeur.t_lmus as TiersPayeurModifiePar, 
tierspayeur.t_lmdt as TiersPayeurDateModification, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tierspayeur.t_bpst,'4') as TiersPayeurStatut, 
tierspayeur.t_stdt as TiersPayeurDateStatutDe, 
tierspayeur.t_endt as TiersPayeurDateStatutA, 
tierspayeur.t_cadr as TiersPayeurCodeAdresse, 
tierspayeur.t_clan as TiersPayeurLangue, 
tierspayeur.t_ccur as TiersPayeurDevise, 
tierspayeur.t_rtyp as TiersPayeurTypeTauxChange, 
tiersvendeur.t_user as TiersVendeurCreePar, 
tiersvendeur.t_crdt as TiersVendeurDateCreation, 
tiersvendeur.t_lmus as TiersVendeurModifiePar, 
tiersvendeur.t_lmdt as TiersVendeurDateModification, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tiersvendeur.t_bpst,'4') as TiersVendeurStatut, 
tiersvendeur.t_stdt as TiersVendeurDateStatutDe, 
tiersvendeur.t_endt as TiersVendeurDateStatutA, 
tiersvendeur.t_cadr as TiersVendeurCodeAdresse, 
tiersvendeur.t_ccnt as TiersVendeurContactPrincipal, 
tiersvendeur.t_clan as TiersVendeurLangue, 
tiersvendeur.t_ccal as TiersVendeurCalendrier, 
tiersvendeur.t_ccon as TiersVendeurAcheteur, 
empa.t_nama as TiersVendeurNomAcheteur, 
tiersvendeur.t_ocus as TiersVendeurNotreNumeroClient, 
dbo.convertenum('tc','B61C','a9','bull','crrf',tiersvendeur.t_crrf,'4') as TiersVendeurReferenceCroiseeArticle, 
tiersvendeur.t_cdec as TiersVendeurConditionLivraison, 
tiersvendeur.t_rdec as TiersVendeurConditionRetourLivraison, 
tiersexpediteur.t_user as TiersExpediteurCreePar, 
tiersexpediteur.t_crdt as TiersExpediteurDateCreation, 
tiersexpediteur.t_lmus as TiersExpediteurModifiePar, 
tiersexpediteur.t_lmdt as TiersExpediteurDateModification, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tiersexpediteur.t_bpst,'4') as TiersExpediteurStatut, 
tiersexpediteur.t_stdt as TiersExpediteurDateStatutDe, 
tiersexpediteur.t_endt as TiersExpediteurDateStatutA, 
tiersexpediteur.t_cadr as TiersExpediteurCodeAdresse, 
tiersexpediteur.t_ccnt as TiersExpediteurContactPrincipal, 
tiersexpediteur.t_clan as TiersExpediteurLangue, 
tiersexpediteur.t_ccal as TiersExpediteurCalendrier, 
dbo.convertenum('tc','B61C','a9','bull','yesno',tiersexpediteur.t_qual,'4') as TiersExpediteurControle, 
tiersfacturant.t_user as TiersFacturantCreePar, 
tiersfacturant.t_crdt as TiersFacturantDateCreation, 
tiersfacturant.t_lmus as TiersFacturantModifiePar, 
tiersfacturant.t_lmdt as TiersFacturantDateModification, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tiersfacturant.t_bpst,'4') as TiersFacturantStatut, 
tiersfacturant.t_stdt as TiersFacturantDateStatutDe, 
tiersfacturant.t_endt as TiersFacturantDateStatutA, 
tiersfacturant.t_cadr as TiersFacturantCodeAdresse, 
tiersfacturant.t_clan as TiersFacturantLangue, 
tiersfacturant.t_ccur as TiersFacturantDevise, 
tiersfacturant.t_rtyp as TiersFacturantTypeTauxChange, 
tiersfacturant.t_cfsg as TiersFacturantGroupeFournisseurFinanciers, 
grpfrn.t_desc as DescriptionGroupeFournisseur, 
tiersfacturant.t_cpay as TiersFacturantConditionReglement, 
tiersfacturant.t_rpay as TiersFacturantConditionReglementAvoir, 
tiersfacturant.t_paym as TiersFacturantMethodeReglement, 
tiersfacturant.t_rpym as TiersFacturantMethodeReglementAvoir, 
tierspaye.t_user as TiersPayeCreePar, 
tierspaye.t_crdt as TiersPayeDateCreation, 
tierspaye.t_lmus as TiersPayeModifiePar, 
tierspaye.t_lmdt as TiersPayeDateModification, 
dbo.convertenum('tc','B61C','a9','bull','com.prst',tierspaye.t_bpst,'4') as TiersPayeStatut, 
tierspaye.t_stdt as TiersPayeDateStatutDe, 
tierspaye.t_endt as TiersPayeDateStatutA, 
tierspaye.t_cadr as TiersPayeCodeAdresse, 
tierspaye.t_ccnt as TiersPayeContactPrincipal, 
tierspaye.t_clan as TiersPayeLangue, 
tierspaye.t_ccur as TiersPayeDevise, 
tierspaye.t_rtyp as TiersPayeTypeTauxChange 
from ttccom100500 tiers --Tiers
left outer join ttcmcs019500 titre on titre.t_ctit = tiers.t_ctit --Fonctions
left outer join ttcmcs046500 lang on lang.t_clan = tiers.t_clan --Langue
left outer join ttcmcs002500 devise on devise.t_ccur = tiers.t_ccur --Devise
left outer join ttctax400500 numtva on numtva.t_bpid = tiers.t_bpid and numtva.t_efdt < getdate() and (numtva.t_exdt > getdate() or numtva.t_exdt = '01/01/1970') --Numero TVA ; date d'application inférieure à la date du jour et date d'expiration supérieure à la date du jour ou est vide (01/01/1970)
left outer join ttccom110500 tiersacheteur on tiersacheteur.t_ofbp = tiers.t_bpid --Tiers Acheteur
left outer join ttcmcs066500 canal on canal.t_chan = tiersacheteur.t_chan --Canal de Distribution
left outer join ttccom111500 tiersdestinataire on tiersdestinataire.t_stbp = tiers.t_bpid --Tiers Destinataire
left outer join ttccom112500 tiersfacture on tiersfacture.t_itbp = tiers.t_bpid --Tiers Facturé
left outer join ttfacr001500 grpcli on grpcli.t_ficu = tiersfacture.t_cfcg --Groupes Financiers Clients
left outer join ttccom114500 tierspayeur on tierspayeur.t_pfbp = tiers.t_bpid --Tiers Payeur
left outer join ttccom120500 tiersvendeur on tiersvendeur.t_otbp = tiers.t_bpid --Tiers Vendeur
left outer join ttccom001500 empa on empa.t_emno = tiersvendeur.t_ccon --Employé - Acheteur
left outer join ttccom121500 tiersexpediteur on tiersexpediteur.t_sfbp = tiers.t_bpid --Tiers Expéditeur
left outer join ttccom122500 tiersfacturant on tiersfacturant.t_ifbp = tiers.t_bpid --Tiers Facturant
left outer join ttfacp001500 grpfrn on grpfrn.t_fisu = tiersfacturant.t_cfsg --Groupes Financiers Fournisseur
left outer join ttccom124500 tierspaye on tierspaye.t_ptbp = tiers.t_bpid --Tiers Paye
where tiers.t_crdt between @date_f and @date_t --Date Creation du Tiers 
or tiersacheteur.t_crdt between @date_f and @date_t --Date Creation du Tiers Acheteur
or tiersdestinataire.t_crdt between @date_f and @date_t --Date Creation du Tiers Destinataire
or tiersfacture.t_crdt between @date_f and @date_t --Date Creation du Tiers Facture
or tierspayeur.t_crdt between @date_f and @date_t --Date Creation du Tiers Payeur
or tiersvendeur.t_crdt between @date_f and @date_t --Date Creation du Tiers Vendeur
or tiersexpediteur.t_crdt between @date_f and @date_t --Date Creation du Tiers Expéditeur
or tiersfacturant.t_crdt between @date_f and @date_t --Date Creation du Tiers Facturant
or tierspaye.t_crdt between @date_f and @date_t --Date Creation du Tiers Payeur