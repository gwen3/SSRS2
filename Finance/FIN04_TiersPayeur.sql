-------------------------
-- FIN04 - Tiers Payeur
-------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select tierspay.t_pfbp as TiersPayeur
,tiers.t_nama as NomTiers
,dbo.convertenum('tc','B61C','a9','bull','com.bpst',tierspay.t_bpst,'4') as StatutTiersPayeur
,dbo.convertenum('tc','B61C','a9','bull','com.prst',tiers.t_prst,'4') as StatutTiers
,contacttiers.t_ccnt as ContactPrincipalTiersPayeur
,contact.t_fuln as NomContactPrincipalTiersPayeur
,contact.t_info as MailContactPrincipalTiersPayeur
from ttccom114500 tierspay --Tiers Payeur
left outer join ttccom100500 tiers on tiers.t_bpid = tierspay.t_pfbp --Tiers
left outer join ttccom145500 contacttiers on contacttiers.t_ccnt = tierspay.t_ccnt and contacttiers.t_bpid = tierspay.t_pfbp and contacttiers.t_ctpr_4 = 1 --Contact par Tiers Payeur, on prend le contact principal à oui pour le tiers payeur
left outer join ttccom140500 contact on contact.t_ccnt = contacttiers.t_ccnt --Contact
where tierspay.t_bpst in (@statpay)
and tiers.t_prst in (@stattiers)
order by tierspay.t_pfbp