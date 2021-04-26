SET SERVEROUTPUT ON; 
/**
##### REQ 2: LISTADO DE EMPLEADOS ######################################################################################

**/ 

CREATE OR REPLACE PROCEDURE listado_empleados IS 

    --Cursor  que almacenan los monitores 
    CURSOR c_monitores IS 
        SELECT emple.n_empleado, emple.nombre, emple.dni, emple.telefono, moni.titulo FROM monitor moni, empleado emple
            WHERE UPPER(emple.puesto) ='MONITOR' AND emple.n_empleado=moni.n_empleado ;
    r_monitores c_monitores%ROWTYPE;
    
    --Cursor que almacena los de matenimiento
    CURSOR c_manteni IS 
        SELECT emple.n_empleado, emple.nombre, emple.dni, emple.telefono, mante.especialidad FROM mantenimiento mante, empleado emple
            WHERE UPPER(emple.puesto) ='MANTENIMIENTO' AND emple.n_empleado=mante.n_empleado ;
    r_manteni c_manteni%ROWTYPE;
    
    --Cursor que almacena a los de restaurante
     CURSOR c_restau IS 
        SELECT emple.n_empleado, emple.nombre, emple.dni, emple.telefono, rest.labor FROM restaurante rest, empleado emple
            WHERE UPPER(emple.puesto) ='RESTAURANTE' AND emple.n_empleado=rest.n_empleado ;
    r_restau c_restau%ROWTYPE;
BEGIN
     DBMS_OUTPUT.PUT_LINE('********** EMPLEADOS **************');
     OPEN c_monitores;
    DBMS_OUTPUT.PUT_LINE('**********MONITORES**********');
    LOOP 
        FETCH c_monitores INTO r_monitores;
        EXIT WHEN c_monitores%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE('Nº empleado: ' || r_monitores.n_empleado);
         DBMS_OUTPUT.PUT_LINE('Nombre: ' || r_monitores.nombre || ' Dni: '|| r_monitores.dni || ' Telefono: ' || r_monitores.telefono);
         DBMS_OUTPUT.PUT_LINE('Titulo: ' || r_monitores.titulo);
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END LOOP; --Bucle monitores
    CLOSE c_monitores;
    
    OPEN c_manteni;
    DBMS_OUTPUT.PUT_LINE('*********MANTENIMIENTO**************');
    LOOP 
        FETCH c_manteni INTO r_manteni;
        EXIT WHEN c_manteni%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE('Nº empleado: ' || r_manteni.n_empleado);
         DBMS_OUTPUT.PUT_LINE('Nombre: ' || r_manteni.nombre || ' Dni: '|| r_manteni.dni || ' Telefono: ' || r_manteni.telefono);
         DBMS_OUTPUT.PUT_LINE('Especialidad: ' || r_manteni.especialidad);
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END LOOP; --Bucle mantenimiento
    CLOSE c_manteni;
    
    OPEN c_restau;
    DBMS_OUTPUT.PUT_LINE('************RESTAURANTE*************');
    LOOP 
        FETCH c_restau INTO r_restau;
        EXIT WHEN c_restau%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE('Nº empleado: ' || r_restau.n_empleado);
         DBMS_OUTPUT.PUT_LINE('Nombre: ' || r_restau.nombre || ' Dni: '|| r_restau.dni || ' Telefono: ' || r_restau.telefono);
         DBMS_OUTPUT.PUT_LINE('Labor: ' || r_restau.labor);
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END LOOP; --Bucle restaurante
    CLOSE c_restau;
END;
/


 
/**
####################################################################################################################################
**/