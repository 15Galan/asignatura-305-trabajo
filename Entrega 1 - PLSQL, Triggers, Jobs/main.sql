-- Trabajo en Grupo (PL/SQL, Triggers, Jobs), a 29 Abril 2020.
-- Antonio J. Galan, Manuel Gonzalez, Pablo Rodriguez, Joaquin Terrasa

-- Ver estado (ON / OFF) del paquete DBMS_OUTPUT
-- SHOW SERVEROUTPUT;
-- Activar la opcion de mostrar mensajes por pantalla (1 vez / sesion)
SET SERVEROUTPUT ON;

/* Que ejercicios funcionan 100%
  + Ej 1
  + Ej 2
  + Ej 4

*/

/* Que falta
 + Ej 3: revisar la respuesta de Onieva/Enrique en el foro - no esta claro el ejercicio
 + Ej
*/

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
    TO R_ADMINISTRATIVO;

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

-- Para comprobar que todas las politicas funcionan
SELECT * FROM AUTORACLE.CLIENTE; -- { desde SYSTEM }
SELECT * FROM AUTORACLE.CLIENTE; -- { desde USUARIO1, cuyo ID se asocia a un cliente previamente }
SELECT * FROM AUTORACLE.EMPLEADO; -- { desde AUTORACLE, que es ABD }
SELECT * FROM AUTORACLE.EMPLEADO; -- { desde USUARIO2, cuyo ID se asocia a un empleado previamente }

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
    PROCEDURE autoracle.p_revisa IS
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
    
    END p_revisa;
/

-- Comprobamos que funciona
UPDATE AUTORACLE.PIEZA
    SET FECCADUCIDAD = SYSDATE - 1
    WHERE CODREF = '1234';

BEGIN
    p_revisa;
END;
/

SELECT * FROM AUTORACLE.COMPRA_FUTURA;

/* [3]
Agregar dos campos a la tabla factura: iva calculado y total. Implementar un procedimiento P_CALCULA_FACT que recorre los
datos necesarios de las piezas utilizadas y el porcentaje de iva y calcula la cantidad en euros para estos dos campos.
*/

ALTER TABLE AUTORACLE.FACTURA
    ADD (iva_calculado NUMBER, total NUMBER);

-- inicializamos a 0 todos los valores (iva_calculado, total)
-- de esta forma despues lo unico que hacemos es ir acumulando los valores
UPDATE AUTORACLE.FACTURA
    SET iva_calculado = 0, total = 0;

CREATE OR REPLACE PROCEDURE AUTORACLE.P_CALCULA_FACT AS
    iva_mult NUMBER;
    CURSOR tabla IS
        SELECT f.IDFACTURA, f.IVA, p.CODREF, p.PRECIOUNIDADVENTA, p.PRECIOUNIDADCOMPRA
        FROM AUTORACLE.FACTURA f
        JOIN AUTORACLE.CONTIENE c ON c.FACTURA_IDFACTURA = f.IDFACTURA
        JOIN AUTORACLE.PIEZA p ON c.PIEZA_CODREF = p.CODREF;
BEGIN
    FOR fila IN tabla LOOP
        iva_mult := 1 + (fila.IVA / 100); -- el IVA es un factor de crecimiento
        UPDATE AUTORACLE.FACTURA
            SET IVA_CALCULADO = IVA_CALCULADO + iva_mult * fila.PRECIOUNIDADVENTA,
                TOTAL = TOTAL + ((iva_mult * fila.PRECIOUNIDADVENTA) - fila.PRECIOUNIDADCOMPRA)
            WHERE IDFACTURA = fila.IDFACTURA;
    END LOOP;
END;
/

-- Comprobamos que funcione
BEGIN
    p_calcula_fact;
END;
/

SELECT * FROM AUTORACLE.FACTURA;

/* [4]
Necesitamos una vista denominada V_IVA_CUATRIMESTRE con los atributos ANNO, TRIMESTRE, IVA_TOTAL siendo trimestre
un numero de 1 a 4. El IVA_TOTAL es el IVA devengado (suma del IVA de las facturas de ese trimestre).
Dar permiso de seleccion a los Administrativos.
*/

-- Suponiendo que existe una vista V_COSTE_PIEZAS_TOTAL que proporcione, para cada factura, el coste total de piezas y
-- [el coste total de horas trabajadas], y la fecha de emision de la factura
-- Dada la arquitectura de la BD proporcionada, no hay manera de agregar las horas trabajadas por empleado.

CREATE OR REPLACE VIEW AUTORACLE.V_IVA_TRIMESTRE AS
    SELECT TO_CHAR(f.FECEMISION, 'YYYY') AS "ANNO",
        TO_CHAR(f.FECEMISION, 'Q') AS "TRIMESTRE",
        (f.IVA / 100) * SUM(p.PRECIOUNIDADVENTA) AS IVA_DEVANGADO
    FROM AUTORACLE.factura f
    JOIN AUTORACLE.contiene c ON f.IDFACTURA = c.FACTURA_IDFACTURA
    JOIN AUTORACLE.pieza p ON p.CODREF = c.PIEZA_CODREF
    GROUP BY TO_CHAR(f.FECEMISION, 'YYYY'), 
            TO_CHAR(f.FECEMISION, 'Q'),
            f.IVA;

GRANT SELECT ON AUTORACLE.V_IVA_TRIMESTRE TO R_ADMINISTRATIVO;

-- Comprobamos que funcione
SELECT * FROM AUTORACLE.V_IVA_TRIMESTRE; -- { desde AUTORACLE (rol administrativo) }
SELECT * FROM AUTORACLE.V_IVA_TRIMESTRE; -- { desde USUARIO1 (rol cliente) }


/* [5]
Crear un paquete en PL/SQL de analisis de datos que contenga:
    1.  La funcion F_Calcular_Piezas: devolvera la media, minimo y maximo numero
        de unidades compradas (en cada lote) de una determinada pieza en un aÃ±o
        concreto.
    2.  La funcion F_Calcular_Tiempos: devolvera la media de dias en las que se
        termina un servicio (Fecha de realizacion - Fecha de entrada en taller)
        asi como la media de las horas de mano de obra de los servicios de
        Reparacion.
    3.  El procedimiento P_Recompensa: encuentra el servicio proporcionado mas
        rapido y mas lento (en dias) y a los empleados involucrados los
        recompensa con un +/- 5% en su sueldo base respectivamente.
*/

-- Primero, agrupamos las funciones y procedimientos en un paquete
-- http://www.rebellionrider.com/how-to-create-pl-sql-packages-in-oracle-database/
CREATE OR REPLACE
    PACKAGE autoracle.PKG_AUTORACLE_ANALISIS AS

    TYPE MEDIA_MIN_MAX_UNITS IS
        RECORD (media NUMBER, minimo NUMBER, maximo NUMBER);

    TYPE TIEMPOS_SERVICIO IS
        RECORD (dias NUMBER, horas NUMBER);

    FUNCTION F_CALCULAR_PIEZAS(codref IN VARCHAR2, anno in VARCHAR2)
        RETURN MEDIA_MIN_MAX_UNITS;

    FUNCTION F_CALCULAR_TIEMPOS(servicio IN NUMBER)
        RETURN tiempos_servicio;

    PROCEDURE P_RECOMPENSA;

END pkg_autoracle_analisis;
/


-- Creamos las funciones y procedimientos del paquete (RECOMIENDO probar a definirlas fuera del paquete para ver si
-- compilan, y despues borrarlas)
CREATE OR REPLACE
    PACKAGE BODY AUTORACLE.PKG_AUTORACLE_ANALISIS AS

    FUNCTION F_CALCULAR_PIEZAS(codref IN VARCHAR2, anno in VARCHAR2)
        RETURN MEDIA_MIN_MAX_UNITS AS

            resultado MEDIA_MIN_MAX_UNITS;

            media NUMBER := 0;
            minimo NUMBER := 1000;
            maximo NUMBER := 0;
            contador NUMBER := 0;

            CURSOR tabla IS
                SELECT  TO_CHAR(c.FECEMISION, 'YYYY') AS ANNO,
                        L.PIEZA_CODREF AS PIEZA_CODREF,
                        L.NUMERO_DE_PIEZAS AS NUMERO_DE_PIEZAS
                    FROM autoracle.COMPRA c
                        JOIN AUTORACLE.LOTE L ON c.IDCOMPRA = L.COMPRA_IDCOMPRA;

        BEGIN
            FOR fila IN tabla LOOP
                -- Este IF puede ir en el cursor en el WHERE
                IF fila.ANNO = anno AND fila.PIEZA_CODREF = codref THEN
                    contador := contador + 1;
                    media := media + fila.NUMERO_DE_PIEZAS;

                    IF fila.NUMERO_DE_PIEZAS > maximo THEN
                        maximo := fila.NUMERO_DE_PIEZAS;

                    ELSIF fila.NUMERO_DE_PIEZAS < minimo THEN
                        minimo := fila.NUMERO_DE_PIEZAS;

                    END IF;

                END IF;

            END LOOP;

            resultado.media :=  media / contador;
            resultado.minimo := minimo;
            resultado.maximo := maximo;

            RETURN resultado;
        END;

    -- Es una funcion, pero entiendo que si se usa para TODOS los servicios,
    -- entonces es mejor un Procedimiento.
    FUNCTION F_CALCULAR_TIEMPOS(servicio IN NUMBER)
        RETURN TIEMPOS_SERVICIO AS

            resultado TIEMPOS_SERVICIO;

            CURSOR datos IS
                SELECT  SUM(S.fecrealizacion - S.fecrecepcion) / COUNT(S.idservicio) AS media_dias,
                        SUM(R.horas) / COUNT(S.idservicio) AS media_horas,
                        S.idservicio AS id_servicio
                    FROM servicio S
                        JOIN reparacion R ON S.idservicio = R.idservicio
                        GROUP BY S.idservicio;

        BEGIN
            FOR fila IN DATOS LOOP
                IF servicio = fila.id_servicio THEN
                    resultado.dias := fila.media_dias;
                    resultado.horas := fila.media_horas;

                END IF;

            END LOOP;

            RETURN resultado;
        END;

    -- Creo que este procedimiento usa las funcion del (2) para cada servicio
    PROCEDURE P_RECOMPENSA AS
        servicio_mas_lento_horas NUMBER := 0;       -- Se esperan valores '>0'
        servicio_mas_rapido_horas NUMBER := 1000;   -- Se esperan valores '<1000'

        servicio_mas_lento NUMBER;
        servicio_mas_lento_idempleado NUMBER;

        servicio_mas_rapido NUMBER;
        servicio_mas_rapido_idempleado NUMBER;

        -- Debe revisarse como usar un dato de un RECORD (error de tipo)
        /* El cursor debe ser reparado
        CURSOR servicios IS
            SELECT F_CALCULAR_TIEMPOS(s.IDSERVICIO).dias as MEDIA_DIAS,
                   s.IDSERVICIO as IDSERVICIO,
                   t.EMPLEADO_IDEMPLEADO as IDEMPLEADO
                FROM AUTORACLE.SERVICIO s
                    JOIN AUTORACLE.TRABAJA t ON s.IDSERVICIO = t.SERVICIO_IDSERVICIO;
        */

    BEGIN
        NULL;

        -- Descomentar una vez se arregle el cursor o dara fallo al compilar,
        -- elimina la sentencia NULL; anterior, ya que esta puesta por lo mismo
        /*
        -- Encontrar los servicios mas rapido y mas lento
        FOR servicio IN servicios LOOP
            IF servicio.MEDIA_DIAS < servicio_mas_rapido_horas THEN
                servicio_mas_rapido := servicio.IDSERVICIO;
                servicio_mas_rapido_horas := servicio.MEDIA_DIAS;
                servicio_mas_rapido_idempleado := servicio.IDEMPLEADO;

            ELSIF servicio.MEDIA_DIAS > servicio_mas_lento_horas THEN
                servicio_mas_lento := servicio.IDSERVICIO;
                servicio_mas_lento_horas := servicio.MEDIA_DIAS;
                servicio_mas_lento_idempleado := servicio.IDEMPLEADO;

            END IF;

        END LOOP;

        -- Obtenidos los servicios, se actualizan los sueldos
        UPDATE AUTORACLE.EMPLEADO
            SET SUELDOBASE = SUELDOBASE - (0.05 * SUELDOBASE)
                WHERE IDEMPLEADO = servicio_mas_lento_idempleado;

        UPDATE AUTORACLE.EMPLEADO
            SET SUELDOBASE = SUELDOBASE + (0.05 * SUELDOBASE)
                WHERE IDEMPLEADO = servicio_mas_rapido_idempleado;

        COMMIT;
        */
    END;

END pkg_autoracle_analisis;
/



/* [6]
AÃ±adir al modelo una tabla FIDELIZACION que permite almacenar un descuento por
cliente y aÃ±o; y crear un paquete en PL/SQL de gestion de descuentos.
    1.  El procedimiento P_Calcular_Descuento, tomara un cliente y un aÃ±o y
        calculara el descuento del que podra disfrutar el aÃ±o siguiente. Para
        ello, hasta un maximo del 10%, ira incrementando el descuento en un 1%
        por cada una de las siguientes acciones:
            * Por cada servicio pagado por el cliente.
            * Por cada ocasion en la que el cliente tuvo que esperar mas de 5
              dias desde que solicito la cita hasta que se concerto.
            * Por cada servicio proporcionado en el que tuvo que esperar mas de
              la media de todos los servicios.
    2.  El procedimiento P_Aplicar_descuento tomara el aÃ±o y el cliente. Si en
        la tabla FIDELIZACION hay un descuento calculado a aplicar ese aÃ±o,
        lo harÃ¡ para todas las facturas que encuentre (en ese aÃ±o).
*/

CREATE TABLE AUTORACLE.FIDELIZACION(
    cliente_idcliente VARCHAR2(16),
    descuento NUMBER(3),            -- de 0 a 100
    anno NUMBER(4)                  -- de 0 a 9999
);

-- Para asegurarnos de que hay UN descuento POR cliente y aÃ±o, creamos un trigger
CREATE OR REPLACE
  TRIGGER AUTORACLE.TR_ASEGURAR_FIDELIZACION
    BEFORE INSERT OR UPDATE
      ON AUTORACLE.FIDELIZACION FOR EACH ROW

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
            RAISE_APPLICATION_ERROR(-20015, 'Ya existe un descuento para el cliente '||:new.CLIENTE_IDCLIENTE||' en el aÃ±o '||:new.ANNO);
    END;
/


-- Ahora, creamos el paquete :)
CREATE OR REPLACE
    PACKAGE AUTORACLE.PKG_GESTION_DESCUENTOS AS
        PROCEDURE p_calcular_descuento(cliente VARCHAR2, anno NUMBER);
        PROCEDURE p_aplicar_descuento(cliente VARCHAR2, anno NUMBER);

END pkg_gestion_descuentos;
/

CREATE OR REPLACE
    PACKAGE BODY AUTORACLE.PKG_GESTION_DESCUENTOS AS

        PROCEDURE P_CALCULAR_DESCUENTO(cliente VARCHAR2, anno NUMBER) AS
            v_descuento NUMBER := 0;    -- Comenzamos con descuento 0
            facturas NUMBER;            -- Contador para facturas pagadas
            citas5dias NUMBER;          -- Contador para citas esperadas
            servicios_largos NUMBER;    -- Contador para servicios esperados
            media_horas NUMBER;         -- Horas de espera media de los servicios

            BEGIN
                -- Todas las facturas del cliente (en ese aÃ±o)
                SELECT COUNT(*) INTO facturas
                    FROM AUTORACLE.FACTURA
                        WHERE CLIENTE_IDCLIENTE = cliente
                            AND TO_CHAR(FECEMISION, 'YYYY') = TO_CHAR(anno);


                -- Todas las citas con mas de 5 dias de espera (en ese aÃ±o)
                SELECT COUNT(*) INTO citas5dias
                    FROM AUTORACLE.CITA
                        WHERE CLIENTE_IDCLIENTE = cliente
                            AND ABS(FECHA_CONCERTADA - FECHA_SOLICITUD) > 5
                            AND TO_CHAR(FECHA_SOLICITUD, 'YYYY') = TO_CHAR(anno);


                SELECT AVG(FECREALIZACION - FECAPERTURA) INTO media_horas
                    FROM SERVICIO;

                -- Todos los servicios con mas de la media de dias de espera (en ese aÃ±o)
                SELECT COUNT(*) INTO servicios_largos
                    FROM AUTORACLE.SERVICIO s
                        JOIN AUTORACLE.VEHICULO v ON s.VEHICULO_NUMBASTIDOR = v.NUMBASTIDOR
                        WHERE v.CLIENTE_IDCLIENTE = cliente
                            AND TO_CHAR(s.FECAPERTURA, 'YYYY') = TO_CHAR(anno)
                            AND (FECREALIZACION - FECAPERTURA) > media_horas;

                -- Guardamos el descuento para el aÃ±o siguiente (maximo 10%)
                v_descuento := LEAST(facturas + citas5dias + servicios_largos, 10);

                INSERT INTO AUTORACLE.FIDELIZACION
                    VALUES (cliente, v_descuento, anno + 1);

            END;

        PROCEDURE P_APLICAR_DESCUENTO(cliente VARCHAR2, anno NUMBER) AS
            v_descuento NUMBER := 0;    -- Por defecto el descuento es 0

            BEGIN
                SELECT descuento INTO v_descuento   -- Descuento (si existe)
                    FROM AUTORACLE.FIDELIZACION F
                        WHERE CLIENTE_IDCLIENTE = cliente
                            AND TO_NUMBER(F.anno) = anno;

                UPDATE AUTORACLE.FACTURA
                    SET DESCUENTO = v_descuento
                        WHERE CLIENTE_IDCLIENTE = cliente
                            AND TO_CHAR(FECEMISION, 'YYYY') = TO_CHAR(anno);

            EXCEPTION
                WHEN no_data_found THEN     -- Si no existe el descuento...
                    RAISE_APPLICATION_ERROR(-20016, 'P_APLICAR_DESCUENTO Error: No hay descuento para el cliente '||cliente||' para el aÃ±o '||anno);

            END;

END pkg_gestion_descuentos;
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



CREATE OR REPLACE PROCEDURE PR_CREAR_EMPLEADO(nombre EMPLEADO.NOMBRE%TYPE, ap EMPLEADO.APELLIDO1%TYPE) IS

identificacion NUMBER;

sentencia VARCHAR2(500);

BEGIN
    sentencia := 'CREATE USER ' || nombre || ' IDENTIFIED BY ' || nombre || ' 
    DEFAULT TABLESPACE TS_AUTORACLE';
    DBMS_OUTPUT.PUT_LINE(sentencia);
    EXECUTE IMMEDIATE sentencia;
    --Se ejecuta la sentencia, Se crea el usuario para el empleado y un ID aleatorio--
    SELECT USER_ID INTO identificacion FROM ALL_USERS WHERE USERNAME = nombre;
    --Este select no funciona porque cuando se ejecuta el Select, no esta el dato aun en la BD 
    --(aunque deberia estar, porque la sentencia EXECUTE IMMEDIATE sirve para eso)--
    INSERT INTO EMPLEADO(IDEMPLEADO, NOMBRE, APELLIDO1, FECENTRADA, DESPEDIDO, SUELDOBASE)
        VALUES(identificacion, nombre, ap, sysdate, 0, 1500);

END;
/

CREATE OR REPLACE PROCEDURE PR_MODIFICAR_EMPLEADO( ide EMPLEADO.IDEMPLEADO%TYPE, des EMPLEADO.DESPEDIDO%TYPE,
                sueldo EMPLEADO.SUELDOBASE%TYPE, pos EMPLEADO.PUESTO%TYPE, 
                horas EMPLEADO.HORAS%TYPE, ret EMPLEADO.RETENCIONES%TYPE ) IS         
 des_mal EXCEPTION;

BEGIN
    IF ( ((des > 1) OR (des < 0) )) then 
        RAISE des_mal;
    END IF;

    UPDATE EMPLEADO
    SET DESPEDIDO = des , SUELDOBASE = sueldo ,
    PUESTO = pos , HORAS = horas, RETENCIONES = ret
    WHERE IDEMPLEADO = ide;
        EXCEPTION 
         WHEN des_mal THEN
         DBMS_OUTPUT.PUT_LINE('Valor de "Despido" incorrecto (ingrese 0 o 1)'); 
         WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Parametros incorrectos.
            Introduce (IDEmpleado, Despido, Sueldo Base, Puesto, Horas, Retenciones)');
END;
/
CREATE OR REPLACE PROCEDURE PR_BORRAR_EMPLEADO(ide EMPLEADO.IDEMPLEADO%TYPE) IS
    usuario All_USERS.USER_ID%TYPE;
BEGIN

    delete FROM empleado
    where IDEMPLEADO = ide;
    --¿Cuando se elimina el empleado se elimina su usuario ? 
    -- SELECT USERNAME INTO usuario 
    -- FROM ALL_USERS WHERE USER_ID = ide; --
    
    --DROP USER usuario CASCADE--
END;
/







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

--BEGIN
--    DBMS_SCHEDULER.CREATE_JOB (
--        job_name => 'Llamada_A_Recompensas',
--        job_type => 'PLSQL_BLOCK',
--        job_action => 'BEGIN PROCEDURE P_Recompensa END;',
--        start_date => TO_DATE('2020-12-31 23:55:00' , 'YYYY-MM-DD HH24:MI:SS'),
--        repeat_interval => 'FREQ = YEARLY; INTERVAL=1',
--        enabled => TRUE,
--        comments => 'Llama al procedimiento P_Recompensa anualmente el 31 de Diciembre a las 23.55');
--
--END;
--/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"AUTORACLE"."JOB_REVISA"',
            job_type => 'STORED_PROCEDURE',
            job_action => 'AUTORACLE.P_REVISA',
            number_of_arguments => 0,
            start_date => NULL,
            repeat_interval => 'FREQ=DAILY;BYTIME=210000',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'Ejecuta el procedimiento p_revisa');

         
     
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"AUTORACLE"."JOB_REVISA"', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"AUTORACLE"."JOB_REVISA"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
      
   
  
    
    DBMS_SCHEDULER.enable(
             name => '"AUTORACLE"."JOB_REVISA"');
END;

/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"AUTORACLE"."JOB_RECOMPENSA"',
            job_type => 'STORED_PROCEDURE',
            job_action => 'AUTORACLE.P_RECOMPENSA',
            number_of_arguments => 0,
            start_date => NULL,
            repeat_interval => 'FREQ=YEARLY;BYDATE=1231;BYTIME=235500',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'Trabajo que ejecuta el procedimiento p_recompensa');

         
     
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"AUTORACLE"."JOB_RECOMPENSA"', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"AUTORACLE"."JOB_RECOMPENSA"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
      
   
  
    
    DBMS_SCHEDULER.enable(
             name => '"AUTORACLE"."JOB_RECOMPENSA"');
END;

/
