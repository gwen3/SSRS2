-----------------------------------------------
-- MDM10 - Contr�le des Articles Sous Trait�s
-----------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 'UE Centre de Charge diff�rent de UE T�che' as Source
,left(gam.t_mitm, 9) as ProjetArticleFabrique
,substring(gam.t_mitm, 10, len(gam.t_mitm)) as ArticleFabrique
,art.t_dsca as DescriptionArticleFabrique
,gam.t_opno as OperationGamme
,gam.t_seqn as SeguenceGamme
,gam.t_tano as Tache
,tache.t_dsca as NomTache
,gam.t_cwoc as CentreCharge
,cc.t_dsca as NomCentreCharge
,gam.t_indt as DateApplication
,gam.t_exdt as DateExpiration
,art.t_cood as CoordinateurTechnique
,emp.t_nama as NomCoordinateurTechnique
,donpers.t_mail as MailCoordinateurTechnique
from ttirou102500 gam --Op�rations de Gammes
inner join ttcibd001500 art on art.t_item = gam.t_mitm --Articles - Fabriqu�s
left outer join ttirou003500 tache on tache.t_tano = gam.t_tano --Tache
left outer join ttirou001500 cc on cc.t_cwoc = gam.t_cwoc --Centre de Charge
left outer join ttccom001500 emp on emp.t_emno = art.t_cood --Employ� - Repr�sentant Interne
left outer join tbpmdm001500 donpers on donpers.t_emno = art.t_cood --Employ�s - Donn�es du Personnel - Repr�sentant Interne
where gam.t_cwoc = 'LVC901'
and gam.t_tano not like 'LVT3%'
and gam.t_exdt >= getdate()
)
union all
(select 'UE T�che diff�rent de UE Centre de Charge' as Source
,left(gam.t_mitm, 9) as ProjetArticleFabrique
,substring(gam.t_mitm, 10, len(gam.t_mitm)) as ArticleFabrique
,art.t_dsca as DescriptionArticleFabrique
,gam.t_opno as OperationGamme
,gam.t_seqn as SeguenceGamme
,gam.t_tano as Tache
,tache.t_dsca as NomTache
,gam.t_cwoc as CentreCharge
,cc.t_dsca as NomCentreCharge
,gam.t_indt as DateApplication
,gam.t_exdt as DateExpiration
,art.t_cood as CoordinateurTechnique
,emp.t_nama as NomCoordinateurTechnique
,donpers.t_mail as MailCoordinateurTechnique
from ttirou102500 gam --Op�rations de Gammes
inner join ttcibd001500 art on art.t_item = gam.t_mitm --Articles - Fabriqu�s
left outer join ttirou003500 tache on tache.t_tano = gam.t_tano --Tache
left outer join ttirou001500 cc on cc.t_cwoc = gam.t_cwoc --Centre de Charge
left outer join ttccom001500 emp on emp.t_emno = art.t_cood --Employ� - Repr�sentant Interne
left outer join tbpmdm001500 donpers on donpers.t_emno = art.t_cood --Employ�s - Donn�es du Personnel - Repr�sentant Interne
where gam.t_tano like 'LVT3%'
and gam.t_cwoc != 'LVC901'
and gam.t_exdt >= getdate()
)