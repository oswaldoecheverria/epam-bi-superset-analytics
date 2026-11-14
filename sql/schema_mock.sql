-- ==============================================================================
-- SCHEMA MOCK & DATOS SINTÉTICOS DE PRUEBA (DATA PRIVACY & LOPDP COMPLIANT)
-- Proyecto: Business Intelligence para Recaudación en EPAM con Apache Superset
-- Motor compatible: MySQL 8.0+ / MariaDB 10.5+
-- Nota: Este script contiene estructuras y datos simulados para propósitos de
-- demostración, reproducibilidad en GitHub y resguardo de confidencialidad.
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS portalepam_mock CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE portalepam_mock;

-- 1. Tabla de Personas / Abonados
DROP TABLE IF EXISTS personas;
CREATE TABLE personas (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    identificacion VARCHAR(20) NOT NULL,
    nombres VARCHAR(150) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    email VARCHAR(120) DEFAULT NULL,
    telefono VARCHAR(30) DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Tabla de Contratos de Servicios de Agua Potable
DROP TABLE IF EXISTS contratos;
CREATE TABLE contratos (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo_contrato VARCHAR(10) NOT NULL,
    codigo_medidor VARCHAR(13) DEFAULT NULL,
    servicio VARCHAR(120) DEFAULT 'AGUA POTABLE Y ALCANTARILLADO',
    persona_id BIGINT UNSIGNED DEFAULT NULL,
    direccion VARCHAR(255) DEFAULT NULL,
    tipo_consumo ENUM('RESIDENCIAL', 'COMERCIAL', 'INDUSTRIAL') NOT NULL DEFAULT 'RESIDENCIAL',
    estado_conexion VARCHAR(50) DEFAULT 'ACTIVO',
    estado TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_codigo_contrato (codigo_contrato),
    KEY fk_contratos_persona (persona_id),
    CONSTRAINT fk_contratos_persona FOREIGN KEY (persona_id) REFERENCES personas (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Tabla de Deudas y Facturación por Contrato
DROP TABLE IF EXISTS detalle_deudas_contratos;
CREATE TABLE detalle_deudas_contratos (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_factura VARCHAR(50) NOT NULL,
    codigo_factura VARCHAR(50) DEFAULT NULL,
    contrato_id BIGINT UNSIGNED NOT NULL,
    deuda_id BIGINT UNSIGNED DEFAULT NULL,
    fecha_emision DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    monto DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    pago DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    saldo DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    estado ENUM('PENDIENTE', 'CANCELADA', 'ANULADA') NOT NULL DEFAULT 'PENDIENTE',
    tipo_consumo ENUM('RESIDENCIAL', 'COMERCIAL', 'INDUSTRIAL') NOT NULL DEFAULT 'RESIDENCIAL',
    consumom3 DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_numero_factura (numero_factura),
    KEY fk_deudas_contrato (contrato_id),
    CONSTRAINT fk_deudas_contrato FOREIGN KEY (contrato_id) REFERENCES contratos (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Tabla de Transacciones y Pagos en Línea
DROP TABLE IF EXISTS py_payments;
CREATE TABLE py_payments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED DEFAULT NULL,
    codigoContrato VARCHAR(10) NOT NULL,
    referencia VARCHAR(100) DEFAULT NULL,
    valor DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    canal_pago VARCHAR(50) DEFAULT 'PORTAL_EN_LINEA',
    estado VARCHAR(10) NOT NULL DEFAULT 'ACT',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_codigoContrato (codigoContrato),
    KEY idx_pagos_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==============================================================================
-- INSERCIÓN DE DATOS SINTÉTICOS DE PRUEBA (MOCK DATASET)
-- ==============================================================================

-- Personas
INSERT INTO personas (id, identificacion, nombres, apellidos, email) VALUES
(1, '1312345678', 'Consumidor', 'Residencial Alpha', 'alpha@example.com'),
(2, '1312345679', 'Empresa', 'Comercial Beta', 'beta@example.com'),
(3, '1398765432', 'Planta Industrial', 'Gamma Corp', 'gamma@example.com');

-- Contratos
INSERT INTO contratos (id, codigo_contrato, codigo_medidor, persona_id, tipo_consumo) VALUES
(1, 'CTR-001', 'MED-1001', 1, 'RESIDENCIAL'),
(2, 'CTR-002', 'MED-2002', 2, 'COMERCIAL'),
(3, 'CTR-003', 'MED-3003', 3, 'INDUSTRIAL');

-- Facturas / Deudas
INSERT INTO detalle_deudas_contratos 
(numero_factura, contrato_id, fecha_emision, fecha_vencimiento, monto, pago, saldo, estado, tipo_consumo, consumom3) VALUES
('FAC-2024-001', 1, '2024-01-05', '2024-01-20', 18.50, 18.50, 0.00, 'CANCELADA', 'RESIDENCIAL', 14.5),
('FAC-2024-002', 1, '2024-02-05', '2024-02-20', 21.00, 21.00, 0.00, 'CANCELADA', 'RESIDENCIAL', 16.0),
('FAC-2024-003', 1, '2024-03-05', '2024-03-20', 19.80, 0.00, 19.80, 'PENDIENTE', 'RESIDENCIAL', 15.2),
('FAC-2024-004', 2, '2024-01-10', '2024-01-25', 145.00, 145.00, 0.00, 'CANCELADA', 'COMERCIAL', 85.0),
('FAC-2024-005', 2, '2024-02-10', '2024-02-25', 160.00, 160.00, 0.00, 'CANCELADA', 'COMERCIAL', 92.0),
('FAC-2024-006', 2, '2024-03-10', '2024-03-25', 155.00, 50.00, 105.00, 'PENDIENTE', 'COMERCIAL', 88.0),
('FAC-2024-007', 3, '2024-01-15', '2024-02-01', 3400.00, 3400.00, 0.00, 'CANCELADA', 'INDUSTRIAL', 1850.0),
('FAC-2024-008', 3, '2024-02-15', '2024-03-01', 3850.00, 0.00, 3850.00, 'PENDIENTE', 'INDUSTRIAL', 2100.0),
('FAC-2024-009', 3, '2024-03-15', '2024-04-01', 4100.00, 0.00, 4100.00, 'PENDIENTE', 'INDUSTRIAL', 2250.0);

-- Pagos Registrados
INSERT INTO py_payments (user_id, codigoContrato, referencia, valor, canal_pago, estado, created_at) VALUES
(1, 'CTR-001', 'PAY-ONLINE-001', 18.50, 'PORTAL_EN_LINEA', 'ACT', '2024-01-18 10:15:00'),
(1, 'CTR-001', 'PAY-ONLINE-002', 21.00, 'PORTAL_EN_LINEA', 'ACT', '2024-02-19 14:30:00'),
(2, 'CTR-002', 'PAY-ONLINE-003', 145.00, 'PORTAL_EN_LINEA', 'ACT', '2024-01-22 09:45:00'),
(2, 'CTR-002', 'PAY-ONLINE-004', 160.00, 'PORTAL_EN_LINEA', 'ACT', '2024-02-24 16:10:00'),
(2, 'CTR-002', 'PAY-ONLINE-005', 50.00, 'PORTAL_EN_LINEA', 'ACT', '2024-03-22 11:20:00'),
(3, 'CTR-003', 'PAY-ONLINE-006', 3400.00, 'TRANSFERENCIA_BANCARIA', 'ACT', '2024-02-25 17:00:00');
