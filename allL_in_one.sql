
/* CREATION OF TABLE SPACE */
create TABLESPACE SQL3_TBS DATAFILE  'C:\Table\tbs_SQL3_TBS.dat'  SIZE 200k  AUTOEXTEND ON   ONLINE;
create TEMPORARY TABLESPACE SQL3_TempTBS TEMPFILE  'C:\Table\tbs_SQL3_TempTBS.dat'  SIZE 5m  AUTOEXTEND ON;

/* CREATION OF A USER */
connect SYSTEM/SYSTEM1234 as sysdba;
create User SQL3 Identified by BELINE Default Tablespace
SQL3_TBS Temporary Tablespace  SQL3_TempTBS;

/* GRANT PRIVILIGES TO THE NEW USER */
GRANT ALL privileges to SQL3;
CONNEct SQL3/BELINE;

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

/*****************************/

/********************************/
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
/************************/

/*************************/
/******* INSERTION ******/ 

-- Table EMPLOYE

INSERT INTO EMPLOYE VALUES (temploye(12,'HADJ','Zouhir','Cité de la Mosquée Bt 14?Boufarik?Blida','025474882'));
INSERT INTO EMPLOYE VALUES (temploye(15,'OUSSEDIK','Hakim','152,rue Hassiba Ben Bouali 1er étage ?Hamma?Alger','021653445'));
INSERT INTO EMPLOYE VALUES (temploye(22,'ABAD','Abdelhamid','8 Cours Aissat Idir?El Harrach?Alger','021524587'));
INSERT INTO EMPLOYE VALUES (temploye(25,'ABAYAHIA','Abdelkader','53 rue de la gare routière?Douera?Alger','021416455'));
INSERT INTO EMPLOYE VALUES (temploye(29,'ABBOU','Mohamed','RUE CHEIKH BOUAAMAMA 45000?Naama','049796574'));
INSERT INTO EMPLOYE VALUES (temploye(45,'ABDELOUAHAB','OUAHIBA','cité des vieux moulins BEO?Bab El Oued?Alger','021967015'));
INSERT INTO EMPLOYE VALUES (temploye(49,'ABDEMEZIANE','Madjid','Avenue Abane Ramdane,Larbaa Nath Iraten?Tizi Ouzou','026261311'));
INSERT INTO EMPLOYE VALUES (temploye(57,'ACHAIBOU','Rachid','Rue colonel Zamoum ali?Tizi Ouzou','026211639'));
INSERT INTO EMPLOYE VALUES (temploye(71,'AGGOUN','Khadidja','20 rue Mohamed Ben Mohamed?Béchar','049800695'));
INSERT INTO EMPLOYE VALUES (temploye(73,'AISSAT','Salima','Cité 350 lgts. Bt. 12 n°2 Boumerdes','024819915'));
INSERT INTO EMPLOYE VALUES (temploye(86,'BABACI','Mourad','Cité Mohamed Boudiaf bt 04 n° 72?Djelfa','027875147'));
INSERT INTO EMPLOYE VALUES (temploye(95,'BADI','Hatem','Secteur sanitaire Hassi messaoud 30500?Ouargla','029737052'));
INSERT INTO EMPLOYE VALUES (temploye(97,'BAKIR','ADEL','COGRAL 1 RUE DE GAO NOUVEAU PORT?Alger','0555037013'));
INSERT INTO EMPLOYE VALUES (temploye(98,'BALI','Malika','Cité HLM,Ain M\lila?Oum El Bouaghi','032449120'));
INSERT INTO EMPLOYE VALUES (temploye(116,'BELABES','Abdelkader','Cité nouvelle Mosquée?Djelfa','027877777'));
INSERT INTO EMPLOYE VALUES (temploye(127,'BELHAMIDI','Mustapha','Route de Saida ?Sidi Bel Abbes','048560678'));
INSERT INTO EMPLOYE VALUES (temploye(130,'BELKACEMI','Hocine','Medouha tizi?ouzou','26889885'));
INSERT INTO EMPLOYE VALUES (temploye(131,'BELKOUT','Tayeb','09,rue Alphonse Daudet les Sources?Bir Mourad Raïs?Alger','021448066'));
INSERT INTO EMPLOYE VALUES (temploye(139,'FERAOUN','Houria','batiment A,n°11,cité El khelloua?Bologhine?Alger','021954629'));
INSERT INTO EMPLOYE VALUES (temploye(151,'CHAKER','Nadia','Cité CNEP Bt 16 Bouzareah?Alger','0551688473'));
INSERT INTO EMPLOYE VALUES (temploye(155,'IGOUDJIL','Redouane','Les Vergers Bir mourad rais?Alger','0552637888'));
INSERT INTO EMPLOYE VALUES (temploye(162,'GHEZALI','Lakhdar','cité des 62 logts?staoueli?Alger','021391333'));
INSERT INTO EMPLOYE VALUES (temploye(163,'KOULA','Brahim','Cité Ali Sadek N° 59 (SNTP)) HAMIZ?Dar El Beida Alger','020406207'));
INSERT INTO EMPLOYE VALUES (temploye(169,'BELAID','Layachi','Annaba centre?Annaba','0772452613'));
INSERT INTO EMPLOYE VALUES (temploye(176,'CHALABI','Mourad','14,Route Nationale Hassi Bounif ORAN','041275151'));
INSERT INTO EMPLOYE VALUES (temploye(189,'SAIDOUNI','Wafa','Cité le sahel Bt A 11 Air de France?Bouzareah?Alger','021943031'));
INSERT INTO EMPLOYE VALUES (temploye(194,'Yalaoui','Lamia','Lot C N° 99 Draria?Draria?Alger','020373667'));
INSERT INTO EMPLOYE VALUES (temploye(195,'AYATA','Samia','76,Rue Ali Remli?Bouzareah?Alger','021930764'));

INSERT INTO EMPLOYE VALUES (4,'BOUROUBI','Taous','Lotissement Dauphin n°30 DRARIA/ALGER','021356085');
INSERT INTO EMPLOYE VALUES(7,'BOUZIDI','AMEL','En face brigade gendarmerie?Douera?Alger','0556863528');
INSERT INTO EMPLOYE VALUES(8,'LACHEMI','Bouzid','140,Av Ali Khoudja?El Biar?Alger','021928568');
INSERT INTO EMPLOYE VALUES(10,'BOUCHEMLA','Elias','6,hai sidi serhane ?Khemis El Khechna?Boumerdes','024873549');
INSERT INTO EMPLOYE VALUES (temploye(19,'AAKOUB','Fatiha','Boulvard Colonel Amirouche?Sfissef?Sidi Bel Abbas','048595512'));
INSERT INTO EMPLOYE VALUES (temploye(24,'ABADA','Mohamed','2 rue del/Abreuvoir?Alger','021737000'));
INSERT INTO EMPLOYE VALUES (temploye(26,'ABBACI','Abdelmadjid','14 rue Ouabdelkader?Bejaia','034201409'));
INSERT INTO EMPLOYE VALUES (temploye(27,'ABBAS','Samira','22 rue ahmaed aoune el harrach?alger','0664027500'));
INSERT INTO EMPLOYE VALUES (temploye(31,'ABDELAZIZ','Ahmed','43 avenue du 1er novembre?Ghardaia','029892979'));
INSERT INTO EMPLOYE VALUES (temploye(34,'ABDELMOUMEN','Nassima','Cité Kharoubi Bt. 18?Médéa','025584204'));
INSERT INTO EMPLOYE VALUES (temploye(50,'ABERKANE','Aicha','Cité des 300 logts N°10?Bab Ezzouar?Alger','021248345'));
INSERT INTO EMPLOYE VALUES (temploye(53,'AZOUG','Dalila','64 rue de Tripoli?Hussein Dey?Alger','021771170'));
INSERT INTO EMPLOYE VALUES (temploye(54,'BENOUADAH','Mohammed','26,boulevard Said Touati?Beb el oued?ALGER','021962035'));
INSERT INTO EMPLOYE VALUES (temploye(64,'ADDAD','Fadila','9 cite el hana?Oum El Bouaghi?Alger','032421633'));
INSERT INTO EMPLOYE VALUES (temploye(80,'AMARA','Dahbia','Nouvelle villa n°27?Hammedi?Boumerdes','024860591'));
INSERT INTO EMPLOYE VALUES (temploye(82,'AROUEL','Leila','cite frères SADANE bt 34a?Guelma','037205906'));
INSERT INTO EMPLOYE VALUES (temploye(85,'BAALI','Souad','3 rue Aissani Said?Guelma','037264734'));
INSERT INTO EMPLOYE VALUES (temploye(88,'BACHA','Nadia','Cité des 200 logts Bt f n° A?Ouled Yaich?Blida','025436875'));
INSERT INTO EMPLOYE VALUES (temploye(89,'BAHBOUH','Naima','Cité bonne fontaine?CHERAGA?ALGER','0773298155'));
INSERT INTO EMPLOYE VALUES (temploye(99,'BASSI','Fatima','Cité du 5 juillet bloc 130?Mostaganem','045217227'));
INSERT INTO EMPLOYE VALUES (temploye(113,'BEHADI','Youcef','9 rue B Koucha?Bordj Bou Arreridj','035681165'));
INSERT INTO EMPLOYE VALUES (temploye(114,'BEKKAT','Hadia','Bd colonele amirouche?Baba Hassen?Alger','021481514'));
INSERT INTO EMPLOYE VALUES (temploye(122,'BELAKERMI','Mohammed','Rue de Palestine Sidi Bel Abbes','048544923'));
INSERT INTO EMPLOYE VALUES (temploye(126,'BELGHALI','Mohammed','100 rue Maski Mhamed?Tipaza','024496636'));
INSERT INTO EMPLOYE VALUES (temploye(135,'RAHALI','Ahcene','105,Lot Oued Tarfa?Draria?ALGER','0557705901'));
INSERT INTO EMPLOYE VALUES (temploye(140,'TERKI','Amina','17 Rue Mohammed CHABANI?Alger Centre?Alger','021235894'));
INSERT INTO EMPLOYE VALUES (temploye(141,'CHAOUI','Farid','13,rue khawarismi ?Kouba?Alger','021234163'));
INSERT INTO EMPLOYE VALUES (temploye(144,'BENDALI','Hacine','Cité Sonelgaz N° 31?Ben Aknoun?Alger','0663163973'));
INSERT INTO EMPLOYE VALUES (temploye(152,'BOULARAS','Fatima','21,rue Ferhat Boussaad?Alger','021237998'));
INSERT INTO EMPLOYE VALUES (temploye(179,'MOHAMMEDI','Mustapha','42 Ber El?Djir?Oran','0771255642'));
INSERT INTO EMPLOYE VALUES (temploye(180,'FEKAR','Abdelaziz','Cité Garidi 1 Bt 38,N° 9?Kouba?Alger','021687563'));
INSERT INTO EMPLOYE VALUES (temploye(196,'TEBIBEL','Nabila','33,rue du Hoggar?Hydra?Alger','021604840'));




-- Table PATIENT

INSERT INTO PATIENT VALUES (tpatient(1,'GRIGAHCINE','Nacer','95,Bd Bougara?El biar?Alger','021920313','MNAM', T_SET_REF_SOIGNE(),T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(3,'ABADA','ABDELHAMID','Rue Des Freres Bouchama Bt A Bloc F N 138?Constantine','031944128','LMDE',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(6,'ABERKANE','Aboukhallil','CITE 500 LOGTS BT 29 N 02 KHROUB? Constantine','031963658','MNH',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(13,'MAHBOUBA','Cherifa','CITE 1013 LOGTS BT 61 KHROUB? Constantine','031966095','MAAF',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(14,'ACHEUK','Youcef','Rue Des Freres Khaznadar Bt N 28? Constantine','031964664','MGEN',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(21,'ACHOUR','Fadila','CITE 1650 LOGTS BT F8 N 71 AIN SMARA? Constantine','031974253','MMA',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(23,'AKROUM','Mohammed','Cité Aïssa Harièche,Bâtiment B,n° 12 18000-Jijel','034497088','CNAMTS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(33,'ADJALI','Temim','lot 212 villa n 52 ain smara? Constantine','031974214','CCVRP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(35,'HADJ','Haroun','avenue 1er novembre 54?Sétif','036834401','MNFTC',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(36,'LATRI','Cherifa','cite 600 logts bt a10 n66?Sétif','036512093','MAS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(37,'SEDDIK AMEUR','Moussa','cite belkhired hacene bt d39 n°593?Sétif','036722343','AG2R',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(41,'ZENTOUT','Nazih','47,Rue des Frere Niati– Plateaux-Oran','041400805','MGSP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(43,'CHALABI','Mirali','24 rue Larbi Ben Mhidi-0ran','041292275','MNAM',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(44,'BOUABDALLAH','Reda','7è rue n° 394 Tourville-Arzew-W.Oran','0770920566','LMDE',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(46,'BESALAH','Kaddour','112,coop de 18 fevrier ?St hubert-Oran','041343241','MNH',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(52,'BOUDJELAL','Salim','15,Rue Miloud Benhaddou– Plateaux-Oran','041407746','MAAF',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(55,'AMARA','Med Sofiane','CITE DAKSI BT 09 N 03 CONSTANTINE','031637827','MGEN',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(56,'AMROUNE','Ahmed Lamine','04 RUE MICHELET CONSTANTINE','031923090','MMA',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(60,'AZZI','Kamel','RUE ABANE RAMDANE N 13 CONSTANTINE','031911002','CNAMTS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(61,'BACHTARZI','Faycal','7,RUE BENMELIEK ( EX RUE PINGET) CONSTANTINE','031912244','CCVRP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(63,'BOUZIDI ','kamal','79 RUE BELOUIZDAD BELCOURT?Alger','021650220','MNFTC',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(65,'MAICH','Sid?Ali','87,avenue Ali Khodja ?El Biar?Alger ','021925219','MAS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(66,'HAFIZ','Mahmoud','01,lot Houari Boumediènne  .SIDI MOUSSA ?Alger','0770360116','AG2R',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(67,'OUGHANEM','Mohamed','Diar Es Saada,Bt T,N°2 El Madania,Alger','021279526','MGSP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(68,'SERIR','Mustapha','2,rue ait Boudjemaa ? Chéraga?Alger','021361688','MNAM',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(70,'ZEGGAI','Abdelkader','219 route Ain Elbordj Tissemssilt 38000?Tissemsilt','046496134','LMDE',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(72,'TAHMI','Lamia','CITE BACHEDJARAH BATIMENT 38 ?Bach Djerrah?Alger ','021261446','MNH',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(74,'DIAF AMROUNI','Ghania','43,rue Abderrahmane Sbaa Belle vue?El Harrach?Alger ','021526166','MAAF',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(75,'MELEK','Chahinaz','HLM Aissat idir cage 9 3ème etage?El Harrach?Alger','021828898','MGEN',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(76,'TECHTACHE','Noura','16,route el djamila?Ain Benian?Alger','021306517','MMA',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(77,'TOUATI','Widad','14 Rue des frères aoudia?El Mouradia?Alger','021690000','CNAMTS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(78,'MAIDAT','Yassine','cité soumam Bt B1 n° 6?Boufarik?Blida','025473974','CCVRP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(79,'CHERIF','Nassim','Avenue hanafi hadjress?Beni Messous?Alger','0550084741','MNFTC',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(81,'YOUSFI','Mohamed','Résidence Familiale?Hussein Dey?Alger','021479918','MAS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(90,'YASRI','Hocine','6 rue med Fellah Kouba?Alger','021286589','AG2R',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(91,'BAKIR','Adel','Cogral 1 rue de gao nouveau port alger','0555037013','MGSP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(92,'ABLOUL','Faiza','Cité diplomatique Bt Bleu 14B n°3 Dérgana? Alger','021217888','MNAM',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(100,'HORRA','Assia','32 rue Ahmed Ouaked?Dely Brahim?Alger','021919105','LMDE',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(101,'MESBAH','Souad','Résidence Chabani?Hydra?Alger','021602311','MNH',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(102,'LAAOUAR','Ali','CITÉ 1ER MAI EX 137 LOGEMENTS?Adrar','049963143','MAAF',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(103,'DRIZI','Djamel','36 hai salem. 2000?Chlef','027722020','MNAM',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(104,'HADJADJ','Boumediene','EPSP ksar el hirane LAGHOUAT','0661646970','LMDE',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(105,'GROUDA','Houda','EPSP thniet elabed batna','0773516149','MNH',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(107,'MEDJAHED','Ahmed','CITE el naaser?Ain Touta?Batna','033835858','MAAF',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(108,'IDJAAD','Mohand','504 logts bt 07?Akbou?Bejaia','034353567','MGEN',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(109,'KACI','Ali','08 Rue SEFACENE Ahmed?El?Kseur?Bejaia','034252429','MMA',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(117,'KECIR','Laziz','av hassiba benbouali?Béjaïa','034217564','CNAMTS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(119,'FENNICHE','Saida','cite de l’indépendance larbaa blida','025466475','CCVRP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(120,'KOUBA','Mohamed','CENTRE BENCHAABANE?Ben Khellil?Blida','025470276','MNFTC',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(121,'AOUIZ','Messoud','Rue Saidani Abdesslam ?Ain Bessem?Bouira','026974956','MAS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(123,'OUADAHI','Djaffar','rue amar makhlouf m\chedallah bouira','0554180643','AG2R',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(124,'MIMOUNI','Salah','bp 474 tamanrasset','0550993505','MGSP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(128,'TOUMI','Ahmed','cite 5 juillet BP n° 294?In Salah?Tamanrasset','029360311','MNAM',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(133,'TRAD','Abd elkader','El Ogla el Malha?Tébessa','037447300','LMDE',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(137,'SAADI','Med Tayeb','route strategique 12000?Tébessa','037481154','MNH',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(138,'HALFAOUI','Redouane','Aderb krima rue des frères benchekra?Tlemcen','0779719617','MAAF',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(145,'KEDJNANE','Brahim','cité des 48 lgts?Sougueur?Tiaret','0663125949','MGEN',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(146,'FADEL','Abderahmane','Cité Rousseau Bt D?Tiaret','046451212','MMA',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(147,'BENNABI','Ahmed','cité 120 logts bt C n° 11. 15600?Tigzirt?Tizi Ouzou','026258494','CNAMTS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(148,'AKIL','Farid','3 rue Larbi Ben M\hidi?Draa El Mizan?Tizi Ouzou','026234316','CCVRP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(149,'DIAF','Ali','Rue Ali Abdelmoumen?Tigzirt?Tizi Ouzou','026259630','MNFTC',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(153,'CHERFI','Rabah','Hassi Bahbah?Hassi Bahbah?Djelfa','027863306','MAS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(154,'RABOUZI','Mohamed','Cité Mohamed Chaounan bloc 831?02?Djelfa','0665781440','AG2R',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(158,'HMIA','Seddik','25 rue Ben Yahiya?Jijel','034472300','MGSP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(159,'MERABET','Ourida','19 Av. Ben Yahiya?Jijel','034472300','MNAM',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(164,'OUALI','Samia','cité 200 logements bt1 n°1?Jijel','034501028','LMDE',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(166,'HADDAD','Fatiha','rue boufada lakhdarat?Ain Oulmène?Setif','036720221','MNH',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(167,'MATI','Djamel','Draa kebila hammam guergour sétif','0664504332','MAAF',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(168,'Maiza','Rima','Cité brarma n 5?Sétif','0774208681','MGEN',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(171,'RAFFAOUI','Meriem','Rue MERIEM BOUATOURA SETIF','0557541887','MMA',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(172,'ZERARGA','Mustapha','Cité Hachemi D2 N° 18 Sétif','0551269045','CNAMTS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(175,'OUCHERIT','Aissa','43,Rue Larbi Ben Mhidi-Oran','041406670','CCVRP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(181,'GHRAIR','Mohamed','Cité Jeanne d’Arc Ecran B5?Gambetta-Oran','041531208','MNFTC',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(182,'MOUHTADI','Dalila','6,Bd Tripoli-Oran','041391640','MAS',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(184,'CHALAH','Younes','cité des 60logts bt D n° 48?Naciria?Boumerdes','024880106','AG2R',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(187,'HAMIDI','Mahfoud','BP 24 G Frantz Fanon?Boumerdes','0771500169','MGSP',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(188,'TITOUCHE','Mohamed','Cité des 50 logts. Sidi Daoud?Boumerdes','024891120','MNAM',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(190,'BARKAT','Boubeker','CITE MENTOURI N 71 BT AB SMK Constantine','031688561','LMDE',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(191,'DJAKANI','Mostafa','hai nasr?Tindouf','049934241','MNH',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));
INSERT INTO PATIENT VALUES (tpatient(192,'HABABB','khadra','Cité lakssabi?Tindouf','049922543','MAAF',T_SET_REF_SOIGNE(), T_SET_REF_HOSPITALISATION()));


-- Table MEDECIN

INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (4,'Orthopédiste', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(7,'Cardiologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(8,'Cardiologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(10,'Cardiologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(19,'Traumatologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(24,'Orthopédiste', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(26,'Orthopédiste', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(27,'Orthopédiste', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(31,'Anesthésiste', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(34,'Pneumologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(50,'Pneumologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(53,'Traumatologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(54,'Pneumologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(64,'Radiologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(80,'Cardiologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(82,'Orthopédiste', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(85,'Anesthésiste', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(88,'Cardiologue ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(89,'Radiologue ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES(99,'Anesthésiste', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());

INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (113,'Pneumologue ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (114,'Traumatologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (122,'Pneumologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (126,'Radiologue', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (135,'Anesthésiste', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (140,'Cardiologue ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (141,'Traumatologue  ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (144,'Radiologue ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (152,'Cardiologue ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (179,'Anesthésiste ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (180,'Cardiologue ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());
INSERT INTO MEDECIN (NUM_MED, SPECIALITE, medecin_soigne, directeur_service) VALUES (196,'Traumatologue  ', T_SET_REF_SOIGNE(),T_SET_REF_SERVICE ());

-- TABLE SERVICE

INSERT INTO SERVICE VALUES (tservice('CAR','Cardiologie','B',(SELECT REF(m) FROM medecin m WHERE m.num_med = 80),T_SET_REF_infirmier(), T_SET_REF_CHAMBRE(), t_set_ref_hospitalisation() ));
INSERT INTO SERVICE VALUES(tservice('CHG','Chirurgie générale','A',(SELECT REF(m) FROM medecin m WHERE m.num_med = 34),T_SET_REF_infirmier(), T_SET_REF_CHAMBRE(), t_set_ref_hospitalisation()));
INSERT INTO SERVICE VALUES(tservice('REA','Réanimation et Traumatologie','A',(SELECT REF(m) FROM medecin m WHERE m.num_med = 19),T_SET_REF_infirmier(), T_SET_REF_CHAMBRE(), t_set_ref_hospitalisation()));


-- Table infirmier

INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(12,(SELECT REF(m) FROM service m WHERE m.code_service = 'REA'), 'JOUR',12560.78,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(15,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'), 'JOUR',11780.48,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(22,(SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),'JOUR',14980.21,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(25,(SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),'JOUR',15741.25,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(29,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'JOUR',13582.45,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(45,(SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),'JOUR',14653.25,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(49,(SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),'JOUR',12565.78,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(57,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'JOUR',17654.21,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(71,(SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),'NUIT',13357.86,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(73,(SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),'NUIT',14738.29,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(86,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'JOUR',11785.48,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(95,(SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),'NUIT',19470.61,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(97,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'NUIT',11840.26,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(98,(SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),'JOUR',14984.21,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(116,(SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),'JOUR',15747.25,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(127,(SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),'NUIT',12657.38,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(130,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'JOUR',13548.45,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(131,(SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),'JOUR',14655.25,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(139,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'NUIT',20374.82,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(151,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'JOUR',17685.21,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(155,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'NUIT',13335.86,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(162,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'NUIT',13841.29,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(163,(SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),'NUIT',14738.29,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(169,(SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),'NUIT',12947.61,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(176,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'NUIT',12184.26,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(189,(SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),'NUIT',13267.38,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(194,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'NUIT',22034.82,t_set_ref_chambre() );
INSERT INTO infirmier(NUM_INF, infirmier_service, ROTATION, SALAIRE,infirmier_chambre )  VALUES(195,(SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),'NUIT',12381.29,t_set_ref_chambre() );


-- Table CHAMBRE

INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),101,
(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =95), 3, T_SET_REF_HOSPITALISATION()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),
102,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =95),2,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),
103,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =95),1,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),
104,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =169),3,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),
105,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =169),2,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CAR'),
106,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =169),1,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
201,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =29),4,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
202,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =29),4,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
301,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =57),2,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
302,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =57),2,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
303,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =57),1,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
401,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =130),4,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
402,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =130),4,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
403,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =151),2,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
404,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =151),2,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'CHG'),
405,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =151),1,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),
101,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =12),1,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),
102,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =12),1,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),
103,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =22),2,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),
104,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =22),2,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),
105,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =49),1,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),
106,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =49),1,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),
107,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =49),2,T_SET_REF_HOSPITALISATION ()));
INSERT INTO CHAMBRE VALUES (tchambre((SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),
108,(SELECT REF(m) FROM infirmier m WHERE m.NUM_INF =116),2,T_SET_REF_HOSPITALISATION ()));


-- Table SOIGNE

drop sequence seq_person;
CREATE SEQUENCE seq_person
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;

desc soigne
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =13),(SELECT REF(m) FROM medecin m WHERE m.num_med=4)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =23),(SELECT REF(m) FROM medecin m WHERE m.num_med=4)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =63),(SELECT REF(m) FROM medecin m WHERE m.num_med=4)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =78),(SELECT REF(m) FROM medecin m WHERE m.num_med=4)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =81),(SELECT REF(m) FROM medecin m WHERE m.num_med=4)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =100),(SELECT REF(m) FROM medecin m WHERE m.num_med=4)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =109),(SELECT REF(m) FROM medecin m WHERE m.num_med=7)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =119),(SELECT REF(m) FROM medecin m WHERE m.num_med=7)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =133),(SELECT REF(m) FROM medecin m WHERE m.num_med=7)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =158),(SELECT REF(m) FROM medecin m WHERE m.num_med=7)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =175),(SELECT REF(m) FROM medecin m WHERE m.num_med=7)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =191),(SELECT REF(m) FROM medecin m WHERE m.num_med=7)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =13),(SELECT REF(m) FROM medecin m WHERE m.num_med=8)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =23),(SELECT REF(m) FROM medecin m WHERE m.num_med=8)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =35),(SELECT REF(m) FROM medecin m WHERE m.num_med=8)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =44),(SELECT REF(m) FROM medecin m WHERE m.num_med=8)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =14),(SELECT REF(m) FROM medecin m WHERE m.num_med=10)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =72),(SELECT REF(m) FROM medecin m WHERE m.num_med=10)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =75),(SELECT REF(m) FROM medecin m WHERE m.num_med=10)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =76),(SELECT REF(m) FROM medecin m WHERE m.num_med=10)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =92),(SELECT REF(m) FROM medecin m WHERE m.num_med=10)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =1),(SELECT REF(m) FROM medecin m WHERE m.num_med=19)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =21),(SELECT REF(m) FROM medecin m WHERE m.num_med=19)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =55),(SELECT REF(m) FROM medecin m WHERE m.num_med=19)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =145),(SELECT REF(m) FROM medecin m WHERE m.num_med=24)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =147),(SELECT REF(m) FROM medecin m WHERE m.num_med=24)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =35),(SELECT REF(m) FROM medecin m WHERE m.num_med=26)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =43),(SELECT REF(m) FROM medecin m WHERE m.num_med=26)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =61),(SELECT REF(m) FROM medecin m WHERE m.num_med=26)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =79),(SELECT REF(m) FROM medecin m WHERE m.num_med=26)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =101),(SELECT REF(m) FROM medecin m WHERE m.num_med=26)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =121),(SELECT REF(m) FROM medecin m WHERE m.num_med=27)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =128),(SELECT REF(m) FROM medecin m WHERE m.num_med=27)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =146),(SELECT REF(m) FROM medecin m WHERE m.num_med=27)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =164),(SELECT REF(m) FROM medecin m WHERE m.num_med=27)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =166),(SELECT REF(m) FROM medecin m WHERE m.num_med=27)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =184),(SELECT REF(m) FROM medecin m WHERE m.num_med=27)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =103),(SELECT REF(m) FROM medecin m WHERE m.num_med=31)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =145),(SELECT REF(m) FROM medecin m WHERE m.num_med=31)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =182),(SELECT REF(m) FROM medecin m WHERE m.num_med=31)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =6),(SELECT REF(m) FROM medecin m WHERE m.num_med=34)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =52),(SELECT REF(m) FROM medecin m WHERE m.num_med=34)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =61),(SELECT REF(m) FROM medecin m WHERE m.num_med=34)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =65),(SELECT REF(m) FROM medecin m WHERE m.num_med=34)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =66),(SELECT REF(m) FROM medecin m WHERE m.num_med=34)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =119),(SELECT REF(m) FROM medecin m WHERE m.num_med=50)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =138),(SELECT REF(m) FROM medecin m WHERE m.num_med=50)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =164),(SELECT REF(m) FROM medecin m WHERE m.num_med=50)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =171),(SELECT REF(m) FROM medecin m WHERE m.num_med=50)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =181),(SELECT REF(m) FROM medecin m WHERE m.num_med=50)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =3),(SELECT REF(m) FROM medecin m WHERE m.num_med=53)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =33),(SELECT REF(m) FROM medecin m WHERE m.num_med=53)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =46),(SELECT REF(m) FROM medecin m WHERE m.num_med=53)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =60),(SELECT REF(m) FROM medecin m WHERE m.num_med=53)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =70),(SELECT REF(m) FROM medecin m WHERE m.num_med=53)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =90),(SELECT REF(m) FROM medecin m WHERE m.num_med=53)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =120),(SELECT REF(m) FROM medecin m WHERE m.num_med=54)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =147),(SELECT REF(m) FROM medecin m WHERE m.num_med=54)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =21),(SELECT REF(m) FROM medecin m WHERE m.num_med=64)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =68),(SELECT REF(m) FROM medecin m WHERE m.num_med=64)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =76),(SELECT REF(m) FROM medecin m WHERE m.num_med=64)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =74),(SELECT REF(m) FROM medecin m WHERE m.num_med=80)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =76),(SELECT REF(m) FROM medecin m WHERE m.num_med=80)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =108),(SELECT REF(m) FROM medecin m WHERE m.num_med=82)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =117),(SELECT REF(m) FROM medecin m WHERE m.num_med=82)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =137),(SELECT REF(m) FROM medecin m WHERE m.num_med=82)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =159),(SELECT REF(m) FROM medecin m WHERE m.num_med=82)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =1),(SELECT REF(m) FROM medecin m WHERE m.num_med=85)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =3),(SELECT REF(m) FROM medecin m WHERE m.num_med=85)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =6),(SELECT REF(m) FROM medecin m WHERE m.num_med=85)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =43),(SELECT REF(m) FROM medecin m WHERE m.num_med=85)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =46),(SELECT REF(m) FROM medecin m WHERE m.num_med=85)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =52),(SELECT REF(m) FROM medecin m WHERE m.num_med=85)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =76),(SELECT REF(m) FROM medecin m WHERE m.num_med=85)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =23),(SELECT REF(m) FROM medecin m WHERE m.num_med=88)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =41),(SELECT REF(m) FROM medecin m WHERE m.num_med=88)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =52),(SELECT REF(m) FROM medecin m WHERE m.num_med=88)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =56),(SELECT REF(m) FROM medecin m WHERE m.num_med=88)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =68),(SELECT REF(m) FROM medecin m WHERE m.num_med=88)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =77),(SELECT REF(m) FROM medecin m WHERE m.num_med=88)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =78),(SELECT REF(m) FROM medecin m WHERE m.num_med=88)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =100),(SELECT REF(m) FROM medecin m WHERE m.num_med=88)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =103),(SELECT REF(m) FROM medecin m WHERE m.num_med=89)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =107),(SELECT REF(m) FROM medecin m WHERE m.num_med=89)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =123),(SELECT REF(m) FROM medecin m WHERE m.num_med=89)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =137),(SELECT REF(m) FROM medecin m WHERE m.num_med=89)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =146),(SELECT REF(m) FROM medecin m WHERE m.num_med=89)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =147),(SELECT REF(m) FROM medecin m WHERE m.num_med=89)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =182),(SELECT REF(m) FROM medecin m WHERE m.num_med=89)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =108),(SELECT REF(m) FROM medecin m WHERE m.num_med=99)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =123),(SELECT REF(m) FROM medecin m WHERE m.num_med=99)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =172),(SELECT REF(m) FROM medecin m WHERE m.num_med=99)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =37),(SELECT REF(m) FROM medecin m WHERE m.num_med=113)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =41),(SELECT REF(m) FROM medecin m WHERE m.num_med=113)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =44),(SELECT REF(m) FROM medecin m WHERE m.num_med=113)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =67),(SELECT REF(m) FROM medecin m WHERE m.num_med=113)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =81),(SELECT REF(m) FROM medecin m WHERE m.num_med=113)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =102),(SELECT REF(m) FROM medecin m WHERE m.num_med=113)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =6),(SELECT REF(m) FROM medecin m WHERE m.num_med=114)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =13),(SELECT REF(m) FROM medecin m WHERE m.num_med=114)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =36),(SELECT REF(m) FROM medecin m WHERE m.num_med=114)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =63),(SELECT REF(m) FROM medecin m WHERE m.num_med=114)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =91),(SELECT REF(m) FROM medecin m WHERE m.num_med=114)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =70),(SELECT REF(m) FROM medecin m WHERE m.num_med=122)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =91),(SELECT REF(m) FROM medecin m WHERE m.num_med=122)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =102),(SELECT REF(m) FROM medecin m WHERE m.num_med=122)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =3),(SELECT REF(m) FROM medecin m WHERE m.num_med=126)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =36),(SELECT REF(m) FROM medecin m WHERE m.num_med=126)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =41),(SELECT REF(m) FROM medecin m WHERE m.num_med=126)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =74),(SELECT REF(m) FROM medecin m WHERE m.num_med=126)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =77),(SELECT REF(m) FROM medecin m WHERE m.num_med=126)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =6),(SELECT REF(m) FROM medecin m WHERE m.num_med=135)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =21),(SELECT REF(m) FROM medecin m WHERE m.num_med=135)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =33),(SELECT REF(m) FROM medecin m WHERE m.num_med=135)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =36),(SELECT REF(m) FROM medecin m WHERE m.num_med=135)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =55),(SELECT REF(m) FROM medecin m WHERE m.num_med=135)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =56),(SELECT REF(m) FROM medecin m WHERE m.num_med=135)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =61),(SELECT REF(m) FROM medecin m WHERE m.num_med=135)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =68),(SELECT REF(m) FROM medecin m WHERE m.num_med=135)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =104),(SELECT REF(m) FROM medecin m WHERE m.num_med=140)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =124),(SELECT REF(m) FROM medecin m WHERE m.num_med=140)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =148),(SELECT REF(m) FROM medecin m WHERE m.num_med=140)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =168),(SELECT REF(m) FROM medecin m WHERE m.num_med=140)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =172),(SELECT REF(m) FROM medecin m WHERE m.num_med=140)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =187),(SELECT REF(m) FROM medecin m WHERE m.num_med=140)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =188),(SELECT REF(m) FROM medecin m WHERE m.num_med=140)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =192),(SELECT REF(m) FROM medecin m WHERE m.num_med=140)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =105),(SELECT REF(m) FROM medecin m WHERE m.num_med=141)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =107),(SELECT REF(m) FROM medecin m WHERE m.num_med=141)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =117),(SELECT REF(m) FROM medecin m WHERE m.num_med=141)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =128),(SELECT REF(m) FROM medecin m WHERE m.num_med=141)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =147),(SELECT REF(m) FROM medecin m WHERE m.num_med=141)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =153),(SELECT REF(m) FROM medecin m WHERE m.num_med=141)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =171),(SELECT REF(m) FROM medecin m WHERE m.num_med=141)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =184),(SELECT REF(m) FROM medecin m WHERE m.num_med=141)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =190),(SELECT REF(m) FROM medecin m WHERE m.num_med=141)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =108),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =119),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =120),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =145),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =153),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =154),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =159),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =181),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =184),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =192),(SELECT REF(m) FROM medecin m WHERE m.num_med=144)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =123),(SELECT REF(m) FROM medecin m WHERE m.num_med=152)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =145),(SELECT REF(m) FROM medecin m WHERE m.num_med=152)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =149),(SELECT REF(m) FROM medecin m WHERE m.num_med=152)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =159),(SELECT REF(m) FROM medecin m WHERE m.num_med=152)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =167),(SELECT REF(m) FROM medecin m WHERE m.num_med=152)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =105),(SELECT REF(m) FROM medecin m WHERE m.num_med=179)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =117),(SELECT REF(m) FROM medecin m WHERE m.num_med=179)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =154),(SELECT REF(m) FROM medecin m WHERE m.num_med=179)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =192),(SELECT REF(m) FROM medecin m WHERE m.num_med=179)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =103),(SELECT REF(m) FROM medecin m WHERE m.num_med=180)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =105),(SELECT REF(m) FROM medecin m WHERE m.num_med=180)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =172),(SELECT REF(m) FROM medecin m WHERE m.num_med=180)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =182),(SELECT REF(m) FROM medecin m WHERE m.num_med=180)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =108),(SELECT REF(m) FROM medecin m WHERE m.num_med=196)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =117),(SELECT REF(m) FROM medecin m WHERE m.num_med=196)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =159),(SELECT REF(m) FROM medecin m WHERE m.num_med=196)));
INSERT INTO SOIGNE VALUES (tsoigne( seq_person.nextval,(SELECT REF(m) FROM patient m WHERE m.num_patient =172),(SELECT REF(m) FROM medecin m WHERE m.num_med=196)));


-- Table HOSPITALISATION

drop sequence seq_hospitalisation;
CREATE SEQUENCE seq_hospitalisation
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;

INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =1),(SELECT ref(m) FROM service m WHERE m.code_service = 'REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =101),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =3),(SELECT REF(m) FROM service m WHERE m.code_service = 'REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =102),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =6),(SELECT REF(m) FROM service m WHERE m.code_service ='REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =103),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =21),(SELECT REF(m) FROM service m WHERE m.code_service ='REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =103),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =33),(SELECT REF(m) FROM service m WHERE m.code_service ='REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =104),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =36),(SELECT REF(m) FROM service m WHERE m.code_service ='REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =104),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =37),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =201),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =41),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =201),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =43),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =201),3));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =46),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =202),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =52),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =202),3));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =55),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =202),4));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =56),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =301),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =61),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =301),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =65),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =302),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =66),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =302),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =67),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =303),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =68),(SELECT REF(m) FROM service m WHERE m.code_service ='CAR'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =101),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =72),(SELECT REF(m) FROM service m WHERE m.code_service ='CAR'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =101),3));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =74),(SELECT REF(m) FROM service m WHERE m.code_service ='CAR'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =102),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =76),(SELECT REF(m) FROM service m WHERE m.code_service ='CAR'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =102),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =77),(SELECT REF(m) FROM service m WHERE m.code_service ='CAR'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =103),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =103),(SELECT REF(m) FROM service m WHERE m.code_service ='REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =105),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =105),(SELECT REF(m) FROM service m WHERE m.code_service ='REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =107),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =108),(SELECT REF(m) FROM service m WHERE m.code_service ='REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =107),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =117),(SELECT REF(m) FROM service m WHERE m.code_service ='REA'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =108),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =120),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =401),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =123),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =401),4));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =137),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =402),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =145),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =402),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =147),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =402),3));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =149),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =403),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =154),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =403),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =159),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =404),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =167),(SELECT REF(m) FROM service m WHERE m.code_service ='CHG'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =405),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =172),(SELECT REF(m) FROM service m WHERE m.code_service ='CAR'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =104),1));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =182),(SELECT REF(m) FROM service m WHERE m.code_service ='CAR'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =104),3));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =188),(SELECT REF(m) FROM service m WHERE m.code_service ='CAR'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =105),2));
INSERT INTO HOSPITALISATION  VALUES (thospitalisation(seq_hospitalisation.nextval,(SELECT REF(m) FROM patient  m WHERE m.NUM_PATIENT =192),(SELECT REF(m) FROM service m WHERE m.code_service ='CAR'),(SELECT REF(m) FROM chambre m WHERE m.num_chambre =106),1));

/**************************************/

/***********************************/
/************ UPDATE TABLE IMBRIQUE **************/

 /* Mettre à jour de la table imbriquée  patient_soigne */
 
insert into table (select m.patient_soigne from patient m where num_patient=13) (select ref(s) from soigne s where num_soigne= 1);
insert into table (select m.Patient_soigne from patient m where num_patient=23) (select ref(s) from soigne s where num_soigne= 2);
insert into table (select m.Patient_soigne from patient m where num_patient=63) (select ref(s) from soigne s where num_soigne= 3);
insert into table (select m.Patient_soigne from patient m where num_patient=78) (select ref(s) from soigne s where num_soigne= 4);
insert into table (select m.Patient_soigne from patient m where num_patient=81) (select ref(s) from soigne s where num_soigne= 5);
insert into table (select m.Patient_soigne from patient m where num_patient=100) (select ref(s) from soigne s where num_soigne= 6);
insert into table (select m.Patient_soigne from patient m where num_patient=109) (select ref(s) from soigne s where num_soigne= 7);
insert into table (select m.Patient_soigne from patient m where num_patient=119) (select ref(s) from soigne s where num_soigne= 8);
insert into table (select m.Patient_soigne from patient m where num_patient=133) (select ref(s) from soigne s where num_soigne= 9);
insert into table (select m.Patient_soigne from patient m where num_patient=158) (select ref(s) from soigne s where num_soigne= 10);
insert into table (select m.Patient_soigne from patient m where num_patient=175) (select ref(s) from soigne s where num_soigne= 11);
insert into table (select m.Patient_soigne from patient m where num_patient=191) (select ref(s) from soigne s where num_soigne= 12);
insert into table (select m.Patient_soigne from patient m where num_patient=13) (select ref(s) from soigne s where num_soigne= 13);
insert into table (select m.Patient_soigne from patient m where num_patient=23) (select ref(s) from soigne s where num_soigne= 14);
insert into table (select m.Patient_soigne from patient m where num_patient=35) (select ref(s) from soigne s where num_soigne= 15);
insert into table (select m.Patient_soigne from patient m where num_patient=44) (select ref(s) from soigne s where num_soigne= 16);
insert into table (select m.Patient_soigne from patient m where num_patient=14) (select ref(s) from soigne s where num_soigne= 17);
insert into table (select m.Patient_soigne from patient m where num_patient=72) (select ref(s) from soigne s where num_soigne= 18);
insert into table (select m.Patient_soigne from patient m where num_patient=75) (select ref(s) from soigne s where num_soigne= 19);
insert into table (select m.Patient_soigne from patient m where num_patient=76) (select ref(s) from soigne s where num_soigne= 20);
insert into table (select m.Patient_soigne from patient m where num_patient=92) (select ref(s) from soigne s where num_soigne= 21);
insert into table (select m.Patient_soigne from patient m where num_patient=1) (select ref(s) from soigne s where num_soigne= 22);
insert into table (select m.Patient_soigne from patient m where num_patient=21) (select ref(s) from soigne s where num_soigne= 23);
insert into table (select m.Patient_soigne from patient m where num_patient=55) (select ref(s) from soigne s where num_soigne= 24);
insert into table (select m.Patient_soigne from patient m where num_patient=145) (select ref(s) from soigne s where num_soigne= 25);
insert into table (select m.Patient_soigne from patient m where num_patient=147) (select ref(s) from soigne s where num_soigne= 26);
insert into table (select m.Patient_soigne from patient m where num_patient=35) (select ref(s) from soigne s where num_soigne= 27);
insert into table (select m.Patient_soigne from patient m where num_patient=43) (select ref(s) from soigne s where num_soigne= 28);
insert into table (select m.Patient_soigne from patient m where num_patient=61) (select ref(s) from soigne s where num_soigne= 29);
insert into table (select m.Patient_soigne from patient m where num_patient=79) (select ref(s) from soigne s where num_soigne= 30);
insert into table (select m.Patient_soigne from patient m where num_patient=101) (select ref(s) from soigne s where num_soigne= 31);
insert into table (select m.Patient_soigne from patient m where num_patient=121) (select ref(s) from soigne s where num_soigne= 32);
insert into table (select m.Patient_soigne from patient m where num_patient=128) (select ref(s) from soigne s where num_soigne= 33);
insert into table (select m.Patient_soigne from patient m where num_patient=146) (select ref(s) from soigne s where num_soigne= 34);
insert into table (select m.Patient_soigne from patient m where num_patient=164) (select ref(s) from soigne s where num_soigne= 35);
insert into table (select m.Patient_soigne from patient m where num_patient=166) (select ref(s) from soigne s where num_soigne= 36);
insert into table (select m.Patient_soigne from patient m where num_patient=184) (select ref(s) from soigne s where num_soigne= 37);
insert into table (select m.Patient_soigne from patient m where num_patient=103) (select ref(s) from soigne s where num_soigne= 38);
insert into table (select m.Patient_soigne from patient m where num_patient=145) (select ref(s) from soigne s where num_soigne= 39);
insert into table (select m.Patient_soigne from patient m where num_patient=182) (select ref(s) from soigne s where num_soigne= 40);
insert into table (select m.Patient_soigne from patient m where num_patient=6) (select ref(s) from soigne s where num_soigne= 41);
insert into table (select m.Patient_soigne from patient m where num_patient=52) (select ref(s) from soigne s where num_soigne= 42);
insert into table (select m.Patient_soigne from patient m where num_patient=61) (select ref(s) from soigne s where num_soigne= 43);
insert into table (select m.Patient_soigne from patient m where num_patient=65) (select ref(s) from soigne s where num_soigne= 44);
insert into table (select m.Patient_soigne from patient m where num_patient=66) (select ref(s) from soigne s where num_soigne= 45);
insert into table (select m.Patient_soigne from patient m where num_patient=119) (select ref(s) from soigne s where num_soigne= 46);
insert into table (select m.Patient_soigne from patient m where num_patient=138) (select ref(s) from soigne s where num_soigne= 47);
insert into table (select m.Patient_soigne from patient m where num_patient=164) (select ref(s) from soigne s where num_soigne= 48);
insert into table (select m.Patient_soigne from patient m where num_patient=171) (select ref(s) from soigne s where num_soigne= 49);
insert into table (select m.Patient_soigne from patient m where num_patient=181) (select ref(s) from soigne s where num_soigne= 50);
insert into table (select m.Patient_soigne from patient m where num_patient=3) (select ref(s) from soigne s where num_soigne= 51);
insert into table (select m.Patient_soigne from patient m where num_patient=33) (select ref(s) from soigne s where num_soigne= 52);
insert into table (select m.Patient_soigne from patient m where num_patient=46) (select ref(s) from soigne s where num_soigne= 53);
insert into table (select m.Patient_soigne from patient m where num_patient=60) (select ref(s) from soigne s where num_soigne= 54);
insert into table (select m.Patient_soigne from patient m where num_patient=70) (select ref(s) from soigne s where num_soigne= 55);
insert into table (select m.Patient_soigne from patient m where num_patient=90) (select ref(s) from soigne s where num_soigne= 56);
insert into table (select m.Patient_soigne from patient m where num_patient=120) (select ref(s) from soigne s where num_soigne= 57);
insert into table (select m.Patient_soigne from patient m where num_patient=147) (select ref(s) from soigne s where num_soigne= 58);
insert into table (select m.Patient_soigne from patient m where num_patient=21) (select ref(s) from soigne s where num_soigne= 59);
insert into table (select m.Patient_soigne from patient m where num_patient=68) (select ref(s) from soigne s where num_soigne= 60);
insert into table (select m.Patient_soigne from patient m where num_patient=76) (select ref(s) from soigne s where num_soigne= 61);
insert into table (select m.Patient_soigne from patient m where num_patient=74) (select ref(s) from soigne s where num_soigne= 62);
insert into table (select m.Patient_soigne from patient m where num_patient=76) (select ref(s) from soigne s where num_soigne= 63);
insert into table (select m.Patient_soigne from patient m where num_patient=108) (select ref(s) from soigne s where num_soigne= 64);
insert into table (select m.Patient_soigne from patient m where num_patient=117) (select ref(s) from soigne s where num_soigne= 65);
insert into table (select m.Patient_soigne from patient m where num_patient=137) (select ref(s) from soigne s where num_soigne= 66);
insert into table (select m.Patient_soigne from patient m where num_patient=159) (select ref(s) from soigne s where num_soigne= 67);
insert into table (select m.Patient_soigne from patient m where num_patient=1) (select ref(s) from soigne s where num_soigne= 68);
insert into table (select m.Patient_soigne from patient m where num_patient=3) (select ref(s) from soigne s where num_soigne= 69);
insert into table (select m.Patient_soigne from patient m where num_patient=6) (select ref(s) from soigne s where num_soigne= 70);
insert into table (select m.Patient_soigne from patient m where num_patient=43) (select ref(s) from soigne s where num_soigne= 71);
insert into table (select m.Patient_soigne from patient m where num_patient=46) (select ref(s) from soigne s where num_soigne= 72);
insert into table (select m.Patient_soigne from patient m where num_patient=52) (select ref(s) from soigne s where num_soigne= 73);
insert into table (select m.Patient_soigne from patient m where num_patient=76) (select ref(s) from soigne s where num_soigne= 74);
insert into table (select m.Patient_soigne from patient m where num_patient=23) (select ref(s) from soigne s where num_soigne= 75);
insert into table (select m.Patient_soigne from patient m where num_patient=41) (select ref(s) from soigne s where num_soigne= 76);
insert into table (select m.Patient_soigne from patient m where num_patient=52) (select ref(s) from soigne s where num_soigne= 77);
insert into table (select m.Patient_soigne from patient m where num_patient=56) (select ref(s) from soigne s where num_soigne= 78);
insert into table (select m.Patient_soigne from patient m where num_patient=68) (select ref(s) from soigne s where num_soigne= 79);
insert into table (select m.Patient_soigne from patient m where num_patient=77) (select ref(s) from soigne s where num_soigne= 80);
insert into table (select m.Patient_soigne from patient m where num_patient=78) (select ref(s) from soigne s where num_soigne= 81);
insert into table (select m.Patient_soigne from patient m where num_patient=100) (select ref(s) from soigne s where num_soigne= 82);
insert into table (select m.Patient_soigne from patient m where num_patient=103) (select ref(s) from soigne s where num_soigne= 83);
insert into table (select m.Patient_soigne from patient m where num_patient=107) (select ref(s) from soigne s where num_soigne= 84);
insert into table (select m.Patient_soigne from patient m where num_patient=123) (select ref(s) from soigne s where num_soigne= 85);
insert into table (select m.Patient_soigne from patient m where num_patient=137) (select ref(s) from soigne s where num_soigne= 86);
insert into table (select m.Patient_soigne from patient m where num_patient=146) (select ref(s) from soigne s where num_soigne= 87);
insert into table (select m.Patient_soigne from patient m where num_patient=147) (select ref(s) from soigne s where num_soigne= 88);
insert into table (select m.Patient_soigne from patient m where num_patient=182) (select ref(s) from soigne s where num_soigne= 89);
insert into table (select m.Patient_soigne from patient m where num_patient=108) (select ref(s) from soigne s where num_soigne= 90);
insert into table (select m.Patient_soigne from patient m where num_patient=123) (select ref(s) from soigne s where num_soigne= 91);
insert into table (select m.Patient_soigne from patient m where num_patient=172) (select ref(s) from soigne s where num_soigne= 92);
insert into table (select m.Patient_soigne from patient m where num_patient=37) (select ref(s) from soigne s where num_soigne= 93);
insert into table (select m.Patient_soigne from patient m where num_patient=41) (select ref(s) from soigne s where num_soigne= 94);
insert into table (select m.Patient_soigne from patient m where num_patient=44) (select ref(s) from soigne s where num_soigne= 95);
insert into table (select m.Patient_soigne from patient m where num_patient=67) (select ref(s) from soigne s where num_soigne= 96);
insert into table (select m.Patient_soigne from patient m where num_patient=81) (select ref(s) from soigne s where num_soigne= 97);
insert into table (select m.Patient_soigne from patient m where num_patient=102) (select ref(s) from soigne s where num_soigne= 98);
insert into table (select m.Patient_soigne from patient m where num_patient=6) (select ref(s) from soigne s where num_soigne= 99);
insert into table (select m.Patient_soigne from patient m where num_patient=13) (select ref(s) from soigne s where num_soigne= 100);
insert into table (select m.Patient_soigne from patient m where num_patient=36) (select ref(s) from soigne s where num_soigne= 101);
insert into table (select m.Patient_soigne from patient m where num_patient=63) (select ref(s) from soigne s where num_soigne= 102);
insert into table (select m.Patient_soigne from patient m where num_patient=91) (select ref(s) from soigne s where num_soigne= 103);
insert into table (select m.Patient_soigne from patient m where num_patient=70) (select ref(s) from soigne s where num_soigne= 104);
insert into table (select m.Patient_soigne from patient m where num_patient=91) (select ref(s) from soigne s where num_soigne= 105);
insert into table (select m.Patient_soigne from patient m where num_patient=102) (select ref(s) from soigne s where num_soigne= 106);
insert into table (select m.Patient_soigne from patient m where num_patient=3) (select ref(s) from soigne s where num_soigne= 107);
insert into table (select m.Patient_soigne from patient m where num_patient=36) (select ref(s) from soigne s where num_soigne= 108);
insert into table (select m.Patient_soigne from patient m where num_patient=41) (select ref(s) from soigne s where num_soigne= 109);
insert into table (select m.Patient_soigne from patient m where num_patient=74) (select ref(s) from soigne s where num_soigne= 110);
insert into table (select m.Patient_soigne from patient m where num_patient=77) (select ref(s) from soigne s where num_soigne= 111);
insert into table (select m.Patient_soigne from patient m where num_patient=6) (select ref(s) from soigne s where num_soigne= 112);
insert into table (select m.Patient_soigne from patient m where num_patient=21) (select ref(s) from soigne s where num_soigne= 113);
insert into table (select m.Patient_soigne from patient m where num_patient=33) (select ref(s) from soigne s where num_soigne= 114);
insert into table (select m.Patient_soigne from patient m where num_patient=36) (select ref(s) from soigne s where num_soigne= 115);
insert into table (select m.Patient_soigne from patient m where num_patient=55) (select ref(s) from soigne s where num_soigne= 116);
insert into table (select m.Patient_soigne from patient m where num_patient=56) (select ref(s) from soigne s where num_soigne= 117);
insert into table (select m.Patient_soigne from patient m where num_patient=61) (select ref(s) from soigne s where num_soigne= 118);
insert into table (select m.Patient_soigne from patient m where num_patient=68) (select ref(s) from soigne s where num_soigne= 119);
insert into table (select m.Patient_soigne from patient m where num_patient=104) (select ref(s) from soigne s where num_soigne= 120);
insert into table (select m.Patient_soigne from patient m where num_patient=124) (select ref(s) from soigne s where num_soigne= 121);
insert into table (select m.Patient_soigne from patient m where num_patient=148) (select ref(s) from soigne s where num_soigne= 122);
insert into table (select m.Patient_soigne from patient m where num_patient=168) (select ref(s) from soigne s where num_soigne= 123);
insert into table (select m.Patient_soigne from patient m where num_patient=172) (select ref(s) from soigne s where num_soigne= 124);
insert into table (select m.Patient_soigne from patient m where num_patient=187) (select ref(s) from soigne s where num_soigne= 125);
insert into table (select m.Patient_soigne from patient m where num_patient=188) (select ref(s) from soigne s where num_soigne= 126);
insert into table (select m.Patient_soigne from patient m where num_patient=192) (select ref(s) from soigne s where num_soigne= 127);
insert into table (select m.Patient_soigne from patient m where num_patient=105) (select ref(s) from soigne s where num_soigne= 128);
insert into table (select m.Patient_soigne from patient m where num_patient=107) (select ref(s) from soigne s where num_soigne= 129);
insert into table (select m.Patient_soigne from patient m where num_patient=117) (select ref(s) from soigne s where num_soigne= 130);
insert into table (select m.Patient_soigne from patient m where num_patient=128) (select ref(s) from soigne s where num_soigne= 131);
insert into table (select m.Patient_soigne from patient m where num_patient=147) (select ref(s) from soigne s where num_soigne= 132);
insert into table (select m.Patient_soigne from patient m where num_patient=153) (select ref(s) from soigne s where num_soigne= 133);
insert into table (select m.Patient_soigne from patient m where num_patient=171) (select ref(s) from soigne s where num_soigne= 134);
insert into table (select m.Patient_soigne from patient m where num_patient=184) (select ref(s) from soigne s where num_soigne= 135);
insert into table (select m.Patient_soigne from patient m where num_patient=190) (select ref(s) from soigne s where num_soigne= 136);
insert into table (select m.Patient_soigne from patient m where num_patient=108) (select ref(s) from soigne s where num_soigne= 137);
insert into table (select m.Patient_soigne from patient m where num_patient=119) (select ref(s) from soigne s where num_soigne= 138);
insert into table (select m.Patient_soigne from patient m where num_patient=120) (select ref(s) from soigne s where num_soigne= 139);
insert into table (select m.Patient_soigne from patient m where num_patient=145) (select ref(s) from soigne s where num_soigne= 140);
insert into table (select m.Patient_soigne from patient m where num_patient=153) (select ref(s) from soigne s where num_soigne= 141);
insert into table (select m.Patient_soigne from patient m where num_patient=154) (select ref(s) from soigne s where num_soigne= 142);
insert into table (select m.Patient_soigne from patient m where num_patient=159) (select ref(s) from soigne s where num_soigne= 143);
insert into table (select m.Patient_soigne from patient m where num_patient=181) (select ref(s) from soigne s where num_soigne= 144);
insert into table (select m.Patient_soigne from patient m where num_patient=184) (select ref(s) from soigne s where num_soigne= 145);
insert into table (select m.Patient_soigne from patient m where num_patient=192) (select ref(s) from soigne s where num_soigne= 146);
insert into table (select m.Patient_soigne from patient m where num_patient=123) (select ref(s) from soigne s where num_soigne= 147);
insert into table (select m.Patient_soigne from patient m where num_patient=145) (select ref(s) from soigne s where num_soigne= 148);
insert into table (select m.Patient_soigne from patient m where num_patient=149) (select ref(s) from soigne s where num_soigne= 149);
insert into table (select m.Patient_soigne from patient m where num_patient=159) (select ref(s) from soigne s where num_soigne= 150);
insert into table (select m.Patient_soigne from patient m where num_patient=167) (select ref(s) from soigne s where num_soigne= 151);
insert into table (select m.Patient_soigne from patient m where num_patient=105) (select ref(s) from soigne s where num_soigne= 152);
insert into table (select m.Patient_soigne from patient m where num_patient=117) (select ref(s) from soigne s where num_soigne= 153);
insert into table (select m.Patient_soigne from patient m where num_patient=154) (select ref(s) from soigne s where num_soigne= 154);
insert into table (select m.Patient_soigne from patient m where num_patient=192) (select ref(s) from soigne s where num_soigne= 155);
insert into table (select m.Patient_soigne from patient m where num_patient=103) (select ref(s) from soigne s where num_soigne= 156);
insert into table (select m.Patient_soigne from patient m where num_patient=105) (select ref(s) from soigne s where num_soigne= 157);
insert into table (select m.Patient_soigne from patient m where num_patient=172) (select ref(s) from soigne s where num_soigne= 158);
insert into table (select m.Patient_soigne from patient m where num_patient=182) (select ref(s) from soigne s where num_soigne= 159);
insert into table (select m.Patient_soigne from patient m where num_patient=108) (select ref(s) from soigne s where num_soigne= 160);
insert into table (select m.Patient_soigne from patient m where num_patient=117) (select ref(s) from soigne s where num_soigne= 161);
insert into table (select m.Patient_soigne from patient m where num_patient=159) (select ref(s) from soigne s where num_soigne= 162);
insert into table (select m.Patient_soigne from patient m where num_patient=172) (select ref(s) from soigne s where num_soigne= 163);


 
 
/* Mettre à jour de la table imbriquée  medecin_soigne */

insert into table (select m.medecin_soigne from medecin m where num_med=4) (select ref(s) from soigne s where num_soigne= 1);
insert into table (select m.medecin_soigne from medecin m where num_med=4) (select ref(s) from soigne s where num_soigne= 2);
insert into table (select m.medecin_soigne from medecin m where num_med=4) (select ref(s) from soigne s where num_soigne= 3);
insert into table (select m.medecin_soigne from medecin m where num_med=4) (select ref(s) from soigne s where num_soigne= 4);
insert into table (select m.medecin_soigne from medecin m where num_med=4) (select ref(s) from soigne s where num_soigne= 5);
insert into table (select m.medecin_soigne from medecin m where num_med=4) (select ref(s) from soigne s where num_soigne= 6);
insert into table (select m.medecin_soigne from medecin m where num_med=7) (select ref(s) from soigne s where num_soigne= 7);
insert into table (select m.medecin_soigne from medecin m where num_med=7) (select ref(s) from soigne s where num_soigne= 8);
insert into table (select m.medecin_soigne from medecin m where num_med=7) (select ref(s) from soigne s where num_soigne= 9);
insert into table (select m.medecin_soigne from medecin m where num_med=7) (select ref(s) from soigne s where num_soigne= 10);
insert into table (select m.medecin_soigne from medecin m where num_med=7) (select ref(s) from soigne s where num_soigne= 11);
insert into table (select m.medecin_soigne from medecin m where num_med=7) (select ref(s) from soigne s where num_soigne= 12);
insert into table (select m.medecin_soigne from medecin m where num_med=8) (select ref(s) from soigne s where num_soigne= 13);
insert into table (select m.medecin_soigne from medecin m where num_med=8) (select ref(s) from soigne s where num_soigne= 14);
insert into table (select m.medecin_soigne from medecin m where num_med=8) (select ref(s) from soigne s where num_soigne= 15);
insert into table (select m.medecin_soigne from medecin m where num_med=8) (select ref(s) from soigne s where num_soigne= 16);
insert into table (select m.medecin_soigne from medecin m where num_med=10) (select ref(s) from soigne s where num_soigne= 17);
insert into table (select m.medecin_soigne from medecin m where num_med=10) (select ref(s) from soigne s where num_soigne= 18);
insert into table (select m.medecin_soigne from medecin m where num_med=10) (select ref(s) from soigne s where num_soigne= 19);
insert into table (select m.medecin_soigne from medecin m where num_med=10) (select ref(s) from soigne s where num_soigne= 20);
insert into table (select m.medecin_soigne from medecin m where num_med=10) (select ref(s) from soigne s where num_soigne= 21);
insert into table (select m.medecin_soigne from medecin m where num_med=19) (select ref(s) from soigne s where num_soigne= 22);
insert into table (select m.medecin_soigne from medecin m where num_med=19) (select ref(s) from soigne s where num_soigne= 23);
insert into table (select m.medecin_soigne from medecin m where num_med=19) (select ref(s) from soigne s where num_soigne= 24);
insert into table (select m.medecin_soigne from medecin m where num_med=24) (select ref(s) from soigne s where num_soigne= 25);
insert into table (select m.medecin_soigne from medecin m where num_med=24) (select ref(s) from soigne s where num_soigne= 26);
insert into table (select m.medecin_soigne from medecin m where num_med=26) (select ref(s) from soigne s where num_soigne= 27);
insert into table (select m.medecin_soigne from medecin m where num_med=26) (select ref(s) from soigne s where num_soigne= 28);
insert into table (select m.medecin_soigne from medecin m where num_med=26) (select ref(s) from soigne s where num_soigne= 29);
insert into table (select m.medecin_soigne from medecin m where num_med=26) (select ref(s) from soigne s where num_soigne= 30);
insert into table (select m.medecin_soigne from medecin m where num_med=26) (select ref(s) from soigne s where num_soigne= 31);
insert into table (select m.medecin_soigne from medecin m where num_med=27) (select ref(s) from soigne s where num_soigne= 32);
insert into table (select m.medecin_soigne from medecin m where num_med=27) (select ref(s) from soigne s where num_soigne= 33);
insert into table (select m.medecin_soigne from medecin m where num_med=27) (select ref(s) from soigne s where num_soigne= 34);
insert into table (select m.medecin_soigne from medecin m where num_med=27) (select ref(s) from soigne s where num_soigne= 35);
insert into table (select m.medecin_soigne from medecin m where num_med=27) (select ref(s) from soigne s where num_soigne= 36);
insert into table (select m.medecin_soigne from medecin m where num_med=27) (select ref(s) from soigne s where num_soigne= 37);
insert into table (select m.medecin_soigne from medecin m where num_med=31) (select ref(s) from soigne s where num_soigne= 38);
insert into table (select m.medecin_soigne from medecin m where num_med=31) (select ref(s) from soigne s where num_soigne= 39);
insert into table (select m.medecin_soigne from medecin m where num_med=31) (select ref(s) from soigne s where num_soigne= 40);
insert into table (select m.medecin_soigne from medecin m where num_med=34) (select ref(s) from soigne s where num_soigne= 41);
insert into table (select m.medecin_soigne from medecin m where num_med=34) (select ref(s) from soigne s where num_soigne= 42);
insert into table (select m.medecin_soigne from medecin m where num_med=34) (select ref(s) from soigne s where num_soigne= 43);
insert into table (select m.medecin_soigne from medecin m where num_med=34) (select ref(s) from soigne s where num_soigne= 44);
insert into table (select m.medecin_soigne from medecin m where num_med=34) (select ref(s) from soigne s where num_soigne= 45);
insert into table (select m.medecin_soigne from medecin m where num_med=50) (select ref(s) from soigne s where num_soigne= 46);
insert into table (select m.medecin_soigne from medecin m where num_med=50) (select ref(s) from soigne s where num_soigne= 47);
insert into table (select m.medecin_soigne from medecin m where num_med=50) (select ref(s) from soigne s where num_soigne= 48);
insert into table (select m.medecin_soigne from medecin m where num_med=50) (select ref(s) from soigne s where num_soigne= 49);
insert into table (select m.medecin_soigne from medecin m where num_med=50) (select ref(s) from soigne s where num_soigne= 50);
insert into table (select m.medecin_soigne from medecin m where num_med=53) (select ref(s) from soigne s where num_soigne= 51);
insert into table (select m.medecin_soigne from medecin m where num_med=53) (select ref(s) from soigne s where num_soigne= 52);
insert into table (select m.medecin_soigne from medecin m where num_med=53) (select ref(s) from soigne s where num_soigne= 53);
insert into table (select m.medecin_soigne from medecin m where num_med=53) (select ref(s) from soigne s where num_soigne= 54);
insert into table (select m.medecin_soigne from medecin m where num_med=53) (select ref(s) from soigne s where num_soigne= 55);
insert into table (select m.medecin_soigne from medecin m where num_med=53) (select ref(s) from soigne s where num_soigne= 56);
insert into table (select m.medecin_soigne from medecin m where num_med=54) (select ref(s) from soigne s where num_soigne= 57);
insert into table (select m.medecin_soigne from medecin m where num_med=54) (select ref(s) from soigne s where num_soigne= 58);
insert into table (select m.medecin_soigne from medecin m where num_med=64) (select ref(s) from soigne s where num_soigne= 59);
insert into table (select m.medecin_soigne from medecin m where num_med=64) (select ref(s) from soigne s where num_soigne= 60);
insert into table (select m.medecin_soigne from medecin m where num_med=64) (select ref(s) from soigne s where num_soigne= 61);
insert into table (select m.medecin_soigne from medecin m where num_med=80) (select ref(s) from soigne s where num_soigne= 62);
insert into table (select m.medecin_soigne from medecin m where num_med=80) (select ref(s) from soigne s where num_soigne= 63);
insert into table (select m.medecin_soigne from medecin m where num_med=82) (select ref(s) from soigne s where num_soigne= 64);
insert into table (select m.medecin_soigne from medecin m where num_med=82) (select ref(s) from soigne s where num_soigne= 65);
insert into table (select m.medecin_soigne from medecin m where num_med=82) (select ref(s) from soigne s where num_soigne= 66);
insert into table (select m.medecin_soigne from medecin m where num_med=82) (select ref(s) from soigne s where num_soigne= 67);
insert into table (select m.medecin_soigne from medecin m where num_med=85) (select ref(s) from soigne s where num_soigne= 68);
insert into table (select m.medecin_soigne from medecin m where num_med=85) (select ref(s) from soigne s where num_soigne= 69);
insert into table (select m.medecin_soigne from medecin m where num_med=85) (select ref(s) from soigne s where num_soigne= 70);
insert into table (select m.medecin_soigne from medecin m where num_med=85) (select ref(s) from soigne s where num_soigne= 71);
insert into table (select m.medecin_soigne from medecin m where num_med=85) (select ref(s) from soigne s where num_soigne= 72);
insert into table (select m.medecin_soigne from medecin m where num_med=85) (select ref(s) from soigne s where num_soigne= 73);
insert into table (select m.medecin_soigne from medecin m where num_med=85) (select ref(s) from soigne s where num_soigne= 74);
insert into table (select m.medecin_soigne from medecin m where num_med=88) (select ref(s) from soigne s where num_soigne= 75);
insert into table (select m.medecin_soigne from medecin m where num_med=88) (select ref(s) from soigne s where num_soigne= 76);
insert into table (select m.medecin_soigne from medecin m where num_med=88) (select ref(s) from soigne s where num_soigne= 77);
insert into table (select m.medecin_soigne from medecin m where num_med=88) (select ref(s) from soigne s where num_soigne= 78);
insert into table (select m.medecin_soigne from medecin m where num_med=88) (select ref(s) from soigne s where num_soigne= 79);
insert into table (select m.medecin_soigne from medecin m where num_med=88) (select ref(s) from soigne s where num_soigne= 80);
insert into table (select m.medecin_soigne from medecin m where num_med=88) (select ref(s) from soigne s where num_soigne= 81);
insert into table (select m.medecin_soigne from medecin m where num_med=88) (select ref(s) from soigne s where num_soigne= 82);
insert into table (select m.medecin_soigne from medecin m where num_med=89) (select ref(s) from soigne s where num_soigne= 83);
insert into table (select m.medecin_soigne from medecin m where num_med=89) (select ref(s) from soigne s where num_soigne= 84);
insert into table (select m.medecin_soigne from medecin m where num_med=89) (select ref(s) from soigne s where num_soigne= 85);
insert into table (select m.medecin_soigne from medecin m where num_med=89) (select ref(s) from soigne s where num_soigne= 86);
insert into table (select m.medecin_soigne from medecin m where num_med=89) (select ref(s) from soigne s where num_soigne= 87);
insert into table (select m.medecin_soigne from medecin m where num_med=89) (select ref(s) from soigne s where num_soigne= 88);
insert into table (select m.medecin_soigne from medecin m where num_med=89) (select ref(s) from soigne s where num_soigne= 89);
insert into table (select m.medecin_soigne from medecin m where num_med=99) (select ref(s) from soigne s where num_soigne= 90);
insert into table (select m.medecin_soigne from medecin m where num_med=99) (select ref(s) from soigne s where num_soigne= 91);
insert into table (select m.medecin_soigne from medecin m where num_med=99) (select ref(s) from soigne s where num_soigne= 92);
insert into table (select m.medecin_soigne from medecin m where num_med=113) (select ref(s) from soigne s where num_soigne= 93);
insert into table (select m.medecin_soigne from medecin m where num_med=113) (select ref(s) from soigne s where num_soigne= 94);
insert into table (select m.medecin_soigne from medecin m where num_med=113) (select ref(s) from soigne s where num_soigne= 95);
insert into table (select m.medecin_soigne from medecin m where num_med=113) (select ref(s) from soigne s where num_soigne= 96);
insert into table (select m.medecin_soigne from medecin m where num_med=113) (select ref(s) from soigne s where num_soigne= 97);
insert into table (select m.medecin_soigne from medecin m where num_med=113) (select ref(s) from soigne s where num_soigne= 98);
insert into table (select m.medecin_soigne from medecin m where num_med=114) (select ref(s) from soigne s where num_soigne= 99);
insert into table (select m.medecin_soigne from medecin m where num_med=114) (select ref(s) from soigne s where num_soigne= 100);
insert into table (select m.medecin_soigne from medecin m where num_med=114) (select ref(s) from soigne s where num_soigne= 101);
insert into table (select m.medecin_soigne from medecin m where num_med=114) (select ref(s) from soigne s where num_soigne= 102);
insert into table (select m.medecin_soigne from medecin m where num_med=114) (select ref(s) from soigne s where num_soigne= 103);
insert into table (select m.medecin_soigne from medecin m where num_med=122) (select ref(s) from soigne s where num_soigne= 104);
insert into table (select m.medecin_soigne from medecin m where num_med=122) (select ref(s) from soigne s where num_soigne= 105);
insert into table (select m.medecin_soigne from medecin m where num_med=122) (select ref(s) from soigne s where num_soigne= 106);
insert into table (select m.medecin_soigne from medecin m where num_med=126) (select ref(s) from soigne s where num_soigne= 107);
insert into table (select m.medecin_soigne from medecin m where num_med=126) (select ref(s) from soigne s where num_soigne= 108);
insert into table (select m.medecin_soigne from medecin m where num_med=126) (select ref(s) from soigne s where num_soigne= 109);
insert into table (select m.medecin_soigne from medecin m where num_med=126) (select ref(s) from soigne s where num_soigne= 110);
insert into table (select m.medecin_soigne from medecin m where num_med=126) (select ref(s) from soigne s where num_soigne= 111);
insert into table (select m.medecin_soigne from medecin m where num_med=135) (select ref(s) from soigne s where num_soigne= 112);
insert into table (select m.medecin_soigne from medecin m where num_med=135) (select ref(s) from soigne s where num_soigne= 113);
insert into table (select m.medecin_soigne from medecin m where num_med=135) (select ref(s) from soigne s where num_soigne= 114);
insert into table (select m.medecin_soigne from medecin m where num_med=135) (select ref(s) from soigne s where num_soigne= 115);
insert into table (select m.medecin_soigne from medecin m where num_med=135) (select ref(s) from soigne s where num_soigne= 116);
insert into table (select m.medecin_soigne from medecin m where num_med=135) (select ref(s) from soigne s where num_soigne= 117);
insert into table (select m.medecin_soigne from medecin m where num_med=135) (select ref(s) from soigne s where num_soigne= 118);
insert into table (select m.medecin_soigne from medecin m where num_med=135) (select ref(s) from soigne s where num_soigne= 119);
insert into table (select m.medecin_soigne from medecin m where num_med=140) (select ref(s) from soigne s where num_soigne= 120);
insert into table (select m.medecin_soigne from medecin m where num_med=140) (select ref(s) from soigne s where num_soigne= 121);
insert into table (select m.medecin_soigne from medecin m where num_med=140) (select ref(s) from soigne s where num_soigne= 122);
insert into table (select m.medecin_soigne from medecin m where num_med=140) (select ref(s) from soigne s where num_soigne= 123);
insert into table (select m.medecin_soigne from medecin m where num_med=140) (select ref(s) from soigne s where num_soigne= 124);
insert into table (select m.medecin_soigne from medecin m where num_med=140) (select ref(s) from soigne s where num_soigne= 125);
insert into table (select m.medecin_soigne from medecin m where num_med=140) (select ref(s) from soigne s where num_soigne= 126);
insert into table (select m.medecin_soigne from medecin m where num_med=140) (select ref(s) from soigne s where num_soigne= 127);
insert into table (select m.medecin_soigne from medecin m where num_med=141) (select ref(s) from soigne s where num_soigne= 128);
insert into table (select m.medecin_soigne from medecin m where num_med=141) (select ref(s) from soigne s where num_soigne= 129);
insert into table (select m.medecin_soigne from medecin m where num_med=141) (select ref(s) from soigne s where num_soigne= 130);
insert into table (select m.medecin_soigne from medecin m where num_med=141) (select ref(s) from soigne s where num_soigne= 131);
insert into table (select m.medecin_soigne from medecin m where num_med=141) (select ref(s) from soigne s where num_soigne= 132);
insert into table (select m.medecin_soigne from medecin m where num_med=141) (select ref(s) from soigne s where num_soigne= 133);
insert into table (select m.medecin_soigne from medecin m where num_med=141) (select ref(s) from soigne s where num_soigne= 134);
insert into table (select m.medecin_soigne from medecin m where num_med=141) (select ref(s) from soigne s where num_soigne= 135);
insert into table (select m.medecin_soigne from medecin m where num_med=141) (select ref(s) from soigne s where num_soigne= 136);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 137);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 138);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 139);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 140);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 141);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 142);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 143);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 144);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 145);
insert into table (select m.medecin_soigne from medecin m where num_med=144) (select ref(s) from soigne s where num_soigne= 146);
insert into table (select m.medecin_soigne from medecin m where num_med=152) (select ref(s) from soigne s where num_soigne= 147);
insert into table (select m.medecin_soigne from medecin m where num_med=152) (select ref(s) from soigne s where num_soigne= 148);
insert into table (select m.medecin_soigne from medecin m where num_med=152) (select ref(s) from soigne s where num_soigne= 149);
insert into table (select m.medecin_soigne from medecin m where num_med=152) (select ref(s) from soigne s where num_soigne= 150);
insert into table (select m.medecin_soigne from medecin m where num_med=152) (select ref(s) from soigne s where num_soigne= 151);
insert into table (select m.medecin_soigne from medecin m where num_med=179) (select ref(s) from soigne s where num_soigne= 152);
insert into table (select m.medecin_soigne from medecin m where num_med=179) (select ref(s) from soigne s where num_soigne= 153);
insert into table (select m.medecin_soigne from medecin m where num_med=179) (select ref(s) from soigne s where num_soigne= 154);
insert into table (select m.medecin_soigne from medecin m where num_med=179) (select ref(s) from soigne s where num_soigne= 155);
insert into table (select m.medecin_soigne from medecin m where num_med=180) (select ref(s) from soigne s where num_soigne= 156);
insert into table (select m.medecin_soigne from medecin m where num_med=180) (select ref(s) from soigne s where num_soigne= 157);
insert into table (select m.medecin_soigne from medecin m where num_med=180) (select ref(s) from soigne s where num_soigne= 158);
insert into table (select m.medecin_soigne from medecin m where num_med=180) (select ref(s) from soigne s where num_soigne= 159);
insert into table (select m.medecin_soigne from medecin m where num_med=196) (select ref(s) from soigne s where num_soigne= 160);
insert into table (select m.medecin_soigne from medecin m where num_med=196) (select ref(s) from soigne s where num_soigne= 161);
insert into table (select m.medecin_soigne from medecin m where num_med=196) (select ref(s) from soigne s where num_soigne= 162);
insert into table (select m.medecin_soigne from medecin m where num_med=196) (select ref(s) from soigne s where num_soigne= 163);


 
/* Mettre à jour de la table imbriquée  directeur_service */

insert into table (select m.directeur_service from medecin m where num_med=80) (select ref(s) from service s where code_service= 'CAR');
insert into table (select m.directeur_service from medecin m where num_med=34) (select ref(s) from service s where code_service= 'CHG');
insert into table (select m.directeur_service from medecin m where num_med=19) (select ref(s) from service s where code_service= 'REA');

/* Mettre à jour de la table imbriquée  service_infirmier */

insert into table (select m.service_infirmier from service m where code_service='REA') (select ref(s) from infirmier s where num_inf= 12);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 15);
insert into table (select m.service_infirmier from service m where code_service='REA') (select ref(s) from infirmier s where num_inf= 22);
insert into table (select m.service_infirmier from service m where code_service='CAR') (select ref(s) from infirmier s where num_inf= 25);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 29);
insert into table (select m.service_infirmier from service m where code_service='CAR') (select ref(s) from infirmier s where num_inf= 45);
insert into table (select m.service_infirmier from service m where code_service='REA') (select ref(s) from infirmier s where num_inf= 49);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 57);
insert into table (select m.service_infirmier from service m where code_service='CAR') (select ref(s) from infirmier s where num_inf= 71);
insert into table (select m.service_infirmier from service m where code_service='REA') (select ref(s) from infirmier s where num_inf= 73);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 86);
insert into table (select m.service_infirmier from service m where code_service='CAR') (select ref(s) from infirmier s where num_inf= 95);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 97);
insert into table (select m.service_infirmier from service m where code_service='CAR') (select ref(s) from infirmier s where num_inf= 98);
insert into table (select m.service_infirmier from service m where code_service='REA') (select ref(s) from infirmier s where num_inf= 116);
insert into table (select m.service_infirmier from service m where code_service='REA') (select ref(s) from infirmier s where num_inf= 127);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 130);
insert into table (select m.service_infirmier from service m where code_service='CAR') (select ref(s) from infirmier s where num_inf= 131);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 139);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 151);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 155);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 162);
insert into table (select m.service_infirmier from service m where code_service='CAR') (select ref(s) from infirmier s where num_inf= 163);
insert into table (select m.service_infirmier from service m where code_service='CAR') (select ref(s) from infirmier s where num_inf= 169);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 176);
insert into table (select m.service_infirmier from service m where code_service='REA') (select ref(s) from infirmier s where num_inf= 189);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 194);
insert into table (select m.service_infirmier from service m where code_service='CHG') (select ref(s) from infirmier s where num_inf= 195);

/* Mettre à jour de la table imbriquée  patient_hospitalisation */

insert into table (select m.patient_hospitalisation from patient m where num_patient=1) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 1);
insert into table (select m.patient_hospitalisation from patient m where num_patient=3) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 2);
insert into table (select m.patient_hospitalisation from patient m where num_patient=6) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 3);
insert into table (select m.patient_hospitalisation from patient m where num_patient=21) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 4);
insert into table (select m.patient_hospitalisation from patient m where num_patient=33) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 5);
insert into table (select m.patient_hospitalisation from patient m where num_patient=36) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 6);
insert into table (select m.patient_hospitalisation from patient m where num_patient=37) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 7);
insert into table (select m.patient_hospitalisation from patient m where num_patient=41) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 8);
insert into table (select m.patient_hospitalisation from patient m where num_patient=43) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 9);
insert into table (select m.patient_hospitalisation from patient m where num_patient=46) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 10);
insert into table (select m.patient_hospitalisation from patient m where num_patient=52) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 11);
insert into table (select m.patient_hospitalisation from patient m where num_patient=55) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 12);
insert into table (select m.patient_hospitalisation from patient m where num_patient=56) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 13);
insert into table (select m.patient_hospitalisation from patient m where num_patient=61) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 14);
insert into table (select m.patient_hospitalisation from patient m where num_patient=65) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 15);
insert into table (select m.patient_hospitalisation from patient m where num_patient=66) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 16);
insert into table (select m.patient_hospitalisation from patient m where num_patient=67) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 17);
insert into table (select m.patient_hospitalisation from patient m where num_patient=68) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 18);
insert into table (select m.patient_hospitalisation from patient m where num_patient=72) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 19);
insert into table (select m.patient_hospitalisation from patient m where num_patient=74) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 20);
insert into table (select m.patient_hospitalisation from patient m where num_patient=76) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 21);
insert into table (select m.patient_hospitalisation from patient m where num_patient=77) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 22);
insert into table (select m.patient_hospitalisation from patient m where num_patient=103) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 23);
insert into table (select m.patient_hospitalisation from patient m where num_patient=105) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 24);
insert into table (select m.patient_hospitalisation from patient m where num_patient=108) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 25);
insert into table (select m.patient_hospitalisation from patient m where num_patient=117) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 26);
insert into table (select m.patient_hospitalisation from patient m where num_patient=120) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 27);
insert into table (select m.patient_hospitalisation from patient m where num_patient=123) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 28);
insert into table (select m.patient_hospitalisation from patient m where num_patient=137) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 29);
insert into table (select m.patient_hospitalisation from patient m where num_patient=145) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 30);
insert into table (select m.patient_hospitalisation from patient m where num_patient=147) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 31);
insert into table (select m.patient_hospitalisation from patient m where num_patient=149) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 32);
insert into table (select m.patient_hospitalisation from patient m where num_patient=154) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 33);
insert into table (select m.patient_hospitalisation from patient m where num_patient=159) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 34);
insert into table (select m.patient_hospitalisation from patient m where num_patient=167) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 35);
insert into table (select m.patient_hospitalisation from patient m where num_patient=172) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 36);
insert into table (select m.patient_hospitalisation from patient m where num_patient=182) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 37);
insert into table (select m.patient_hospitalisation from patient m where num_patient=188) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 38);
insert into table (select m.patient_hospitalisation from patient m where num_patient=192) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 39);

/* Mettre à jour de la table imbriquée  service_hospitalisation */

insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 1);
insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 2);
insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 3);
insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 4);
insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 5);
insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 6);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 7);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 8);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 9);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 10);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 11);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 12);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 13);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 14);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 15);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 16);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 17);
insert into table (select m.service_hospitalisation from service m where code_service='CAR') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 18);
insert into table (select m.service_hospitalisation from service m where code_service='CAR') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 19);
insert into table (select m.service_hospitalisation from service m where code_service='CAR') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 20);
insert into table (select m.service_hospitalisation from service m where code_service='CAR') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 21);
insert into table (select m.service_hospitalisation from service m where code_service='CAR') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 22);
insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 23);
insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 24);
insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 25);
insert into table (select m.service_hospitalisation from service m where code_service='REA') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 26);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 27);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 28);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 29);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 30);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 31);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 32);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 33);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 34);
insert into table (select m.service_hospitalisation from service m where code_service='CHG') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 35);
insert into table (select m.service_hospitalisation from service m where code_service='CAR') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 36);
insert into table (select m.service_hospitalisation from service m where code_service='CAR') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 37);
insert into table (select m.service_hospitalisation from service m where code_service='CAR') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 38);
insert into table (select m.service_hospitalisation from service m where code_service='CAR') (select ref(s) from hospitalisation s where NUM_Hospitalisation= 39);

/* Mettre à jour de la table imbriquée  chambre_hospitalisation */

insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=101) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 1);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=102) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 2);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=103) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 3);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=103) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 4);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=104) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 5);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=104) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 6);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=201) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 7);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=201) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 8);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=201) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 9);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=202) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 10);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=202) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 11);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=202) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 12);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=301) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 13);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=301) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 14);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=302) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 15);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=302) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 16);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=303) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 17);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=101) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 18);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=101) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 19);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=102) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 20);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=102) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 21);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=103) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 22);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=105) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 23);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=107) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 24);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=107) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 25);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=108) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 26);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=401) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 27);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=401) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 28);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=402) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 29);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=402) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 30);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=402) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 31);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=403) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 32);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=403) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 33);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=404) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 34);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=405) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 35);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=104) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 36);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=104) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 37);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=105) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 38);
insert into table (select m.chambre_hospitalisation from chambre m where num_chambre=106) (select ref(s) from hospitalisation s where NUM_Hospitalisation= 39);

/* Mettre à jour de la table imbriquée  service_chambre */

insert into table (select m.service_chambre from service m where code_service='CAR') (select ref(s) from chambre s where num_chambre= 101);
insert into table (select m.service_chambre from service m where code_service='CAR') (select ref(s) from chambre s where num_chambre= 102);
insert into table (select m.service_chambre from service m where code_service='CAR') (select ref(s) from chambre s where num_chambre= 103);
insert into table (select m.service_chambre from service m where code_service='CAR') (select ref(s) from chambre s where num_chambre= 104);
insert into table (select m.service_chambre from service m where code_service='CAR') (select ref(s) from chambre s where num_chambre= 105);
insert into table (select m.service_chambre from service m where code_service='CAR') (select ref(s) from chambre s where num_chambre= 106);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 202);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 202);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 301);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 302);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 303);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 401);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 402);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 403);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 404);
insert into table (select m.service_chambre from service m where code_service='CHG') (select ref(s) from chambre s where num_chambre= 405);
insert into table (select m.service_chambre from service m where code_service='REA') (select ref(s) from chambre s where num_chambre= 101);
insert into table (select m.service_chambre from service m where code_service='REA') (select ref(s) from chambre s where num_chambre= 102);
insert into table (select m.service_chambre from service m where code_service='REA') (select ref(s) from chambre s where num_chambre= 103);
insert into table (select m.service_chambre from service m where code_service='REA') (select ref(s) from chambre s where num_chambre= 104);
insert into table (select m.service_chambre from service m where code_service='REA') (select ref(s) from chambre s where num_chambre= 105);
insert into table (select m.service_chambre from service m where code_service='REA') (select ref(s) from chambre s where num_chambre= 106);
insert into table (select m.service_chambre from service m where code_service='REA') (select ref(s) from chambre s where num_chambre= 107);
insert into table (select m.service_chambre from service m where code_service='REA') (select ref(s) from chambre s where num_chambre= 108);

/* Mettre à jour de la table imbriquée  service_infirmier */

insert into table (select m.infirmier_chambre from infirmier m where num_inf=95) (select ref(s) from chambre s where num_chambre= 101);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=95) (select ref(s) from chambre s where num_chambre= 102);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=95) (select ref(s) from chambre s where num_chambre= 103);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=169) (select ref(s) from chambre s where num_chambre= 104);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=169) (select ref(s) from chambre s where num_chambre= 105);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=169) (select ref(s) from chambre s where num_chambre= 106);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=29) (select ref(s) from chambre s where num_chambre= 202);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=29) (select ref(s) from chambre s where num_chambre= 202);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=57) (select ref(s) from chambre s where num_chambre= 301);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=57) (select ref(s) from chambre s where num_chambre= 302);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=57) (select ref(s) from chambre s where num_chambre= 303);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=130) (select ref(s) from chambre s where num_chambre= 401);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=130) (select ref(s) from chambre s where num_chambre= 402);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=151) (select ref(s) from chambre s where num_chambre= 403);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=151) (select ref(s) from chambre s where num_chambre= 404);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=151) (select ref(s) from chambre s where num_chambre= 405);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=12) (select ref(s) from chambre s where num_chambre= 101);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=12) (select ref(s) from chambre s where num_chambre= 102);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=22) (select ref(s) from chambre s where num_chambre= 103);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=22) (select ref(s) from chambre s where num_chambre= 104);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=49) (select ref(s) from chambre s where num_chambre= 105);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=49) (select ref(s) from chambre s where num_chambre= 106);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=49) (select ref(s) from chambre s where num_chambre= 107);
insert into table (select m.infirmier_chambre from infirmier m where num_inf=116) (select ref(s) from chambre s where num_chambre= 108);

/**********************************/

/*************************************/
/************ METHODES ET LEUR TESTS ***************/

/***************/
/* ADD METHODS */

/**** 1 ******/
ALTER TYPE tmedecin add member function calcul_nombre_medecin_par_specialite return integer cascade;
create or replace type body tmedecin
    as member function calcul_nombre_medecin_par_specialite return integer
    is nombre_med integer;
    Begin
         select count(*) into nombre_med  from medecin m  WHERE m.specialite = SELF.specialite; 
         Return nombre_med;
    End calcul_nombre_medecin_par_specialite;
End;
/
SELECT DISTINCT m.specialite, m.calcul_nombre_medecin_par_specialite() FROM medecin m;
/***********/

 
/**** 2*******/
ALTER TYPE tservice add member function calcul_nombre_infirmier_et_patient_par_service return integer cascade;
create or replace type body tservice as member function 
calcul_nombre_infirmier_et_patient_par_service return integer
        is 
        nombre_infirmier integer;
        Begin
            select  count(deref(value(si)).num_inf) into nombre_infirmier
                from service s, table(s.service_infirmier) si  where s.code_service=self.code_service;
            select   count(deref(deref(value(hos)).hospitalisation_patient).num_patient)+ 
                nombre_infirmier into nombre_infirmier
                from service s, table(s.service_hospitalisation) hos where s.code_service=self.code_service;
            return nombre_infirmier;
        end calcul_nombre_infirmier_et_patient_par_service;
        end;
        /
select s.code_service, s.calcul_nombre_infirmier_et_patient_par_service() from service s;

/***********/

     
/***** 3 *****/
ALTER TYPE tpatient add member function calcul_nombre_medecin_par_patient return integer cascade;
create or replace type body tpatient  as member function calcul_nombre_medecin_par_patient return integer
        is nombre integer;
        Begin
            select count(distinct deref(deref(value(pc)).soigne_medecin).num_med) into nombre
            from patient p, table(p.patient_soigne) pc  where p.num_patient=self.num_patient 
            and deref(value(pc).soigne_medecin).num_med is not null;
            return nombre;
        end calcul_nombre_medecin_par_patient;
        end;
/
select p.num_patient, p.calcul_nombre_medecin_par_patient() from patient p;   
/*********************/


/***** 4 *****/

alter type tinfirmier add  member procedure affichage cascade;
create or replace type body tinfirmier as member procedure affichage

    is  nombre integer;
    Begin
        select inf.salaire into nombre from infirmier inf where inf.num_inf=self.num_inf;
        if nombre >=10000 and nombre<=30000 then 
            DBMS_OUTPUT.PUT_LINE('vérification positive'); 
        else 
            DBMS_OUTPUT.PUT_LINE('vérification negative'); 
        end if;
    End ;
End;
/

select inf.salaire from infirmier inf where inf.num_inf=12;
DECLARE
    uninfirmier tinfirmier;
BEGIN
    SELECT VALUE(inf) INTO uninfirmier
    FROM infirmier inf WHERE inf.num_inf = 12;
    uninfirmier.affichage();
END;
/ 

/*******************************************************/

/*************** REPONSE AUX DIFFERENTES COMMANDES ***********************/


