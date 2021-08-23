-- extraction des donn�es de mise � la route, de transport, de financement et d'homologation pour suivre les t�ches du commerce sur les commandes
-- 27/09/2017 cr�ation
-- 13/02/2018 modification du crit�re pour ne prendre que la ligne 10
-- 20/02/2018 ajout des champs : repr�sentant interne, N� de s�rie, Tiers payeur et sa description,
--            ajout des CDF concession MAR et Transport
--            ajout du crit�re ligne non ferm�e
--            date souhait�e client � vide si non renseign�e
--            filtre avances client
-- 12/03/2018 passage du SSRS dans administration avec rapport li� pour les sites, ajout des varialbles @ue_f et @ue_t
-- 21/03/2018 correction des dates cerfa et immat qui affichaient la date t_drti si non vide !
-- 29/10/2018 ajout des champs, Date d'arriv�e pr�vue du chassis, DIFFERENTIEL, Besoin financement, Type de financement et Impression Bon Exp
-- 31/10/2018 certaines dates au 01/01/1970 pour le BL
-- 19/11/2018 ne plus filtrer par le statut ferm� uniquement, les conserver dans l'extraction si le BL date de moins de 15 jours (ajout de @date_historique_BL)

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- variables pour tests
/*
declare @ue_f char(6) = 'AL'
declare @ue_t char(6) = 'AMZZZZ'
*/
-- date historique
declare @date_historique_BL date = DATEADD(DD, -15, CAST(CURRENT_TIMESTAMP AS DATE));

select top 10000
ttdsls401500.t_orno as commande, -- commande
ttdsls401500.t_ofbp as 'tiers acheteur', -- tiers acheteur
ttccom100500_ofbp.t_nama as 'description tiers acheteur', -- description tiers acheteur
ttdsls401500.t_corn as 'commande du client', -- commande du client
isnull(ttccom001500_crep.t_nama,'') as 'repr�sentant interne', -- repr�sentant interne
isnull(ttccom001500_osrp.t_nama,'') as 'repr�sentant externe', -- repr�sentant externe
iif(convert(char(10),ttdsls401500.t_dapc,103)='01/01/1970','',convert(char(10),ttdsls401500.t_dapc,103)) as 'date d�arriv�e pr�vue du ch�ssis', -- Date d�arriv�e pr�vue du ch�ssis
convert(char(10),ttdsls401500.t_ddta,103) as 'date de production GRUAU (Date de livraison planifi�e)', -- date de production GRUAU (Date de livraison planifi�e)
convert(char(10),ttdsls401500.t_prdt,103) as 'date MADC pr�vue (Date de r�c. planif.)', -- date MADC pr�vue (Date de r�c. planif.)
iif(convert(char(10),ttdsls401500.t_dlsc,103)='01/01/1970','',convert(char(10),ttdsls401500.t_dlsc,103)) as 'date de livraison souhait�e client', -- date de livraison souhait�e client
ttccom130500.t_nama as 'nom de l''adresse de livraison', -- nom de l'adresse de livraison
ttdsls401500.t_cdec as 'condition de livraison', -- condition de livraison
iif(ttdsls401500.t_tcar=1,'Certificat de carrossage',
	iif(ttdsls401500.t_trti=1,'RTI',
	iif(ttdsls401500.t_rces=1, 'RCE',''))) as 'homologation', -- homologation
iif(convert(char(10),ttdsls401500.t_drti,103)='01/01/1970','',convert(char(10),ttdsls401500.t_drti,103)) as 'date de RTI', -- date de RTI
dbo.convertenum('tc','B61C','a9','bull','yesno',ttdsls401500.t_cdf_mrdt,'4') as 'Mise � la route (MAR) ?', -- Mise � la route (MAR) ?
ttdsls401500.t_cdf_comr as 'Concession pour MAR', -- Concession pour MAR
ttdsls401500.t_cdf_tran as 'Transport', -- Transport
iif(ttdsls401500_DIFFERENTIEL.t_pono>0,'oui','') as 'DIFFERENTIEL', -- Article DIFFERENTIEL dans les lignes de la commande
ttdsls401500.t_serl as 'N� de s�rie', -- Num�ro de s�rie
isnull(convert(char(10),ttdsls406500.t_dldt,103),'') as 'date de livraison r�elle', -- date de livraison r�elle
iif(convert(char(10),ttdsls401500.t_cdf_cedt,103)='01/01/1970','',convert(char(10),ttdsls401500.t_cdf_cedt,103)) as 'Cerfa demand� ?', -- Cerfa demand� ?
iif(convert(char(10),ttdsls401500.t_cdf_didt,103)='01/01/1970','',convert(char(10),ttdsls401500.t_cdf_didt,103)) as 'Doc. immat. envoy�s ?', -- Doc. immat. envoy�s ?
dbo.convertenum('tc','B61C','a9','bull','yesno',ttdsls401500.t_bfin,'4') as 'besoin de financement', -- besoin de financement
dbo.convertenum('zg','B61C','a9','bull','type.fin',ttdsls401500.t_typf,'4') as 'type de financement', -- type de financement
isnull(iif(convert(char(10),twhinh430500.t_pdat,103)='01/01/1970','',convert(char(10),twhinh430500.t_pdat,103)),'') as 'date d�impression du bon de livraison', -- date d'impression du bon de livraison
isnull(convert(char(10),ttdsls406500.t_invd,103),'') as 'date de la facture', -- date de la facture
ttdsls400500.t_pfbp as 'Tiers Payeur', -- Tier payeur
ttccom100500_pfbp.t_nama as 'description tiers payeur', -- description tiers payeur
--Rajout par rbesnier le 24/05/2019 suite au ticket
(select top 1 cha.t_rdat from twhltc500500 cha where cha.t_item = '         CHASSIS' and cha.t_serl = ttdsls401500.t_serl and cha.t_cwar = ttdsls401500.t_cwar order by cha.t_rdat desc) as DateArriveeChassis --On prend la date la plus r�cente
from ttdsls401500 -- Lignes de commande client
left join ttdsls411500 on ttdsls411500.t_orno = ttdsls401500.t_orno and ttdsls411500.t_pono = ttdsls401500.t_pono and ttdsls411500.t_sqnb = 0 -- donn�es articles des lignes de commande
left join ttccom100500 as ttccom100500_ofbp on ttccom100500_ofbp.t_bpid = ttdsls401500.t_ofbp -- Tiers acheteur
left join ttdsls400500 on ttdsls400500.t_orno = ttdsls401500.t_orno -- Commande client
left join ttccom100500 as ttccom100500_pfbp on ttccom100500_pfbp.t_bpid = ttdsls400500.t_pfbp -- Tiers payeur
left join ttccom001500 as ttccom001500_crep on ttccom001500_crep.t_emno = ttdsls400500.t_crep -- Employ�s pour Repr�sentant interne
left join ttccom001500 as ttccom001500_osrp on ttccom001500_osrp.t_emno = ttdsls400500.t_osrp -- Employ�s pour Repr�sentant externe
left join ttccom130500 on ttccom130500.t_cadr = ttdsls401500.t_stad -- Adresses
left join ttdsls406500 on ttdsls406500.t_orno = ttdsls401500.t_orno and ttdsls406500.t_pono = ttdsls401500.t_pono and ttdsls406500.t_sqnb = ttdsls401500.t_sqnb -- Lignes de livraison de cmde client r�elles
left join twhinh430500 on twhinh430500.t_shpm = ttdsls406500.t_shpm -- Exp�ditions
left join ttdsls401500 as ttdsls401500_DIFFERENTIEL on ttdsls401500_DIFFERENTIEL.t_orno=ttdsls401500.t_orno and ttdsls401500_DIFFERENTIEL.t_item='         DIFFERENTIEL' -- Lignes de commande client, article DIFFERENTIEL
where
ttdsls400500.t_cofc between @ue_f and @ue_t										-- unit� d'entreprise/service des ventes
-- and (ttdsls401500.t_tcar=1 or ttdsls401500.t_trti=1 or ttdsls401500.t_rces=1)-- homologation renseign�e
and ttdsls401500.t_pono between 10 and 10									    -- num�ros de lignes
-- and ttdsls411500.t_citg between 'DAT001' and 'EBT002'						-- groupe article de transfo
and ttdsls401500.t_clyn <> 1													-- la ligne n'est pas annul�e
and (ttdsls400500.t_hdst <> 30													-- la commande n'est pas ferm�e
or twhinh430500.t_pdat > @date_historique_BL									-- ou le BL est r�cent
or convert(char(10),twhinh430500.t_pdat,103)='01/01/1970')						-- ou le BL n'est pas n'est pas imprim�
and ttdsls401500.t_qoor > 0													    -- la quantit� est au moins 1 pour supprimer les avoirs
and ttdsls401500.t_ofbp <> '100005506'											-- le tiers n'est pas "*** avance client"
-- crit�res pour test
-- and ttdsls401500.t_orno in ('AL5300103','','')
-- and ttdsls400500.t_hdst = 30
-- and convert(char(10),twhinh430500.t_pdat,103)='01/01/1970'

