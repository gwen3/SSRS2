-------------------------------------------------------------
-- DAS38 Mode envoi de facture
-------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select t_cidm as Code,
t_dsca as Description,
concat(t_cidm,'  ',t_dsca) as Affichage
from ttcmcs056500)
union 
(select '' as Code,
'SANS MODE ENVOI' as Description,
'    SANS MODE ENVOI' as Affichage)
order by 1
