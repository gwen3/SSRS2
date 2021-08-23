-------------------------------------------------
-- DAS31 - Liste Type de Transaction - B61-kost
-------------------------------------------------

--Pour faire fonctionner ce Dataset, il faut sélectionner le champ que l'on souhaite dans t_cdom et il faut trouver dans quelle version on se trouve. Dans l'exemple, j'étais dans le version standard.
--La fonction qui a été créé est plus performante car elle fait une boucle, en commençant d'abord par regarder la version donnée (souvent Bull) puis ensuite les autres. Ici on la renseigne en dur

select code.t_cnst as Code
,libelle.t_desc as Description
,concat(code.t_cnst, ' - ', libelle.t_desc) as Affichage
from tttadv401000 code
inner join tttadv140000 libelle on libelle.t_cpac = code.t_cpac and libelle.t_clan = '4' and libelle.t_clab = code.t_za_clab and libelle.t_vers = code.t_vers and libelle.t_rele = code.t_rele
where code.t_vers = 'B61' --On va chercher la version standard
and code.t_cdom = 'kost' --On prend le champ koor
order by Code