---------------------------
-- QUA02 - NQI Semi Ouvre
---------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--use ln6prddb;
--declare @ue_f nvarchar(2) = 'LV';
--declare @ue_t nvarchar(2) = 'LV';
--declare @of_f nvarchar(9) = 'LV0144035';
--declare @of_t nvarchar(9) = 'LV0144036';
--declare @prj_f nvarchar(9) = '         ';
--declare @prj_t nvarchar(9) = 'ZZZZZZZZZ';
--declare @art_f nvarchar = '                 ';
--declare @art_t nvarchar = 'ZZZZZZZZZZZZZZZZZ';
--declare @date_f date = DATEADD(DD, -300, CAST(CURRENT_TIMESTAMP AS DATE));
--declare @date_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));

select opeof.t_pdno as OrdreFab, 
opeof.t_opno as Operation, 
left(opeof.t_item, 9) as ProjetArticle, 
substring(opeof.t_item, 10, len(opeof.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
opeof.t_cmdt as DateAchevement, 
opeof.t_qcmp as QuantiteAchevee, 
opeof.t_qrjc as QuantiteRejetee, 
opeof.t_cwoc as CentreCharge, 
cc.t_dsca as DescriptionCentreCharge, 
opeof.t_reco as MotifRejet, 
epr.t_ecpr_1 as CoutStandard 
from ttisfc010500 opeof --Opérations des Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = opeof.t_item --Articles
left outer join ttcmcs065500 cc on cc.t_cwoc = opeof.t_cwoc --Centre de Charge
left join tticpr007500 epr on epr.t_item = art.t_item -- Données d'établissement des coûts de revient
where 
left(opeof.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'Unite d'Entreprise Definie par l'OF
and opeof.t_pdno between @of_f and @of_t --Bornage sur l'OF
and left(opeof.t_item, 9) between @prj_f and @prj_t --Bornage sur le Projet Article
and substring(opeof.t_item, 10, len(opeof.t_item)) between @art_f and @art_t --Bornage sur le Code Article
and opeof.t_cmdt between @date_f and @date_t --Bornage sur la Date d'Achevement
--and opeof.t_qrjc != 0 --Bornage sur la Quantite Rejetee Differente de 0