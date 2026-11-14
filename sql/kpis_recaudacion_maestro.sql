-- ==============================================================================
-- PROYECTO BUSINESS INTELLIGENCE - EPAM (EMPRESA PÚBLICA AGUAS DE MANTA)
-- Consulta Maestra de Indicadores Clave de Desempeño (KPIs) de Recaudación y Cartera
-- Plataforma: Apache Superset | Motor de Base de Datos: MySQL 8.0
-- Autores: Oswaldo Echeverría & Wellington Alcívar
-- ==============================================================================

SELECT 
    -- 1. KPIs Generales de Deuda
    d.total_deudas,
    d.total_monto_deudas,
    d.desviacion_estandar_montos_deudas,
    d.promedio_monto_deuda_por_contrato,
    
    -- 2. KPIs Generales de Recaudación / Pagos
    p.total_pagos,
    p.total_monto_pagos,
    p.desviacion_estandar_montos_pagos,
    p.promedio_monto_pago_por_contrato,
    
    -- 3. Métricas de Eficiencia, Cartera y Morosidad
    ROUND((d.total_deuda_vencida / NULLIF(d.total_deudas, 0)) * 100, 2) AS porcentaje_deuda_vencida,
    ROUND((d.total_monto_deudas / NULLIF(d.total_clientes_con_deuda, 0)), 2) AS promedio_monto_deuda_por_cliente,
    ROUND((p.total_monto_pagos / NULLIF(p.total_clientes_que_han_pagado, 0)), 2) AS promedio_monto_pago_por_cliente,
    
    -- 4. KPIs de Facturación y Cumplimiento
    d.total_facturas,
    d.total_facturas_pagadas,
    d.porcentaje_facturas_pagadas,
    p.promedio_dias_pago AS promedio_dias_pago_pagos,
    d.promedio_dias_plazo_facturas,
    d.porcentaje_morosidad,
    
    -- 5. Métricas Estadísticas de Comportamiento de Pago
    p.promedio_dias_mora,
    p.desviacion_estandar_dias_mora,
    p.promedio_monto_deuda,
    p.promedio_monto_pago,
    p.porcentaje_pagos_anticipados,
    p.porcentaje_abonos

FROM 
    (
        -- ======================================================================
        -- Subconsulta D: Agregación de Deudas, Facturas y Cartera
        -- ======================================================================
        SELECT 
            COUNT(*) AS total_deudas,
            SUM(CAST(ddc.monto AS DECIMAL(10, 2))) AS total_monto_deudas,
            ROUND(STDDEV(CAST(ddc.monto AS DECIMAL(10, 2))), 2) AS desviacion_estandar_montos_deudas,
            ROUND(SUM(CAST(ddc.monto AS DECIMAL(10, 2))) / NULLIF(COUNT(*), 0), 2) AS promedio_monto_deuda_por_contrato,
            SUM(CASE 
                WHEN ddc.fecha_vencimiento < CURRENT_DATE AND ddc.estado != 'CANCELADA' 
                THEN CAST(ddc.monto AS DECIMAL(10, 2)) 
                ELSE 0 
            END) AS total_deuda_vencida,
            COUNT(DISTINCT cf.persona_id) AS total_clientes_con_deuda,
            COUNT(*) AS total_facturas,
            COUNT(CASE WHEN ddc.saldo = 0 AND ddc.estado = 'CANCELADA' THEN 1 END) AS total_facturas_pagadas,
            (COUNT(CASE WHEN ddc.saldo = 0 AND ddc.estado = 'CANCELADA' THEN 1 END) * 100.0 / COUNT(*)) AS porcentaje_facturas_pagadas,
            ROUND(AVG(DATEDIFF(ddc.fecha_vencimiento, ddc.fecha_emision))) AS promedio_dias_plazo_facturas,
            ((COUNT(DISTINCT ddc.id) - COUNT(DISTINCT CASE WHEN ddc.saldo = 0 AND ddc.estado = 'CANCELADA' THEN ddc.id END)) * 100.0 / COUNT(DISTINCT ddc.id)) AS porcentaje_morosidad
        FROM 
            detalle_deudas_contratos ddc
        JOIN 
            contratos cf ON ddc.contrato_id = cf.id
        WHERE 
            ddc.fecha_emision BETWEEN '2023-12-01' AND '2024-06-30'
            AND cf.tipo_consumo IN ('RESIDENCIAL', 'COMERCIAL', 'INDUSTRIAL')
            AND cf.codigo_contrato IN (
                SELECT DISTINCT c2.codigo_contrato
                FROM contratos c2
                GROUP BY c2.codigo_contrato
            )
    ) d,
    (
        -- ======================================================================
        -- Subconsulta P: Agregación de Transacciones de Pago y Hábitos de Pago
        -- ======================================================================
        SELECT 
            COUNT(*) AS total_pagos,
            SUM(valor) AS total_monto_pagos,
            ROUND(STDDEV(valor), 2) AS desviacion_estandar_montos_pagos,
            ROUND(SUM(valor) / NULLIF(COUNT(*), 0), 2) AS promedio_monto_pago_por_contrato,
            COUNT(DISTINCT pp.user_id) AS total_clientes_que_han_pagado,
            AVG(DATEDIFF(pp.created_at, ddc.fecha_emision)) AS promedio_dias_pago,
            ROUND(AVG(DATEDIFF(pp.created_at, ddc.fecha_emision))) AS promedio_dias_pago_redondeado,
            ROUND(STDDEV(DATEDIFF(pp.created_at, ddc.fecha_emision))) AS desviacion_estandar_dias_pago,
            FLOOR(AVG(CASE 
                WHEN pp.created_at > STR_TO_DATE(ddc.fecha_vencimiento, '%Y-%m-%d') 
                     AND pp.valor >= ddc.monto 
                THEN DATEDIFF(pp.created_at, STR_TO_DATE(ddc.fecha_vencimiento, '%Y-%m-%d'))
                ELSE NULL
            END)) AS promedio_dias_mora,
            ROUND(STDDEV(CASE 
                WHEN pp.created_at > STR_TO_DATE(ddc.fecha_vencimiento, '%Y-%m-%d') 
                     AND pp.valor >= ddc.monto 
                THEN DATEDIFF(pp.created_at, STR_TO_DATE(ddc.fecha_vencimiento, '%Y-%m-%d'))
                ELSE NULL
            END), 2) AS desviacion_estandar_dias_mora,
            ROUND(AVG(CAST(ddc.monto AS DECIMAL(10, 2))), 2) AS promedio_monto_deuda,
            ROUND(AVG(CAST(pp.valor AS DECIMAL(10, 2))), 2) AS promedio_monto_pago,
            (COUNT(CASE WHEN pp.created_at < STR_TO_DATE(ddc.fecha_vencimiento, '%Y-%m-%d') THEN 1 END) * 100.0 / COUNT(pp.id)) AS porcentaje_pagos_anticipados,
            ROUND(SUM(CASE WHEN pp.valor < ddc.monto THEN pp.valor ELSE 0 END) / NULLIF(SUM(ddc.monto), 0) * 100, 2) AS porcentaje_abonos
        FROM 
            py_payments pp
        JOIN 
            contratos cf ON pp.codigoContrato = cf.codigo_contrato
        JOIN 
            detalle_deudas_contratos ddc ON ddc.contrato_id = cf.id
        WHERE 
            pp.estado = 'ACT'
            AND ddc.fecha_emision BETWEEN '2023-12-01' AND '2024-06-30'
            AND cf.tipo_consumo IN ('RESIDENCIAL', 'COMERCIAL', 'INDUSTRIAL')
            AND cf.codigo_contrato IN (
                SELECT DISTINCT c2.codigo_contrato
                FROM contratos c2
                GROUP BY c2.codigo_contrato
            )
    ) p;
