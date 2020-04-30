-- Trabajo en Grupo (PL/SQL, Triggers, Jobs), a 29 Abril 2020.
-- Antonio J. Galán, Manuel González, Pablo Rodríguez, Joaquin Terrasa

-- { Por defecto, usamos el usuario "AUTORACLE" creado previamente en la BD }

-- [1] Modificar el modelo (si es necesario) para almacenar el usuario de Oracle que cada empleado o cliente pueda
-- utilizar para conectarse a la base de datos. Además, habrá de crear roles dependiendo del tipo de usuario:
--   Administrativo, con acceso a toda la BD;
--   Empleado, con acceso sólo a aquellos objetos que precise para su trabajo
--     (y nunca podrá acceder a los datos de otros empleados);
--   Cliente, con acceso sólo a los datos propios, de su vehículo y de sus servicios.
-- Los roles se llamarán R_ADMINISTRATIVO, R_MECANICO, R_CLIENTE.

-- ||||| desde SYSDBA |||||

-- Antes de comenzar, asignaremos USUARIO1 y USUARIO2 (de las practicas anteriores) a las tablas EMPLEADO y CLIENTE
-- respectivamente, para poder probar los cambios que vamos a realizar en la BD.
SELECT username, user_id FROM ALL_USERS;
-- en mi caso, ID(USUARIO1) = 104 e ID(USUARIO2) = 105

UPDATE AUTORACLE.CLIENTE
    SET IDCLIENTE = 104 WHERE IDCLIENTE = 111;

UPDATE AUTORACLE.EMPLEADO
    SET IDEMPLEADO = 105 WHERE IDEMPLEADO = 300;

CREATE ROLE r_administrativo;
CREATE ROLE r_mecanico;
CREATE ROLE r_cliente;

GRANT R_CLIENTE TO USUARIO1;
GRANT R_MECANICO TO USUARIO2;
GRANT R_ADMINISTRATIVO TO AUTORACLE;

-- { permisos para R_ADMINISTRATIVO }

GRANT dba
    TO r_administrativo;

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

-- agregamos una politica VPD (ver practica 3 / tema 2) para limitar el acceso a los datos de cada empleado
-- agregamos restricciones a las tablas "EMPLEADO", "VACACIONES", "FACTURA" y "TRABAJA".
SELECT * FROM ALL_CONSTRAINTS WHERE CONSTRAINT_NAME LIKE '%EMPLEADO%';
-- permite precisar qué tablas dependen de EMPLEADO_ID

-- devuelve un filtro para la clausula WHERE
-- https://www.techonthenet.com/oracle/functions/sys_context.php
CREATE OR REPLACE FUNCTION AUTORACLE.SOLO_EMPLEADO_ACTUAL_EMPLEADO (p_esquema IN VARCHAR2, p_objeto IN VARCHAR2)
    RETURN VARCHAR2 AS
BEGIN
    IF (SYS_CONTEXT('userenv', 'isdba') = 'TRUE') THEN
        RETURN '';
    ELSE
        RETURN 'IDEMPLEADO = ''' || SYS_CONTEXT('userenv', 'session_userid') || '''';
    END IF;
END;

CREATE OR REPLACE FUNCTION AUTORACLE.SOLO_EMPLEADO_ACTUAL_VAC_TRA_FAC (p_esquema IN VARCHAR2, p_objeto IN VARCHAR2)
    RETURN VARCHAR2 AS
BEGIN
    IF (SYS_CONTEXT('userenv', 'isdba') = 'TRUE') THEN
        RETURN '';
    ELSE
        RETURN 'EMPLEADO_IDEMPLEADO = ''' || SYS_CONTEXT('userenv', 'session_userid') || '''';
    END IF;
END;

BEGIN
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE', object_name => 'EMPLEADO', policy_name => 'POL_EMPLEADO_EMPLEADO',
        function_schema => 'AUTORACLE', policy_function => 'SOLO_EMPLEADO_ACTUAL_EMPLEADO', statement_types => 'SELECT'
    );
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE', object_name => 'VACACIONES', policy_name => 'POL_EMPLEADO_VACACIONES',
        function_schema => 'AUTORACLE', policy_function => 'SOLO_EMPLEADO_ACTUAL_VAC_TRA_FAC', statement_types => 'SELECT'
    );
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE', object_name => 'TRABAJA', policy_name => 'POL_EMPLEADO_TRABAJA',
        function_schema => 'AUTORACLE', policy_function => 'SOLO_EMPLEADO_ACTUAL_VAC_TRA_FAC', statement_types => 'SELECT'
    );
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE', object_name => 'FACTURA', policy_name => 'POL_EMPLEADO_FACTURA',
        function_schema => 'AUTORACLE', policy_function => 'SOLO_EMPLEADO_ACTUAL_VAC_TRA_FAC', statement_types => 'SELECT'
    );
END;
/

-- en el caso de que te equivoques:
BEGIN
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'EMPLEADO', 'POL_EMPLEADO_EMPLEADO');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'VACACIONES', 'POL_EMPLEADO_VACACIONES');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'TRABAJA', 'POL_EMPLEADO_TRABAJA');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'FACTURA', 'POL_EMPLEADO_FACTURA');
END;
/

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
    ON autoracle.vehículo
    TO r_mecanico, r_cliente;

-- agregamos una politica VPD (ver practica 3 / tema 2) para limitar el acceso a los datos de cada cliente
-- agregamos restricciones a las tablas "CLIENTE", "CITA", "FACTURA" y "VEHICULO".
SELECT * FROM ALL_CONSTRAINTS WHERE CONSTRAINT_NAME LIKE '%CLIENTE%';
-- permite precisar qué tablas dependen de EMPLEADO_ID

-- devuelve un filtro para la clausula WHERE
-- https://www.techonthenet.com/oracle/functions/sys_context.php
CREATE OR REPLACE FUNCTION AUTORACLE.SOLO_CLIENTE_ACTUAL_CLIENTE (p_esquema IN VARCHAR2, p_objeto IN VARCHAR2)
    RETURN VARCHAR2 AS
BEGIN
    IF (SYS_CONTEXT('userenv', 'isdba') = 'TRUE') THEN
        RETURN '';
    ELSE
        RETURN 'IDCLIENTE = ''' || SYS_CONTEXT('userenv', 'session_userid') | '''';
    END IF;
END;

CREATE OR REPLACE FUNCTION AUTORACLE.SOLO_CLIENTE_ACTUAL_CITA_VEHIC_FAC (p_esquema IN VARCHAR2, p_objeto IN VARCHAR2)
    RETURN VARCHAR2 AS
BEGIN
    IF (SYS_CONTEXT('userenv', 'isdba') = 'TRUE') THEN
        RETURN '';
    ELSE
        RETURN 'CLIENTE_IDCLIENTE = ''' || SYS_CONTEXT('userenv', 'session_userid') || '''';
    END IF;
END;

BEGIN
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE', object_name => 'CLIENTE', policy_name => 'POL_CLIENTE_CLIENTE',
        function_schema => 'AUTORACLE', policy_function => 'SOLO_CLIENTE_ACTUAL_CLIENTE',
        statement_types => 'SELECT'
    );
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE', object_name => 'CITA', policy_name => 'POL_CLIENTE_CITA',
        function_schema => 'AUTORACLE', policy_function => 'SOLO_CLIENTE_ACTUAL_CITA_VEHIC_FAC',
        statement_types => 'SELECT'
    );
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE', object_name => 'VEHICULO', policy_name => 'POL_CLIENTE_VEHICULO',
        function_schema => 'AUTORACLE', policy_function => 'SOLO_CLIENTE_ACTUAL_CITA_VEHIC_FAC',
        statement_types => 'SELECT'
    );
    DBMS_RLS.ADD_POLICY (
        object_schema => 'AUTORACLE', object_name => 'FACTURA', policy_name => 'POL_CLIENTE_FACTURA',
        function_schema => 'AUTORACLE', policy_function => 'SOLO_CLIENTE_ACTUAL_CITA_VEHIC_FAC',
        statement_types => 'SELECT'
    );
END;
/

-- en el caso de que te equivoques:
BEGIN
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'CLIENTE', 'POL_CLIENTE_CLIENTE');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'CITA', 'POL_CLIENTE_CITA');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'VEHICULO', 'POL_CLIENTE_VEHICULO');
    DBMS_RLS.DROP_POLICY('AUTORACLE', 'FACTURA', 'POL_CLIENTE_FACTURA');
END;
/


-- [2] Crea una tabla denominada COMPRA_FUTURA que incluya el NIF, teléfono, nombre e email del proveedor,
-- referencia de pieza y cantidad. Necesitamos un procedimiento P_REVISA que cuando se ejecute compruebe si las piezas
-- han caducado. De esta forma, insertará en COMPRA_FUTURA aquellas piezas caducadas junto a los datos necesarios para
-- realizar en el futuro la compra.

CREATE TABLE COMPRA_FUTURA (
    PROVEEDOR_NIF VARCHAR2(16 BYTE),
    TELEFONO NUMBER(*, 0),
    NOMBRE VARCHAR2(64 BYTE),
	EMAIL VARCHAR2(64 BYTE),
    CANTIDAD NUMBER(*, 0),
    CODREF_PIEZA NUMBER(*, 0));

CREATE OR REPLACE PROCEDURE P_REVISA AS
    CURSOR C_COMPRUEBA IS
        SELECT CODREF, NOMBRE, CANTIDAD, FECCADUCIDAD, PROVEEDOR_NIF
        FROM PIEZA
        WHERE FECCADUCIDAD < SYSDATE;
    tlfo NUMBER(38);
    email VARCHAR2(64);
BEGIN
    FOR FILA IN C_COMPRUEBA LOOP
        SELECT TELEFONO INTO tlfo FROM PROVEEDOR WHERE NIF=FILA.PROVEEDOR_NIF;
        SELECT EMAIL INTO email FROM PROVEEDOR WHERE NIF=FILA.PROVEEDOR_NIF;
        INSERT INTO COMPRA_FUTURA
            VALUES (FILA.PROVEEDOR_NIF, tlfo, FILA.NOMBRE, email, FILA.CODREF, FILA.CANTIDAD);
    END LOOP;
END P_REVISA;
/
			
-- [3] Necesitamos una vista denominada V_IVA_CUATRIMESTRE con los atributos AÑO, TRIMESTRE, IVA_TOTAL siendo trimestre 
-- un número de 1 a 4. El IVA_TOTAL es el IVA devengado (suma del IVA de las facturas de ese trimestre). Dar permiso
-- de selección a los Administrativos.

-- ||||| ESTA MAL! |||||

CREATE OR REPLACE VIEW AUTORACLE.V_IVA_TRIMESTRE AS
    SELECT UNIQUE(TO_CHAR(FECEMISION, 'YYYY')) AS "año",
           TO_CHAR(FECEMISION, 'Q') AS "trimestre",
           SUM(IVA) AS "iva_total"
    FROM AUTORACLE.FACTURA
    GROUP BY FECEMISION;

SELECT * FROM AUTORACLE.V_IVA_TRIMESTRE;
SELECT * FROM AUTORACLE.FACTURA;

-- [4] Crear un paquete en PL/SQL de análisis de datos.
--       1. La función F_Calcular_Piezas devolverá la media, mínimo y máximo número de unidades compradas (en cada lote)
--          de una determinada pieza en un año concreto.
--       2. La función F_Calcular_Tiempos devolverá la media de días en las que se termina un servicio
--          (Fecha de realización – Fecha de entrada en taller) así como la media de las horas de mano de obra de los
--          servicios de Reparación.
--       3. El procedimiento P_Recompensa encuentra el servicio proporcionado más rápido y más lento (en días) y a los
--          empleados involucrados los recompensa con un +/- 5% en su sueldo base respectivamente.

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
CREATE OR REPLACE PACKAGE BODY PKG_AUTORACLE_ANALISIS IS
    -- 1.
    CREATE OR REPLACE FUNCTION F_CALCULAR_PIEZAS(codref IN VARCHAR2, year in VARCHAR2) RETURN MEDIA_MIN_MAX_UNITS AS
        resultado MEDIA_MIN_MAX_UNITS;
    BEGIN
        -- Falta por hacer
    END;

    -- 2. Es una funcion, pero entiendo que si se usa para TODOS los servicios, entonces es mejor un Procedimiento.
    -- Lo aclararia en el foro.
    CREATE OR REPLACE FUNCTION F_CALCULAR_TIEMPOS RETURN QUE_WEA_SE_DEVUELVE_PENDEJO AS
        dummy_var NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Do nothing');
    END;

    -- 3. VALE! Creo que este procedimiento usa las dos funciones de arriba para cada servicio. Entonces las funciones
    -- van para cada servicio (No se explica bien en el enunciado).
    CREATE OR REPLACE PROCEDURE P_RECOMPENSA AS
        dummy_var NUMBER;
    BEGIN
        FOR numero IN (SELECT 1 FROM DUAL) LOOP
            DBMS_OUTPUT.PUT_LINE('Do nothing');
        END LOOP;
    END;
END;


-- [5] Añadir al modelo una tabla FIDELIZACIÓN que permite almacenar un descuento por cliente y año. Crear un paquete en
-- PL/SQL de gestión de descuentos.
--       1. El procedimiento P_Calcular_Descuento, tomará un cliente y un año y calculará el descuento del que podrá
--          disfrutar el año siguiente. Para ello, hasta un máximo del 10%, irá incrementando el descuento en un 1%,
--          por cada una de las siguientes acciones:
--              1. Por cada servicio pagado por el cliente.
--              2. Por cada ocasión en la que el cliente tuvo que esperar más de 5 días desde que solicitó la cita hasta
--                 que se concertó.
--              3. Por cada servicio proporcionado en el que tuvo que esperar más de la media de todos los servicios.

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
			
			
-- [6] Crear un paquete en PL/SQL de gestión de empleados que incluya las operaciones para crear, borrar y modificar los
-- datos de un empleado. Hay que tener en cuenta que algunos empleados tienen un usuario y, por tanto, al insertar o 
-- modificar un empleado, si su usuario no es nulo, habrá que crear su usuario. Además, el paquete ofrecerá
-- procedimientos para bloquear/desbloquear cuentas de usuarios de modo individual.
-- También se debe disponer de una opción para bloquear y desbloquear todas las cuentas de los empleados.

-- [7] Escribir un trigger que cuando se eliminen los datos de un cliente fidelizado se eliminen a su vez toda su
-- información de fidelización y los datos de su vehículo.

-- [8] Crear un JOB que ejecute el procedimiento P_REVISA todos los días a las 21:00. Crear otro JOB que, anualmente 
-- (el 31 de diciembre a las 23.55), llame a P_Recompensa.

	BEGIN
		DBMS_SCHEDULER.CREATE_JOB
		(
			job_name => 'Llamada_A_Recompensas',
			job_type => 'PLSQL_BLOCK',
			job_action => 'BEGIN PROCEDURE P_Recompensa END;',
			start_date => TO_DATE('2020-12-31 23:55:00' , 'YYYY-MM-DD HH24:MI:SS'),
			repeat_interval => 'FREQ = YEARLY; INTERVAL=1',
			enabled => TRUE,
			comments => 'Llama al procedimiento P_Recompensa anualmente el 31 de Diciembre a las 23.55'
		):

	END;
/