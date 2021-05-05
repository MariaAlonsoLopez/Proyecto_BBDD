SET SERVEROUTPUT ON;
/**
    BLOQUE ANONIMO PROGRAMA PRINCIPAL 
**/

DECLARE 
    v_opcion NUMBER;
BEGIN
    v_opcion := 12;
    CASE v_opcion
    --(1)Dar de alta a un socio.   
        WHEN 1 THEN  alta_socio(10234321, 'Fabio Palacios');
    --(2)Dar de alta a un abonado
        WHEN 2 THEN alta_abonado(11211121,'21568542Ñ','Fabio Palacios','PRINCIPAL',30,'Fabio Palacios' , '02/12/2018');
    --(3)Dar de alta a un empleado.
        WHEN 3 THEN alta_empleado(12435645, 'Alberto Arranz', '56245895P', 635625418, 'MANTENIMIENTO','FONTANERIA');
    --(4)Consultar disponibilidad para reserva.
    --Revisar 
        WHEN 4 THEN DBMS_OUTPUT.PUT_LINE('Para la pista 004 el dia 6 de Julio de 2012 hay disponibilidad a las horas: ' || consultar_disponibilidad(5,5,2012,'004'));
    --(5)Hacer una reserva.
        WHEN 5 THEN hacer_reserva (3,4,2013,10,'12345678', '001', 'CON', 'PayPal' );
    --(6)Sacar factura de un socio.
        WHEN 6 THEN factura_socio('José Duran');   
    --(7)Hacer listado de socios y abonados.
        WHEN 7 THEN  listado_socios;
    --(8)Hacer listado de grupos y clases.
        WHEN 8 THEN listado_grupos;
    --(9)Hacer listado de empleados.
        WHEN 9 THEN listado_empleados;
    --(10)Dar de baja a un empleado.
        WHEN 10 THEN baja_empleado(41254868);
    --(11)Dar de baja a un abonado.
        WHEN 11 THEN baja_abonado(55555558);
    --(12)Dar de baja a un socio.
    --Revisar 
        WHEN 12 THEN baja_socio(67890123);
    ELSE DBMS_OUTPUT.PUT_LINE('Opción no válida');
    END CASE;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió el error ' || SQLCODE ||' mensaje: ' || SQLERRM);   
END;
/
