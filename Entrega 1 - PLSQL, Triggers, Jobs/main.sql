-- Trabajo en Grupo (PL/SQL, Triggers, Jobs), a 29 Abril 2020.
-- Antonio J. Galan, Manuel Gonzalez, Pablo Rodriguez, Joaquin Terrasa

-- { Por defecto, usamos el usuario "AUTORACLE" creado previamente en la BD }

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
Añadir dos campos a la tabla factura: iva calculado y total.
Implementar un procedimiento P_CALCULA_FACT
que recorre los datos necesarios de las piezas utilizadas y 
el porcentaje de iva y calcula la cantidad en euros para estos dos campos.
*/

ALTER TABLE factura ADD (iva_calculado NUMBER,iva_total NUMBER);			
			
			
/* [4]
Necesitamos una vista denominada V_IVA_CUATRIMESTRE con los atributos AÑO, TRIMESTRE, IVA_TOTAL siendo trimestre
un numero de 1 a 4. El IVA_TOTAL es el IVA devengado (suma del IVA de las facturas de ese trimestre).
Dar permiso de seleccion a los Administrativos.
*/

-- ||||| ESTA MAL! |||||

CREATE OR REPLACE VIEW AUTORACLE.V_IVA_TRIMESTRE AS
    SELECT UNIQUE(TO_CHAR(FECEMISION, 'YYYY')) AS "año",
           TO_CHAR(FECEMISION, 'Q') AS "trimestre",
           SUM(IVA) AS "iva_total"
    FROM AUTORACLE.FACTURA
    GROUP BY FECEMISION;

SELECT * FROM AUTORACLE.V_IVA_TRIMESTRE;
SELECT * FROM AUTORACLE.FACTURA;



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

-- Primero, agrupamos las funciones y procedimientos en un paquete
-- http://www.rebellionrider.com/how-to-create-pl-sql-packages-in-oracle-database/
CREATE OR REPLACE PACKAGE PKG_AUTORACLE_ANALISIS AS
    FUNCTION F_CALCULAR_PIEZAS(codref IN VARCHAR2, year in VARCHAR2) RETURN MEDIA_MIN_MAX_UNITS;
    FUNCTION F_CALCULAR_TIEMPOS RETURN QUE_WEA_SE_DEVUELVE_PENDEJO;
    PROCEDURE P_RECOMPENSA;
END;

-- Creamos todos los tipos propios que nos hagan falta
CREATE OR REPLACE TYPE MEDIA_MIN_MAX_UNITS AS OBJECT (
    media NUMBER,
    minimo NUMBER,
    maximo NUMBER);

-- Creamos las funciones y procedimientos del paquete (RECOMIENDO probar a definirlas fuera del paquete para ver si
-- compilan, y despues borrarlas)
CREATE OR REPLACE PACKAGE BODY AUTORACLE.PKG_AUTORACLE_ANALISIS IS
    -- 1.
    CREATE OR REPLACE FUNCTION F_CALCULAR_PIEZAS(codref IN VARCHAR2, year in VARCHAR2) RETURN MEDIA_MIN_MAX_UNITS AS
        resultado MEDIA_MIN_MAX_UNITS;
    BEGIN
        -- PENDIENTE
    END;

    -- 2. Es una funcion, pero entiendo que si se usa para TODOS los servicios, entonces es mejor un Procedimiento.
    -- Lo aclararia en el foro.
    CREATE OR REPLACE FUNCTION F_CALCULAR_TIEMPOS
        RETURNS TABLE(mediaDias NUMBER, mediaHoras NUMBER)
    BEGIN
        RETURN QUERY
            SELECT SUM((s.FECREALIZACION - s.FECRECEPCION)) / COUNT(s.IDSERVICIO) AS MediaDias,
                   SUM(r.HORAS) / COUNT(s.IDSERVICIO) AS MediaHoras
            FROM servicio s
            JOIN reparacion r ON s.IDSERVICIO = r.IDSERVICIO;
    END;

    -- 3. VALE! Creo que este procedimiento usa las dos funciones de arriba para cada servicio. Entonces las funciones
    -- van para cada servicio (no se explica bien en el enunciado).
    CREATE OR REPLACE PROCEDURE P_RECOMPENSA AS
        dummy_var NUMBER;
    BEGIN
        FOR numero IN (SELECT 1 FROM DUAL) LOOP
            DBMS_OUTPUT.PUT_LINE('Do nothing');
        END LOOP;
    END;
END;



/* [6]
Añadir al modelo una tabla FIDELIZACIoN que permite almacenar un descuento por cliente y año.
Crear un paquete en PL/SQL de gestion de descuentos.
    El procedimiento P_Calcular_Descuento, tomara un cliente y un año y calculara el descuento del que podra
    disfrutar el año siguiente. Para ello, hasta un maximo del 10%, ira incrementando el descuento en un 1%,
    por cada una de las siguientes acciones:
        1.  Por cada servicio pagado por el cliente.
        2.  Por cada ocasion en la que el cliente tuvo que esperar mas de 5 dias desde que solicito la cita hasta
            que se concerto.
        3.  Por cada servicio proporcionado en el que tuvo que esperar mas de la media de todos los servicios.
*/

CREATE TABLE autoracle.fidelizacion(
    "CLIENTE" VARCHAR2(16),
    "DESCUENTO" NUMBER,
    "ANNO" DATE
);

CREATE OR REPLACE PACKAGE autoracle.pck_gestion_descuentos AS
    PROCEDURE p_calcular_descuento(cliente VARCHAR2,anno DATE);
    PROCEDURE p_aplicar_descuento(cliente VARCHAR2,anno DATE);
END pck_gestion_descuentos;
/

CREATE OR REPLACE PACKAGE BODY autoracle.pck_gestion_descuentos AS
    PROCEDURE p_calcular_descuento(cliente VARCHAR2,anno DATE) AS
    BEGIN
        IF
        THEN
            UPDATE fidelizacion F
            SET F.descuento=F.descuento+0.01
            WHERE F.cliente=cliente;
        END IF;
        IF (SELECT fecha_concertada-fecha_solicitud
            FROM cita
            WHERE cliente_idcliente=cliente) > 5
        THEN
            UPDATE fidelizacion F
            SET F.descuento=F.descuento+0.01
            WHERE F.cliente=cliente;
        END IF;
        IF  (SELECT S.fecrealizacion-S.fecapertura
            FROM servicio S
            WHERE S.idservicio IS IN
            (SELECT S.idservicio FROM servicio S JOIN vehiculo V
            ON S.vehiculo_numbastidor=V.numbastidor
            WHERE S.vehiculo_numbastidor=V.numbastidor
            AND V.cliente_idcliente=cliente))
            >
            (SELECT AVG(fecrealizacion-fecapertura)
            FROM servicio
            WHERE fecrealizacion IS NOT NULL)
        THEN
            UPDATE fidelizacion F
            SET F.descuento=F.descuento+0.01
            WHERE F.cliente=cliente;
        END IF;
        IF (SELECT F.descuento FROM fidelizacion F WHERE F.cliente=cliente)>10 THEN
            UPDATE fidelizacion F SET F.descuento=10 WHERE F.cliente=cliente;
        END IF;
    END p_calcular_descuento;
    PROCEDURE p_aplicar_descuento(cliente VARCHAR2,anno DATE) AS
    BEGIN

    END p_aplicar_descuento;
END pck_gestion_descuentos;
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
