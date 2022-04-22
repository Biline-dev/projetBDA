
drop type tlit force;
drop type thospitalisation force;
drop type tpatient force;
drop type tmedecin force;
drop type tinfirmier force;
drop type tchambre force;
drop type tservice force;
drop type temploye force;
drop type tbatiment force;
drop type tsoigne force;

drop type t_set_ref_medecin force;
drop type t_set_ref_infirmier force;
drop type t_set_ref_service force;
drop type t_set_ref_hospitalisation force;
drop type t_set_ref_chambre force;
drop type t_set_ref_lit force;
drop type t_set_ref_soigne force;
drop type tinfirmier force;
drop type t_set_ref_patient force;


drop table patient cascade constraints;
drop table medecin cascade constraints;
drop table service cascade constraints;
drop table hospitalisation cascade constraints;
drop table soigne cascade constraints;
drop table chambre cascade constraints;
drop table employe cascade constraints;
drop table infirmier cascade constraints;




