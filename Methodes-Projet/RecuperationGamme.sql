select gam.t_mitm as Article, 
art.t_dsca as DescriptionArticle, 
art.t_citg as GroupeArticle, 
dbo.convertenum('tc','B61C','a9','bull','yesno',gam.t_stor,'4') as GammeStandard, 
gam.t_strc as CodeGammeStandard, 
gam.t_opro as Gamme 
from ttirou101500 gam --Code Gamme par Articles
inner join ttcibd001500 art on art.t_item = gam.t_mitm --Articles
where art.t_citg between '200' and '200' --Bornage sur le Groupe Article
and left(gam.t_mitm, 9) = ' ' --On ne prend que les articles sans Projet