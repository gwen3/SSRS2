--------------------------------------
-- VER10 - Différences d'Imprimantes
--------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Imprimantes en Prod qui ne sont pas en PreProd
select impprd.t_devc as Imprimante, 
impprd.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',impprd.t_chal,'4') as Modification, 
dbo.convertenum('tc','B61C','a9','bull','yesno',impprd.t_xmli,'4') as XML 
from PRD.ln6prddb.dbo.tttaad300000 impprd --Imprimantes de la Prod
where impprd.t_devc not in (select distinct imppre.t_devc from PRE.ln6db.dbo.tttaad300000 imppre) --Comparaison avec les imprimantes de la PreProd

--Imprimantes en PreProd qui ne sont pas en Test
select imppre.t_devc as Imprimante, 
imppre.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imppre.t_chal,'4') as Modification, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imppre.t_xmli,'4') as XML 
from PRE.ln6db.dbo.tttaad300000 imppre --Imprimantes de la PreProd
where imppre.t_devc not in (select distinct imptst.t_devc from tttaad300000 imptst) --Comparaison avec les imprimantes de la Test

--Imprimantes en Test qui ne sont pas en Prod
select imptst.t_devc as Imprimante, 
imptst.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imptst.t_chal,'4') as Modification, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imptst.t_xmli,'4') as XML 
from tttaad300000 imptst --Imprimantes de la Test
where imptst.t_devc not in (select distinct impprd.t_devc from PRD.ln6prddb.dbo.tttaad300000 impprd) --Comparaison avec les imprimantes de la Prod

--Imprimantes en PreProd qui ne sont pas en Prod
select imppre.t_devc as Imprimante, 
imppre.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imppre.t_chal,'4') as Modification, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imppre.t_xmli,'4') as XML 
from PRE.ln6db.dbo.tttaad300000 imppre --Imprimantes de la PreProd
where imppre.t_devc not in (select distinct impprd.t_devc from PRD.ln6prddb.dbo.tttaad300000 impprd) --Comparaison avec les imprimantes de la Production

--Imprimantes en Prod qui n'ont pas le bon chemin pour du fichier XML
select impprd.t_devc as Imprimante, 
impprd.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',impprd.t_xmli,'4') as XML 
from PRD.ln6prddb.dbo.tttaad300000 impprd --Imprimantes de la Prod
where impprd.t_path not like '\\mc1lvl\comet\Lasernet\Production\Input\%' --On prend les chemins qui ne pointent pas vers la Production
and impprd.t_xmli = 1 --On prend les impressions XML
and impprd.t_prog = 'ozgintlaser' --On prend les imprimantes lasernet

--Imprimantes en PreProd qui n'ont pas le bon chemin pour du fichier XML
select imppre.t_devc as Imprimante, 
imppre.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imppre.t_xmli,'4') as XML 
from PRE.ln6db.dbo.tttaad300000 imppre --Imprimantes de la Prod
where imppre.t_path not like '\\mc1lvl\comet\Lasernet\PreProduction\Input\%' --On prend les chemins qui ne pointent pas vers la PreProduction
and imppre.t_xmli = 1 --On prend les impressions XML
and imppre.t_prog = 'ozgintlaser' --On prend les imprimantes lasernet

--Imprimantes en Test qui n'ont pas le bon chemin pour du fichier XML
select imptst.t_devc as Imprimante, 
imptst.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imptst.t_xmli,'4') as XML 
from tttaad300000 imptst --Imprimantes de la Prod
where imptst.t_path not like '\\mc1lvl\comet\Lasernet\Test\Input\%' --On prend les chemins qui ne pointent pas vers la Test
and imptst.t_xmli = 1 --On prend les impressions XML
and imptst.t_prog = 'ozgintlaser' --On prend les imprimantes lasernet

--Imprimantes en Prod qui n'ont pas le bon chemin pour du fichier Texte
select impprd.t_devc as Imprimante, 
impprd.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',impprd.t_xmli,'4') as XML 
from PRD.ln6prddb.dbo.tttaad300000 impprd --Imprimantes de la Prod
where impprd.t_path not like '\\mc1lvl\comet\Lasernet\Production\Input Texte\%' --On prend les chemins qui ne pointent pas vers la Production
and impprd.t_xmli = 2 --On prend les impressions qui ne sont pas du XML
and impprd.t_prog = 'ozgintlaser' --On prend les imprimantes lasernet

--Imprimantes en PreProd qui n'ont pas le bon chemin pour du fichier Texte
select imppre.t_devc as Imprimante, 
imppre.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imppre.t_xmli,'4') as XML 
from PRE.ln6db.dbo.tttaad300000 imppre --Imprimantes de la Prod
where imppre.t_path not like '\\mc1lvl\comet\Lasernet\PreProduction\Input Texte\%' --On prend les chemins qui ne pointent pas vers la PreProduction
and imppre.t_xmli = 2 --On prend les impressions qui ne sont pas du XML
and imppre.t_prog = 'ozgintlaser' --On prend les imprimantes lasernet

--Imprimantes en Test qui n'ont pas le bon chemin pour du fichier Texte
select imptst.t_devc as Imprimante, 
imptst.t_path as Chemin, 
dbo.convertenum('tc','B61C','a9','bull','yesno',imptst.t_xmli,'4') as XML 
from tttaad300000 imptst --Imprimantes de la Prod
where imptst.t_path not like '\\mc1lvl\comet\Lasernet\Test\Input Texte\%' --On prend les chemins qui ne pointent pas vers la Test
and imptst.t_xmli = 2 --On prend les impressions qui ne sont pas du XML
and imptst.t_prog = 'ozgintlaser' --On prend les imprimantes lasernet
