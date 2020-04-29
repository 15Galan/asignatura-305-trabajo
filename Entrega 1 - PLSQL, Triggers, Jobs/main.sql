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
