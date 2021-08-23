-----------------------------------------
-- FIN09 En-Cours Tiers Facturant
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--
--Grand Laval
--
(select
'500' as SocFin
,enctf.t_ttyp as Journal
,enctf.t_ninv as Document
,enctf.t_line as Ligne
,enctf.t_tdoc as Document2
,enctf.t_lino as Ligne2
,enctf.t_ifbp as Tiers_Facturant
,tiers.t_nama as Nom_Tiers
,dbo.convertenum('tc','B61C','a9','bull','bprl',tiers.t_bprl,'4') as Role_Tiers
,dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as Statut_Tiers_Facturant
,enctf.t_isup as NumFactFour
,enctf.t_docd as DateDocument
,dbo.convertenum('tf','B61U','a','stnd','acp.tpay',enctf.t_tpay,'4') as Type_Document
,dbo.convertenum('tf','B61U','a','stnd','acp.stap',enctf.t_stap,'4') as Statut_Facture
,dbo.convertenum('tf','B61U','a','stnd','acp.inv',enctf.t_appr,'4') as RapprocherCde
,enctf.t_orno as Commande
,enctf.t_dued as DateEcheance
,enctf.t_amnt as MontantDevise
,enctf.t_ccur as Devise
--
-- Recherche si PJ pour le document/facture
--
,(case
	when exists(select top 1 lienobj.t_trid				
				from tdmcom010500 lienobj
				--left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
				--inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
				--inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
				where lienobj.t_trtp like 'PURCHASE INVOICE' and lienobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%'))
	then 'Oui'
	else 'Non'
end) as PJ
--
from ttfacp200500 enctf -- En-Cours Tiers Facturant 
inner join ttccom100500 tiers on tiers.t_bpid = enctf.t_ifbp --Tiers 
where
'500' in (@stefin)
and enctf.t_stap <= '2' -- 1 = Enregistré - 2 = Ecritures saisies
--and enctf.t_tpay in ('1', '4')
and enctf.t_ttyp between @ttyp_f and @ttyp_t
and enctf.t_docd between @docd_f and @docd_t
and enctf.t_ifbp between @ifbp_f and @ifbp_t
--
-- Tiers avec/sans PJ
and (('1' in (@tfpj) and '2' in (@tfpj)) 
	or ('1' in (@tfpj) and '2' not in (@tfpj) and 
		(case
			when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
			then '1'
			else '0'
		end) > 0)
	or ('2' in (@tfpj) and '1' not in (@tfpj) and
		(case
		when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
		then '1'
		else '0'
		end) = 0))
)
union all
--
--Labbé
--
(select
'400' as SocFin
,enctf.t_ttyp as Journal
,enctf.t_ninv as Document
,enctf.t_line as Ligne
,enctf.t_tdoc as Document2
,enctf.t_lino as Ligne2
,enctf.t_ifbp as Tiers_Facturant
,tiers.t_nama as Nom_Tiers
,dbo.convertenum('tc','B61C','a9','bull','bprl',tiers.t_bprl,'4') as Role_Tiers
,dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as Statut_Tiers_Facturant
,enctf.t_isup as NumFactFour
,enctf.t_docd as DateDocument
,dbo.convertenum('tf','B61U','a','stnd','acp.tpay',enctf.t_tpay,'4') as Type_Document
,dbo.convertenum('tf','B61U','a','stnd','acp.stap',enctf.t_stap,'4') as Statut_Facture
,dbo.convertenum('tf','B61U','a','stnd','acp.inv',enctf.t_appr,'4') as RapprocherCde
,enctf.t_orno as Commande
,enctf.t_dued as DateEcheance
,enctf.t_amnt as MontantDevise
,enctf.t_ccur as Devise
--
-- Recherche si PJ pour le document/facture
--
,(case
	when exists(select top 1 lienobj.t_trid				
				from tdmcom010500 lienobj
				--left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
				--inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
				--inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
				where lienobj.t_trtp like 'PURCHASE INVOICE' and lienobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%'))
	then 'Oui'
	else 'Non'
end) as PJ
--
from ttfacp200400 enctf -- En-Cours Tiers Facturant 
inner join ttccom100500 tiers on tiers.t_bpid = enctf.t_ifbp --Tiers 
where
'400' in (@stefin)
and enctf.t_stap <= '2' -- 1 = Enregistré - 2 = Ecritures saisies
--and enctf.t_tpay in ('1', '4')
and enctf.t_ttyp between @ttyp_f and @ttyp_t
and enctf.t_docd between @docd_f and @docd_t
and enctf.t_ifbp between @ifbp_f and @ifbp_t
--
-- Tiers avec/sans PJ
and (('1' in (@tfpj) and '2' in (@tfpj)) 
	or ('1' in (@tfpj) and '2' not in (@tfpj) and 
		(case
			when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
			then '1'
			else '0'
		end) > 0)
	or ('2' in (@tfpj) and '1' not in (@tfpj) and
		(case
		when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
		then '1'
		else '0'
		end) = 0))
)
union all
--
--GIFA
--
(select
'600' as SocFin
,enctf.t_ttyp as Journal
,enctf.t_ninv as Document
,enctf.t_line as Ligne
,enctf.t_tdoc as Document2
,enctf.t_lino as Ligne2
,enctf.t_ifbp as Tiers_Facturant
,tiers.t_nama as Nom_Tiers
,dbo.convertenum('tc','B61C','a9','bull','bprl',tiers.t_bprl,'4') as Role_Tiers
,dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as Statut_Tiers_Facturant
,enctf.t_isup as NumFactFour
,enctf.t_docd as DateDocument
,dbo.convertenum('tf','B61U','a','stnd','acp.tpay',enctf.t_tpay,'4') as Type_Document
,dbo.convertenum('tf','B61U','a','stnd','acp.stap',enctf.t_stap,'4') as Statut_Facture
,dbo.convertenum('tf','B61U','a','stnd','acp.inv',enctf.t_appr,'4') as RapprocherCde
,enctf.t_orno as Commande
,enctf.t_dued as DateEcheance
,enctf.t_amnt as MontantDevise
,enctf.t_ccur as Devise
--
-- Recherche si PJ pour le document/facture
--
,(case
	when exists(select top 1 lienobj.t_trid				
				from tdmcom010500 lienobj
				--left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
				--inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
				--inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
				where lienobj.t_trtp like 'PURCHASE INVOICE' and lienobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%'))
	then 'Oui'
	else 'Non'
end) as PJ
--
from ttfacp200600 enctf -- En-Cours Tiers Facturant 
inner join ttccom100500 tiers on tiers.t_bpid = enctf.t_ifbp --Tiers 
where
'600' in (@stefin)
and enctf.t_stap <= '2' -- 1 = Enregistré - 2 = Ecritures saisies
--and enctf.t_tpay in ('1', '4')
and enctf.t_ttyp between @ttyp_f and @ttyp_t
and enctf.t_docd between @docd_f and @docd_t
and enctf.t_ifbp between @ifbp_f and @ifbp_t
--
-- Tiers avec/sans PJ
and (('1' in (@tfpj) and '2' in (@tfpj)) 
	or ('1' in (@tfpj) and '2' not in (@tfpj) and 
		(case
			when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
			then '1'
			else '0'
		end) > 0)
	or ('2' in (@tfpj) and '1' not in (@tfpj) and
		(case
		when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
		then '1'
		else '0'
		end) = 0))
)
union all
--
--Petit-Picot
--
(select
'610' as SocFin
,enctf.t_ttyp as Journal
,enctf.t_ninv as Document
,enctf.t_line as Ligne
,enctf.t_tdoc as Document2
,enctf.t_lino as Ligne2
,enctf.t_ifbp as Tiers_Facturant
,tiers.t_nama as Nom_Tiers
,dbo.convertenum('tc','B61C','a9','bull','bprl',tiers.t_bprl,'4') as Role_Tiers
,dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as Statut_Tiers_Facturant
,enctf.t_isup as NumFactFour
,enctf.t_docd as DateDocument
,dbo.convertenum('tf','B61U','a','stnd','acp.tpay',enctf.t_tpay,'4') as Type_Document
,dbo.convertenum('tf','B61U','a','stnd','acp.stap',enctf.t_stap,'4') as Statut_Facture
,dbo.convertenum('tf','B61U','a','stnd','acp.inv',enctf.t_appr,'4') as RapprocherCde
,enctf.t_orno as Commande
,enctf.t_dued as DateEcheance
,enctf.t_amnt as MontantDevise
,enctf.t_ccur as Devise
--
-- Recherche si PJ pour le document/facture
--
,(case
	when exists(select top 1 lienobj.t_trid				
				from tdmcom010500 lienobj
				--left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
				--inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
				--inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
				where lienobj.t_trtp like 'PURCHASE INVOICE' and lienobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%'))
	then 'Oui'
	else 'Non'
end) as PJ
--
from ttfacp200610 enctf -- En-Cours Tiers Facturant 
inner join ttccom100500 tiers on tiers.t_bpid = enctf.t_ifbp --Tiers 
where
'610' in (@stefin)
and enctf.t_stap <= '2' -- 1 = Enregistré - 2 = Ecritures saisies
--and enctf.t_tpay in ('1', '4')
and enctf.t_ttyp between @ttyp_f and @ttyp_t
and enctf.t_docd between @docd_f and @docd_t
and enctf.t_ifbp between @ifbp_f and @ifbp_t
--
-- Tiers avec/sans PJ
and (('1' in (@tfpj) and '2' in (@tfpj)) 
	or ('1' in (@tfpj) and '2' not in (@tfpj) and 
		(case
			when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
			then '1'
			else '0'
		end) > 0)
	or ('2' in (@tfpj) and '1' not in (@tfpj) and
		(case
		when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
		then '1'
		else '0'
		end) = 0))
)
union all
--
--Sanicar/Ducarme
--
(select
'620' as SocFin
,enctf.t_ttyp as Journal
,enctf.t_ninv as Document
,enctf.t_line as Ligne
,enctf.t_tdoc as Document2
,enctf.t_lino as Ligne2
,enctf.t_ifbp as Tiers_Facturant
,tiers.t_nama as Nom_Tiers
,dbo.convertenum('tc','B61C','a9','bull','bprl',tiers.t_bprl,'4') as Role_Tiers
,dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as Statut_Tiers_Facturant
,enctf.t_isup as NumFactFour
,enctf.t_docd as DateDocument
,dbo.convertenum('tf','B61U','a','stnd','acp.tpay',enctf.t_tpay,'4') as Type_Document
,dbo.convertenum('tf','B61U','a','stnd','acp.stap',enctf.t_stap,'4') as Statut_Facture
,dbo.convertenum('tf','B61U','a','stnd','acp.inv',enctf.t_appr,'4') as RapprocherCde
,enctf.t_orno as Commande
,enctf.t_dued as DateEcheance
,enctf.t_amnt as MontantDevise
,enctf.t_ccur as Devise
--
-- Recherche si PJ pour le document/facture
--
,(case
	when exists(select top 1 lienobj.t_trid				
				from tdmcom010500 lienobj
				--left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
				--inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
				--inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
				where lienobj.t_trtp like 'PURCHASE INVOICE' and lienobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%'))
	then 'Oui'
	else 'Non'
end) as PJ
--
from ttfacp200620 enctf -- En-Cours Tiers Facturant 
inner join ttccom100500 tiers on tiers.t_bpid = enctf.t_ifbp --Tiers 
where
'620' in (@stefin)
and enctf.t_stap <= '2' -- 1 = Enregistré - 2 = Ecritures saisies
--and enctf.t_tpay in ('1', '4')
and enctf.t_ttyp between @ttyp_f and @ttyp_t
and enctf.t_docd between @docd_f and @docd_t
and enctf.t_ifbp between @ifbp_f and @ifbp_t
--
-- Tiers avec/sans PJ
and (('1' in (@tfpj) and '2' in (@tfpj)) 
	or ('1' in (@tfpj) and '2' not in (@tfpj) and 
		(case
			when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
			then '1'
			else '0'
		end) > 0)
	or ('2' in (@tfpj) and '1' not in (@tfpj) and
		(case
		when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
		then '1'
		else '0'
		end) = 0))
)
union all
--
--Le Mans
--
(select
'300' as SocFin
,enctf.t_ttyp as Journal
,enctf.t_ninv as Document
,enctf.t_line as Ligne
,enctf.t_tdoc as Document2
,enctf.t_lino as Ligne2
,enctf.t_ifbp as Tiers_Facturant
,tiers.t_nama as Nom_Tiers
,dbo.convertenum('tc','B61C','a9','bull','bprl',tiers.t_bprl,'4') as Role_Tiers
,dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as Statut_Tiers_Facturant
,enctf.t_isup as NumFactFour
,enctf.t_docd as DateDocument
,dbo.convertenum('tf','B61U','a','stnd','acp.tpay',enctf.t_tpay,'4') as Type_Document
,dbo.convertenum('tf','B61U','a','stnd','acp.stap',enctf.t_stap,'4') as Statut_Facture
,dbo.convertenum('tf','B61U','a','stnd','acp.inv',enctf.t_appr,'4') as RapprocherCde
,enctf.t_orno as Commande
,enctf.t_dued as DateEcheance
,enctf.t_amnt as MontantDevise
,enctf.t_ccur as Devise
--
-- Recherche si PJ pour le document/facture
--
,(case
	when exists(select top 1 lienobj.t_trid				
				from tdmcom010500 lienobj
				--left outer join tdmdoc110500 docs on docs.t_dcid = substring(lienobj.t_srid,3,10) and docs.t_type = substring(lienobj.t_srid,38,7)
				--inner join tdmdoc430500 verfic on verfic.t_dcid = docs.t_dcid
				--inner join tdmdoc420500 nomfic on nomfic.t_fnid = verfic.t_fnid
				where lienobj.t_trtp like 'PURCHASE INVOICE' and lienobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%'))
	then 'Oui'
	else 'Non'
end) as PJ
--
from ttfacp200300 enctf -- En-Cours Tiers Facturant 
inner join ttccom100500 tiers on tiers.t_bpid = enctf.t_ifbp --Tiers 
where
'300' in (@stefin)
and enctf.t_stap <= '2' -- 1 = Enregistré - 2 = Ecritures saisies
--and enctf.t_tpay in ('1', '4')
and enctf.t_ttyp between @ttyp_f and @ttyp_t
and enctf.t_docd between @docd_f and @docd_t
and enctf.t_ifbp between @ifbp_f and @ifbp_t
--
-- Tiers avec/sans PJ
and (('1' in (@tfpj) and '2' in (@tfpj)) 
	or ('1' in (@tfpj) and '2' not in (@tfpj) and 
		(case
			when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
			then '1'
			else '0'
		end) > 0)
	or ('2' in (@tfpj) and '1' not in (@tfpj) and
		(case
		when (exists(select top 1 lobj.t_trid				
						from tdmcom010500 lobj
						where lobj.t_trtp like 'PURCHASE INVOICE' and lobj.t_trid like concat('{"',enctf.t_ttyp,'",',enctf.t_ninv, ',',enctf.t_line,',%')))
		then '1'
		else '0'
		end) = 0))
)