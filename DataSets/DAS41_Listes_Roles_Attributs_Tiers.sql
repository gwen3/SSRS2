--------------------------------------------
-- DAS41 - Attributs pour Roles Tiers
--------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select code.t_cnst as Code
,libelle.t_desc as Description
,concat(code.t_cnst, ' - ', libelle.t_desc) as Affichage
from tttadv401000 code
inner join tttadv140000 libelle on libelle.t_cpac = code.t_cpac and libelle.t_clan = '4' and libelle.t_clab = code.t_za_clab and libelle.t_vers = code.t_vers and libelle.t_rele = code.t_rele
where code.t_vers = 'B61' --On va chercher la version standard
and code.t_cdom = 'smi.role' 
order by Code