----------------------------------------------------------
-- COM15 - Ecarts Ordres Magasins / Programmes de Ventes
----------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Sert à ramener les ordres magasins qui n'ont pas été supprimés lors de la modification/annulation du PV
select om.t_orno as Ordre, 
left(om.t_item, 9) as Projet, 
substring(om.t_item, 10, len(om.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
om.t_qana as Quantite, 
om.t_date as DateTransaction 
from twhinp100500 om --Transactions de Stock Planifiés par Article
inner join ttcibd001500 art on art.t_item = om.t_item --Articles
where om.t_koor = 7 --On prend les lignes de type Programmes de ventes
--and om.t_item = '         K00002321'
and not exists 
(select *
from ttdsls307500 lprog 
inner join ttdsls311500 progven on progven.t_schn = lprog.t_schn and progven.t_sctp = lprog.t_sctp and progven.t_revn = lprog.t_revn --Programmes de Ventes
where lprog.t_schn = om.t_orno 
and progven.t_stat != 4 --On enlève les programmes résiliés
and progven.t_stat != 5 --On enlève les programmes au statut résiliation en cours
and left(lprog.t_sdat, 10) = left(om.t_date,10) 
and om.t_qana = lprog.t_qrrq 
and lprog.t_revn = (select top 1 prog1.t_revn from ttdsls307500 prog1 where prog1.t_schn = lprog.t_schn and prog1.t_sctp = lprog.t_sctp order by prog1.t_revn desc))