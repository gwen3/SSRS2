--------------------------------
-- VER18 - DEM par Utilisateur
--------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select uti.t_user as Utilisateur
,uti.t_name as NomUtilisateur
,dememp.t_role as DEM
,demrol.t_desc as DescriptionDEM
,donemp.t_edte as DateSortieEmploye
,emp.t_cwoc as DepartementEmploye
,dep.t_dsca as NomDepartementEmploye
,left(emp.t_cwoc, 2) as SiteEmploye
from tttaad200000 uti -- Données utilisateur
left join ttgbrg820500 dememp on dememp.t_user = uti.t_user -- Employés (DEM)
left join ttgbrg810500 demrol on demrol.t_role = dememp.t_role -- Rôles (DEM)
left join ttccom001500 emp on emp.t_loco = uti.t_user -- Employés
left join tbpmdm001500 donemp on donemp.t_emno = emp.t_emno -- Données Employés
left outer join ttcmcs065500 dep on dep.t_cwoc = emp.t_cwoc -- Départements
where left(emp.t_cwoc, 2) between @ue_f and @ue_t --Bornage sur l'UE défini par le département de l'employé
and uti.t_user between @uti_f and @uti_t --Bornage sur l'utilisateur
and dememp.t_role between @dem_f and @dem_t --Bornage sur le rôle de l'utilisateur
and emp.t_cwoc between @cc_f and @cc_t --Bornage sur le Centre de Charge de l'employé
order by uti.t_user --On filtre par utilisateur
