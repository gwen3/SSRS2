---------------------------------------------
-- LOG14 - Detection Anomalie d'Affectation
---------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 'OF' as Source, 
ofab.t_pdno as OrdreFabrication, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DescriptionArticleFabrique, 
ofab.t_prdt as DateDebutFabrication, 
ofab.t_pldt as DateLivraisonPlanifiee, 
ofab.t_orno as CommandeClientOF, 
ofab.t_pono as PositionCommandeClientOF, 
tqc.t_mser as NumeroChassisOF, 
lcde.t_serl as NumeroChassisOV, 
lcde.t_ddta as DateProductionGruau 
from ttisfc001500 ofab --Ordres de Fabrication
left outer join ttdsls401500 lcde on lcde.t_orno = ofab.t_orno and lcde.t_pono = ofab.t_pono --Lignes Commandes Clients
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttimfc010500 tqc on tqc.t_pdno = ofab.t_pdno --En-tête tel que conçu
where left(ofab.t_pdno, 2) between @ue_f and @ue_t --On récupère l'UE sur le numéro d'OF
and ofab.t_pldt between @date_f and @date_t --Bornage sur la Date de Livraison Planifiée
and tqc.t_mser != lcde.t_serl) --On prend tous les chassis qui sont différents entre OF et OV
union 
(select 'OV' as Source, 
ofab.t_pdno as OrdreFabrication, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DescriptionArticleFabrique, 
ofab.t_prdt as DateDebutFabrication, 
ofab.t_pldt as DateLivraisonPlanifiee, 
ofab.t_orno as CommandeClientOF, 
ofab.t_pono as PositionCommandeClientOF, 
tqc.t_mser as NumeroChassisOF, 
lcde.t_serl as NumeroChassisOV, 
lcde.t_ddta as DateProductionGruau 
from ttdsls401500 lcde --Lignes Commandes Clients
left outer join ttisfc001500 ofab on ofab.t_orno = lcde.t_orno and ofab.t_pono = lcde.t_pono --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttimfc010500 tqc on tqc.t_pdno = ofab.t_pdno --En-tête tel que conçu
where left(lcde.t_orno, 2) between @ue_f and @ue_t --On récupère l'UE sur le numéro d'OF
and ofab.t_pldt between @date_f and @date_t --Bornage sur la Date de Livraison Planifiée
and lcde.t_serl != tqc.t_mser) --On prend tous les chassis qui sont différents entre OF et OV