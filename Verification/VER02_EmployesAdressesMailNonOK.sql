------------------------------------------
-- VER02 - Employés Adresses Mail Non OK
------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select carac.t_emno as CodeEmploye, 
emp.t_nama as NomEmploye, 
emp.t_loco as CodeUtilisateur, 
carac.t_mail as MailEmploye, 
carac.t_sdte as DateEmbauche, 
carac.t_edte as DateDepart, 
carac.t_sexe as SexeEmploye
from tbpmdm001500 carac
inner join ttccom001500 emp on emp.t_emno = carac.t_emno 
where (carac.t_mail = '' or carac.t_mail not like '%@gruau.com' or carac.t_mail not like '%@gifa.fr' or (carac.t_mail like '% %' and carac.t_mail != '')) 
and emp.t_loco != '' --On ne prend que les codes utilisateurs renseignés car les autres n'ont pas forcément besoin d'une adresse mail
and carac.t_emno != 'FELBALOU' --Exclusion des 3 employés Bull
and carac.t_emno != 'PLEVEAUX' 
and carac.t_emno != 'DCOULON' 
and emp.t_cwoc != 'LVC010' --Exclusion du secteur Tolerie qui n'a pas besoin d'adresses mail
and carac.t_edte not between '1980-01-01' and @date;