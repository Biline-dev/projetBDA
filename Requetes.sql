/* Donner la liste des patients (Pr�nom et nom) affili�s � la mutuelle � MAAF �*/

select p.nom_patient, p.prenom_patient from patient p where p.mutuelle='MAAF';

/* Donner pour chaque lit occup� du b�timent � B � de l�h�pital occup� par un patient affili� � une mutuelle
dont le nom commence par � MN... �, le num�ro du lit, le num�ro de la chambre, le nom du service ainsi
que le pr�nom, le nom et la mutuelle du patient l�occupant. */

select deref(hos.hospitalisation_service).nom_service,  
deref(hos.hospitalisation_patient).nom_patient, 
deref(hos.hospitalisation_patient).prenom_patient, 
deref(hos.hospitalisation_patient).mutuelle, 
deref(hos.hospitalisation_chambre).num_chambre, hos.lit  from hospitalisation hos where 
deref(hos.hospitalisation_service).BATIMENT='B' 
and deref(hos.hospitalisation_patient).mutuelle like '%MN%' ;

/* Pour chaque patient soign� par plus de 3 m�decins donner le nombre total de ses m�decins ainsi que le
nombre correspondant de sp�cialit�s m�dicales concern�es. */

select   p.num_patient, count(distinct deref(deref(value(pc)).soigne_medecin).specialite), 
count(distinct deref(deref(value(pc)).soigne_medecin).num_med)as nb from service s, patient p,  
table(p.patient_soigne) pc group by  p.num_patient;

/* Quelle est la moyenne des salaires des infirmiers(�res) par service ?*/

select  avg(deref(value(si)).salaire) from service s, 
table(s.service_infirmier) si  group by s.code_service;

/*Pour chaque service quel est le rapport entre le nombre d�infirmier(�res) affect�(es) au service et le
nombre de patients hospitalis�s dans le service ? */

/* Nous remarquons que pour chaque service, si le nombre des patients est grand, les infirmiers
se mobilisent aussi avec un grand nombre*/

select  s.code_service, count(deref(value(si)).num_inf)
from service s, table(s.service_infirmier) si  group by s.code_service;

select  s.code_service, count(deref(deref(value(hos)).hospitalisation_patient).num_patient)
from service s, table(s.service_hospitalisation) hos group by s.code_service;

select s.code_service, s.calcul_nombre_infirmier_et_patient_par_service() from service s;

/* Donner la liste des m�decins (Pr�nom et nom) ayant un patient hospitalis� dans chaque service. */

select distinct s.code_service, e.nom_emp, e.prenom_emp from employe e, service s, 
table(s.service_hospitalisation) sh, 
table(deref(deref(value(sh)).hospitalisation_patient).patient_soigne) sg where 
e.num_emp=deref(deref(value(sg)).soigne_medecin).num_med order by s.code_service;
