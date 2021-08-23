----------------------------------
-- GEN04 - Controle des Contacts
----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 'Tiers Avec Contacts' as Source, 
contier.t_bpid as Tiers, 
tier.t_nama as NomTiers, 
contact.t_ccnt as Contact, 
contact.t_fuln as NomContact, 
contact.t_info as Mail, 
contier.t_cmsk_1 as CodeRoleContactTiersAcheteur, 
contier.t_cmsk_5 as CodeRoleContactTiersVendeur, 
dbo.convertenum('tc','B61C','a9','bull','yesno',contier.t_cmsk_1,'4') as RoleContactTiersAcheteur, 
dbo.convertenum('tc','B61C','a9','bull','yesno',contier.t_cmsk_5,'4') as RoleContactTiersVendeur, 
cat.t_cctg as CategorieContact, 
(case 
when contact.t_info = '' 
	then 'Pas de Mail Renseigne' 
when contact.t_info not like '%@%.%' 
	then 'Mauvais Format de Mail' 
when contact.t_info not like '%@%' 
	then 'Manque un @' 
when contact.t_info not like '%.%' 
	then 'Manque un Point' 
when contact.t_info like '% %' 
	then 'Contient un Espace' 
else 
	'OK' 
end) as ProblemeContact,
contact.t_crus as Createur,
dut.t_name as NomCreateur,
contact.t_crdt as DateCreation
from ttccom140500 contact --Contact
inner join ttccom145500 contier on contier.t_ccnt = contact.t_ccnt --Contact par Tiers
inner join ttccom100500 tier on tier.t_bpid = contier.t_bpid --Tiers
left outer join ttccom141500 cat on cat.t_ccnt = contact.t_ccnt --Catégorie de Contacts
inner join tttaad200000 dut on dut.t_user = contact.t_crus
where tier.t_prst = 2 --On prend les tiers actifs
and tier.t_bprl in (@role) --On borne sur les rôles, pouvoir choisir client, fournisseur et les 2
) union all
--Requete pour récupérer les tiers qui n'ont pas de contacts
(select 'Tiers Sans Contacts' as Source, 
tier.t_bpid as Tiers, 
tier.t_nama as NomTiers, 
'' as Contact, 
'' as NomContact, 
'' as Mail, 
'' as CodeRoleContactTiersAcheteur, 
'' as CodeRoleContactTiersVendeur, 
'Non' as RoleContactTiersAcheteur, 
'Non' as RoleContactTiersVendeur, 
'' as CategorieContact, 
'' as ProblemeContact, 
'' as Createur,
'' as NomCreateur,
'' as DateCreation
from ttccom100500 tier --Tiers
where tier.t_prst = 2 --On prend les tiers actifs
and tier.t_bprl in (@role) --On borne sur les rôles, pouvoir choisir client, fournisseur et les 2
and tier.t_bpid not in (select distinct t_bpid from ttccom145500) --On prend tous les tiers qui n'ont pas de contacts renseignés
)
--Récupérer via une autre requête tous les tiers qui n'ont pas de contacts