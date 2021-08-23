-----------------------------------------------------------------------
-- Problème de Mathieu pour les lignes de commandes ayant un prix à 0
-----------------------------------------------------------------------

select ligcom.t_orno, ligcom.t_pono, ligcom.t_sqnb, ligcom.t_otbp, ligcom.t_item, ligcom.t_qoor, ligcom.t_cuqp, ligcom.t_cvqp, ligcom.t_pric, ligcom.t_corg, ligcom.t_porg, ligcom.t_stsd, ligcom.t_btsp, com.t_hdst 
from ttdpur401500 ligcom 
inner join ttdpur400500 com on ligcom.t_orno = com.t_orno 
where ligcom.t_pric = 0;
