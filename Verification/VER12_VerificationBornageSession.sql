------------------------------------------
-- VER12 - Vérification bornage sessions
------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select sess.t_user as Utilisateur, 
sess.t_sess as NomSession, 
convert(varchar(max),sess.t_rcrd) as Parametre 
from tttadv990000 sess 
where sess.t_sess = @sess 
and t_sequ = 0 --Permet de n'obtenir que le 1er bornage
and convert(varchar(max),sess.t_rcrd) not like concat('%', @born,'%') --On renseigne le paramétrage que l'on a mis pour le premier champ
