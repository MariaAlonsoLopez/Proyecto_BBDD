SET SERVEROUTPUT ON;
/**
##### REQ 3: LISTADO DE SOCIOS Y SUS ABONADOS ######################################################################################
**/ 
 
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE listado_socios IS 
    --Cursor  que almacena los socios
    CURSOR c_socios IS 
        SELECT n_socio, nombre, antiguedad FROM socio;
    r_socios c_socios%ROWTYPE;
    --Cursor que devuelve los abonados de dicho socio
    CURSOR c_abonado (socio NUMBER) IS 
        SELECT n_abonado, nombre , parentesco FROM abonado 
            WHERE n_socio=socio;
    r_abonado c_abonado%ROWTYPE;
    v_contador_abonados NUMBER := 0;
BEGIN
    --Abrimos el primer cursor que devolvera todos los socios
    OPEN c_socios;
    DBMS_OUTPUT.PUT_LINE('SOCIOS Y SUS ABONADOS: ');
    LOOP 
        FETCH c_socios INTO r_socios;
        EXIT WHEN c_socios%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE('********************************************');
         DBMS_OUTPUT.PUT_LINE('--Nº socio: '||r_socios.n_socio);
         DBMS_OUTPUT.PUT_LINE('--Nombre: ' || r_socios.nombre);
         DBMS_OUTPUT.PUT_LINE('--Antiguedad: ' || r_socios.antiguedad);
 
        --Trabajamos con el segundo cursor que nos dara los abonados de ese socio
        DBMS_OUTPUT.PUT_LINE('--ABONADOS: ');
        FOR r_abonado IN c_abonado(r_socios.n_socio) LOOP
             DBMS_OUTPUT.PUT_LINE('----Nº abonado: '||r_abonado.n_abonado || ' Nombre: '||r_abonado.nombre || '  Parentesco: '|| r_abonado.parentesco);
             v_contador_abonados := v_contador_abonados+1;   
        END LOOP; --Bucle abonados
        DBMS_OUTPUT.PUT_LINE('--Nº total abonados: '|| v_contador_abonados);
        v_contador_abonados := 0;
    END LOOP; --Bucle socios
    CLOSE c_socios;
END;
/
 
EXEC listado_socios;
 
/**
####################################################################################################################################
**/
