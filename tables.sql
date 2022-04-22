
/*********** Tables ************/
-- Table EMPLOYE 
CREATE TABLE EMPLOYE of temploye (NUM_EMP primary key);

-- Table PATIENT
create table patient of tpatient(constraint pk_NUM_PATIENT primary key(NUM_PATIENT))
nested table patient_soigne store as table_patient_soigne,
nested table patient_hospitalisation store as table_patient_hospitalisation;
/

-- Table MEDECIN 
create table MEDECIN of tmedecin
(
	constraint pk_NUM_MED primary key(NUM_MED),
	SPECIALITE check(SPECIALITE IN ('Anesthésiste','Cardiologue','Généraliste','Orthopédiste'))
)
nested table medecin_soigne store as table_medecin_soigne,
nested table directeur_service store as table_directeur_service;
/

-- Table SERVICE
create table SERVICE of tservice
(
	constraint pk_CODE_SERVICE primary key(CODE_SERVICE),
	constraint fk_SERVICE_MED Foreign key (service_directeur) references medecin,
	constraint Index_Unique_NOM_SERVICE UNIQUE(NOM_SERVICE)
)
nested table service_infirmier store as table_service_infirmier,
nested table service_chambre store as table_service_service_chambre,
nested table service_hospitalisation store as table_service_service_hospitalisation;
/
-- Table INFIRMIER 
create table infirmier of tinfirmier
(
	constraint prk_NUM_INF primary key(NUM_INF),
    constraint fk_INFI_SERVICE Foreign key (infirmier_service) references SERVICE,
	ROTATION check(ROTATION IN ('JOUR','NUIT'))
	
)
nested table infirmier_chambre store as table_infirmier_chambre;
/

-- Table CHAMBRE
create table CHAMBRE of tchambre
(
	constraint pk_NUM_CHAMBRE primary key(NUM_CHAMBRE),
    NB_LITS check(NB_LITS>0),
	constraint fk_CHAMBRE_SERVICE Foreign key (chambre_service) references SERVICE,
	constraint fk_CHAMBRE_INFIRMIER Foreign key (chambre_surveillant) references infirmier
)   
nested table CHAMBRE_hospitalisation store as table_CHAMBRE_hospitalisation;
/
-- Table SOIGNE 
create table SOIGNE of tsoigne
(
	constraint pk_NUM_SOIGNE primary key(NUM_SOIGNE),
	constraint fk_SOIGNE_PATIENT Foreign key (soigne_patient) references PATIENT,
	constraint fk_SOIGNE_MED Foreign key (soigne_medecin) references MEDECIN
);
/
-- Table HOSPITALISATION
create table HOSPITALISATION of thospitalisation
(
	constraint pk_NUM_CHAMB primary key(NUM_hospitalisation),
	LIT check(LIT > 0),
	constraint fk_HOSPI_PATIENT Foreign key (hospitalisation_patient) references patient,	
	constraint fk_HOSPI_service Foreign key (hospitalisation_service) references service,
    constraint fk_HOSPI_CHAMBRE Foreign key (hospitalisation_chambre) references chambre
);
/


