/* ESCPECIALES
Ejecutar desde un usuario administrador
*/
-- Ver todas las politicas de la BD
SELECT *
    FROM all_policies;

SELECT *
    FROM autoracle.cliente;

-- Ver todos los roles y sus objetos
SELECT *
    FROM DBA_TAB_PRIVS
        WHERE GRANTEE = 'R_CLIENTE';

-- Devuelve un booleano respecto a si el usuario que lo ejecuta es DBA o no
SELECT SYS_CONTEXT('userenv', 'isdba')
    FROM dual;

-- Muestra todos los usuarios de la BD
SELECT *
    FROM all_users;




/* EJERCICIOS
Ejecutar desde el usuario AUTORACLE
*/
SET SERVEROUTPUT ON;


-- Pruebas del ejercicio 1
/*
DROP USER cliente_1 CASCADE;
DROP USER cliente_2 CASCADE;
DROP USER trabajador_1 CASCADE;
DROP USER trabajador_2 CASCADE;
DROP USER administrador_1 CASCADE;
DROP USER administrador_2 CASCADE;
*/

CREATE USER cliente_1
    IDENTIFIED BY cliente
    DEFAULT TABLESPACE ts_autoracle;

CREATE USER cliente_2
    IDENTIFIED BY cliente
    DEFAULT TABLESPACE ts_autoracle;

CREATE USER trabajador_1
    IDENTIFIED BY mecanico
    DEFAULT TABLESPACE ts_autoracle;

CREATE USER trabajador_2
    IDENTIFIED BY mecanico
    DEFAULT TABLESPACE ts_autoracle;

CREATE USER administrador_1
    IDENTIFIED BY admin
    DEFAULT TABLESPACE ts_autoracle;

CREATE USER administrador_2
    IDENTIFIED BY admin
    DEFAULT TABLESPACE ts_autoracle;


GRANT r_cliente
    TO cliente_1, cliente_2;

GRANT r_mecanico
    TO trabajador_1, trabajador_2;

GRANT r_administrativo
    TO administrador_1, administrador_2;


SELECT *
    FROM cliente;



-- Pruebas del ejercicio 2
UPDATE AUTORACLE.PIEZA
    SET FECCADUCIDAD = SYSDATE - 1
    WHERE CODREF = '1234';

SELECT *
    FROM pieza
        WHERE feccaducidad < sysdate-1;

EXECUTE autoracle.p_revisa;

SELECT *
    FROM compra_futura;



-- Pruebas del ejercicio 3
UPDATE factura
    SET iva_calculado = 0, total = 0;

SELECT f.IDFACTURA, f.IVA, p.CODREF, p.PRECIOUNIDADVENTA, p.PRECIOUNIDADCOMPRA
    FROM AUTORACLE.FACTURA f
        JOIN AUTORACLE.CONTIENE c ON c.FACTURA_IDFACTURA = f.IDFACTURA
        JOIN AUTORACLE.PIEZA p ON c.PIEZA_CODREF = p.CODREF;

EXECUTE p_calcula_fact;

SELECT *
    FROM factura;


CREATE OR REPLACE
    VIEW AUTORACLE.V_COSTE_PIEZAS_TOTAL AS
        SELECT f.IDFACTURA, f.FECEMISION, f.IVA, SUM(p.PRECIOUNIDADVENTA) AS TOTAL_PIEZAS
            FROM AUTORACLE.factura f
                JOIN AUTORACLE.contiene c ON f.IDFACTURA = c.FACTURA_IDFACTURA
                JOIN AUTORACLE.pieza p ON p.CODREF = c.PIEZA_CODREF
                GROUP BY f.IDFACTURA, f.FECEMISION, f.IVA;

SELECT *
    FROM AUTORACLE.V_COSTE_PIEZAS_TOTAL;


CREATE OR REPLACE
    VIEW AUTORACLE.V_INTERMEDIA_IVA_TRIMESTRE AS
        SELECT  TO_CHAR(FECEMISION, 'YYYY') as "anno",
                TO_CHAR(FECEMISION, 'Q') as "cuatrimestre",
                (IVA / 100) * TOTAL_PIEZAS as "iva_total"
            FROM AUTORACLE.V_COSTE_PIEZAS_TOTAL;

SELECT *
    FROM AUTORACLE.V_INTERMEDIA_IVA_TRIMESTRE;



-- Pruebas del ejercicio 4
SELECT *
    FROM V_COSTE_PIEZAS_TOTAL;

SELECT *
    FROM v_iva_cuatrimestre;



-- Pruebas del ejercicio 5
SELECT  TO_CHAR(c.FECEMISION, 'YYYY') AS ANNO,
        L.PIEZA_CODREF AS PIEZA_CODREF,
        L.NUMERO_DE_PIEZAS AS NUMERO_DE_PIEZAS
    FROM autoracle.COMPRA c
        JOIN AUTORACLE.LOTE L ON c.IDCOMPRA = L.COMPRA_IDCOMPRA;


SELECT SUM(S.fecrealizacion - S.fecrecepcion) / COUNT(S.idservicio) AS media_dias,
    SUM(R.horas) / COUNT(S.idservicio) AS media_horas,
    S.idservicio AS id_servicio
    FROM autoracle.servicio S
        JOIN autoracle.reparacion R ON S.idservicio = R.idservicio
        GROUP BY S.idservicio;


DESC pkg_analisis_datos;

EXECUTE pkg_analisis_datos.p_recompensa;

SELECT idempleado, sueldobase
    FROM empleado;



-- Pruebas del ejercicio 6
INSERT INTO "AUTORACLE"."CLIENTE" (IDCLIENTE, TELEFONO, NOMBRE, APELLIDO1, EMAIL)
    VALUES ('100', '100100100', 'Cien', 'Diez veces diez', '100@gmail.com');

INSERT INTO "AUTORACLE"."VEHICULO" (NUMBASTIDOR, MATRICULA, MODELO_IDMODELO, MODELO_MARCA_IDMARCA, CLIENTE_IDCLIENTE)
    VALUES ('100100100', '0100JJJ', '6', '2', '100');

INSERT INTO "AUTORACLE"."SERVICIO" (IDSERVICIO, ESTADO, FECAPERTURA, FECRECEPCION, FECREALIZACION, OBSCHAPA, VEHICULO_NUMBASTIDOR)
    VALUES ('999', 'Finalizado', TO_DATE('2020-05-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-05-08 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-05-08 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Correcta', '100100100');

INSERT INTO "AUTORACLE"."REPARACION" (IDSERVICIO, MOTIVO, HORAS)
    VALUES ('999', 'Desconocido', '5');

INSERT INTO "AUTORACLE"."SERVICIO" (IDSERVICIO, ESTADO, FECAPERTURA, FECRECEPCION, FECREALIZACION, OBSCHAPA, VEHICULO_NUMBASTIDOR)
    VALUES ('1000', 'Finalizado', TO_DATE('2020-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-05-02 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-05-08 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Mal', '100100100');

INSERT INTO "AUTORACLE"."REPARACION" (IDSERVICIO, MOTIVO, HORAS)
    VALUES ('1000', 'Desconocido', '10');


UPDATE "AUTORACLE"."SERVICIO"
    SET FECAPERTURA = TO_DATE('2020-04-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
        WHERE ROWID = 'AAAS5rAAFAAAAENAAI' AND ORA_ROWSCN = '5912963';


INSERT INTO "AUTORACLE"."CITA" (IDCITA, FECHA_SOLICITUD, FECHA_CONCERTADA, CLIENTE_IDCLIENTE)
    VALUES ('17', TO_DATE('2020-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-05-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '100');

INSERT INTO "AUTORACLE"."CITA" (IDCITA, FECHA_SOLICITUD, FECHA_CONCERTADA, CLIENTE_IDCLIENTE)
    VALUES ('18', TO_DATE('2020-05-02 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2020-05-08 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '100');

INSERT INTO "AUTORACLE"."FACTURA" (IDFACTURA, CLIENTE_IDCLIENTE, IVA, FECEMISION, DESCUENTO, EMPLEADO_IDEMPLEADO)
    VALUES ('999', '100', '20', TO_DATE('2020-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '0', '1');

INSERT INTO "AUTORACLE"."FACTURA" (IDFACTURA, CLIENTE_IDCLIENTE, IVA, FECEMISION, DESCUENTO, EMPLEADO_IDEMPLEADO)
    VALUES ('1000', '100', '20', TO_DATE('2020-05-08 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '3', '1');

INSERT INTO "AUTORACLE"."FACTURA" (IDFACTURA, CLIENTE_IDCLIENTE, IVA, FECEMISION, DESCUENTO, EMPLEADO_IDEMPLEADO)
    VALUES ('1001', '100', '20', TO_DATE('2021-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '0', '1');

-- Todas las facturas del cliente (en ese año)
SELECT COUNT(*)
    FROM AUTORACLE.FACTURA
        WHERE CLIENTE_IDCLIENTE = '100'
            AND TO_CHAR(FECEMISION, 'YYYY') = TO_CHAR(2020);

-- Todas las citas con mas de 5 dias de espera (en ese año)
SELECT COUNT(*)
    FROM AUTORACLE.CITA
        WHERE CLIENTE_IDCLIENTE = '100'
            AND ABS(FECHA_CONCERTADA - FECHA_SOLICITUD) > 5
            AND TO_CHAR(FECHA_SOLICITUD, 'YYYY') = TO_CHAR(2020);


SELECT TRUNC(AVG(FECREALIZACION - FECAPERTURA))
    FROM SERVICIO;

-- Todos los servicios con mas de la media de dias de espera (en ese año)
SELECT COUNT(*)
    FROM AUTORACLE.SERVICIO s
        JOIN AUTORACLE.VEHICULO v ON s.VEHICULO_NUMBASTIDOR = v.NUMBASTIDOR
        WHERE v.CLIENTE_IDCLIENTE = '100'
            AND TO_CHAR(s.FECAPERTURA, 'YYYY') = TO_CHAR(2020)
            AND (FECREALIZACION - FECAPERTURA) > 13;


INSERT ALL
    INTO AUTORACLE.FIDELIZACION
        VALUES ('789', 10, 2020)

    INTO AUTORACLE.FIDELIZACION
        VALUES ('789', 20, 2019)

    INTO AUTORACLE.FIDELIZACION
        VALUES ('16', 35, 2008)

    INTO AUTORACLE.FIDELIZACION
        VALUES ('420', 5, 2020)

SELECT DUMMY
    FROM DUAL;


INSERT INTO fidelizacion    -- No debe dar error
    VALUES ('15', 12, 2020);

INSERT INTO fidelizacion    -- Debe dar error (año repetido para el cliente)
    VALUES ('420', 1, 2020);

-- Debe dar un 4%
EXECUTE PKG_GESTION_DESCUENTOS.p_calcular_descuento('100', 2020);

-- Todas las facturas del cliente de ese año deben tener un 4% de descuento
EXECUTE PKG_GESTION_DESCUENTOS.p_aplicar_descuento('100', 2021);


-- Comprobamos que funciona el trigger
INSERT INTO AUTORACLE.FIDELIZACION
    VALUES ('200', 6, '2018'); -- devuelve error

INSERT INTO AUTORACLE.FIDELIZACION
    VALUES ('200', 6, '2019');



-- Pruebas del ejercicio 7
-- Datos incorrectos en tabla EMPLEADO
UPDATE EMPLEADO
    SET APELLIDO2 = 'Bribon'
    WHERE NOMBRE = 'Felipe';

UPDATE EMPLEADO
    SET APELLIDO2 = 'Rubalcaba'
    WHERE NOMBRE = 'Miguel';

UPDATE EMPLEADO
    SET APELLIDO2 = 'Bribon'
    WHERE NOMBRE = 'Lola';

BEGIN
    -- source: https://www.vortexmag.net/12-portugueses-conhecidos-em-todo-o-mundo/
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Joao', 'Pessoa', 'DaSilva');
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Amalia', 'Pessoa', 'Rodrigues');
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Vasco', 'Pessoa', 'DaGama');
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Jose', 'Pessoa', 'Mourinho');
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Sara', 'Pessoa', 'Sampaio');
END;
/

BEGIN
    PKG_GESTION_EMPLEADOS.PR_MODIFICAR_EMPLEADO(
        sec_idempleado.CURRVAL, -- el ID del ultimo empleado creado
        'Sara',
        'Pessoa',
        'Sampaio',
        sysdate,
        1); -- Tiene que dar error
END;
/

BEGIN
    PKG_GESTION_EMPLEADOS.PR_MODIFICAR_EMPLEADO(
        sec_idempleado.CURRVAL,
        'Sara',
        'Pessoa',
        'Sampaio',
        sysdate,
        1,
        0,
        0,
        'PreZidenta',
        0);
END;
/

BEGIN
    PKG_GESTION_EMPLEADOS.PR_BLOQUEAR_USUARIO('Sara', 'Pessoa', 'Sampaio');
END;
/

BEGIN
    PKG_GESTION_EMPLEADOS.PR_DESBLOQUEAR_USUARIO('Sara', 'Pessoa', 'Sampaio');
END;
/

BEGIN
    -- no funcionara si algun empleado en la tabla EMPLEADO no tiene usuario creado :(
    PKG_GESTION_EMPLEADOS.PR_BLOQUEAR_TODOS_EMPLEADOS;
END;
/

BEGIN
    -- no funcionara si algun empleado en la tabla EMPLEADO no tiene usuario creado :(
    PKG_GESTION_EMPLEADOS.PR_DESBLOQUEAR_TODOS_EMPLEADOS;
END;
/

BEGIN
    PKG_GESTION_EMPLEADOS.PR_BORRAR_EMPLEADO(sec_idempleado.CURRVAL);
END;
/
BEGIN
    -- source: https://www.vortexmag.net/12-portugueses-conhecidos-em-todo-o-mundo/
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Joao', 'Pessoa', 'DaSilva');
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Amalia', 'Pessoa', 'Rodrigues');
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Vasco', 'Pessoa', 'DaGama');
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Jose', 'Pessoa', 'Mourinho');
    PKG_GESTION_EMPLEADOS.PR_CREAR_EMPLEADO('Sara', 'Pessoa', 'Sampaio');
END;
/
