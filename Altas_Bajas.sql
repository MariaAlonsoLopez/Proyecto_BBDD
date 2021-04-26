/**
    ALTAS Y BAJAS
**/
--####################################   ALTAS   ##########################################################
CREATE OR REPLACE PROCEDURE alta_socio ( n_socio NUMBER, nombre VARCHAR2) IS
    v_antiguedad NUMBER;
BEGIN
    SELECT MAX(antiguedad)+1 INTO v_antiguedad FROM socio;
    INSERT INTO SOCIO (N_SOCIO, NOMBRE,ANTIGUEDAD) VALUES ( n_socio, nombre, v_antiguedad);
END;
/
-----------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE alta_abonado (n_abonado NUMBER, dni VARCHAR2, nombre VARCHAR2, parentesco VARCHAR2, edad NUMBER, nombre_socio VARCHAR2, fecha_ingreso DATE) IS
    v_numSocio NUMBER;
    error_paren EXCEPTION;
BEGIN 
    v_numSocio := buscar_num_socio (nombre_socio);
    IF parentesco NOT IN ('PRINCIPAL','HIJO/A','PAREJA','MADRE','PADRE', 'OTRO' ) THEN 
        RAISE error_paren;
    END IF;
    INSERT INTO ABONADO (N_ABONADO, DNI, NOMBRE, PARENTESCO, EDAD, FECHA_INGRESO, N_SOCIO) VALUES (n_abonado, dni, nombre, parentesco, edad, fecha_ingreso, v_numSocio);
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE('Error: Socio no encontrado');
    WHEN error_paren THEN
       DBMS_OUTPUT.PUT_LINE('Parentesco debe ser: PRINCIPAL, HIJO/A, PAREJA, MADRE, PADRE, OTRO'); 
END;
/

--Esta funcion devuelve el numero de socio del socio con el nombre pasado.
CREATE OR REPLACE FUNCTION buscar_num_socio (nombre_socio VARCHAR2) RETURN NUMBER IS 
    v_numSocio NUMBER;
BEGIN 
    SELECT n_socio INTO v_numSocio FROM socio WHERE UPPER(nombre)=UPPER(nombre_socio);
    RETURN v_numSocio;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
         RETURN -1;
END;
/

--Prueba del buscar_num_socio
/*
DECLARE
    v_num NUMBER;
BEGIN
    v_num := buscar_num_socio('Xavi Guirado');
    if v_num=-1 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Socio no encontrado');
    ELSE
        DBMS_OUTPUT.PUT_LINE(V_NUM);
    END IF;
END;
/
*/
 ----------------------------------------------------------
 --Lanzar error cuando el puesto no este bien definido
CREATE OR REPLACE PROCEDURE alta_empleado (n_empleado NUMBER, nombre VARCHAR2, dni VARCHAR2, telefono NUMBER, puesto VARCHAR2, dato_espe VARCHAR2) IS
    error_puesto EXCEPTION;
    error_dato EXCEPTION;
    error_dato2 EXCEPTION;
BEGIN
    IF puesto NOT IN ('MONITOR','MANTENIMIENTO', 'RESTAURANTE' ) THEN 
        RAISE error_puesto;
    END IF;
    IF puesto='MANTENIMIENTO' AND dato_espe NOT IN ('ELECTRICIDAD','FONTANERIA','JARDINERIA') THEN
        RAISE error_dato;
    ELSIF puesto='RESTAURANTE' AND dato_espe NOT IN ('COCINA','SALON','LIMPIEZA') THEN
        RAISE error_dato2;
    END IF;
    INSERT INTO EMPLEADO (N_EMPLEADO, NOMBRE, DNI, TELEFONO, PUESTO) VALUES (n_empleado, nombre, dni, telefono, puesto);
    CASE UPPER(puesto)
        WHEN 'MONITOR' THEN INSERT INTO MONITOR VALUES (n_empleado, dato_espe);
        WHEN 'MANTENIMIENTO' THEN INSERT INTO MANTENIMIENTO VALUES(n_empleado, dato_espe);
        WHEN 'RESTAURANTE' THEN INSERT INTO RESTAURANTE VALUES(n_empleado, dato_espe);
    END CASE;
EXCEPTION
    WHEN error_puesto THEN 
        DBMS_OUTPUT.PUT_LINE('Puesto debe ser : MONITOR, MANTENIMIENTO, RETAURANTE');
    WHEN error_dato THEN
        DBMS_OUTPUT.PUT_LINE('Especialidad debe ser : ELECTRICIDAD, FONTANERIA, JARDINERIA');
    WHEN error_dato2 THEN
        DBMS_OUTPUT.PUT_LINE('Labor debe ser : COCINA, SALON, LIMPIEZA');
END;
/

--#################################### BAJAS ################################################################

--Disparador que borra todos los registos de la tabla clase de ese abonado
CREATE OR REPLACE TRIGGER control_borrado_abonado 
    BEFORE DELETE ON ABONADO
    FOR EACH ROW
BEGIN
    DELETE FROM CLASE WHERE N_ABONADO= :OLD.N_ABONADO;
END borrado_abonado;
/

--Procedimiento que borra un abonado a partir de su n_abonado, controlando si lo ha encontrado o no 
CREATE OR REPLACE PROCEDURE baja_abonado (num_abonado NUMBER) IS
    v_nombre VARCHAR(30);
BEGIN
    --Para controlar que exista el abonado
    SELECT nombre INTO v_nombre FROM abonado WHERE n_abonado=num_abonado;
    DELETE FROM ABONADO WHERE n_abonado=num_abonado;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('Error: Abonado no encontrado');
END;
/

--Prueba de error abonado 
/*
EXEC baja_abonado(77777778);
*/
---------------------------------------------------
--Disparador que borra todos los registos de la tabla reserva y abonado de ese socio y modifica la antiguedad de los demas abonados 
CREATE OR REPLACE TRIGGER borrado_socio
    BEFORE DELETE ON SOCIO
    FOR EACH ROW
BEGIN 
    DELETE FROM RESERVA WHERE N_SOCIO= :OLD.N_SOCIO;
    DELETE FROM ABONADO WHERE N_SOCIO= :OLD.N_SOCIO;
    UPDATE SOCIO SET ANTIGUEDAD = ANTIGUEDAD-1 WHERE ANTIGUEDAD> :OLD.ANTIGUEDAD;
END borrado_socio;
/

--Procedimiento que borra un socio a partir de su n_socio, controlando si lo ha encontrado o no 
CREATE OR REPLACE PROCEDURE baja_socio (num_socio NUMBER) IS
     v_nombre VARCHAR(30);
BEGIN
    --Para controlar que exista el socio
    SELECT nombre INTO v_nombre FROM socio WHERE n_socio=num_socio;
    DELETE FROM SOCIO WHERE n_socio=num_socio;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Socio no encontrado');
END;
/
------------------------------------------------

CREATE OR REPLACE TRIGGER borrado_empleado
    BEFORE DELETE ON EMPLEADO
    FOR EACH ROW 
BEGIN
    --Controlo que si es monitor borre todas los grupos que imparta asi como los registros de las clases de estas y de la tabla monitor
    IF :OLD.PUESTO = 'MONITOR' THEN
        DELETE FROM CLASE WHERE NIVEL IN (SELECT NIVEL FROM GRUPO WHERE N_MONITOR=:OLD.N_EMPLEADO) AND TIPO IN (SELECT TIPO FROM GRUPO WHERE N_MONITOR=:OLD.N_EMPLEADO);
        DELETE FROM GRUPO WHERE N_MONITOR=:OLD.N_EMPLEADO;
        DELETE FROM MONITOR WHERE N_EMPLEADO=:OLD.N_EMPLEADO;
    --Si no pues simplemente se borran o de la tabla mantenimiento o de restaurante
    ELSIF :OLD.PUESTO = 'MANTENIMIENTO' THEN
        DELETE FROM MANTENIMIENTO WHERE N_EMPLEADO=:OLD.N_EMPLEADO;
    ELSE 
        DELETE FROM RESTAURANTE WHERE N_EMPLEADO=:OLD.N_EMPLEADO;
    END IF;
END borrado_empleado;
/

CREATE OR REPLACE PROCEDURE baja_empleado (num_emple NUMBER) IS
     v_nombre VARCHAR(30);
BEGIN
    --Para controlar que exista el empleado
    SELECT nombre INTO v_nombre FROM empleado WHERE n_empleado=num_emple;
    DELETE FROM EMPLEADO WHERE n_empleado=num_emple;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Empleado no encontrado');
END;
/










 