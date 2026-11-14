# Ficha Técnica y Metodología de KPIs

Este documento describe la formulación lógica, matemática y de negocio de los **23 Indicadores Clave de Desempeño (KPIs)** implementados en el proyecto de Business Intelligence sobre Apache Superset para la **Empresa Pública Aguas de Manta (EPAM)**.

---

## 1. Categorización de Indicadores

| Categoría | Propósito de Negocio | KPIs Clave |
| :--- | :--- | :--- |
| **Volumen y Cartera** | Monitoreo del total de obligaciones exigibles y contratos. | `total_deudas`, `total_monto_deudas`, `promedio_monto_deuda_por_contrato` |
| **Recaudación y Cobranza** | Eficiencia y volumen del dinero recaudado en canales digitales. | `total_pagos`, `total_monto_pagos`, `porcentaje_facturas_pagadas` |
| **Riesgo y Morosidad** | Medición de la deuda vencida, retrasos y dispersión de impagos. | `porcentaje_morosidad`, `promedio_dias_mora`, `desviacion_estandar_dias_mora` |
| **Comportamiento de Pago** | Identificación de patrones de abonos y anticipos. | `porcentaje_pagos_anticipados`, `porcentaje_abonos`, `promedio_dias_pago` |
| **Segmentación Tarifaria** | Análisis de impacto por categoría de usuario. | Residencial vs Comercial vs Industrial |

---

## 2. Diccionario de Datos de los 23 KPIs

### 1. `total_deudas`
- **Nombre:** Total de Deudas Registradas
- **Definición:** Conteo absoluto de registros de facturación con saldo o emitidos en el periodo.
- **Fórmula SQL:** `COUNT(*)` sobre `detalle_deudas_contratos`.

### 2. `total_monto_deudas`
- **Nombre:** Monto Total de Deudas Acumuladas
- **Definición:** Valor monetario acumulado de todas las obligaciones emitidas.
- **Fórmula SQL:** `SUM(CAST(ddc.monto AS DECIMAL(10, 2)))`.

### 3. `desviacion_estandar_montos_deudas`
- **Nombre:** Dispersión de Montos de Deuda
- **Definición:** Mide qué tan concentrados o dispersos están los montos adeudados respecto al promedio institucional.
- **Fórmula SQL:** `ROUND(STDDEV(CAST(ddc.monto AS DECIMAL(10, 2))), 2)`.

### 4. `promedio_monto_deuda_por_contrato`
- **Nombre:** Monto Promedio Adeudado por Contrato
- **Definición:** Valor medio que debe un contrato en el ciclo evaluado.
- **Fórmula SQL:** `ROUND(SUM(ddc.monto) / NULLIF(COUNT(*), 0), 2)`.

### 5. `total_pagos`
- **Nombre:** Total de Transacciones de Pago
- **Definición:** Número de pagos exitosos procesados en el sistema transaccional (`py_payments`).
- **Fórmula SQL:** `COUNT(*)` donde `pp.estado = 'ACT'`.

### 6. `total_monto_pagos`
- **Nombre:** Monto Total Recaudado
- **Definición:** Ingresos brutos recaudados a través de los canales en línea.
- **Fórmula SQL:** `SUM(pp.valor)`.

### 7. `desviacion_estandar_montos_pagos`
- **Nombre:** Dispersión del Valor de Pagos
- **Definición:** Evalúa si la recaudación proviene de micropagos o pagos atípicos de alto valor.
- **Fórmula SQL:** `ROUND(STDDEV(pp.valor), 2)`.

### 8. `promedio_monto_pago_por_contrato`
- **Nombre:** Ticket Promedio de Pago
- **Definición:** Importe promedio liquidado por cada transacción de contrato.
- **Fórmula SQL:** `ROUND(SUM(pp.valor) / NULLIF(COUNT(*), 0), 2)`.

### 9. `porcentaje_deuda_vencida`
- **Nombre:** Ratio de Deuda Vencida
- **Definición:** Proporción de dinero en mora respecto a la cartera total exigible.
- **Fórmula SQL:** `(SUM(CASE WHEN fecha_vencimiento < CURRENT_DATE AND estado != 'CANCELADA' THEN monto ELSE 0 END) / total_deudas) * 100`.

### 10. `promedio_monto_deuda_por_cliente`
- **Nombre:** Exposición de Deuda por Abonado Único
- **Definición:** Deuda ponderada por cada cédula / RUC (`persona_id`), útil para clientes con múltiples medidores.
- **Fórmula SQL:** `ROUND(SUM(monto) / COUNT(DISTINCT cf.persona_id), 2)`.

### 11. `promedio_monto_pago_por_cliente`
- **Nombre:** Recaudación Promedio por Abonado Único
- **Definición:** Aporte financiero neto por usuario pagador.
- **Fórmula SQL:** `ROUND(SUM(valor) / COUNT(DISTINCT pp.user_id), 2)`.

### 12. `total_facturas`
- **Nombre:** Total de Facturas Emitidas
- **Definición:** Universo total de documentos tributarios en el ciclo de consumo.

### 13. `total_facturas_pagadas`
- **Nombre:** Facturas Canceladas al 100%
- **Definición:** Documentos cuyo saldo pendiente es 0.00 y su estado es `CANCELADA`.
- **Fórmula SQL:** `COUNT(CASE WHEN saldo = 0 AND estado = 'CANCELADA' THEN 1 END)`.

### 14. `porcentaje_facturas_pagadas`
- **Nombre:** Tasa de Efectividad de Cobranza (Collection Rate)
- **Definición:** Porcentaje de documentos liquidados exitosamente frente al total emitido.
- **Fórmula SQL:** `(total_facturas_pagadas * 100.0 / total_facturas)`.

### 15. `promedio_dias_pago_pagos`
- **Nombre:** Antigüedad Promedio de Cobro
- **Definición:** Días transcurridos entre la fecha de emisión de la planilla y la confirmación bancaria del pago.
- **Fórmula SQL:** `AVG(DATEDIFF(pp.created_at, ddc.fecha_emision))`.

### 16. `promedio_dias_plazo_facturas`
- **Nombre:** Plazo Promedio de Crédito Comercial
- **Definición:** Ventana temporal que otorga la empresa entre emisión y fecha de corte/vencimiento (usualmente ~13 a 15 días).
- **Fórmula SQL:** `AVG(DATEDIFF(ddc.fecha_vencimiento, ddc.fecha_emision))`.

### 17. `porcentaje_morosidad`
- **Nombre:** Índice de Morosidad Institucional
- **Definición:** Porcentaje de facturas que superaron la fecha límite de pago sin haber sido canceladas.
- **Fórmula SQL:** `((total_facturas - total_facturas_pagadas) * 100.0 / total_facturas)`.

### 18. `promedio_dias_mora`
- **Nombre:** Días Promedio de Retraso
- **Definición:** Cuántos días tarda un abonado en liquidar su planilla después de que esta ya venció.
- **Fórmula SQL:** `AVG(DATEDIFF(pp.created_at, ddc.fecha_vencimiento))` para pagos extemporáneos.

### 19. `desviacion_estandar_dias_mora`
- **Nombre:** Variabilidad de la Morosidad
- **Definición:** Mide si el retraso en pagos es homogéneo o si existen abonados atípicos con retrasos extremos.

### 20. `promedio_monto_deuda`
- **Nombre:** Importe Nominal Promedio de Factura
- **Definición:** Monto regular de la planilla mensual emitida.

### 21. `promedio_monto_pago`
- **Nombre:** Importe Nominal Promedio de Transacción
- **Definición:** Cuantía media abonada en las pasarelas de pago.

### 22. `porcentaje_pagos_anticipados`
- **Nombre:** Ratio de Pago Temprano
- **Definición:** Pagos ejecutados antes de que venza la planilla (excelente salud crediticia del abonado).
- **Fórmula SQL:** `(COUNT(CASE WHEN pp.created_at < ddc.fecha_vencimiento THEN 1 END) * 100.0 / COUNT(*))`.

### 23. `porcentaje_abonos`
- **Nombre:** Ratio de Pagos Parciales
- **Definición:** Pagos donde el valor recibido es inferior al monto total de la factura.
- **Fórmula SQL:** `(SUM(CASE WHEN pp.valor < ddc.monto THEN pp.valor ELSE 0 END) / SUM(ddc.monto)) * 100`.
