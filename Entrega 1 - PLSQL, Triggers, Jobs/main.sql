-- Trabajo en Grupo (PL/SQL, Triggers, Jobs), a 29 Abril 2020.
-- Antonio J. Galan, Manuel Gonzalez, Pablo Rodriguez, Joaquin Terrasa

-- { Por defecto, usamos el usuario "AUTORACLE" creado previamente en la BD }
SET SERVEROUTPUT ON; -- para comprobar las funciones/procedimientos/triggers etc

-- SHOW SERVEROUTPUT;
SET SERVEROUTPUT ON;

/* [1] (desde SYSDBA)
Modificar el modelo (si es necesario) para almacenar el usuario de Oracle que
cada empleado o cliente pueda utilizar para conectarse a la base de datos.
Ademas, habra que crear roles dependiendo del tipo de usuario:
 * Administrativo, con acceso a toda la BD;
 * Empleado, con acceso solo a aquellos objetos que precise para su trabajo (y
   nunca podra acceder a los datos de otros empleados);
 * Cliente, con acceso solo a los datos propios, de su vehiculo y de sus
   servicios.
Los roles se llamaran R_ADMINISTRATIVO, R_MECANICO, R_CLIENTE.
*/


-- ROLES Y PERMISOS
/*
DROP ROLE r_administrativo;
DROP ROLE r_mecanico;
DROP ROLE r_cliente;
*/

CREATE ROLE r_administrativo;
CREATE ROLE r_mecanico;
CREATE ROLE r_cliente;


-- { permisos para R_ADMINISTRATIVO }

GRANT dba
    TO r_administrativo;

GRANT R_ADMINISTRATIVO
    TO AUTORACLE;


-- { permisos para R_MECANICO }

GRANT SELECT
    ON autoracle.empleado
    TO r_mecanico;

GRANT SELECT
    ON autoracle.categoria
    TO r_mecanico;

GRANT SELECT
    ON autoracle.compatible
    TO r_mecanico;

GRANT SELECT
    ON autoracle.examen
    TO r_mecanico;

GRANT SELECT
    ON autoracle.mantenimiento
    TO r_mecanico;

GRANT SELECT
    ON autoracle.marca
    TO r_mecanico;

GRANT SELECT
    ON autoracle.modelo
    TO r_mecanico;

GRANT SELECT
    ON autoracle.necesita
    TO r_mecanico;

GRANT SELECT
    ON autoracle.pieza
    TO r_mecanico;

GRANT SELECT
    ON autoracle.reparacion
    TO r_mecanico;

GRANT SELECT
    ON autoracle.requiere
    TO r_mecanico;

GRANT SELECT
    ON autoracle.trabaja
    TO r_mecanico;

GRANT SELECT
    ON autoracle.vacaciones
    TO r_mecanico;


-- { permisos para R_CLIENTE }

GRANT SELECT
    ON autoracle.cliente
    TO r_cliente;

GRANT SELECT
    ON autoracle.cita
    TO r_mecanico, r_cliente;

GRANT SELECT
    ON autoracle.factura
    TO r_mecanico, r_cliente;

GRANT SELECT
    ON autoracle.servicio
    TO r_mecanico, r_cliente;

GRANT SELECT
    ON autoracle.vehiculo
    TO r_mecanico, r_cliente;


-- RESTRICCIONES (POLITICAS)

-- Politicas para R_MECANICO

/*  Agregamos una politica VPD (ver practica 3 / tema 2) para limitar el acceso
    a los datos de cada empleado agregamos restricciones a las tablas "EMPLEADO",
    "VACACIONES", "FACTURA" y "TRABAJA".

    SELECT *
        FROM ALL_CONSTRAINTS
            WHERE CONSTRAINT_NAME LIKE '%EMPLEADO%';

    Permite precisar que tablas dependen de EMPLEADO_ID
*/

-- Devuelve un filtro para la clausula WHERE.
-- https://www.techonthenet.com/oracle/functions/sys_context.php
CREATE OR REPLACE
    FUNCTION AUTORACLE.SOLO_EMPLEADO_ACTUAL_EMPLEADO (p_esquema IN VARCHAR2, p_objeto IN VARCHAR2)
        RETURN VARCHAR2 AS
        BEGIN
            IF (SYS_CONTEXT('userenv', 'isdba') = 'TRUE') THEN
                RETURN '';
            ELSE
                RETURN 'IDEMPLEADO = ''' || SYS_CONTEXT('userenv', 'session_userid') || '''';
            END IF;
        END;
/

-- Devuelve un filtro para la clausula WHERE.
-- https://www.techonthenet.com/oracle/functions/sys_context.php
CREATE OR REPLACE
    FUNCTION AUTORACLE.SOLO_EMPLEADO_ACTUAL_VAC_TRA_FAC (p_esquema IN VARCHAR2, p_objeto IN VARCHAR2)
        RETURN VARCHAR2 AS
        BEGIN
            IF (SYS_CONTEXT('userenv', 'isdba') = 'TRUE') THEN
                RETURN '';
            ELSE
                RETURN 'EMPLEADO_IDEMPLEADO = ''' || SYS_CONTEXT('userenv', 'session_userid') || '''';
            END IF;
        END;
/


/* Eliminar las politicas de R_MECANICO
BEGIN
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'EMPLEADO', 'POL_EMPLEADO_EMPLEADO');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'VACACIONES', 'POL_EMPLEADO_VACACIONES');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'TRABAJA', 'POL_EMPLEADO_TRABAJA');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'FACTURA', 'POL_EMPLEADO_FACTURA');
END;
/
*/

BEGIN
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE',
        object_name => 'EMPLEADO',
        policy_name => 'POL_EMPLEADO_EMPLEADO',
        function_schema => 'AUTORACLE',
        policy_function => 'SOLO_EMPLEADO_ACTUAL_EMPLEADO',
        statement_types => 'SELECT'
    );

    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE',
        object_name => 'VACACIONES',
        policy_name => 'POL_EMPLEADO_VACACIONES',
        function_schema => 'AUTORACLE',
        policy_function => 'SOLO_EMPLEADO_ACTUAL_VAC_TRA_FAC',
        statement_types => 'SELECT'
    );

    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE',
        object_name => 'TRABAJA',
        policy_name => 'POL_EMPLEADO_TRABAJA',
        function_schema => 'AUTORACLE',
        policy_function => 'SOLO_EMPLEADO_ACTUAL_VAC_TRA_FAC',
        statement_types => 'SELECT'
    );

    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE',
        object_name => 'FACTURA',
        policy_name => 'POL_EMPLEADO_FACTURA',
        function_schema => 'AUTORACLE',
        policy_function => 'SOLO_EMPLEADO_ACTUAL_VAC_TRA_FAC',
        statement_types => 'SELECT'
    );
END;
/


-- Restricciones (politicas) para R_CLIENTE

/*  Agregamos una politica VPD (ver practica 3 / tema 2) para limitar el acceso
    a los datos de cada cliente agregamos restricciones a las tablas "CLIENTE",
    "CITA", "FACTURA" y "VEHICULO".

    SELECT *
        FROM ALL_CONSTRAINTS
            WHERE CONSTRAINT_NAME LIKE '%CLIENTE%';

    Permite precisar que tablas dependen de EMPLEADO_ID.
*/

-- Devuelve un filtro para la clausula WHERE.
-- https://www.techonthenet.com/oracle/functions/sys_context.php
CREATE OR REPLACE
    FUNCTION AUTORACLE.SOLO_CLIENTE_ACTUAL_CLIENTE (p_esquema IN VARCHAR2, p_objeto IN VARCHAR2)
        RETURN VARCHAR2 AS
        BEGIN
            IF (SYS_CONTEXT('userenv', 'isdba') = 'TRUE') THEN
                RETURN '';
            ELSE
                RETURN 'IDCLIENTE = ''' || SYS_CONTEXT('userenv', 'session_userid') || '''';
            END IF;
        END;
/

-- Devuelve un filtro para la clausula WHERE.
-- https://www.techonthenet.com/oracle/functions/sys_context.php
CREATE OR REPLACE
    FUNCTION AUTORACLE.SOLO_CLIENTE_ACTUAL_CITA_VEHIC_FAC (p_esquema IN VARCHAR2, p_objeto IN VARCHAR2)
        RETURN VARCHAR2 AS
        BEGIN
            IF (SYS_CONTEXT('userenv', 'isdba') = 'TRUE') THEN
                RETURN '';
            ELSE
                RETURN 'CLIENTE_IDCLIENTE = ''' || SYS_CONTEXT('userenv', 'session_userid') || '''';
            END IF;
        END;
/


/* Eliminar las policias de R_CLIENTE
BEGIN
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'CLIENTE', 'POL_CLIENTE_CLIENTE');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'CITA', 'POL_CLIENTE_CITA');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'VEHICULO', 'POL_CLIENTE_VEHICULO');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'FACTURA', 'POL_CLIENTE_FACTURA');
END;
/
*/

BEGIN
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE',
        object_name => 'CLIENTE',
        policy_name => 'POL_CLIENTE_CLIENTE',
        function_schema => 'AUTORACLE',
        policy_function => 'SOLO_CLIENTE_ACTUAL_CLIENTE',
        statement_types => 'SELECT'
    );

    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE',
        object_name => 'CITA',
        policy_name => 'POL_CLIENTE_CITA',
        function_schema => 'AUTORACLE',
        policy_function => 'SOLO_CLIENTE_ACTUAL_CITA_VEHIC_FAC',
        statement_types => 'SELECT'
    );

    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE',
        object_name => 'VEHICULO',
        policy_name => 'POL_CLIENTE_VEHICULO',
        function_schema => 'AUTORACLE',
        policy_function => 'SOLO_CLIENTE_ACTUAL_CITA_VEHIC_FAC',
        statement_types => 'SELECT'
    );

    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE',
        object_name => 'FACTURA',
        policy_name => 'POL_CLIENTE_FACTURA',
        function_schema => 'AUTORACLE',
        policy_function => 'SOLO_CLIENTE_ACTUAL_CITA_VEHIC_FAC',
        statement_types => 'SELECT'
    );
END;
/



/* [2]
Crea una tabla denominada COMPRA_FUTURA que incluya el NIF, telefono, nombre e email del proveedor, referencia de pieza y
cantidad. Necesitamos un procedimiento P_REVISA que cuando se ejecute compruebe si las piezas han caducado. De esta forma,
insertara en COMPRA_FUTURA aquellas piezas caducadas junto a los datos necesarios para realizar en el futuro la compra.
*/

CREATE TABLE autoracle.COMPRA_FUTURA (
    PROVEEDOR_NIF VARCHAR2(16 BYTE),
    TELEFONO NUMBER(*, 0),
    NOMBRE VARCHAR2(64 BYTE),
	EMAIL VARCHAR2(64 BYTE),
    CODREF_PIEZA NUMBER(*, 0) UNIQUE,
    CANTIDAD NUMBER(*, 0));

CREATE OR REPLACE
    PROCEDURE autoracle.p_revisa AS
        BEGIN
            DECLARE
                CURSOR datos IS
                    SELECT  Pr.nif, Pr.telefono, Pr.nombre, Pr.email,
                            Pi.cantidad, Pi.codref, Pi.feccaducidad
                        FROM autoracle.pieza Pi
                            JOIN autoracle.proveedor Pr ON proveedor_nif = nif;

                repetida NUMBER;

            BEGIN
                FOR fila IN datos LOOP
                    IF fila.feccaducidad < (sysdate-1) THEN
                        INSERT INTO autoracle.compra_futura
                                VALUES (
                                fila.nif,
                                fila.telefono,
                                fila.nombre,
                                fila.email,
                                fila.codref,
                                fila.cantidad);

                        COMMIT;
                    END IF;

                END LOOP;

                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN
                        DBMS_OUTPUT.put_line('Se ignoraron algunas piezas ya incluidas.');
            END;

        END p_revisa;
/

/* [3]
Añadir dos campos a la tabla factura: iva calculado y total. Implementar un procedimiento P_CALCULA_FACT que recorre
los datos necesarios de las piezas utilizadas y el porcentaje de iva y calcula la cantidad en euros para estos dos campos.
*/

ALTER TABLE factura ADD (iva_calculado NUMBER, iva_total NUMBER);			
			
CREATE OR REPLACE P_CALCULA_FACT AS
    dummy NUMBER;
BEGIN

END;
/

/* [4] ----------- HECHO -----------
Necesitamos una vista denominada V_IVA_CUATRIMESTRE con los atributos AÑO, TRIMESTRE, IVA_TOTAL siendo trimestre
un numero de 1 a 4. El IVA_TOTAL es el IVA devengado (suma del IVA de las facturas de ese trimestre).
Dar permiso de seleccion a los Administrativos.
*/

-- Suponiendo que existe una vista V_COSTE_PIEZAS_TOTAL que proporcione, para cada factura, el coste total de piezas y
-- [el coste total de horas trabajadas], y la fecha de emision de la factura
-- Dada la arquitectura de la BD proporcionada, no hay manera de agregar las horas trabajadas por empleado.

CREATE OR REPLACE VIEW AUTORACLE.V_COSTE_PIEZAS_TOTAL AS
    SELECT f.IDFACTURA,
           f.FECEMISION,
           f.IVA,
           SUM(p.PRECIOUNIDADVENTA) AS TOTAL_PIEZAS
    FROM AUTORACLE.factura f
    JOIN AUTORACLE.contiene c ON f.IDFACTURA = c.FACTURA_IDFACTURA
    JOIN AUTORACLE.pieza p ON p.CODREF = c.PIEZA_CODREF
    GROUP BY f.IDFACTURA, f.FECEMISION, f.IVA;

SELECT * FROM AUTORACLE.V_COSTE_PIEZAS_TOTAL;

-- Sorry soy un paquete con los "groups by"
-- https://www.oracletutorial.com/oracle-basics/oracle-group-by/

CREATE OR REPLACE VIEW AUTORACLE.V_INTERMEDIA_IVA_TRIMESTRE AS
    SELECT TO_CHAR(FECEMISION, 'YYYY') as "año",
           TO_CHAR(FECEMISION, 'Q') as "cuatrimestre",
           (IVA / 100) * TOTAL_PIEZAS as "iva_total"
    FROM AUTORACLE.V_COSTE_PIEZAS_TOTAL;
    
SELECT * FROM AUTORACLE.V_INTERMEDIA_IVA_TRIMESTRE;

CREATE OR REPLACE VIEW AUTORACLE.V_IVA_TRIMESTRE AS
    SELECT "año", "cuatrimestre", SUM("iva_total") as "iva_total"
    FROM V_INTERMEDIA_IVA_TRIMESTRE
    GROUP BY "año", "cuatrimestre";
    
SELECT * FROM AUTORACLE.V_IVA_TRIMESTRE;

GRANT SELECT ON AUTORACLE.V_IVA_TRIMESTRE TO R_ADMINISTRATIVO;

/* [5]
Crear un paquete en PL/SQL de analisis de datos que contenga:
    1.  La funcion F_Calcular_Piezas: devolvera la media, minimo y maximo numero de unidades compradas (en cada lote)
        de una determinada pieza en un año concreto.
    2.  La funcion F_Calcular_Tiempos: devolvera la media de dias en las que se termina un servicio
        (Fecha de realizacion - Fecha de entrada en taller) asi como la media de las horas de mano de obra de los
        servicios de Reparacion.
    3.  El procedimiento P_Recompensa: encuentra el servicio proporcionado mas rapido y mas lento (en dias) y a los
        empleados involucrados los recompensa con un +/- 5% en su sueldo base respectivamente.
*/

-- Por la definicion de la BD, hay una columna con un acento en la tabla LOTE. La renombramos
ALTER TABLE LOTE
    RENAME COLUMN "N�MERO_DE_PIEZAS" TO "NUMERO_DE_PIEZAS";

DESC LOTE;
DESC COMPRA;

-- Primero, agrupamos las funciones y procedimientos en un paquete
-- http://www.rebellionrider.com/how-to-create-pl-sql-packages-in-oracle-database/
CREATE OR REPLACE PACKAGE PKG_AUTORACLE_ANALISIS AS
    FUNCTION F_CALCULAR_PIEZAS(codref IN VARCHAR2, year in VARCHAR2) RETURN MEDIA_MIN_MAX_UNITS;
    FUNCTION F_CALCULAR_TIEMPOS RETURN QUE_WEA_SE_DEVUELVE_PENDEJO;
    PROCEDURE P_RECOMPENSA;
END;

-- Creamos todos los tipos propios que nos hagan falta
-- DISCLAIMER: Faltaría pasar MEDIA_MIN_MAX_UNITS como "Record" en vez de como "Object"
CREATE OR REPLACE TYPE MEDIA_MIN_MAX_UNITS AS OBJECT (
    media NUMBER,
    minimo NUMBER,
    maximo NUMBER);

-- DISCLAIMER: Faltaría pasar TIEMPOS_SERVICIO como "Record" en vez de como "Object"
CREATE OR REPLACE TYPE TIEMPOS_SERVICIO AS OBJECT (
    dias NUMBER,
    horas NUMBER);

-- Creamos las funciones y procedimientos del paquete (RECOMIENDO probar a definirlas fuera del paquete para ver si
-- compilan, y despues borrarlas)
CREATE OR REPLACE PACKAGE BODY AUTORACLE.PKG_AUTORACLE_ANALISIS IS
    -- 1.
    CREATE OR REPLACE FUNCTION F_CALCULAR_PIEZAS(input_codref IN VARCHAR2, input_anno in VARCHAR2)
    RETURN MEDIA_MIN_MAX_UNITS AS
        resultado MEDIA_MIN_MAX_UNITS;
        media NUMBER := 0;
        minimo NUMBER := 10e10;
        maximo NUMBER := 0;
        kounter NUMBER := 0;
        CURSOR tabla IS
            SELECT TO_CHAR(c.FECEMISION, 'YYYY') AS "ANNO", 
                   l.PIEZA_CODREF AS "PIEZA_CODREF",
                   l.NUMERO_DE_PIEZAS AS "NUMERO_DE_PIEZAS"
            FROM AUTORACLE.COMPRA c
            JOIN AUTORACLE.LOTE l ON c.IDCOMPRA = l.COMPRA_IDCOMPRA;
    BEGIN
        FOR fila IN tabla LOOP
            IF fila.ANNO = input_anno AND fila.PIEZA_CODREF = input_codref THEN -- este IF puede ir nel cursor nel WHERE
                kounter := kounter + 1;
                media := media + fila.NUMERO_DE_PIEZAS;
                IF fila.NUMERO_DE_PIEZAS > maximo THEN
                    maximo := fila.NUMERO_DE_PIEZAS;
                END IF;
                IF fila.NUMERO_DE_PIEZAS < minimo THEN
                    minimo := fila.NUMERO_DE_PIEZAS;
                END IF;
            END IF;
        END LOOP;

        resultado.media :=  media / kounter;
        resultado.minimo := minimo;
        resultado.maximo := maximo;
        RETURN resultado;
    END;

    -- 2. Es una funcion, pero entiendo que si se usa para TODOS los servicios, entonces es mejor un Procedimiento.
    -- Lo aclararia en el foro.
    -- ESTE EJERCICIO NO LO TENGO CLARO (comprobad el CURSOR, creo que esta mal).
    -- Hay que obtener la media de dias para UN SERVICIO o para todos los servicio de un tipo?????
    -- Media de dias sobre un servicio no tiene sentido, pues UN SERVICIO (IDSERVICIO) SOLO SE HACE UNA VEZ
    CREATE OR REPLACE FUNCTION F_CALCULAR_TIEMPOS(id_servicio IN NUMBER)
    RETURNS TIEMPOS_SERVICIO AS -- deberia de devolver un "RECORD"
        resultado TIEMPOS_SERVICIO;
        CURSOR datos IS
            SELECT SUM((s.FECREALIZACION - s.FECRECEPCION)) / COUNT(s.IDSERVICIO) AS MEDIADIAS,
                   SUM(r.HORAS) / COUNT(s.IDSERVICIO) AS MEDIAHORAS,
                   s.IDSERVICIO AS IDSERVICIO
            FROM AUTORACLE.servicio s
            JOIN AUTORACLE.reparacion r ON s.IDSERVICIO = r.IDSERVICIO;
    BEGIN
        FOR fila IN DATOS LOOP
            IF fila.IDSERVICIO = id_servicio THEN
                resultado.dias = fila.MEDIADIAS;
                resultado.horas = fila.MEDIAHORAS;
            END IF;
        END LOOP;
        RETURN resultado;
    END;

    -- 3. VALE! Creo que este procedimiento usa las funcion del (2) para cada servicio.
    CREATE OR REPLACE PROCEDURE P_RECOMPENSA AS
        servicio_mas_lento_horas NUMBER := 0; -- asi, el mas lento es el que menos dias tarda (por defecto)
        servicio_mas_rapido_horas NUMBER := 10e10; -- asi, el mas rapido es el que mas dias tarda (por defecto)
        servicio_mas_lento NUMBER;
        servicio_mas_lento_idempleado NUMBER;
        servicio_mas_rapido NUMBER;
        servicio_mas_rapido_idempleado NUMBER;
        CURSOR servicios IS
            SELECT F_CALCULAR_TIEMPOS(s.IDSERVICIO).dias as MEDIA_DIAS,
                   s.IDSERVICIO as IDSERVICIO,
                   t.EMPLEADO_IDEMPLEADO as IDEMPLEADO
            FROM AUTORACLE.SERVICIO s
            JOIN AUTORACLE.TRABAJA t ON s.IDSERVICIO = t.SERVICIO_IDSERVICIO;
    BEGIN
        -- seguro que hay una forma mas sencilla de sacar el minimo y el maximo
        FOR servicio IN servicios LOOP
            IF servicio.MEDIA_DIAS < servicio_mas_rapido_horas THEN
                servicio_mas_rapido = servicio.IDSERVICIO;
                servicio_mas_rapido_horas = servicio.MEDIA_DIAS;
                servicio_mas_rapido_idempleado = servicio.IDEMPLEADO;
            END IF;

            IF servicio.MEDIA_DIAS > servicio_mas_lento_horas THEN
                servicio_mas_lento = servicio.IDSERVICIO;
                servicio_mas_lento_horas = servicio.MEDIA_DIAS;
                servicio_mas_lento_idempleado = servicio.IDEMPLEADO;
            END IF;
        END LOOP;

        -- ya tenemos el servicio mas lento y el mas rapido
        UPDATE AUTORACLE.EMPLEADO
            SET SUELDOBASE = SUELDOBASE - (0.05 * SUELDOBASE)
            WHERE IDEMPLEADO = servicio_mas_lento_idempleado;

        UPDATE AUTORACLE.EMPLEADO
            SET SUELDOBASE = SUELDOBASE + (0.05 * SUELDOBASE)
            WHERE IDEMPLEADO = servicio_mas_rapido_idempleado;
    END;
END;



/* [6]
Añadir al modelo una tabla FIDELIZACION que permite almacenar un descuento por cliente y año.
Crear un paquete en PL/SQL de gestion de descuentos.
    El procedimiento P_Calcular_Descuento, tomara un cliente y un año y calculara el descuento del que podra
    disfrutar el año siguiente. Para ello, hasta un maximo del 10%, ira incrementando el descuento en un 1%,
    por cada una de las siguientes acciones:
        1.  Por cada servicio pagado por el cliente.
        2.  Por cada ocasion en la que el cliente tuvo que esperar mas de 5 dias desde que solicito la cita hasta
            que se concerto.
        3.  Por cada servicio proporcionado en el que tuvo que esperar mas de la media de todos los servicios.
*/

CREATE TABLE AUTORACLE.FIDELIZACION(
    "CLIENTE_IDCLIENTE" VARCHAR2(16),
    "DESCUENTO" NUMBER(3), -- de 0 a 100
    "ANNO" VARCHAR2(4) -- de 0 a 9999
);

-- Para asegurarnos de que hay UN descuento POR cliente y año, creamos un trigger
CREATE OR REPLACE TRIGGER AUTORACLE.TR_ASEGURAR_FIDELIZACION
    BEFORE INSERT OR UPDATE ON AUTORACLE.FIDELIZACION FOR EACH ROW
DECLARE
    descuento_ya_existe EXCEPTION;
    CURSOR tabla IS
        SELECT anno
        FROM AUTORACLE.FIDELIZACION
        WHERE cliente_idcliente = :new.CLIENTE_IDCLIENTE;
BEGIN
    FOR fila IN tabla LOOP
        IF fila.ANNO = :new.ANNO THEN -- si el cliente y el anno coinciden: ERROR
            RAISE descuento_ya_existe;
        END IF;
    END LOOP;
EXCEPTION
    WHEN descuento_ya_existe THEN
        RAISE_APPLICATION_ERROR(-20015, 'Ya existe un descuento para '||:new.CLIENTE_IDCLIENTE||' en el año '||:new.ANNO);
END;

INSERT ALL -- agregamos datos a la tabla
    INTO AUTORACLE.FIDELIZACION VALUES ('789', 10, '2020')
    INTO AUTORACLE.FIDELIZACION VALUES ('789', 20, '2019')
    INTO AUTORACLE.FIDELIZACION VALUES ('16', 35, '2008')
    INTO AUTORACLE.FIDELIZACION VALUES ('420', 5, '2020')
SELECT 1 FROM DUAL;
COMMIT;

-- Ahora, creamos el paquete :)
CREATE OR REPLACE PACKAGE AUTORACLE.PKG_GESTION_DESCUENTOS AS
    PROCEDURE p_calcular_descuento(cliente VARCHAR2,anno DATE);
    PROCEDURE p_aplicar_descuento(cliente VARCHAR2,anno DATE);
END pck_gestion_descuentos;
/

CREATE OR REPLACE PACKAGE BODY AUTORACLE.PKG_GESTION_DESCUENTOS AS

    PROCEDURE P_CALCULAR_DESCUENTO(cliente VARCHAR2, anno NUMBER) AS
        v_descuento NUMBER := 0; -- comenzamos con descuento 0
        prox_anno NUMBER := TO_NUMBER(anno) + 1;
        facturas_pagadas NUMBER; -- contador para facturas (servicios) pagadas
        citas_5_dias_espera NUMBER; -- contador para citas esperadas
        servicios_mas_horas_espera NUMBER; -- contador para servicios esperados
        media_horas_espera NUMBER; -- para calcular la media de horas de espera de los servicios
    BEGIN
        -- acumulamos todos los posibles descuentos (hasta 10)
        -- 1. Todos los servicios pagados (facturas) por el cliente (en ese año)
        SELECT COUNT(*) INTO facturas_pagadas
            FROM AUTORACLE.FACTURA
            WHERE CLIENTE_IDCLIENTE = cliente AND TO_CHAR(FECEMISION, 'YYYY') = anno;

        -- 2. Todas las citas donde el cliente tuvo que esperar mas de 5 dias (en ese año)
        SELECT COUNT(*) INTO citas_5_dias_espera
            FROM AUTORACLE.CITA
            WHERE CLIENTE_IDCLIENTE = cliente AND
                  ABS(FECHA_CONCERTADA - FECHA_SOLICITUD) > 5 AND
                  TO_CHAR(FECHA_SOLICITUD, 'YYYY') = anno; -- cogemos la fecha mas antigua

        -- 3. Todos los servicios dados al cliente donde tuvo que esperar mas de la media de dias de todos los servicios
        SELECT AVG(FECREALIZACION - FECAPERTURA) INTO media_horas_espera FROM SERVICIO;
        SELECT COUNT(*) INTO servicios_mas_horas_espera
            FROM AUTORACLE.SERVICIO s
            JOIN AUTORACLE.VEHICULO v ON s.VEHICULO_NUMBASTIDOR = v.NUMBASTIDOR
            WHERE v.CLIENTE_IDCLIENTE = cliente AND
                  TO_CHAR(s.FECAPERTURA, 'YYYY') = anno AND -- cogemos la fecha mas antigua
                  (FECREALIZACION - FECAPERTURA) > media_horas_espera;

        -- guardamos el descuento para el anno siguiente
        v_descuento := (1 * facturas_pagadas) + (1 * citas_5_dias_espera) + (1 * servicios_mas_horas_espera);
        v_descuento := GREATEST(v_descuento, 10); -- como maximo es un 10% descuento

        INSERT INTO AUTORACLE.FIDELIZACION
            VALUES (cliente, v_descuento, TO_CHAR(prox_anno)); -- el prox anno se calcula al principio
    END;

    PROCEDURE P_APLICAR_DESCUENTO(cliente VARCHAR2, anno VARCHAR2) AS -- anno es un string "2000", "1965", etc
        v_descuento NUMBER := 0; -- por defecto el descuento es 0
    BEGIN
        SELECT descuento INTO v_descuento -- obtiene el descuento (si es que existe)
        FROM AUTORACLE.FIDELIZACION
        WHERE CLIENTE_IDCLIENTE = cliente AND ANNO = anno;

        UPDATE AUTORACLE.FACTURA
            SET DESCUENTO = v_descuento
            WHERE CLIENTE_IDCLIENTE = cliente AND TO_CHAR(FECEMISION, 'YYYY') = anno;
    EXCEPTION
        WHEN no_data_found THEN -- si el "SELECT .. INTO .." no obtiene nada
            RAISE_APPLICATION_ERROR(-20016, 'P_APLICAR_DESCUENTO Error: No hay descuento para '||cliente||', '||anno);
    END;

END;
/



/* [7]
Crear un paquete en PL/SQL de gestion de empleados que incluya las operaciones para crear, borrar y modificar los datos de un
empleado. Hay que tener en cuenta que algunos empleados tienen un usuario y, por tanto, al insertar o modificar un empleado,
si su usuario no es nulo, habra que crear su usuario.
Ademas, el paquete ofrecera procedimientos para bloquear/desbloquear cuentas de usuarios de modo individual.
Tambien se debe disponer de una opcion para bloquear y desbloquear todas las cuentas de los empleados.
*/

CREATE OR REPLACE PACKAGE AUTORACLE.PKG_GESTION_EMPLEADOS AS
    PROCEDURE PR_CREAR_EMPLEADO;
    PROCEDURE PR_MODIFICAR_EMPLEADO;
    PROCEDURE PR_BLOQUEAR_DESBLOQUEAR_USUARIO;
    PROCEDURE PR_BLOQUEAR_DESBLOQUEAR_ALL_USUARIOS;
END;

CREATE OR REPLACE PACKAGE BODY AUTORACLE.PKG_GESTION_EMPLEADOS IS
    -- PENDIENTE
END;

-- [8] Escribir un trigger que cuando se eliminen los datos de un cliente fidelizado se eliminen a su vez toda su
-- informacion de fidelizacion y los datos de su vehiculo.

CREATE OR REPLACE TRIGGER TR_Eliminar_Cliente_Fidelizado
BEFORE DELETE ON CLIENTE FOR EACH ROW
BEGIN
	DELETE FROM FIDELIZACION WHERE CLIENTE = :old.IDCLIENTE;
	DELETE FROM VEHICULO WHERE CLIENTE_IDCLIENTE = :old.IDCLIENTE;
END;
/

-- [9] Crear un JOB que ejecute el procedimiento P_REVISA todos los dias a las 21:00. Crear otro JOB que, anualmente
-- (el 31 de diciembre a las 23.55), llame a P_Recompensa.

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'Llamada_A_Recompensas',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN PROCEDURE P_Recompensa END;',
        start_date => TO_DATE('2020-12-31 23:55:00' , 'YYYY-MM-DD HH24:MI:SS'),
        repeat_interval => 'FREQ = YEARLY; INTERVAL=1',
        enabled => TRUE,
        comments => 'Llama al procedimiento P_Recompensa anualmente el 31 de Diciembre a las 23.55');

END;
/
