----------------------------------------------------
-- MDM12 Ctrl adresses destinataires pour Extranet
----------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select desta.t_ofbp as Code_Tiers
,tiers.t_nama as Nom_Tiers
,desta.t_stbp as Tiers_Destinataire
,tiersd.t_nama as Nom_Tiers_Dest
,dbo.convertenum('tc','B61C','a9','bull','com.bpst',destt.t_bpst,'4') as Statut_Tiers_Dest
,tiersd.t_lmdt as Date_Mod_Tiers_Dest
--,tiersd.t_lmus as Util_Mod_Tiers_Dest
,utilt.t_name as Tiers_Modifie_Par
,destt.t_lmdt as Date_Mod_Dest
--,destt.t_lmus as Util_Mod_Dest
,utild.t_name as Tiers_Dest_Modifie_Par
,tiersd.t_cdf_exep as Exception
from ttccom117500 desta
inner join ttccom100500 tiers on tiers.t_bpid = desta.t_ofbp --Tiers (pour tiers acheteur)
inner join ttccom100500 tiersd on tiersd.t_bpid = desta.t_stbp --Tiers  (pour tiers destinataire)
inner join ttccom111500 destt on destt.t_stbp = desta.t_stbp --Tiers destinataire
left outer join tttaad200000 utilt on utilt.t_user = tiersd.t_lmus --Utilisateurs (pour tiers)
left outer join tttaad200000 utild on utild.t_user = destt.t_lmus --Utilisateurs (pour tiers destinatire)
where desta.t_ofbp between @tiersa_f and @tiersa_t --Bornage tiers acheteur
and desta.t_stbp between @tiersd_f and @tiersd_t --Bornage tiers destinataire