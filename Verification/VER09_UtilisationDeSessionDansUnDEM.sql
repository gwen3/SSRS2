------------------------------------------------
-- VER09 - Utilisation de Sessions dans un DEM
------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select uti.t_user as Utilisateur, 
uti.t_role as Role, 
rproc.t_proc as Processus, 
process.t_desc as NomProcessus, 
aproc.t_pono as Position, 
aproc.t_desc as NomActivite, 
aproc.t_acco as Application, 
aproc.t_argu as Argument, 
aproc.t_auth as AutorisationApplication
from ttgbrg820500 uti --Roles par Employes
inner join ttgbrg506500 rproc on rproc.t_vers = uti.t_vers and rproc.t_role = uti.t_role --Roles par Processus
inner join ttgbrg520500 aproc on aproc.t_proc = rproc.t_proc and aproc.t_prov = rproc.t_vers --Activite des Processus
inner join ttgbrg500500 process on process.t_proc = rproc.t_proc and process.t_vers = uti.t_vers --Processus
where aproc.t_acco between @applic_f and @applic_t 
and aproc.t_argu between @argu_f and @argu_t