------------------------------------------
-- DAS23 - Statut Commandes Fournisseurs
------------------------------------------

select distinct list.t_cnst as Code
,label.t_desc as Description
,concat(list.t_cnst, ' - ', label.t_desc) as Affichage
from tttadv401000 list 
inner join tttadv140000 label on label.t_cpac = list.t_cpac and label.t_clab = list.t_za_clab and label.t_vers = list.t_vers and label.t_rele = list.t_rele and label.t_cust = list.t_cust 
where label.t_clan = '4' --Choix de la Langue
and list.t_cpac = 'td' --Choix de l'application
and list.t_cdom = 'pur.hdst' --Choix du Domaine