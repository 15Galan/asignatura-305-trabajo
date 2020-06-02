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
