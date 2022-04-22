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


/*********************/