-- Trabajo en Grupo (PL/SQL, Triggers, Jobs), a 29 Abril 2020.
-- Antonio J. Galán, Manuel González, Pablo Rodríguez, Joaquin Terrasa

-- { Por defecto, usamos el usuario "AUTORACLE" creado previamente en la BD }

-- [1]
CREATE ROLE r_administrativo;
CREATE ROLE r_mecanico;
CREATE ROLE r_cliente;


GRANT dba
    TO r_administrativo;


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


-- [2]
CREATE TABLE COMPRA_FUTURA (
    PROVEEDOR_NIF VARCHAR2(16 BYTE),
    TELEFONO NUMBER(*, 0),
    NOMBRE VARCHAR2(64 BYTE),
	EMAIL VARCHAR2(64 BYTE),
    CANTIDAD NUMBER(*, 0),
    CODREF_PIEZA NUMBER(*, 0));

CREATE OR REPLACE PROCEDURE P_REVISA AS
BEGIN
    DECLARE
        CURSOR C_COMPRUEBA IS SELECT CODREF,NOMBRE,CANTIDAD,FECCADUCIDAD,PROVEEDOR_NIF FROM PIEZA;
    BEGIN
        FOR FILA IN C_COMPRUEBA LOOP
            IF FILA.FECCADUCIDAD < SYSDATE THEN
                INSERT INTO COMPRA_FUTURA VALUES (
                        FILA.PROVEEDOR_NIF,
                        (SELECT TELEFONO FROM PROVEEDOR WHERE NIF=FILA.PROVEEDOR_NIF),
                        FILA.NOMBRE,
                        (SELECT EMAIL FROM PROVEEDOR WHERE NIF=FILA.PROVEEDOR_NIF),
                        FILA.CODREF,
                        FILA.CANTIDAD
                    ); 
            END IF;
        END LOOP;
    END;
END P_REVISA;
/

/*
PROCEDURE autoracle.p_revisa AS
        BEGIN
            DECLARE
                CURSOR datos IS
                    SELECT nif, telefono, Pr.nombre, email, Pi.cantidad, codref, feccaducidad
                        FROM autoracle.pieza Pi
                            JOIN autoracle.proveedor Pr ON proveedor_nif = nif;

            BEGIN
                FOR fila IN datos LOOP
                    IF (sysdate - fila.feccaducidad) < 0 THEN
                        EXECUTE IMMEDIATE
                            'INSERT INTO autoracle.compra_futura
                                VALUES ('
                                ||fila.nif||','
                                ||fila.telefono||','
                                ||fila.nombre||','
                                ||fila.email||','
                                ||fila.cantidad||','
                                ||fila.codref||');';

                        COMMIT;
                    END IF;

                END LOOP;

            END;

        END p_revisa;
/
*/
			
-- [3]

-- [4]

-- [5]

-- [6]

-- [7]

-- [8]
