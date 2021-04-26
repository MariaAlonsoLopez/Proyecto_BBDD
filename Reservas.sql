/**
    RESERVAS Y FACTURAS
**/

--DISPONIBILIDAD DE HORAS  
CREATE OR REPLACE FUNCTION consultar_disponibilidad (v_dia NUMBER, v_mes NUMBER, v_anyo NUMBER, v_pista CHAR) 
RETURN VARCHAR2 IS

    v_disponible VARCHAR2(40);
    v_reservado VARCHAR(40);
    CURSOR c_reservas (re_dia NUMBER, re_mes NUMBER, re_anyo NUMBER, re_pista CHAR) IS
        SELECT hora FROM reserva WHERE dia=re_dia AND mes=re_mes AND anyo=re_anyo AND n_pista=re_pista;
    r_reservas c_reservas%ROWTYPE;
BEGIN
    v_disponible := '';
    v_reservado := '';
    OPEN c_reservas(v_dia, v_mes, v_anyo, v_pista);
        LOOP
            FETCH c_reservas INTO r_reservas;
            EXIT WHEN c_reservas%NOTFOUND; 
                v_reservado := v_reservado +', ' + r_reservas.hora;
        END LOOP;
    CLOSE c_reservas; 
    FOR i IN 9..21 LOOP
        IF i NOT IN (v_reservado) THEN 
            v_disponible := v_disponible +', '+i;
        END IF;
    END LOOP;
    RETURN v_disponible;
END;
/
--Pruebo el consultar disponibilidad no funciona        
/*
DECLARE 
     v_disponibilidad VARCHAR2(40);
BEGIN
    v_disponibilidad := consultar_disponibilidad(5,5,2012,'004');
    DBMS_OUTPUT.PUT_LINE('Para la pista 004 el dia 6 de Julio de 2012 hay disponibilidad a las horas: ' || v_disponibilidad);
END;
/
*/
--RESERVAR UNA PISTA falta control de errores como que no exista el socio y arreglar funcion consultar disponibilidad para limpir codigo
CREATE OR REPLACE PROCEDURE hacer_reserva (v_dia NUMBER, v_mes NUMBER, v_anyo NUMBER, v_hora NUMBER ,v_socio NUMBER, v_pista CHAR, v_luz VARCHAR2, v_pago VARCHAR2 ) IS
    v_nombre_socio VARCHAR2(20);
    v_precio NUMBER;
    v_reservado VARCHAR(40);
    error_limite_horas EXCEPTION;
BEGIN
    --Aqui cotrolo que la hora solicitada este en el rango permitido
    IF v_hora<9 OR v_hora>21 THEN
        RAISE error_limite_horas;
    END IF;
    --Aqui controlo que exista el socio ademas de conseguir el nombre a partir de su codigo.
    SELECT nombre into v_nombre_socio FROM socio WHERE n_socio=v_socio;
    v_precio := 0;
    v_reservado := consultar_disponibilidad(v_dia,v_mes,v_anyo,v_pista);
    --Este if es para controlar si la hora que reserva esta ya reservada si esta reservada simplemente dice que no hay disponibilidad
    --Pero no se como controlarlo entonces porque v_hora es un number y v_reservado un VARCHAR2
    IF v_hora NOT IN (v_reservado) THEN 
        --Aqui obtengo el precio de esa pista en concreto
        SELECT precio INTO v_precio FROM pista WHERE n_pista=v_pista;
        --Hago el insert en la tabla reserva
        INSERT INTO RESERVA (N_SOCIO, N_PISTA, DIA, MES, ANYO, HORA, LUZ, TIPO_PAGO) VALUES (v_socio, v_pista, v_dia, v_mes, v_anyo, v_hora, v_luz, v_pago);
        --Y muestro la factura de esta 
        DBMS_OUTPUT.PUT_LINE('RESERVA:');
        DBMS_OUTPUT.PUT_LINE('Nº SOCIO: ' || v_socio || '    Nº PISTA: '|| v_pista);
        DBMS_OUTPUT.PUT_LINE('NOMBRE: ' || v_nombre_socio);
        DBMS_OUTPUT.PUT_LINE('DIA: ' || v_dia || '/' || v_mes || '/' || v_anyo || '    HORA: ' || v_hora);
        --Aqui como si la reservas con luz cuesta un euro mas se lo sumo al precio
        IF v_luz = 'CON' THEN
            DBMS_OUTPUT.PUT_LINE('CON LUZ');
            v_precio := v_precio +1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('SIN LUZ');
        END IF;
        DBMS_OUTPUT.PUT_LINE('TIPO DE PAGO: '|| v_pago);
        DBMS_OUTPUT.PUT_LINE('PRECIO: ' || v_precio || '€');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No hay disponibilidad');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Socio no encontrado');
    WHEN error_limite_horas THEN
        DBMS_OUTPUT.PUT_LINE('Error: Hora no válida, solo se puede reservar desde las 9 hasta las 21 horas.');
END;
/

/*
--Prueba de hora no valida 
EXEC hacer_reserva (3,4,2013,5,'12345678', '001', 'CON', 'PayPal' );
--Prueba socio no encontrado
EXEC hacer_reserva (3,4,2013,10,'00345678', '001', 'CON', 'PayPal' );
--Prueba hora reservada (no funciona, pasa el not in)
EXEC hacer_reserva(5,5,2012,18,'12345678', '004', 'CON', 'PayPal');
--Prueba valida 
EXEC hacer_reserva (3,4,2013,10,'12345678', '001', 'CON', 'PayPal' );
*/

--FACTURA DE SOCIO 

CREATE OR REPLACE PROCEDURE factura_socio (nombre_socio VARCHAR2) IS
    v_num_socio NUMBER;
    v_num_abonados NUMBER;
    v_antiguedad NUMBER;
    v_precio NUMBER;
    v_tarifa NUMBER;
BEGIN
    --Variable de tarifa de socio 
    v_tarifa := 100;
    --Funcion que devuelve el numero de socio y si no lo encuentra devuelve -1
    v_num_socio := buscar_num_socio(nombre_socio);
    IF  v_num_socio=-1 THEN
          DBMS_OUTPUT.PUT_LINE('Error: Socio no encontrado');
    ELSE
        v_precio := v_tarifa;
        --Recojo antiguedad
        SELECT antiguedad INTO v_antiguedad FROM socio WHERE n_socio=v_num_socio;
        --Recojo numero de abonados de ese socio
        SELECT COUNT(n_abonado) INTO v_num_abonados FROM abonado WHERE n_socio=v_num_socio;
        DBMS_OUTPUT.PUT_LINE('FACTURA DE SOCIO:');
        DBMS_OUTPUT.PUT_LINE('Nº Socio: ' || v_num_socio);
        DBMS_OUTPUT.PUT_LINE('Antiguedad: '|| v_antiguedad);
        DBMS_OUTPUT.PUT_LINE('Tarifa: ' || v_tarifa ||'€');
        
        --Cntrolo el plus por superar los 5 abonados 
        IF v_num_abonados>5 THEN
        DBMS_OUTPUT.PUT_LINE('Plus (10€ por abonados de más):' || 10*(v_num_abonados-5) || '€');
        v_precio := v_precio +  10*(v_num_abonados-5);
        END IF;
        
        --Controlo los descuentos por antiguedad
        IF v_antiguedad<5 THEN 
            DBMS_OUTPUT.PUT_LINE('Descuento por antiguedad: -15%');
            v_precio := v_precio - (v_precio*0.15);
        ELSIF v_antiguedad<7 THEN 
             DBMS_OUTPUT.PUT_LINE('Descuento por antiguedad: -10%');
             v_precio := v_precio - (v_precio*0.10);
        END IF;
         DBMS_OUTPUT.PUT_LINE('TOTAL: ' || v_precio);
    END IF;
END;
/

/*
--Prueba
EXEC factura_socio('José Duran');
*/
















