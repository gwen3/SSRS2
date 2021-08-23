--------------------------------------
-- DAS35 - Liste Code Signal Article
--------------------------------------

select ' ' as Code
,' ' as Description
,' ' as Affichage
union
select sig.t_csig as Code
,sig.t_dsca as Description
,concat(sig.t_csig, ' ', sig.t_dsca) as Affichage
from ttcmcs018500 sig