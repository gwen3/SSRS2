-------------------------------
-- DAS25 - Statut Traçabilité
-------------------------------

select distinct traca.t_stat as Code
,dbo.convertenum('br','B61C','a9','bull','gru.stat',traca.t_stat,4) as Description
,concat(traca.t_stat, ' - ', dbo.convertenum('br','B61C','a9','bull','gru.stat',traca.t_stat,4)) as Affichage
from tbrgru900500 traca 