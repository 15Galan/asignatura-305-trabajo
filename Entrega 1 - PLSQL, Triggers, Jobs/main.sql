-- Trabajo en Grupo (PL/SQL, Triggers, Jobs), a 29 Abril 2020.
-- Antonio J. Galan, Manuel Gonzalez, Pablo Rodriguez, Joaquin Terrasa

-- Ver estado (ON / OFF) del paquete DBMS_OUTPUT
-- SHOW SERVEROUTPUT;
-- Activar la opcion de mostrar mensajes por pantalla (1 vez / sesion)
SET SERVEROUTPUT ON;

/* [1]
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


/*-- Nueva tabla para almacenar usuarios
DROP TABLE autoracle.usuario;
CREATE TABLE autoracle.usuario (
  idusuario VARCHAR2(16),
  username VARCHAR2(64) NOT NULL,
  email VARCHAR2(64) NOT NULL,
  contrasena VARCHAR2(32) DEFAULT 'defaultPASSWORD',    -- Proteger mas adelante
  tipo NUMBER(1) NOT NULL,       -- cliente (0), empleado (1) y administrador (2)
  PRIMARY KEY (idusuario, tipo));

ALTER TABLE autoracle.usuario
  ADD CONSTRAINT fk_cliente FOREIGN KEY (idusuario) REFERENCES autoracle.cliente(idcliente);

ALTER TABLE autoracle.usuario
  ADD CONSTRAINT fk_empleado FOREIGN KEY (idusuario) REFERENCES autoracle.empleado(idempleado);
*/

CREATE OR REPLACE
  VIEW autoracle.v_clientes_datos AS (
    SELECT
      C.idcliente AS "ID",
      -- U.username AS usuario,
      C.nombre AS nombre,
      C.apellido1 AS "PRIMER APELLIDO",
      C.apellido2 AS "SEGUNDO APELLIDO",
      C.telefono AS telefono,
      -- U.email AS email,
      V.matricula AS matricula,
      MA.nombre AS marca,
      MO.nombre AS modelo,
      V.kilometraje AS kilometros

      FROM autoracle.cliente C
        INNER JOIN autoracle.vehiculo V ON C.idcliente = V.cliente_idcliente
        INNER JOIN autoracle.marca MA   ON V.modelo_marca_idmarca = MA.idmarca
        INNER JOIN autoracle.modelo MO  ON V.modelo_idmodelo = MO.idmodelo
  );

CREATE OR REPLACE
    VIEW autoracle.v_cliente_datos AS (
        SELECT *
            FROM autoracle.v_clientes
                WHERE usuario = user
    );


CREATE OR REPLACE
  VIEW autoracle.v_clientes_servicios AS (
    SELECT
      C.idcliente AS "ID",
      -- U.username AS usuario,
      C.nombre AS nombre,
      C.apellido1 AS "PRIMER APELLIDO",
      C.apellido2 AS "SEGUNDO APELLIDO",
      C.telefono AS telefono,
      -- U.email AS email,
      S.idservicio AS servicio,
      S.estado AS estado,
      S.fecapertura AS "FECHA DE APERTURA",
      S.fecrealizacion AS "FECHA DE REALIZACION",
      S.fecrecepcion AS "FECHA DE RECEPCION",
      S.obschapa AS chapa,
      S.efectividad AS efectividad,
      S.vehiculo_numbastidor AS vehiculo,
      V.matricula AS matricula,
      MA.nombre AS marca,
      MO.nombre AS modelo,
      V.kilometraje AS kilometros

      FROM autoracle.cliente C
        INNER JOIN autoracle.vehiculo V ON C.idcliente = V.cliente_idcliente
        INNER JOIN autoracle.marca MA   ON V.modelo_marca_idmarca = MA.idmarca
        INNER JOIN autoracle.modelo MO  ON V.modelo_idmodelo = MO.idmodelo
        INNER JOIN autoracle.servicio S ON V.numbastidor = S.vehiculo_numbastidor
  );

CREATE OR REPLACE
    VIEW v_cliente_servicios AS (
        SELECT *
            FROM v_clientes_servicios
                -- WHERE usuario = user
    );


CREATE OR REPLACE
  VIEW autoracle.v_empleados_datos AS (
    SELECT
      E.idempleado AS "ID",
      -- U.username AS usuario,
      E.nombre AS nombre,
      E.apellido1 AS "PRIMER APELLIDO",
      E.apellido2 AS "SEGUNDO APELLIDO",
      -- U.email AS email,
      E.despedido AS despedido,
      E.fecentrada AS contratado,
      E.sueldobase AS "SUELDO BASE",
      E.horas AS horas,
      E.puesto AS puesto,
      E.retenciones AS retenciones,
      V.identificador AS vacaciones,
      V.concedido AS concedidas,
      V.fecentrada AS comienzo,
      V.fecsalida AS final

      FROM autoracle.empleado E
        INNER JOIN autoracle.vacaciones V ON E.idempleado = V.empleado_idempleado
  );

CREATE OR REPLACE
    VIEW v_empleado_datos AS (
        SELECT *
            FROM v_empleados_datos
                -- WHERE usuario = user
    );


CREATE OR REPLACE
  VIEW autoracle.v_empleados_servicios AS (
    SELECT
      E.idempleado AS "ID",
      -- U.username AS usuario,
      E.nombre AS nombre,
      E.apellido1 AS "PRIMER APELLIDO",
      E.apellido2 AS "SEGUNDO APELLIDO",
      -- U.email AS email,
      S.idservicio AS servicio,
      S.estado AS "ESTADO DEL SERVICO",
      S.fecapertura AS "FECHA DE APERTURA",
      S.fecrealizacion AS "FECHA DE REALIZACION",
      S.fecrecepcion AS "FECHA DE RECEPCION",
      S.obschapa AS chapa,
      S.efectividad AS efectividad,
      S.vehiculo_numbastidor AS vehiculo,
      R.motivo AS "MOTIVO DE REPARACION",
      R.horas AS horas,
      M.fecproxrevision AS "PROXIMA REVISION",
      X.estado AS "ESTADO DEL EXAMEN",
      C.nombre AS categoria,
      F.idfactura AS factura,
      F.fecemision AS "FECHA DE EMISION",
      F.descuento AS descuento,
      F.iva AS iva,
      F.total AS "TOTAL (SIN IVA)",
      F.iva_calculado AS "TOTAL (CON IVA)"

      FROM autoracle.empleado E
        INNER JOIN autoracle.trabaja T          ON E.idempleado = T.empleado_idempleado
        INNER JOIN autoracle.servicio S         ON T.servicio_idservicio = S.idservicio
        INNER JOIN autoracle.reparacion R       ON S.idservicio = R.idservicio
        INNER JOIN autoracle.mantenimiento M    ON S.idservicio = M.idservicio
        INNER JOIN autoracle.examen X           ON M.idservicio = X.mantenimiento_idservicio
        INNER JOIN autoracle.categoria C        ON X.categoria_idcategoria = C.idcategoria
        INNER JOIN autoracle.factura F          ON E.idempleado = F.empleado_idempleado
  );


CREATE OR REPLACE
    VIEW v_empleado_servicios AS (
        SELECT *
            FROM v_empleados_servicios
                -- WHERE usuario = user
    );


-- ROLES Y PERMISOS
/*
DROP ROLE r_administrativo;
DROP ROLE r_mecanico;
DROP ROLE r_cliente;
*/

CREATE ROLE r_administrativo;
CREATE ROLE r_mecanico;
CREATE ROLE r_cliente;


GRANT SELECT ON autoracle.v_clientes_datos TO r_administrativo;
GRANT SELECT ON autoracle.v_clientes_servicios TO r_administrativo;
GRANT SELECT ON autoracle.v_empleados_datos TO r_administrativo;
GRANT SELECT ON autoracle.v_empleados_servicios TO r_administrativo;

GRANT SELECT ON autoracle.v_empleado_datos TO r_mecanico;
GRANT SELECT ON autoracle.v_empleado_servicios TO r_mecanico;
GRANT SELECT ON autoracle.categoria TO r_mecanico;
GRANT SELECT ON autoracle.cita TO r_mecanico;
GRANT SELECT ON autoracle.compatible TO r_mecanico;
GRANT SELECT ON autoracle.compra TO r_mecanico;
GRANT SELECT ON autoracle.comprafutura TO r_mecanico;
GRANT SELECT ON autoracle.contiene TO r_mecanico;
GRANT SELECT ON autoracle.lote TO r_mecanico;
GRANT SELECT ON autoracle.necesita TO r_mecanico;
GRANT SELECT ON autoracle.pieza TO r_mecanico;
GRANT SELECT ON autoracle.provee TO r_mecanico;
GRANT SELECT ON autoracle.proveedor TO r_mecanico;

GRANT SELECT ON autoracle.v_cliente_datos TO r_cliente;
GRANT SELECT ON autoracle.v_cliente_servicios TO r_cliente;



/* [2]
Crea una tabla denominada COMPRA_FUTURA que incluya el NIF, telefono, nombre e
email del proveedor, referencia de pieza y cantidad. Necesitamos un procedimiento
P_REVISA que cuando se ejecute compruebe si las piezas han caducado.
De esta forma, insertara en COMPRA_FUTURA aquellas piezas caducadas junto a los
datos necesarios para realizar en el futuro la compra.
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



/* [3]
Añadir dos campos a la tabla factura: iva calculado y total
Implementar un procedimiento P_CALCULA_FACT que recorre los datos necesarios de
las piezas utilizadas y el porcentaje de iva y calcula la cantidad en euros para
estos dos campos.
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
                TOTAL = TOTAL + fila.PRECIOUNIDADVENTA
            WHERE IDFACTURA = fila.IDFACTURA;
    END LOOP;
END;
/



/* [4]
Necesitamos una vista denominada V_IVA_CUATRIMESTRE con los atributos AÑO,
TRIMESTRE, IVA_TOTAL siendo trimestre un numero de 1 a 4. El IVA_TOTAL es el IVA
devengado (suma del IVA de las facturas de ese trimestre).
Dar permiso de seleccion a los Administrativos.
*/

CREATE OR REPLACE
    VIEW AUTORACLE.V_IVA_TRIMESTRE AS
        SELECT  TO_CHAR(f.FECEMISION, 'YYYY') AS "ANNO",
                TO_CHAR(f.FECEMISION, 'Q') AS "TRIMESTRE",
                (f.IVA / 100) * SUM(p.PRECIOUNIDADVENTA) AS IVA_DEVANGADO
            FROM AUTORACLE.factura f
                JOIN AUTORACLE.contiene c ON f.IDFACTURA = c.FACTURA_IDFACTURA
                JOIN AUTORACLE.pieza p ON p.CODREF = c.PIEZA_CODREF
                GROUP BY TO_CHAR(f.FECEMISION, 'YYYY'), TO_CHAR(f.FECEMISION, 'Q'), f.IVA;

GRANT SELECT ON AUTORACLE.V_IVA_TRIMESTRE
    TO R_ADMINISTRATIVO;



/* [5]
Crear un paquete en PL/SQL de analisis de datos que contenga:
    1.  La funcion F_Calcular_Piezas: devolvera la media, minimo y maximo numero
        de unidades compradas (en cada lote) de una determinada pieza en un año
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
    PACKAGE autoracle.pkg_analisis_datos AS

    TYPE MEDIA_MIN_MAX_UNITS IS
        RECORD (media NUMBER, minimo NUMBER, maximo NUMBER);

    TYPE TIEMPOS_SERVICIO IS
        RECORD (dias NUMBER, horas NUMBER);

    FUNCTION F_CALCULAR_PIEZAS(codref IN VARCHAR2, anno in VARCHAR2)
        RETURN MEDIA_MIN_MAX_UNITS;

    FUNCTION F_CALCULAR_TIEMPOS
        RETURN tiempos_servicio;

    PROCEDURE P_RECOMPENSA;

END pkg_analisis_datos;
/


-- Creamos las funciones y procedimientos del paquete (RECOMIENDO probar a
-- definirlas fuera del paquete para ver si compilan, y despues borrarlas)
CREATE OR REPLACE
    PACKAGE BODY AUTORACLE.pkg_analisis_datos AS

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
    FUNCTION F_CALCULAR_TIEMPOS
        RETURN TIEMPOS_SERVICIO AS

            dias_totales NUMBER := 0;
            horas_totales NUMBER := 0;
            servicios_totales NUMBER := 0;

            resultado TIEMPOS_SERVICIO;

            CURSOR datos IS
                SELECT  S.idservicio AS id_servicio,
                        SUM(S.fecrealizacion - S.fecrecepcion) AS num_dias,
                        SUM(R.horas) AS num_horas
                    FROM servicio S
                        JOIN reparacion R ON S.idservicio = R.idservicio
                        GROUP BY S.idservicio;

        BEGIN
            FOR fila IN DATOS LOOP
                IF fila.num_dias IS NOT NULL AND fila.num_horas IS NOT NULL THEN
                    dias_totales := dias_totales + fila.num_dias;
                    horas_totales := horas_totales + fila.num_horas;
                    servicios_totales := servicios_totales + 1;

                END IF;

            END LOOP;

            resultado.dias := dias_totales / servicios_totales;
            resultado.horas := horas_totales / servicios_totales;

            RETURN resultado;
        END;

    -- Creo que este procedimiento usa las funcion del (2) para cada servicio
    PROCEDURE P_RECOMPENSA AS
        servicio_mas_lento NUMBER;
        servicio_mas_lento_dias NUMBER := 0;       -- Se esperan valores '>0'
        servicio_mas_lento_idempleado NUMBER;

        servicio_mas_rapido NUMBER;
        servicio_mas_rapido_dias NUMBER := 1000;   -- Se esperan valores '<1000'
        servicio_mas_rapido_idempleado NUMBER;

        tiempo_medio TIEMPOS_SERVICIO := F_CALCULAR_TIEMPOS;

        CURSOR servicios IS
            SELECT s.IDSERVICIO as id_servicio,
                   t.EMPLEADO_IDEMPLEADO as id_empleado
                FROM AUTORACLE.SERVICIO s
                    JOIN AUTORACLE.TRABAJA t ON s.IDSERVICIO = t.SERVICIO_IDSERVICIO;

        BEGIN
            -- Encontrar los servicios mas rapido y mas lento
            FOR servicio IN servicios LOOP
                IF tiempo_medio.dias < servicio_mas_rapido_dias THEN
                    servicio_mas_rapido := servicio.id_servicio;
                    servicio_mas_rapido_dias := tiempo_medio.dias;
                    servicio_mas_rapido_idempleado := servicio.id_empleado;

                ELSIF tiempo_medio.dias > servicio_mas_lento_dias THEN
                    servicio_mas_lento := servicio.id_servicio;
                    servicio_mas_lento_dias := tiempo_medio.dias;
                    servicio_mas_lento_idempleado := servicio.id_empleado;

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
        END;

END pkg_analisis_datos;
/



/* [6]
Añadir al modelo una tabla FIDELIZACION que permite almacenar un descuento por
cliente y año; y crear un paquete en PL/SQL de gestion de descuentos.
    1.  El procedimiento P_Calcular_Descuento, tomara un cliente y un año y
        calculara el descuento del que podra disfrutar el año siguiente. Para
        ello, hasta un maximo del 10%, ira incrementando el descuento en un 1%
        por cada una de las siguientes acciones:
            * Por cada servicio pagado por el cliente.
            * Por cada ocasion en la que el cliente tuvo que esperar mas de 5
              dias desde que solicito la cita hasta que se concerto.
            * Por cada servicio proporcionado en el que tuvo que esperar mas de
              la media de todos los servicios.
    2.  El procedimiento P_Aplicar_descuento tomara el año y el cliente. Si en
        la tabla FIDELIZACION hay un descuento calculado a aplicar ese año,
        lo hará para todas las facturas que encuentre (en ese año).
*/

CREATE TABLE AUTORACLE.FIDELIZACION(
    cliente_idcliente VARCHAR2(16),
    descuento NUMBER(3),            -- de 0 a 100
    anno NUMBER(4)                  -- de 0 a 9999
);

-- Agregamos algunos datos
INSERT ALL
    INTO AUTORACLE.FIDELIZACION
    VALUES ('200', 10, '2018')

    INTO AUTORACLE.FIDELIZACION
    VALUES ('200', 5, '2017')

    INTO AUTORACLE.FIDELIZACION
    VALUES ('200', 2, '2016')

    INTO AUTORACLE.FIDELIZACION
    VALUES ('22', 7, '2019')

    INTO AUTORACLE.FIDELIZACION
    VALUES ('3', 4, '2018')
SELECT 1 FROM DUAL;
COMMIT;

SELECT * FROM AUTORACLE.FIDELIZACION; -- { desde Autoracle }

-- Para asegurarnos de que hay UN descuento POR cliente y año, creamos un trigger

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
            RAISE_APPLICATION_ERROR(-20015, 'Ya existe un descuento para el cliente '||:new.CLIENTE_IDCLIENTE||' en el año '||:new.ANNO);
    END;
/

-- Comprobamos que funciona el trigger
INSERT INTO AUTORACLE.FIDELIZACION
    VALUES ('200', 6, '2018'); -- devuelve error

INSERT INTO AUTORACLE.FIDELIZACION
    VALUES ('200', 6, '2019');


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
                -- Todas las facturas del cliente (en ese año)

                SELECT COUNT(*) INTO facturas
                    FROM AUTORACLE.FACTURA
                        WHERE CLIENTE_IDCLIENTE = cliente
                            AND TO_CHAR(FECEMISION, 'YYYY') = TO_CHAR(anno);


                -- Todas las citas con mas de 5 dias de espera (en ese año)

                SELECT COUNT(*) INTO citas5dias
                    FROM AUTORACLE.CITA
                        WHERE CLIENTE_IDCLIENTE = cliente
                            AND ABS(FECHA_CONCERTADA - FECHA_SOLICITUD) > 5
                            AND TO_CHAR(FECHA_SOLICITUD, 'YYYY') = TO_CHAR(anno);


                SELECT AVG(FECREALIZACION - FECAPERTURA) INTO media_horas
                    FROM SERVICIO;


                -- Todos los servicios con mas de la media de dias de espera (en ese año)

                SELECT COUNT(*) INTO servicios_largos
                    FROM AUTORACLE.SERVICIO s
                        JOIN AUTORACLE.VEHICULO v ON s.VEHICULO_NUMBASTIDOR = v.NUMBASTIDOR
                        WHERE v.CLIENTE_IDCLIENTE = cliente
                            AND TO_CHAR(s.FECAPERTURA, 'YYYY') = TO_CHAR(anno)
                            AND (FECREALIZACION - FECAPERTURA) > media_horas;


                -- Guardamos el descuento para el año siguiente (maximo 10%)

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
                    SET DESCUENTO = v_descuento, TOTAL = TOTAL - (TOTAL * v_descuento/100)
                        WHERE CLIENTE_IDCLIENTE = cliente
                            AND TO_CHAR(FECEMISION, 'YYYY') = TO_CHAR(anno);

            EXCEPTION
                WHEN no_data_found THEN     -- Si no existe el descuento...
                    RAISE_APPLICATION_ERROR(-20016, 'P_APLICAR_DESCUENTO Error: No hay descuento para el cliente '||cliente||' para el año '||anno);

            END;

END pkg_gestion_descuentos;
/



/* [7]
Crear un paquete en PL/SQL de gestion de empleados que incluya las operaciones
para crear, borrar y modificar los datos de un empleado. Hay que tener en cuenta
que algunos empleados tienen un usuario y, por tanto, al insertar o modificar un
empleado, si su usuario no es nulo, habra que crear su usuario.
Ademas, el paquete ofrecera procedimientos para bloquear/desbloquear cuentas de
usuarios de modo individual. Tambien se debe disponer de una opcion para bloquear
y desbloquear todas las cuentas de los empleados.
*/

CREATE SEQUENCE sec_idempleado
    START WITH 10000
    INCREMENT BY 1;

CREATE OR REPLACE PACKAGE AUTORACLE.PKG_GESTION_EMPLEADOS AS
    PROCEDURE PR_CREAR_EMPLEADO(nombre EMPLEADO.NOMBRE%TYPE, ap EMPLEADO.APELLIDO1%TYPE);
    PROCEDURE PR_BORRAR_EMPLEADO(ide EMPLEADO.IDEMPLEADO%TYPE);
    PROCEDURE PR_MODIFICAR_EMPLEADO( ide EMPLEADO.IDEMPLEADO%TYPE, nom EMPLEADO.NOMBRE%TYPE,
                ap1 EMPLEADO.APELLIDO1%TYPE, ap2 EMPLEADO.APELLIDO2%TYPE,
                fec EMPLEADO.FECENTRADA%TYPE, des EMPLEADO.DESPEDIDO%TYPE,
                sueldo EMPLEADO.SUELDOBASE%TYPE, horas EMPLEADO.HORAS%TYPE,
                pos EMPLEADO.PUESTO%TYPE,  ret EMPLEADO.RETENCIONES%TYPE );
    PROCEDURE PR_BLOQUEAR_USUARIO(nom EMPLEADO.NOMBRE%TYPE );
    PROCEDURE PR_DESBLOQUEAR_USUARIO(nom EMPLEADO.NOMBRE%TYPE );
    PROCEDURE PR_BLOQUEAR_TODOS_EMPLEADOS;
    PROCEDURE PR_DESBLOQUEAR_TODOS_EMPLEADOS;

END;
/

CREATE OR REPLACE PACKAGE BODY AUTORACLE.PKG_GESTION_EMPLEADOS AS

    PROCEDURE PR_CREAR_EMPLEADO(nombre EMPLEADO.NOMBRE%TYPE, ap EMPLEADO.APELLIDO1%TYPE) IS

    identificacion NUMBER;

    sentencia VARCHAR2(500);

BEGIN
    SELECT sec_idempleado.nextval INTO identificacion from dual;
     INSERT INTO EMPLEADO(IDEMPLEADO, NOMBRE, APELLIDO1, FECENTRADA, DESPEDIDO, SUELDOBASE)
        VALUES(identificacion, nombre, ap, sysdate, 0, 1500);
    sentencia := 'CREATE USER ' || nombre || ' IDENTIFIED BY ' || nombre || '
    DEFAULT TABLESPACE TS_AUTORACLE';
    DBMS_OUTPUT.PUT_LINE(sentencia);
    EXECUTE IMMEDIATE sentencia;
END;


    PROCEDURE PR_BORRAR_EMPLEADO(ide EMPLEADO.IDEMPLEADO%TYPE) IS
    usuario EMPLEADO.NOMBRE%TYPE;
    sentencia VARCHAR2(500);
BEGIN
    SELECT NOMBRE INTO usuario FROM EMPLEADO WHERE IDEMPLEADO = ide;
    sentencia := 'DROP USER ' || usuario || ' CASCADE';
    DBMS_OUTPUT.PUT_LINE(sentencia);
    EXECUTE IMMEDIATE sentencia;
    delete FROM empleado
    where IDEMPLEADO = ide;

END;

    PROCEDURE PR_MODIFICAR_EMPLEADO( ide EMPLEADO.IDEMPLEADO%TYPE, nom EMPLEADO.NOMBRE%TYPE,
                ap1 EMPLEADO.APELLIDO1%TYPE, ap2 EMPLEADO.APELLIDO2%TYPE,
                fec EMPLEADO.FECENTRADA%TYPE, des EMPLEADO.DESPEDIDO%TYPE,
                sueldo EMPLEADO.SUELDOBASE%TYPE, horas EMPLEADO.HORAS%TYPE,
                pos EMPLEADO.PUESTO%TYPE,  ret EMPLEADO.RETENCIONES%TYPE ) IS
 des_mal EXCEPTION;

BEGIN
    IF ( ((des > 1) OR (des < 0) )) then
        RAISE des_mal;
    END IF;

    UPDATE EMPLEADO
    SET NOMBRE = nom, APELLIDO1 = ap1,
    APELLIDO2 = ap2, FECENTRADA = fec,
    DESPEDIDO = des , SUELDOBASE = sueldo ,
    HORAS = horas, PUESTO = pos , RETENCIONES = ret
    WHERE IDEMPLEADO = ide;
        EXCEPTION
         WHEN des_mal THEN
         DBMS_OUTPUT.PUT_LINE('Valor de "Despido" incorrecto (ingrese 0 o 1)');
         WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Parametros incorrectos.
            Introduce (IDEmpleado, Despido, Sueldo Base, Puesto, Horas, Retenciones)');
END;

    PROCEDURE PR_BLOQUEAR_USUARIO(nom EMPLEADO.NOMBRE%TYPE ) AS
    usuario ALL_USERS.USERNAME%TYPE;
    sentencia VARCHAR2(500);
BEGIN
    usuario := UPPER(nom);
    sentencia := 'ALTER USER ' || usuario || ' ACCOUNT LOCK;' ;
    DBMS_OUTPUT.PUT_LINE(sentencia);
    EXECUTE IMMEDIATE sentencia;
END;

    PROCEDURE PR_DESBLOQUEAR_USUARIO(nom EMPLEADO.NOMBRE%TYPE ) AS
    usuario ALL_USERS.USERNAME%TYPE;
    sentencia VARCHAR2(500);
BEGIN
    usuario := UPPER(nom);
    sentencia := 'ALTER USER ' || usuario || ' ACCOUNT UNLOCK;' ;
    DBMS_OUTPUT.PUT_LINE(sentencia);
    EXECUTE IMMEDIATE sentencia;
END;

PROCEDURE PR_BLOQUEAR_TODOS_EMPLEADOS AS
sentencia VARCHAR(500);
CURSOR empleados IS
    SELECT NOMBRE FROM EMPLEADO;

BEGIN
    FOR nom IN empleados LOOP
    sentencia := 'ALTER USER ' || UPPER(nom.NOMBRE) || ' ACCOUNT LOCK';
    EXECUTE IMMEDIATE sentencia;
    END LOOP;
END;

PROCEDURE PR_DESBLOQUEAR_TODOS_EMPLEADOS AS
sentencia VARCHAR(500);
CURSOR empleados IS
    SELECT NOMBRE FROM EMPLEADO;

BEGIN
    FOR nom IN empleados LOOP
    sentencia := 'ALTER USER ' || UPPER(nom.NOMBRE) || ' ACCOUNT UNLOCK';
    EXECUTE IMMEDIATE sentencia;
    END LOOP;
END;

END;
/


/* [8]
Escribir un trigger que cuando se eliminen los datos de un cliente
fidelizado se eliminen a su vez toda su
informacion de fidelizacion y los datos de su vehiculo.
*/

CREATE OR REPLACE TRIGGER TR_Eliminar_Cliente_Fidelizado
BEFORE DELETE ON CLIENTE FOR EACH ROW
BEGIN
	DELETE FROM FIDELIZACION WHERE CLIENTE = :old.IDCLIENTE;
	DELETE FROM VEHICULO WHERE CLIENTE_IDCLIENTE = :old.IDCLIENTE;
END;
/



/* [9]
Crear un JOB que ejecute el procedimiento P_REVISA todos los dias a las 21:00.
Crear otro JOB que llame anualmente a P_Recompensa el 31 de diciembre a las 23:55.
*/

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
