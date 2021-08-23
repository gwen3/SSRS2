-------------------------------------------------------------------------
-- LOG40 - Ordres MPS
-------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
set datefirst 1; -- Date de début de semaine est le lundi

select 
left(pda.t_plni, 3) as Cluster
,substring(pda.t_plni, 4, 9) as ProjetArticle 
,substring(pda.t_plni, 13, len(pda.t_plni)) as Article
,art.t_dsca as Description_Article
,art.t_csig as CodeSignal
,dbo.convertenum('tc','B61','a','','kitm',art.t_kitm,'4') as Type_Art
,dbo.convertenum('cp','B61','a','','rpd.plit',artp.t_plit,'4') as Type_Art_Plan
,pda.t_chan as CanalDistribution
,pda.t_pern as Periode
,pda.t_pdat as DateFinPer
,concat(year(pda.t_pdat),'-',right('0' + cast(datepart(week,pda.t_pdat) as varchar(2)),2)) as SemFinPer
,pda.t_sdat as DateDebPer
,pda.t_demf as PrevDemande
,pda.t_csdf as PrevDemandeConso
,pda.t_spde as DemandeSpe
,pda.t_exdt as DemandeSuppl
,pda.t_cord as CdeClients
,pda.t_unco as CdeClientsNC
,pda.t_eomd as DemandeDepProg
,pda.t_ermd as DemandeMatDep
,pda.t_eidm as DemandeDistrDep
,pda.t_ipco as DistrCdesClients
,pda.t_cdel as LivClients
,pda.t_iidl as LivDistribution
,pda.t_alde as DemandeAutorisee
,pda.t_prec as PlanProd
,pda.t_copr as ReceptCoProd
,pda.t_ppor as OFPlanif
,pda.t_pupl as PlanAchat
,pda.t_pirc as ODPlanif
,pda.t_ppur as OAPlanif
,pda.t_spur as ReceptAchatProg
,pda.t_arec as ReceptReelles
,pda.t_srec as ReceptFabProg
,pda.t_sirc as ReceptDistrProg
,pda.t_pstc as PlanStock
,pda.t_astc as StockPrevu
,pda.t_avtp as DAV
,pda.t_atpc as DAVCumul
from tcprmp300500 pda --Plan directeur articles
inner join tcprpd100500 artp on artp.t_plni = pda.t_plni -- Articles Planification
inner join ttcibd001500 art on art.t_item = substring(pda.t_plni, 4, len(pda.t_plni)) 
where 
left(pda.t_plni, 3) between @cluster_f and @cluster_t
and substring(pda.t_plni, 4, 9) between @prj_f and @prj_t
and substring(pda.t_plni, 13, len(pda.t_plni)) between @item_f and @item_t
and pda.t_pern between @pern_f and @pern_t
and pda.t_demf between @demf_f and @demf_t
and art.t_kitm= '2' -- Articles Fabriqués
and pda.t_pdat >= getdate()
and art.t_csig in (@csig) -- Codes signaux à prendre en compte (y compris ceux qui n'en n'ont pas)