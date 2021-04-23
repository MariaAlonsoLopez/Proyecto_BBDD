SET SERVEROUTPUT ON; 
/**
##### REQ 1: LISTADO DE GRUPOS Y CLASES ######################################################################################

**/ 

CREATE OR REPLACE PROCEDURE listado_grupos IS 

    --Cursor  que almacena el nivel, el tipo , el max de alumnos y el nombre del monitor de los grupos
    CURSOR c_grupos IS 
        SELECT nivel, tipo, max_alumnos, emple.nombre AS "MONITOR" FROM grupo, empleado emple
            WHERE emple.n_empleado=n_monitor ;
    r_grupos c_grupos%ROWTYPE;
    
    --Cursor que devuelve los alumnos de dicho grupo        
    CURSOR c_clase (nivel_gru VARCHAR2, tipo_gru VARCHAR2) IS 
        SELECT cla.n_abonado as "NUM" , abo.nombre as "NOMBRE", abo.edad as "EDAD" FROM clase cla, abonado abo 
            WHERE cla.nivel=nivel_gru AND cla.tipo=tipo_gru AND cla.n_abonado=abo.n_abonado;
    r_clase c_clase%ROWTYPE;
    
BEGIN
    --Abrimos el primer cursor que devolvera todos los grupos
    OPEN c_grupos;
    LOOP 
        FETCH c_grupos INTO r_grupos;
        EXIT WHEN c_grupos%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE('********************************************');
         DBMS_OUTPUT.PUT_LINE('Grupo: ' || r_grupos.nivel || ' ' || r_grupos.tipo);
         DBMS_OUTPUT.PUT_LINE('Número máximo de alumnos: ' || r_grupos.max_alumnos);
         DBMS_OUTPUT.PUT_LINE('Monitor: ' || r_grupos.monitor);
             --Usamos el segundo cursor paralos alumnos de esa clase
             FOR r_clase IN c_clase(r_grupos.nivel, r_grupos.tipo) LOOP
                DBMS_OUTPUT.PUT_LINE('---Nº abonado:' || r_clase.num || ' Nombre: '||r_clase.nombre || ' Edad: ' || r_clase.edad);
             END LOOP;
    END LOOP; --Bucle grupos
    CLOSE c_grupos;
END;
/

EXEC listado_grupos;
 
/**
####################################################################################################################################
**/

