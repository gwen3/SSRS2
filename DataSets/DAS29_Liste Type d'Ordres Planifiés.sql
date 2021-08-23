------------------------------------------
-- DAS29 - Liste Type d'Ordres Planifiés
------------------------------------------

select distinct list.t_type as Code
,dbo.convertenum('tc','B61C','a9','bull','koor',list.t_type,'4') as Description
,concat(list.t_type, ' - ', dbo.convertenum('tc','B61C','a9','bull','koor',list.t_type,'4')) as Affichage
from tcprrp100500 list
order by list.t_type