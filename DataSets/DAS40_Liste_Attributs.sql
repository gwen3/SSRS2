-------------------------------------------------------------
-- DAS40 Liste Attributs Tiers
-------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select t_cfea as Code,
t_labl as Description,
concat(t_cfea,'  ',t_labl) as Affichage
from ttdsmi050500) --Attributs
--union 
--(select ' SsAttr' as Code,
--'SANS ATTRIBUT' as Description,
--'SANS ATTRIBUT' as Affichage)
order by 1
