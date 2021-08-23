-- extraction des commandes Gifa pour Zoho, alimentation du "parc"
-- 03/10/2019 initialistion à partir du com08
-- 21/10/2019 évolutions, colonnes : "Carrossier", "Gestionnaire de parc" (jointure avec les données du personnel), "couleur" devient "Type de véhicule", "montant HT", "annulé ?", "Produit" (jointure avec le configurateur)

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- variables pour tests

declare @ue_f char(6) = 'AL'
declare @ue_t char(6) = 'AMZZZZ'

-- date historique
declare @date_historique date = DATEADD(DD, -365, CAST(CURRENT_TIMESTAMP AS DATE));

select top 10000
'Client actif' as 'Type de Compte', -- client actif ?
ttdsls401500.t_ofbp as 'Code client', -- tiers acheteur
ttccom100500_ofbp.t_nama as 'Nom du compte', -- description tiers acheteur
ttccom100500_ofbp.t_lgid as 'Siret', -- N° Registre du Commerce
-- ttcmcs044500.t_dsca, -- Groupe statistique
isnull(ttipcf110500.t_dsca,'') as 'Produit', -- Options par caractéristique du produit et article configurable pour l'option typetransfo
iif(left(ttdsls400500.t_cofc,2)='AL' or left(ttdsls400500.t_cofc,2)='AM','GIFACOLLET',ttdsls400500.t_cofc) as 'Carrossier', -- Service des ventes
isnull(iif(convert(char(10),twhinh430500.t_pdat,103)='01/01/1970','',convert(char(10),twhinh430500.t_pdat,103)),'') as 'Date de livraison', -- date d'impression du bon de livraison
iif(convert(char(10),ttdsls400500.t_cdf_bcdt,103)='01/01/1970','',convert(char(10),ttdsls400500.t_cdf_bcdt,103)) as 'Date de commande', -- date de signature du Bon de commande
'' as 'Durée de financement', -- cdf à créer sur LN
dbo.convertenum('zg','B61C','a9','bull','type.fin',ttdsls401500.t_typf,'4') as 'Type de financement', -- type de financement
ttccom100500_pfbp.t_nama as 'Nom de la société de financement (facturé)', -- description tiers payeur
isnull(tbpmdm001500_osrp.t_mail,'') as 'Gestionnaire de Parc', -- mail du représentant externe
'' as  'Type de véhicule', -- 
ttdsls401500.t_orno as 'N° OLG', -- commande
ttdsls401500.t_corn as 'commande du client', -- commande du client
ttdsls401500.t_serl as 'N° Châssis', -- Numéro de série
'Actif' as 'Véhicule', -- véhicule plus utilisé ?
isnull(ttcmcs062500.t_dsca,'') as 'Détail du produit', -- classe de produits, révupérer type sur le châssis ?
iif(ttdsls400500.t_oamt<0.1,'0',ttdsls400500.t_oamt) as 'Montant HT', -- total hors taxe de la commande, TVA à récupérer et ajouter
ttdsls400500.t_cbrn as 'Secteur d''activité', -- Secteur d'activité
iif(ttdsls400500.t_oamt<0.1,'1',ttdsls401500.t_clyn) as 'Annulé ?' -- statut de la ligne n'est pas annulée, oui/non, on ne prend que les lignes facturées donc pas d'annulation mais des avoirs
-- tests
-- ,SUBSTRING(ttdsls401500.t_item,10,21)
from ttdsls401500 -- Lignes de commande client
left join ttdsls411500 on ttdsls411500.t_orno = ttdsls401500.t_orno and ttdsls411500.t_pono = ttdsls401500.t_pono and ttdsls411500.t_sqnb = 0 -- données articles des lignes de commande
left join ttcmcs044500 on ttcmcs044500.t_csgp = ttdsls411500.t_csgs -- Groupes statistiques
left join ttcmcs062500 on ttcmcs062500.t_cpcl = ttdsls411500.t_cpcl -- Classe de produits
left join ttccom100500 as ttccom100500_ofbp on ttccom100500_ofbp.t_bpid = ttdsls401500.t_ofbp -- Tiers acheteur
left join ttdsls400500 on ttdsls400500.t_orno = ttdsls401500.t_orno -- Commande client
left join ttccom100500 as ttccom100500_pfbp on ttccom100500_pfbp.t_bpid = ttdsls400500.t_pfbp -- Tiers payeur
left join ttccom001500 as ttccom001500_crep on ttccom001500_crep.t_emno = ttdsls400500.t_crep -- Employés pour Représentant interne
left join ttccom001500 as ttccom001500_osrp on ttccom001500_osrp.t_emno = ttdsls400500.t_osrp -- Employés pour Représentant externe
left join tbpmdm001500 as tbpmdm001500_osrp on tbpmdm001500_osrp.t_emno = ttdsls400500.t_osrp -- Employés - Données du personnel (BP) pour Représentant externe
left join ttccom130500 on ttccom130500.t_cadr = ttdsls401500.t_stad -- Adresses
left join ttdsls406500 on ttdsls406500.t_orno = ttdsls401500.t_orno and ttdsls406500.t_pono = ttdsls401500.t_pono and ttdsls406500.t_sqnb = ttdsls401500.t_sqnb -- Lignes de livraison de cmde client réelles
left join twhinh430500 on twhinh430500.t_shpm = ttdsls406500.t_shpm -- Expéditions
left join ttdsls401500 as ttdsls401500_DIFFERENTIEL on ttdsls401500_DIFFERENTIEL.t_orno=ttdsls401500.t_orno and ttdsls401500_DIFFERENTIEL.t_item='         DIFFERENTIEL' -- Lignes de commande client, article DIFFERENTIEL
left join ttipcf520500 on ttipcf520500.t_cpva = ttdsls401500.t_cpva and ttipcf520500.t_cpft='typetransfo' -- Options de variantes de produits
left join ttipcf500500 on ttipcf500500.t_cpva = ttdsls401500.t_cpva -- Codes Variante de produit
left join ttipcf110500 on ttipcf110500.t_copt = ttipcf520500.t_copt and ttipcf110500.t_cpft = ttipcf520500.t_cpft and ttipcf110500.t_item = ttipcf500500.t_item -- Options par caractéristique du produit et article configurable
where
ttdsls400500.t_cofc between @ue_f and @ue_t										-- unité d'entreprise/service des ventes
and ttdsls401500.t_pono between 10 and 10									    -- numéros de lignes
and ttdsls406500.t_invd > @date_historique										-- facture récente
and ttdsls401500.t_qoor > 0													    -- la quantité est au moins 1 pour supprimer les avoirs
-- critères pour test
-- and ttdsls401500.t_orno in ('AM3200034','','')
-- and ttdsls400500.t_hdst = 30
-- and convert(char(10),twhinh430500.t_pdat,103)='01/01/1970'
-- and ttdsls401500.t_clyn = 1