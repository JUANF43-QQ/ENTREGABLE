CREATE DATABASE clinica_citas;
USE clinica_citas;

CREATE TABLE especialidad (
  id_especialidad INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50),
  descripcion TEXT
);

CREATE TABLE medico (
  id_medico INT PRIMARY KEY AUTO_INCREMENT,
  nombres VARCHAR(50),
  apellidos VARCHAR(50),
  id_especialidad INT,
  consultorio VARCHAR(10),
  horario VARCHAR(100),
  FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
);

CREATE TABLE paciente (
  id_paciente INT PRIMARY KEY AUTO_INCREMENT,
  nombres VARCHAR(50),
  apellidos VARCHAR(50),
  telefono VARCHAR(20),
  correo VARCHAR(100),
  fecha_nacimiento DATE
);

CREATE TABLE cita (
  id_cita INT PRIMARY KEY AUTO_INCREMENT,
  id_paciente INT,
  id_medico INT,
  fecha_cita DATE,
  hora_cita TIME,
  estado VARCHAR(20),
  FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
  FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);

-- Insertar datos de prueba
INSERT INTO especialidad (nombre, descripcion) VALUES 
('Pediatría', 'Atención médica para niños'),
('Cardiología', 'Tratamiento de enfermedades del corazón'),
('Dermatología', 'Especialidad en piel y enfermedades cutáneas'),
('Ginecología', 'Atención médica femenina'),
('Neurología', 'Trastornos del sistema nervioso');


INSERT INTO medico (nombres, apellidos, id_especialidad, consultorio, horario) VALUES 
('Laura', 'Martínez', 1, '302A', 'Lunes a Viernes 8am - 4pm'),
('Juan', 'Pérez', 2, '210B', 'Martes a Sábado 9am - 3pm'),
('Camila', 'Gómez', 3, '305C', 'Lunes a Jueves 10am - 6pm'),
('Andrés', 'Ruiz', 4, '410A', 'Lunes a Viernes 7am - 1pm'),
('María', 'Lozano', 5, '112B', 'Miércoles a Domingo 11am - 7pm');


INSERT INTO paciente (nombres, apellidos, telefono, correo, fecha_nacimiento) VALUES 
('Carlos', 'Ramos', '3124567890', 'carlos@example.com', '1990-05-20'),
('Ana', 'Torres', '3101234567', 'ana.torres@example.com', '1985-08-12'),
('Luis', 'Fernández', '3117896543', 'luisf@example.com', '1979-03-30'),
('Paola', 'Muñoz', '3135556677', 'paolam@example.com', '2000-11-05'),
('Daniel', 'García', '3140009999', 'danielg@example.com', '1992-01-15');


INSERT INTO cita (id_paciente, id_medico, fecha_cita, hora_cita, estado) VALUES 
(1, 1, '2025-07-18', '10:00:00', 'Programada'),
(2, 2, '2025-07-19', '11:00:00', 'Programada'),
(3, 3, '2025-07-20', '12:30:00', 'Completada'),
(4, 4, '2025-07-21', '09:00:00', 'Cancelada'),
(5, 5, '2025-07-22', '14:00:00', 'Programada'),
(1, 2, '2025-07-23', '15:00:00', 'Programada'),
(2, 1, '2025-07-24', '08:30:00', 'Completada');

-- 1. Ver todas las citas programadas
SELECT c.id_cita, p.nombres AS paciente, m.nombres AS medico, e.nombre AS especialidad,
       c.fecha_cita, c.hora_cita, c.estado
FROM cita c
JOIN paciente p ON c.id_paciente = p.id_paciente
JOIN medico m ON c.id_medico = m.id_medico
JOIN especialidad e ON m.id_especialidad = e.id_especialidad;

-- 2. Ver médicos por especialidad
SELECT m.nombres, m.apellidos, e.nombre AS especialidad
FROM medico m
JOIN especialidad e ON m.id_especialidad = e.id_especialidad;

-- 3. Ver citas por paciente
SELECT c.id_cita, c.fecha_cita, c.hora_cita, c.estado, m.nombres AS medico
FROM cita c
JOIN paciente p ON c.id_paciente = p.id_paciente
JOIN medico m ON c.id_medico = m.id_medico
WHERE p.id_paciente = 1;

-- 4. Contar cuántas citas tiene cada médico
SELECT m.nombres, m.apellidos, COUNT(c.id_cita) AS total_citas
FROM medico m
LEFT JOIN cita c ON m.id_medico = c.id_medico
GROUP BY m.id_medico;

-- 5. Pacientes que no tienen citas
SELECT p.*
FROM paciente p
LEFT JOIN cita c ON p.id_paciente = c.id_paciente
WHERE c.id_cita IS NULL;

-- Vista: Información completa de las citas
CREATE VIEW vista_citas_completas AS
SELECT c.id_cita, p.nombres AS nombre_paciente, m.nombres AS nombre_medico,
       e.nombre AS especialidad, c.fecha_cita, c.hora_cita, c.estado
FROM cita c
JOIN paciente p ON c.id_paciente = p.id_paciente
JOIN medico m ON c.id_medico = m.id_medico
JOIN especialidad e ON m.id_especialidad = e.id_especialidad;

-- Vista: Agenda de un médico (filtro por id_medico = 1)
CREATE VIEW vista_agenda_medico_1 AS
SELECT c.fecha_cita, c.hora_cita, p.nombres AS paciente, c.estado
FROM cita c
JOIN paciente p ON c.id_paciente = p.id_paciente
WHERE c.id_medico = 1;

DELIMITER $$

CREATE PROCEDURE registrar_paciente_y_contar_citas (
    IN p_nombres VARCHAR(50),
    IN p_apellidos VARCHAR(50),
    IN p_telefono VARCHAR(20),
    IN p_correo VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    INOUT p_id_paciente INT,
    OUT total_citas INT
)
BEGIN
    -- Insertar nuevo paciente si no existe (si p_id_paciente = 0)
    IF p_id_paciente = 0 THEN
        INSERT INTO paciente (nombres, apellidos, telefono, correo, fecha_nacimiento)
        VALUES (p_nombres, p_apellidos, p_telefono, p_correo, p_fecha_nacimiento);
        
        SET p_id_paciente = LAST_INSERT_ID();
    END IF;

    -- Contar cuántas citas tiene el paciente
    SELECT COUNT(*) INTO total_citas
    FROM cita
    WHERE id_paciente = p_id_paciente;
END $$

DELIMITER ;

-- Variables para probar
SET @id_paciente = 0;
SET @total = 0;

-- Llamar al procedimiento
CALL registrar_paciente_y_contar_citas(
  'Pedro', 'Lopez', '3129998888', 'pedro@example.com', '1995-02-15',
  @id_paciente,
  @total
);

-- Ver resultados
SELECT @id_paciente AS 'Nuevo ID Paciente', @total AS 'Total Citas';

