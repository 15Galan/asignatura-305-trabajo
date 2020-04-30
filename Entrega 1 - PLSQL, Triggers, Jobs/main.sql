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

-- [4]

-- [5]

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
			
			
-- [6]

-- [7]

-- [8]
