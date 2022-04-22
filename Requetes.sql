/* Donner la liste des patients (Prénom et nom) affiliés à la mutuelle « MAAF »*/

select p.nom_patient, p.prenom_patient from patient p where p.mutuelle='MAAF';

/* Donner pour chaque lit occupé du bâtiment « B » de l’hôpital occupé par un patient affilié à une mutuelle
dont le nom commence par « MN... », le numéro du lit, le numéro de la chambre, le nom du service ainsi
que le prénom, le nom et la mutuelle du patient l’occupant. */

select deref(hos.hospitalisation_service).nom_service,  
deref(hos.hospitalisation_patient).nom_patient, 
deref(hos.hospitalisation_patient).prenom_patient, 
deref(hos.hospitalisation_patient).mutuelle, 
deref(hos.hospitalisation_chambre).num_chambre, hos.lit  from hospitalisation hos where 
deref(hos.hospitalisation_service).BATIMENT='B' 
and deref(hos.hospitalisation_patient).mutuelle like '%MN%' ;

/* Pour chaque patient soigné par plus de 3 médecins donner le nombre total de ses médecins ainsi que le
nombre correspondant de spécialités médicales concernées. */

select   p.num_patient, count(distinct deref(deref(value(pc)).soigne_medecin).specialite), 
count(distinct deref(deref(value(pc)).soigne_medecin).num_med)as nb from service s, patient p,  
table(p.patient_soigne) pc group by  p.num_patient;

/* Quelle est la moyenne des salaires des infirmiers(ères) par service ?*/

select  avg(deref(value(si)).salaire) from service s, 
table(s.service_infirmier) si  group by s.code_service;

/*Pour chaque service quel est le rapport entre le nombre d’infirmier(ères) affecté(es) au service et le
nombre de patients hospitalisés dans le service ? */

/* Nous remarquons que pour chaque service, si le nombre des patients est grand, les infirmiers
se mobilisent aussi avec un grand nombre*/

select  s.code_service, count(deref(value(si)).num_inf)
from service s, table(s.service_infirmier) si  group by s.code_service;

select  s.code_service, count(deref(deref(value(hos)).hospitalisation_patient).num_patient)
from service s, table(s.service_hospitalisation) hos group by s.code_service;

select s.code_service, s.calcul_nombre_infirmier_et_patient_par_service() from service s;

/* Donner la liste des médecins (Prénom et nom) ayant un patient hospitalisé dans chaque service. */

select distinct s.code_service, e.nom_emp, e.prenom_emp from employe e, service s, 
table(s.service_hospitalisation) sh, 
table(deref(deref(value(sh)).hospitalisation_patient).patient_soigne) sg where 
e.num_emp=deref(deref(value(sg)).soigne_medecin).num_med order by s.code_service;
