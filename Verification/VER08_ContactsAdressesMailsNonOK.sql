-------------------------------------------
-- VER08 - Contacts Adresses Mails Non OK
-------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select contier.t_bpid as Tiers, 
tier.t_nama as NomTiers, 
contact.t_ccnt as Contact, 
contact.t_fuln as NomContact, 
contact.t_info as Mail 
from ttccom140500 contact --Contact
inner join ttccom145500 contier on contier.t_ccnt = contact.t_ccnt --Contact par Tiers
inner join ttccom100500 tier on tier.t_bpid = contier.t_bpid --Tiers
where t_info = '' 
or contact.t_info not like '%@%.%' 
or contact.t_info not like '%@%' 
or contact.t_info not like '%.%' 
or contact.t_info like '% %';
