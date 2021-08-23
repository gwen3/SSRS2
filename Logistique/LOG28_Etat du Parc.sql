-------------------------
-- LOG28 - Etat du Parc
-------------------------

select left(parc.t_item, 9) as Projet
,substring(parc.t_item, 10, len(parc.t_item)) as Article
,parc.t_serl as Chassis
,parc.t_cwar as Magasin
,parc.t_rdat as DateReception
,parc.t_idat as DateStockage
,parc.t_lsid as DateDernierControleStock
,parc.t_cdf_coul as CodeCouleur
,dbo.convertlistcdf('wh','B61C','a9','grup','cou',parc.t_cdf_coul,'4') as NomCouleur
,parc.t_cdf_marq as CodeMarque
,dbo.convertlistcdf('wh','B61C','a9','grup','mar',parc.t_cdf_marq,'4') as NomMarque
,parc.t_cdf_type as Type
,dbo.convertlistcdf('wh','B61C','a9','grup','typ',parc.t_cdf_type,'4') as NomType
from twhltc500500 parc
where left(parc.t_cwar, 2) between @ue_f and @ue_t --On borne sur l'UE défini par le magasin
and parc.t_cwar in (@mag) --On sélectionne les parcs que l'on souhaite
and parc.t_isdt < '01/01/1980' --On borne sur la date de sortie qui doit être nulle pour ne ramener que ce qui est toujours en stock