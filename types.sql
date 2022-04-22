
/**************************/
/* incomplete types */
create or replace type tpatient;
/
create or replace type tmedecin;
/
create or replace type tchambre;
/
create or replace type tservice;
/
create or replace type thospitalisation;
/
create or replace type tsoigne;
/
create or replace type tlit;
/

/****************************/

/*******************************/
/* type collection*/

create or replace type t_set_ref_patient as table of ref tpatient
/
create or replace type t_set_ref_service as table of ref tservice
/
create or replace type t_set_ref_hospitalisation as table of ref thospitalisation
/
create or replace type t_set_ref_chambre as table of ref tchambre
/
create or replace type t_set_ref_soigne as table of ref tsoigne
/

/***************************/

/*************************/
/* objet et association*/


-- TYPE TEMPLOYE
create or replace type temploye as object( NUM_EMP Number(7),
                                NOM_EMP varchar2(30),
                                PRENOM_EMP varchar2(30),
                                ADRESSE_EMP varchar2(100),
                                TEL_EMP varchar2(10)
                                ) not final;
/

-- TYPE TMEDECIN
create or replace type tmedecin under temploye( NUM_MED number(7),
                                     SPECIALITE varchar2(40),
                                     medecin_soigne t_set_ref_soigne,
                                     directeur_service t_set_ref_service
                                );
/


-- TYPE TINFIRMIER
create or replace type tinfirmier under temploye(NUM_INF number(7),
                                      infirmier_service ref tservice,
                                      ROTATION char(4),
                                      SALAIRE  number(10,2),
                                      infirmier_chambre t_set_ref_chambre
                                );  
/ 

create or replace type t_set_ref_infirmier as table of ref tinfirmier;
/

-- TYPE TSOIGNE
create or replace type tsoigne as object ( num_soigne integer,
                                soigne_patient ref tpatient,
                                soigne_medecin ref tmedecin
                               );     
/

-- TYPE THOSPITALISATION
create or replace type thospitalisation as object( NUM_Hospitalisation number(7),
                                        hospitalisation_patient ref tpatient,
                                        hospitalisation_service ref  tservice,
                                        hospitalisation_chambre ref  tchambre,
                                        LIT int      
                                        );
/                                        

-- TYPE TCHAMBRE                 
create or replace type tchambre as object ( chambre_service ref  tservice,
                                 NUM_CHAMBRE Number(4),
                                 chambre_surveillant ref  tinfirmier,
                                 NB_LITS int ,
                                 chambre_hospitalisation  t_set_ref_hospitalisation
		       	);  
/		   

-- TYPE TSERVICE
create or replace type tservice as object (CODE_SERVICE char(3),
                                NOM_SERVICE varchar2(40),
                                BATIMENT char,
                                service_directeur ref tmedecin,
                                service_infirmier t_set_ref_infirmier,
                                service_chambre  t_set_ref_chambre,
                                service_hospitalisation  t_set_ref_hospitalisation
                                );		       	 
/

-- TYPE TPATIENT
create or replace type tpatient as object( NUM_PATIENT Number(7),
                                NOM_PATIENT varchar2(30),
                                PRENOM_PATIENT varchar2(30),
                                ADRESSE_PATIENT varchar2(100),
                                TEL_PATIENT varchar2(10),
                                MUTUELLE varchar2(10),
                                patient_soigne t_set_ref_soigne,
                                patient_hospitalisation t_set_ref_hospitalisation
                                );
/



