---------------------------
-- DAS34 - Liste Services
---------------------------

select serv.t_cwoc as Code
,serv.t_dsca as Description
,concat(serv.t_cwoc, ' ', serv.t_dsca) as Affichage
from ttcmcs065500 serv