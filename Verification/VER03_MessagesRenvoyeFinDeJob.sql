---------------------------------------
-- VER03 - Message Renvoyé Fin de Job
---------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select t_cjob as NomJob, 
t_cpac as Application, 
t_cmod as Module, 
t_cses as Session, 
t_edte as DateImpression, 
t_mess as Message 
from tttaad512500 
where t_cjob = @job --On choisit le job 
and t_cpac = @applic --On choisit l'application
and t_cmod = @mod --On choisit le module
and t_cses = @session --On choisit la session
and t_edte between datediff(day, 1, getdate()) and getdate(); --On borne pour avoir la veille
