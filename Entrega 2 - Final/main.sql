-- Trabajo en Grupo (entrega final), a 29 Mayo 2020.
-- Antonio J. Galan, Manuel Gonzalez, Pablo Rodriguez, Joaquin Terrasa

-- Ver estado (ON / OFF) del paquete DBMS_OUTPUT
-- SHOW SERVEROUTPUT;
-- Activar la opcion de mostrar mensajes por pantalla (1 vez / sesion)
SET SERVEROUTPUT ON;



-- Indices
CREATE INDEX autoracle.idx_empleado_nombre
    ON autoracle.empleado(nombre);

-- CREATE INDEX autoracle.idx_empleado_usuario  -- Columna ya indexada
--     ON autoracle.empleado(usuario);

CREATE INDEX autoracle.idx_cliente_nombre
    ON autoracle.cliente(nombre);

-- CREATE INDEX autoracle.idx_cliente_usuario   -- Columna ya indexada
--     ON autoracle.cliente(usuario);

CREATE INDEX autoracle.idx_factura_empleado
    ON autoracle.factura(empleado_idempleado);

CREATE INDEX autoracle.idx_factura_cliente
    ON autoracle.factura(cliente_idcliente);

CREATE INDEX autoracle.idx_proveedor_nombre
    ON autoracle.proveedor(nombre);

CREATE INDEX autoracle.idx_proveedor_email
    ON autoracle.proveedor(email);

CREATE INDEX autoracle.idx_proveedor_zona
    ON autoracle.proveedor(codpostal);



-- Restricciones
-- * precios, cantidades y años positivos
-- * intervalos de fechas coherentes
-- * emails y telefonos con un formato adecuado
-- * ...
ALTER TABLE autoracle.cita
    ADD CONSTRAINT check_cita_fechas
        CHECK (fecha_solicitud <= fecha_concertada);

-- ALTER TABLE autoracle.cliente
--     ADD CONSTRAINT check_cliente_id      -- No es NUMBER, sino VARCHAR2
--        CHECK (idcliente != '-%');

ALTER TABLE autoracle.compra
    ADD CONSTRAINT check_compra_fechas
        CHECK (fecemision <= fecrecepcion);

ALTER TABLE autoracle.compra_futura
    ADD CONSTRAINT check_comprafutura_telefono
        CHECK (999999999 >= telefono AND telefono <= 100000000)
    ADD CONSTRAINT check_comprafutura_email
        CHECK (REGEXP_LIKE(EMAIL, '^\w+(\.\w+)*+@\w+(\.\w+)+$'))
    ADD CONSTRAINT check_comprafutura_cantidad
        CHECK (cantidad >= 0);

ALTER TABLE autoracle.empleado
--    ADD CONSTRAINT check_empleado_id      -- No es NUMBER, sino VARCHAR2
--        CHECK (idempleado >= 0)
    ADD CONSTRAINT check_empleado_sueldo
        CHECK (sueldobase > 0)
    ADD CONSTRAINT check_empleado_horas
        CHECK (horas >= 0)
    ADD CONSTRAINT check_empelado_retenciones
        CHECK (retenciones >= 0)
    ADD CONSTRAINT check_empleado_email
        CHECK (REGEXP_LIKE(EMAIL, '^\w+(\.\w+)*+@\w+(\.\w+)+$'));

ALTER TABLE autoracle.factura
    ADD CONSTRAINT check_idfactura_positivo
        CHECK (idfactura >= 0)
    ADD CONSTRAINT check_factura_IVA
        CHECK (iva >= 0)
    ADD CONSTRAINT check_factura_descuento
        CHECK (descuento >= 0)
    ADD CONSTRAINT check_factura_preciototaliva
        CHECK (iva_calculado >= 0)
    ADD CONSTRAINT check_factura_preciototal
        CHECK (total >= 0)
    ADD CONSTRAINT check_factura_iva_total
        CHECK (iva_calculado >= total);

ALTER TABLE autoracle.fidelizacion
    ADD CONSTRAINT check_fidelizacion_descuento
        CHECK (descuento >= 0)
    ADD CONSTRAINT check_fidelizacion_anno
        CHECK (anno >= 0);

ALTER TABLE autoracle.lote
    ADD CONSTRAINT check_lote_cantidad
        CHECK (numero_de_piezas >= 0)
    ADD CONSTRAINT check_lote_iva
        CHECK (iva >= 0);

ALTER TABLE autoracle.marca
    ADD CONSTRAINT check_marca_precio
        CHECK (preciohora >= 0);

ALTER TABLE autoracle.modelo
    ADD CONSTRAINT check_modelo_puertas
        CHECK (numpuertas >= 0)
    ADD CONSTRAINT check_modelo_maletero
        CHECK (capacmaletero >= 0);

ALTER TABLE autoracle.pieza
    ADD CONSTRAINT check_pieza_preciocompra
        CHECK (preciounidadventa >= 0)
    ADD CONSTRAINT check_pieza_precioventa
        CHECK (preciounidadcompra >= 0)
    ADD CONSTRAINT check_pieza_cantidad
        CHECK (cantidad >= 0);

ALTER TABLE autoracle.proveedor
    ADD CONSTRAINT check_proveedor_telefono
        CHECK (999999999 >= telefono AND telefono >= 100000000)
    ADD CONSTRAINT check_proveedor_email
        CHECK (REGEXP_LIKE(EMAIL, '^\w+(\.\w+)*+@\w+(\.\w+)+$'))
    ADD CONSTRAINT check_proveedor_zona
        CHECK (codpostal >= 0);

ALTER TABLE autoracle.servicio
    ADD CONSTRAINT check_servicio_fechas1
        CHECK (fecapertura <= fecrecepcion)
    ADD CONSTRAINT check_servicio_fechas2
        CHECK (fecrecepcion <= fecrealizacion);

ALTER TABLE autoracle.vacaciones
    ADD CONSTRAINT check_vacaciones_fechas
        CHECK (fecentrada <= fecsalida);

ALTER TABLE autoracle.vehiculo                  -- IDEA: Formato de matricula
    ADD CONSTRAINT check_vehiculo_fabricacion
        CHECK (fabricacion >= 0)
    ADD CONSTRAINT check_vehiculo_kilometrajes
        CHECK (kilometraje >= 0);



        --- Vistas
        CREATE OR REPLACE
            VIEW autoracle.v_proveedorespiezas AS (
                SELECT
                    Pi.nombre AS pieza,
                    Pi.preciounidadventa AS "PRECIO VENTA",
                    Pi.preciounidadcompra AS "PRECIO COMPRA",
                    Pr.nombre AS proveedor,
                    Pr.email AS email,
                    Pr.telefono AS telefono,
                    Pr.direccion AS direccion,
                    Pr.web AS web

                    FROM autoracle.pieza Pi
                        JOIN autoracle.proveedor Pr ON Pi.proveedor_nif = Pr.nif
                    );

        CREATE OR REPLACE
            VIEW autoracle.v_clientefidelizado AS (
                SELECT
                    C.idcliente AS id,
                    C.usuario AS usuario,
                    C.nombre AS nombre,
                    C.apellido1 AS "PRIMER APELLIDO",
                    C.APELLIDO2 AS "SEGUNDO APELLIDO",
                    C.telefono AS telefono,
                    C.email AS email,
                    F.descuento AS descuento,
                    F.anno AS anno

                    FROM autoracle.cliente C
                        JOIN autoracle.fidelizacion F ON C.idcliente LIKE F.cliente_idcliente
            );

        GRANT SELECT
            ON autoracle.v_proveedorespiezas
            TO r_administrativo;

        GRANT SELECT
            ON autoracle.v_clientefidelizado
            TO r_administrativo;

        GRANT SELECT
            ON autoracle.v_proveedorespiezas
            TO r_mecanico;

        GRANT SELECT
            ON autoracle.v_clientefidelizado
            TO r_mecanico;
