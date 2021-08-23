--------------------------------
-- DAS36 - Liste Centre Charge
--------------------------------

select cc.t_cwoc as Code
,cc.t_dsca as Description
,concat(cc.t_cwoc, ' ', cc.t_dsca) as Affichage
from ttirou001500 cc