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
BEGIN 
    v_numSocio := buscar_num_socio (nombre_socio);
    INSERT INTO ABONADO (N_ABONADO, DNI, NOMBRE, PARENTESCO, EDAD, FECHA_INGRESO, N_SOCIO) VALUES (n_abonado, dni, nombre, parentesco, edad, fecha_ingreso, v_numSocio);
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE('Error: Socio no encontrado');
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

--Da error
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

SELECT N_SOCIO FROM SOCIO WHERE UPPER(NOMBRE) LIKE '%XAVI GUIRADO%';

 
 ----------------------------------------------------------
 --Lanzar error cuando el puesto no este bien definido
CREATE OR REPLACE PROCEDURE alta_empleado (n_empleado NUMBER, nombre VARCHAR2, dni VARCHAR2, telefono NUMBER, puesto VARCHAR2, dato_espe VARCHAR2) IS
    error_puesto EXCEPTION;
BEGIN
    IF puesto NOT IN ('MONITOR','MANTENIMIENTO', 'RESTAURANTE' ) THEN 
        RAISE error_puesto;
    END IF;
    INSERT INTO EMPLEADO (N_EMPLEADO, NOMBRE, DNI, TELEFONO, PUESTO) VALUES (n_empleado, nombre, dni, telefono, puesto);
    CASE UPPER(puesto)
        WHEN 'MONITOR' THEN INSERT INTO MONITOR VALUES (n_empleado, dato_espe);
        WHEN 'MANTENIMIENTO' THEN INSERT INTO MANTENIMIENTO VALUES(n_empleado, dato_espe);
        WHEN 'RESTAURANTE' THEN INSERT INTO RESTAURANTE VALUES(n_empleado, dato_espe);
    END CASE;
EXCEPTION
    WHEN error_puesto THEN 
        DBMS_OUTPUT.PUT_LINE('Puesto debe ser : ');
END;
/

--#################################### BAJAS ################################################################

--Disparador que borra todos los registos de la tabla clase de ese abonado
CREATE OR REPLACE TRIGGER borrado_abonado 
    BEFORE DELETE ON ABONADO
    FOR EACH ROW
BEGIN
    DELETE FROM CLASE WHERE N_ABONADO= :OLD.N_ABONADO;
END borrado_abonado;
/

--Procedimiento que borra un abonado a partir de su n_abonado, controlando si lo ha encontrado o no 
CREATE OR REPLACE PROCEDURE baja_abonado (num_abonado NUMBER) IS
BEGIN
--Quiero controlar un error que si no encuentra ese abonado que lo comunique diciendo 'Abonado no encontrado' pero el delete si no lo encuentra no da error simplemente no borra nada;
    DELETE FROM ABONADO WHERE n_abonado=num_abonado;
END;
/

EXEC baja_abonado(77777774);

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
BEGIN
--Quiero controlar un error que si no encuentra ese socio que lo comunique diciendo 'Socio no encontrado' pero el delete si no lo encuentra no da error simplemente no borra nada;
    DELETE FROM SOCIO WHERE n_socio=num_socio;
END;
/

delete from socio where n_socio=10102012; --0 filas eliminadas

------------------------------------------------

CREATE OR REPLACE TRIGGER borrado_empleado
    BEFORE DELETE ON EMPLEADO
    FOR EACH ROW 
BEGIN
    IF :OLD.PUESTO = 'MONITOR' THEN
        DELETE FROM CLASE WHERE NIVEL=SUB.NIVEL AND TIPO=SUB.TIPO 











 